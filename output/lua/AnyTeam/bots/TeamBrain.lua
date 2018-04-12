 
Script.Load("lua/bots/BotUtils.lua")
Script.Load("lua/bots/BotDebug.lua")
Script.Load("lua/bots/ManyToOne.lua")

-- gBotDebug is only available on the server.
if gBotDebug then
    gBotDebug:AddBoolean("debugteam")
end

class 'TeamBrain'


local function GetSightedMapBlips(keepFunc, enemyTeamNum)

    local blips = {}

    for _, blip in ientitylist(Shared.GetEntitiesWithClassname("MapBlip")) do

        local ent = Shared.GetEntity( blip:GetOwnerEntityId() )

        local validEnt = ent and ent.GetMapBlipInfo
        local isEnemy = ent.GetTeamNumber and ent:GetTeamNumber() == enemyTeamNum
        -- if it is an enemy, we need it to be sighted, otherwise we keep it
        local valid = validEnt and (not isEnemy or blip:GetIsSighted())
        if valid and (keepFunc == nil or keepFunc(blip)) then
            table.insert( blips, blip )
        end
    end

    return blips

end



local function GetAudibleEnemies(keepFunc, enemyTeamNum)

    local sounds = {}

    for _, sound in ientitylist(Shared.GetEntitiesWithClassname("SoundEffect")) do

        local ent = sound:GetParent()
        local validEnemy = ent and ent.GetMapBlipInfo and ent.GetTeamNumber and ent:GetTeamNumber() == enemyTeamNum
        if validEnemy and (keepFunc == nil or keepFunc(sound)) then
            table.insert( sounds, sound )
        end
    end

    return sounds

end



local function UpdateMemory(mem, ent, fromSound)

    -- this works as long as this is run as part of the server, as we will always have full
    -- information about entities.
    if ent  and ent.GetMapBlipInfo and (fromSound or (ent.GetIsSighted and ent:GetIsSighted())) then
        local success, blipType, blipTeam, isAttacked, isParasited = ent:GetMapBlipInfo()
        mem.btype = blipType
        mem.lastSeenPos = ent:GetOrigin()
        
        local timeSinceLastUpdated = Shared.GetTime() - mem.lastSeenTime
        if ent:isa("Player") and timeSinceLastUpdated > 2 then
            DebugPrint("Updated %s %s", ent, fromSound and " from sound" or " from sight")
        end
    end
    
    if not fromSound then
        mem.lastSightedTime = Shared.GetTime()
    end

    -- otherwise, do not update it - keep the last known position/type
    mem.lastSeenTime = Shared.GetTime()

end


local function CreateMemory(ent)

    local success, blipType, blipTeam, isAttacked, isParasited = ent:GetMapBlipInfo()
    local mem =
    {
        entId = ent:GetId(),
        btype = blipType,
        lastSeenPos = ent:GetOrigin(),
        lastSeenTime = Shared.GetTime(),
        lastSightedTime = 0
    }
    return mem

end


local function MemoryToString(mem)

    local s = ""
    local ent = Shared.GetEntity(mem.entId)
    if ent ~= nil then
        s = s .. string.format("%d-%s", mem.entId, ent:GetClassName())
    else
        s = s .. "<NIL>"
    end
    
    return s
    
end

function TeamBrain:Initialize(label, teamNumber)

    -- table of entity ID to remembered blips
    -- remembered blips
    self.entId2memory = {}
    self.entMemories = {}

    self.lastUpdate = 0

    self.debug = false
    self.label = label
    self.teamNumber = teamNumber

    self.assignments = ManyToOne()
    self.assignments:Initialize()

end

function TeamBrain:Reset()
    self.entId2memory = {}
    self.entMemories = {}
    self.lastUpdate = 0
    self.assignments:Reset()
end

function TeamBrain:GetMemories()
    if self.lastUpdate < Shared.GetTime() then
        self:Update()
    end

    return self.entMemories
end

function TeamBrain:OnEntityChange(oldId)

    -- make sure we clear the memory
    -- do not worry about the new ID, since it should get added via the normal blip code path

    if self.entId2memory[oldId] then

        self.assignments:RemoveGroup(oldId)
        for i = 1, #self.entMemories do
            if self.entMemories[i].entId == oldId then
                table.remove(self.entMemories, i)
                break
            end
        end
        self.entId2memory[oldId] = nil

    end

end

function TeamBrain:DebugDraw()

    -- TEMP
    if self.teamNumber ~= kMarineTeamType then
        return
    end

    for _,mem in ipairs(self.entMemories) do

        local lostTime = Shared.GetTime() - mem.lastSeenTime
        local ent = Shared.GetEntity(mem.entId)
        assert( ent ~= nil )

        Shared.DebugColor(0,1,1,1)
        Shared.DebugText( string.format("-- %s %0.2f (%d)",
                    ent:GetClassName(), lostTime,
                    self.assignments:GetNumAssignedTo(mem.entId)),
                mem.lastSeenPos, 0.0 )

        for _, playerId in ipairs(self.assignments:GetItems(mem.entId)) do
            local player = Shared.GetEntity(playerId)
            if player ~= nil then
                local playerPos = player:GetOrigin()
                local ofs = Vector(0,1,0)
                DebugLine( mem.lastSeenPos+ofs, playerPos+ofs, 0.0,
                        0.5,0.5,0.5,1,   true )
            end
        end

    end

end


function TeamBrain:UpdateMemoryOfEntity( ent, fromSound)
    PROFILE("TeamBrain:UpdateMemoryOfEntity")

    local entId = ent:GetId()
    local mem = self.entId2memory[ entId ]
    if not mem then
        mem = CreateMemory(ent)
        self.entMemories[ #self.entMemories + 1 ] = mem
        self.entId2memory[ entId ] = mem
        if ent:isa("Player") and gBotDebug:Get("spam") then
            Log("Brain %d detected %s from %s", self.teamNumber, ent, fromSound and "sound" or "sight")
        end
    end
    UpdateMemory( mem, ent, fromSound )
end

function TeamBrain:GetIsSoundAudible(sound)
    
    -- find all our players inside a 20m range
    -- we only do this call for sounds that belong to enemy players that are actually playing, so this
    -- should not be horribly expensive.
    
    -- here we simulate how "loud" a sound is
    local soundName = sound:GetSoundName()
    local dist = 20
    if string.match(soundName, "draw") then
        dist = 5
    elseif string.match(soundName, "deploy") then
        dist = 5
    elseif string.match(soundName, "land") then
        dist = 10
    elseif string.match(soundName, "jump") then
        dist = 10
    elseif string.match(soundName, "idle") then
        dist = 3
    end
    
    for _, friend in ipairs( GetEntitiesForTeamWithinRange("Player", self.teamNumber, sound:GetWorldOrigin(), dist) ) do
        if friend:GetIsAlive() then
            return true
        end
    
    end

    return false
end

function TeamBrain:Update()
    PROFILE("TeamBrain:Update")

    if gBotDebug:Get("spam") then
        Log("TeamBrain:Update")
    end

    local currBlips = GetSightedMapBlips(nil, GetEnemyTeamNumber(self.teamNumber))

    -- update our entId2memory, keyed by blip ent IDs
    for _, blip in ipairs(currBlips) do

        local entId = blip:GetOwnerEntityId()
        local ent = Shared.GetEntity(entId)
        if ent then
            self:UpdateMemoryOfEntity(ent)            
        end

    end

    
    -- find all resource towers within range of a player
    for _, enemyResourceTower in ipairs( GetEntitiesForTeam("ResourceTower", GetEnemyTeamNumber(self.teamNumber)) ) do
        if #GetEntitiesForTeamWithinRange("Player", self.teamNumber, enemyResourceTower:GetOrigin(), 30) > 0 then
            self:UpdateMemoryOfEntity(enemyResourceTower)    
        end
    end
    -- find all command structures within range of a player
    for _, enemyCommandStructure in ipairs( GetEntitiesForTeam("CommandStructure", GetEnemyTeamNumber(self.teamNumber)) ) do
        if #GetEntitiesForTeamWithinRange("Player", self.teamNumber, enemyCommandStructure:GetOrigin(), 30) > 0 then
            self:UpdateMemoryOfEntity(enemyCommandStructure)    
        end
    end
    
    -- find all things that recently dealt damage to this team
    local time = Shared.GetTime()
    for _, player in ipairs( GetEntitiesForTeam("Player", self.teamNumber) ) do
        if player:GetTimeOfLastDamage() and 
            player:GetTimeOfLastDamage() + 1 > time then
            local entity = Shared.GetEntity(player:GetAttackerIdOfLastDamage())
            if entity and entity.GetIsAlive and entity:GetIsAlive() and entity.GetMapBlipInfo then
                self:UpdateMemoryOfEntity(entity)
            end
        end
    end
    
    -- treat hearing an enemy the same as seeing it; a little odd but works fine
    local enemySounds = GetAudibleEnemies(
        function (sound)
            if sound:GetIsPlaying() then
                return self:GetIsSoundAudible(sound)
            end
            return false
        end,
        GetEnemyTeamNumber(self.teamNumber))
    
    for _, sound in ipairs(enemySounds) do
        self:UpdateMemoryOfEntity(sound:GetParent(), true)      
    end

    ------------------------------------------
    --  Remove memories that have been investigated (ie. a marine went to the last known pos),
    --  but it has been a while since we last saw it
    ------------------------------------------
    local entMemories = self.entMemories
    for i, mem in ipairs(entMemories) do

        local memEntId = mem.entId
        local ent = Shared.GetEntity(memEntId)
        local removeIt = true
        
        -- never forget hives and CCs
        if ent and ent:isa("CommandStructure") then
            removeIt = false
        end
        if ent and removeIt then
            local memAge = Shared.GetTime() - mem.lastSeenTime
            
            -- we time out very old player memories because they are
            -- not very likely to be around that long
            local veryOldPlayerMemory = ent:isa("Player") and memAge > 10
            if not veryOldPlayerMemory then
                
                removeIt = false                
                if memAge > 5.0 then

                    for _,playerId in ipairs(self.assignments:GetItems(mem.entId)) do
                        
                        local player = Shared.GetEntity(playerId)
                        if player then 
                            
                            local playerPos = player:GetOrigin()
                            local didInvestigate = mem.lastSeenPos:GetDistance(playerPos) < 4.0
                            if didInvestigate then
                                removeIt = true
                                break
                            end
                        end    
                    end
                end
            end
        end

        if removeIt then
            if gBotDebug:Get("spam") then
                Log("... remove memory of %s", memEntId)
            end

            self.assignments:RemoveGroup(memEntId)
            self.entId2memory[memEntId] = nil
            table.remove(self.entMemories, i)
        end

    end

    --DebugPrint("%s mem has %d blips", self.label, GetTableSize(self.entId2memory) )

    if gBotDebug:Get("debugall") or gBotDebug:Get("debugteam") then
        self:DebugDraw()
    end

    self.lastUpdate = Shared.GetTime()

end

------------------------------------------
--  Events from bots
------------------------------------------

------------------------------------------
--  Bots should call this when they assign themselves to a memory, e.g. a bot deciding to attack a hive.
--  Used for load-balancing purposes.
------------------------------------------
function TeamBrain:AssignBotToMemory( bot, mem )

    local player = bot:GetPlayer()
    assert(player ~= nil)
    assert(mem ~= nil)
    local playerId = player:GetId()

    self.assignments:Assign( playerId, mem.entId )

end

function TeamBrain:AssignBotToEntity( bot, entId )

    local mem = self.entId2memory[entId]
    if mem then
        self:AssignBotToMemory( bot, mem )
    end

end

function TeamBrain:UnassignBot( bot )

    local player = bot:GetPlayer()
    assert(player ~= nil)
    local playerId = player:GetId()

    self.assignments:Unassign(playerId)

end

function TeamBrain:GetIsBotAssignedTo( bot, mem )

    local player = bot:GetPlayer()
    assert(player ~= nil)
    local playerId = player:GetId()

    return self.assignments:GetIsAssignedTo(playerId, mem.entId)

end

function TeamBrain:GetNumAssignedTo( mem, countsFunc )

    return self.assignments:GetNumAssignedTo( mem.entId, countsFunc )

end

function TeamBrain:GetNumAssignedToEntity( entId, countsFunc )

    if not self.entId2memory[entId] then return end
    return self.assignments:GetNumAssignedTo( entId, countsFunc )

end

function TeamBrain:GetNumOthersAssignedToEntity( entId, exceptBot )

    return self:GetNumAssignedToEntity( entId, function(otherId)
            return otherId ~= exceptBot:GetPlayer():GetId()
            end)

end

function TeamBrain:DebugDump()

    function Group2String(memEntId)
        local mem = self.entId2memory[memEntId]
        return MemoryToString(mem)
    end

    function Item2String(playerId)
        local player = Shared.GetEntity(playerId)
        assert( player ~= nil )
        return player:GetName()
    end

    self.assignments:DebugDump( Item2String, Group2String )

end
