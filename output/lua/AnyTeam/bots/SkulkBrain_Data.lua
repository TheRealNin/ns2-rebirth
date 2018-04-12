
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kUpgrades = {
    kTechId.Crush,
    kTechId.Carapace,
    kTechId.Regeneration,
        
    kTechId.Vampirism,
    kTechId.Aura,
    kTechId.Focus,
    
    kTechId.Silence,
    kTechId.Celerity,
    kTechId.Adrenaline,
}

local kEvolutions = {
-- gorge is bugged as hell
    kTechId.Lerk,
    kTechId.Fade,
    kTechId.Onos
}




------------------------------------------
--  Handles things like using tunnels, walljumping, leaping etc
------------------------------------------
local function PerformMove( alienPos, targetPos, bot, brain, move )

    bot:GetMotion():SetDesiredMoveTarget( targetPos )
    bot:GetMotion():SetDesiredViewTarget( nil )
    
    local player = bot:GetPlayer()
    local isSneaking = player.movementModiferState
    
    local disiredDiff = (targetPos-alienPos)
    if not isSneaking and disiredDiff:GetLengthSquared() > 25 and
        player:GetVelocity():GetLengthXZ() / player:GetMaxSpeed() > 0.9 and
        Math.DotProduct(player:GetVelocity():GetUnit(), disiredDiff:GetUnit()) > 0.6 then
        if player.timeOfLastJump == nil or player.timeOfLastJump + .25 > Shared.GetTime() then
            move.commands = AddMoveCommand( move.commands, Move.Crouch )
        else
            move.commands = AddMoveCommand( move.commands, Move.Jump )
        end
        
    end
    if not isSneaking and disiredDiff:GetLengthSquared() > 9 and
        Math.DotProduct(player:GetVelocity():GetUnit(), disiredDiff:GetUnit()) > 0.6 then
    
        -- leap, maybe?
        if player:GetEnergy() > 85 then
            move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
        end
    end
    
    --[[
    local dist, gate = GetTunnelDistanceForAlien( bot:GetPlayer(), targetPos, brain.lastGateId )

    if gate ~= nil then

        local gatePos = gate:GetOrigin()
        bot:GetMotion():SetDesiredMoveTarget( gatePos )
        bot:GetMotion():SetDesiredViewTarget( nil )
        brain.lastGateId = gate:GetId()

    else

        bot:GetMotion():SetDesiredMoveTarget( targetPos )
        bot:GetMotion():SetDesiredViewTarget( nil )
        brain.lastGateId = nil
        
        -- do a jump... we're probably stuck
        if dist < 1.5 and math.abs(marinePos.y - targetPos.y) > 1.0 then
            move.commands = AddMoveCommand(move.commands, Move.Jump)
        end

    end
    ]]--
end

------------------------------------------
--  More urgent == should really attack it ASAP
------------------------------------------
local function GetAttackUrgency(bot, mem)

    -- See if we know whether if it is alive or not
    local ent = Shared.GetEntity(mem.entId)
    if not HasMixin(ent, "Live") or not ent:GetIsAlive() or (ent.GetTeamNumber and ent:GetTeamNumber() == bot:GetTeamNumber()) then
        return 0.0
    end
    
    local botPos = bot:GetPlayer():GetOrigin()
    local targetPos = ent:GetOrigin()
    local distance = botPos:GetDistance(targetPos)

    if mem.btype == kMinimapBlipType.PowerPoint then
        local powerPoint = ent
        if powerPoint ~= nil and powerPoint:GetIsSocketed() then
            return 0.55
        else
            return 0
        end    
    end
        
    local immediateThreats = {
        [kMinimapBlipType.Marine] = true,
        [kMinimapBlipType.JetpackMarine] = true,
        [kMinimapBlipType.Exo] = true,    
        [kMinimapBlipType.Sentry] = true,
        [kMinimapBlipType.Embryo] = true,
        [kMinimapBlipType.Hydra]  = true,
        [kMinimapBlipType.Whip]   = true,
        [kMinimapBlipType.Skulk]  = true,
        [kMinimapBlipType.Gorge]  = true,
        [kMinimapBlipType.Lerk]   = true,
        [kMinimapBlipType.Fade]   = true,
        [kMinimapBlipType.Onos]   = true,
    }
    if table.contains(kMinimapBlipType, "Prowler") then
        immediateThreats[kMinimapBlipType.Prowler] = true
    end
    
    if distance < 15 and immediateThreats[mem.btype] then
        -- Attack the nearest immediate threat (urgency will be 1.1 - 2)
        return 1 + 1 / math.max(distance, 1)
    end
    
    -- No immediate threat - load balance!
    local numOthers = bot.brain.teamBrain:GetNumAssignedTo( mem,
            function(otherId)
                if otherId ~= bot:GetPlayer():GetId() then
                    return true
                end
                return false
            end)

    --Other urgencies do not rank anything here higher than 1!
    local urgencies = {
        [kMinimapBlipType.ARC] =                numOthers >= 2 and 0.4 or 0.9,
        [kMinimapBlipType.CommandStation] =     numOthers >= 4 and 0.3 or 0.75,
        [kMinimapBlipType.PhaseGate] =          numOthers >= 2 and 0.2 or 0.9,
        [kMinimapBlipType.Observatory] =        numOthers >= 2 and 0.2 or 0.8,
        [kMinimapBlipType.Extractor] =          numOthers >= 2 and 0.2 or 0.7,
        [kMinimapBlipType.InfantryPortal] =     numOthers >= 2 and 0.2 or 0.6,
        [kMinimapBlipType.PrototypeLab] =       numOthers >= 1 and 0.2 or 0.55,
        [kMinimapBlipType.Armory] =             numOthers >= 2 and 0.2 or 0.5,
        [kMinimapBlipType.RoboticsFactory] =    numOthers >= 2 and 0.2 or 0.5,
        [kMinimapBlipType.ArmsLab] =            numOthers >= 3 and 0.2 or 0.6,
        [kMinimapBlipType.MAC] =                numOthers >= 1 and 0.2 or 0.4,
        -- from marine
        
        [kMinimapBlipType.Crag] = numOthers >= 2           and 0.2 or 0.95, -- kind of a special case
        [kMinimapBlipType.Hive] = numOthers >= 6           and 0.5 or 0.9,
        [kMinimapBlipType.Harvester] = numOthers >= 2      and 0.4 or 0.8,
        [kMinimapBlipType.Egg] = numOthers >= 1            and 0.2 or 0.5,
        [kMinimapBlipType.Shade] = numOthers >= 2          and 0.2 or 0.5,
        [kMinimapBlipType.Shift] = numOthers >= 2          and 0.2 or 0.5,
        [kMinimapBlipType.Shell] = numOthers >= 2          and 0.2 or 0.5,
        [kMinimapBlipType.Veil] = numOthers >= 2           and 0.2 or 0.5,
        [kMinimapBlipType.Spur] = numOthers >= 2           and 0.2 or 0.5,
        [kMinimapBlipType.TunnelEntrance] = numOthers >= 1 and 0.2 or 0.5,
    }

    if urgencies[ mem.btype ] ~= nil then
        return urgencies[ mem.btype ]
    end

    return 0.0
    
end


local function PerformAttackEntity( eyePos, bestTarget, lastSeenPos, bot, brain, move )

    assert( bestTarget )
    local player = bot:GetPlayer()

    local sighted 
    if not bestTarget.GetIsSighted then
        -- Print("attack target has no GetIsSighted: %s", bestTarget:GetClassName() )
        sighted = true
    else
        sighted = bestTarget:GetIsSighted()
    end
    
    local aimPos = sighted and GetBestAimPoint( bestTarget ) or (lastSeenPos + Vector(0,0.5,0))
    local doFire = false
    
    local distance = GetDistanceToTouch(eyePos, bestTarget)
    local time = Shared.GetTime()
    
    local targetPos = bestTarget:GetEngagementPoint()
    local isDodgeable = bestTarget:isa("Player") or bestTarget:isa("Babbler")
    local hasClearShot = distance < 45.0 and bot:GetBotCanSeeTarget( bestTarget )
    if hasClearShot then
        bot.lastFoughtEnemy = time
    end    
    
    if distance < 2.0 then
        doFire = true
    end
    
    PerformMove(eyePos, aimPos, bot, brain, move)
                
    if doFire then
        
        player:SetActiveWeapon(BiteLeap.kMapName)    
        move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        if isDodgeable then
             -- Attacking a player or babbler
            --local viewTarget = aimPos + Vector( math.random(), math.random(), math.random() ) * 0.3
            
            if bot.aim then
                bot.aim:UpdateAim(target, aimPos)
            end
            
        else
            -- Attacking a structure
            if distance < 1 then
                -- Stop running at the structure when close enough
                bot:GetMotion():SetDesiredMoveTarget(nil)
                bot:GetMotion():SetDesiredViewTarget( aimPos )
            end
        end
    else
        if hasClearShot and bot.aim then
            bot.aim:UpdateAim(target, aimPos)
            if not bot.lastSeenEnemy then
                bot.lastSeenEnemy = Shared.GetTime()
            end
            if player:GetEnergy() > 60 and bot.lastSeenEnemy + 1 < Shared.GetTime() then
                player:SetActiveWeapon(Parasite.kMapName, true)
                move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
            end
        else
            bot.lastSeenEnemy = nil
            local isNotDetected =  not (player:GetIsDetected() or player:GetIsSighted())
            if isNotDetected and bot.sneakyAbility and distance < 20.0 and distance > 4.0 and isDodgeable and
                (not bot.lastFoughtEnemy or bot.lastFoughtEnemy + 10 < time) and not sighted then
                
                move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
            end
            -- uses a gate
            PerformMove( eyePos, aimPos, bot, brain, move )

            doFire = false
        end
    end
    --[[
    if bot.timeOfJump ~= nil and Shared.GetTime() - bot.timeOfJump < 0.5 then
        
        if bot.jumpOffset == nil then
            
            local botToTarget = GetNormalizedVectorXZ(marinePos - eyePos)
            local sideVector = botToTarget:CrossProduct(Vector(0, 1, 0))                
            if math.random() < 0.5 then
                bot.jumpOffset = botToTarget + sideVector
            else
                bot.jumpOffset = botToTarget - sideVector
            end            
            bot:GetMotion():SetDesiredViewTarget( bestTarget:GetEngagementPoint() )
            
        end
        
        bot:GetMotion():SetDesiredMoveDirection( bot.jumpOffset )
    end    
    ]]--
    
end

local function PerformAttack( eyePos, mem, bot, brain, move )

    assert( mem )

    local target = Shared.GetEntity(mem.entId)

    if target ~= nil then

        PerformAttackEntity( eyePos, target, mem.lastSeenPos, bot, brain, move )

    else
        assert(false)
    end
    
    brain.teamBrain:AssignBotToMemory(bot, mem)

end

------------------------------------------
--  Each want function should return the fuzzy weight,
-- along with a closure to perform the action
-- The order they are listed matters - actions near the beginning of the list get priority.
------------------------------------------
kSkulkBrainActions =
{
    
    ------------------------------------------
    --  
    ------------------------------------------
    function(bot, brain)
        return { name = "debug idle", weight = 0.001,
                perform = function(move)
                    bot:GetMotion():SetDesiredMoveTarget(nil)
                    -- there is nothing obvious to do.. figure something out
                    -- like go to the marines, or defend 
                end }
    end,

    ------------------------------------------
    --  
    ------------------------------------------
    CreateExploreAction( 0.01, function(pos, targetPos, bot, brain, move)
            PerformMove(pos, targetPos, bot, brain, move)
    end ),
    
    ------------------------------------------
    --  Tries to evolve (if not a hallucination)
    ------------------------------------------
    function(bot, brain)
        local name = "evolve"

        local weight = 0.0
        local player = bot:GetPlayer()

        -- Hallucinations don't evolve
        if player.isHallucination then
            return { name = name, weight = weight,
                perform = function() end }
        end

        if not bot.lifeformEvolution then
            local pick = math.random(1, #kEvolutions)
            bot.lifeformEvolution = kEvolutions[pick]
        end

        local allowedToBuy = player:GetIsAllowedToBuy()

        local s = brain:GetSenses()
        local res = player:GetPersonalResources()
        
        local distanceToNearestThreat = s:Get("nearestThreat").distance
        local distanceToNearestHive = s:Get("nearestHive").distance
        local desiredUpgrades = {}
        
        if allowedToBuy and
           (distanceToNearestThreat == nil or distanceToNearestThreat > 15) and 
           (distanceToNearestHive == nil or distanceToNearestHive < 25) and 
           (player.GetIsInCombat == nil or not player:GetIsInCombat()) then
            
            -- Safe enough to try to evolve            
            
            local existingUpgrades = player:GetUpgrades()

            local avaibleUpgrades = player.lifeformUpgrades

            if not avaibleUpgrades then
                avaibleUpgrades = {}


                if bot.lifeformEvolution then
                    table.insert(avaibleUpgrades, bot.lifeformEvolution)
                end

                for i = 0, 2 do
                    table.insert(avaibleUpgrades, kUpgrades[math.random(1,3) + i * 3])
                end

                
                player.lifeformUpgrades = avaibleUpgrades
            end

            local evolvingId = kTechId.Skulk

            -- Check lifeform
            local techId = avaibleUpgrades[1]
            local techNode = player:GetTechTree():GetTechNode(techId)
            local isAvailable = techNode and techNode:GetAvailable(player, techId, false)
            local cost = isAvailable and GetCostForTech(techId) or math.huge

            if res >= cost then
                res = res - cost
                evolvingId = techId
                existingUpgrades = {}

                table.insert(desiredUpgrades, techId)
            end

            -- Check upgrades
            for i = 2, #avaibleUpgrades do
                local techId = avaibleUpgrades[i]
                local techNode = player:GetTechTree():GetTechNode(techId)
                local isAvailable = techNode and techNode:GetAvailable(player, techId, false)
                local cost = isAvailable and LookupTechData(evolvingId, kTechDataUpgradeCost, 0) or math.huge
                
                if res >= cost and not table.icontains(existingUpgrades, techId) and
                        GetIsUpgradeAllowed(player, techId, existingUpgrades) and
                        GetIsUpgradeAllowed(player, techId, desiredUpgrades) then
                    res = res - cost
                    table.insert(desiredUpgrades, techId)
                end
            end
            
            if #desiredUpgrades > 0 then
                weight = 100.0
            end                                
        end
        
        return { name = name, weight = weight,
            perform = function(move)
                player:ProcessBuyAction( desiredUpgrades )
            end }
    
    end,
    
    --[[
    -- Save hives under attack
     ]]
    function(bot, brain)
        local skulk = bot:GetPlayer()
        local teamNumber = skulk:GetTeamNumber()

        bot.hiveprotector = bot.hiveprotector or math.random()

        local name = "hiveunderattack"
        if bot.hiveprotector < 0.8 then
            return { name = name, weight = 0,
                perform = function() end }
        end

        local hiveUnderAttack
        for _, hive in ipairs(GetEntitiesForTeam("Hive", teamNumber)) do
            if hive:GetIsAlive() and hive:GetHealthScalar() <= 0.9 and 
                hive:GetTimeOfLastDamage() and hive:GetTimeOfLastDamage() + 10 > Shared.GetTime() then
                hiveUnderAttack = hive
                break
            end
        end

        local hiveOrigin = hiveUnderAttack and hiveUnderAttack:GetOrigin()
        local botOrigin = skulk:GetOrigin()

        if hiveUnderAttack and botOrigin:GetDistanceSquared( hiveOrigin ) < 50 then
            hiveUnderAttack = nil
        end

        local weight = hiveUnderAttack and 1.5 or 0

        return { name = name, weight = weight,
            perform = function(move)
                PerformMove(botOrigin, hiveOrigin, bot, brain, move)
            end }

    end,


    ------------------------------------------
    --  
    ------------------------------------------
    function(bot, brain)
        local name = "attack"
        local skulk = bot:GetPlayer()
        local eyePos = skulk:GetEyePos()
        
        local memories = GetTeamMemories(skulk:GetTeamNumber())
        local bestUrgency, bestMem = GetMaxTableEntry( memories, 
                function( mem )
                    return GetAttackUrgency( bot, mem )
                end)
        
        local weapon = skulk:GetActiveWeapon()
        local canAttack = weapon ~= nil and (weapon:isa("BiteLeap") or weapon:isa("Parasite"))

        local weight = 0.0

        if canAttack and bestMem ~= nil then

            local dist = 0.0
            if Shared.GetEntity(bestMem.entId) ~= nil then
                dist = GetDistanceToTouch( eyePos, Shared.GetEntity(bestMem.entId) )
            else
                dist = eyePos:GetDistance( bestMem.lastSeenPos )
            end

            weight = EvalLPF( dist, {
                    { 0.0, EvalLPF( bestUrgency, {
                        { 0.0, 0.0 },
                        { 10.0, 25.0 }
                        })},
                    { 10.0, EvalLPF( bestUrgency, {
                            { 0.0, 0.0 },
                            { 10.0, 5.0 }
                            })},
                    { 100.0, 0.0 } })
        end

        return { name = name, weight = weight,
            perform = function(move)
                PerformAttack( eyePos, bestMem, bot, brain, move )
            end }
    end,    

    ------------------------------------------
    --  
    ------------------------------------------
    function(bot, brain)
        local name = "pheromone"
        
        local skulk = bot:GetPlayer()
        local eyePos = skulk:GetEyePos()

        local pheromones = GetEntitiesForTeam( "Pheromone", skulk:GetTeamNumber())
        local bestPheromoneLocation = nil
        local bestValue = 0
        
        for p = 1, #pheromones do
        
            local currentPheromone = pheromones[p]
            if currentPheromone then
                local techId = currentPheromone:GetType()
                            
                if techId == kTechId.ExpandingMarker or techId == kTechId.ThreatMarker then
                
                    local location = currentPheromone:GetOrigin()
                    local locationOnMesh = Pathing.GetClosestPoint(location)
                    local distanceFromMesh = location:GetDistance(locationOnMesh)
                    
                    if distanceFromMesh > 0.001 and distanceFromMesh < 2 then
                    
                        local distance = eyePos:GetDistance(location)
                        
                        if currentPheromone.visitedBy == nil then
                            currentPheromone.visitedBy = {}
                        end
                                        
                        if not currentPheromone.visitedBy[bot] then
                        
                            if distance < 5 then 
                                currentPheromone.visitedBy[bot] = true
                            else   
            
                                -- Value goes from 5 to 10
                                local value = 5.0 + 5.0 / math.max(distance, 1.0) - #(currentPheromone.visitedBy)
                        
                                if value > bestValue then
                                    bestPheromoneLocation = locationOnMesh
                                    bestValue = value
                                end
                                
                            end    
                            
                        end    
                            
                    end
                    
                end
                        
            end
            
        end
        
        local weight = EvalLPF( bestValue, {
            { 0.0, 0.0 },
            { 10.0, 1.0 }
            })

        return { name = name, weight = weight,
            perform = function(move)
                PerformMove(pos, bestPheromoneLocation, bot, brain, move)
            end }
    end,

    ------------------------------------------
    --  
    ------------------------------------------
    function(bot, brain)
        local name = "order"

        local skulk = bot:GetPlayer()
        local order = bot:GetPlayerOrder()

        local weight = 0.0
        if order ~= nil then
            weight = 3.0
        end

        return { name = name, weight = weight,
            perform = function(move)
                if order then

                    local target = Shared.GetEntity(order:GetParam())

                    if target ~= nil and order:GetType() == kTechId.Attack then

                        PerformAttackEntity( skulk:GetEyePos(), target, order:GetLocation(), bot, brain, move )
                        
                    else

                        if brain.debug then
                            DebugPrint("unknown order type: %s", ToString(order:GetType()) )
                        end

                        PerformMove(pos, order:GetLocation(), bot, brain, move)

                    end
                end
            end }
    end,    

}

------------------------------------------
--  
------------------------------------------
function CreateSkulkBrainSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("allThreats", function(db)
            local player = db.bot:GetPlayer()
            local team = player:GetTeamNumber()
            local memories = GetTeamMemories( team )
            return FilterTableEntries( memories,
                function( mem )                    
                    local ent = Shared.GetEntity( mem.entId )
                    
                    if ent:isa("Player") or ent:isa("Sentry") then
                        local isAlive = HasMixin(ent, "Live") and ent:GetIsAlive()
                        local isEnemy = HasMixin(ent, "Team") and ent:GetTeamNumber() ~= team                    
                        return isAlive and isEnemy
                    else
                        return false
                    end
                end)                
        end)

    s:Add("nearestHive", function(db)

            local skulk = db.bot:GetPlayer()
            local skulkPos = skulk:GetOrigin()
            local hives = GetEntitiesForTeam( "Hive", skulk:GetTeamNumber() )

            local dist, hive = GetMinTableEntry( hives,
                function(hive)
                    if hive:GetIsBuilt() then
                        return skulkPos:GetDistance( hive:GetOrigin() )
                    end
                end)

            return {entity = hive, distance = dist}
            end)
            
    s:Add("nearestThreat", function(db)
            local allThreats = db:Get("allThreats")
            local player = db.bot:GetPlayer()
            local playerPos = player:GetOrigin()
           
            local distance, nearestThreat = GetMinTableEntry( allThreats,
                function( mem )
                    local origin = mem.origin
                    if origin == nil then
                        origin = Shared.GetEntity(mem.entId):GetOrigin()
                    end
                    return playerPos:GetDistance(origin)
                end)

            return {distance = distance, memory = nearestThreat}
        end)

    return s
end
