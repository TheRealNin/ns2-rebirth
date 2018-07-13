
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")




local function PerformMove( alienPos, targetPos, bot, brain, move )

    bot:GetMotion():SetDesiredMoveTarget( targetPos )
    bot:GetMotion():SetDesiredViewTarget( nil )
    
    local player = bot:GetPlayer()
    -- normal fade
    local disiredDiff = (targetPos-alienPos)
    
    -- wraith fade
    if kFadeTeleportEnergyCost then
        if bot:GetPlayer():GetEnergy() > kFadeTeleportEnergyCost * 3 and disiredDiff:GetLengthSquared() > 25 and not player:GetIsBlinking() and
           Math.DotProduct(player:GetVelocity():GetUnit(), disiredDiff:GetUnit()) > 0.2 then
           
            if not bot.timeOfBlink or bot.timeOfBlink + 0.7 < Shared.GetTime() then
                
                -- this is expensive!!!
                local trace = Shared.TraceRay(alienPos, alienPos + player:GetCoords().zAxis * 3, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOneAndIsa(self, "Babbler"))
                
                if trace.fraction >= 1 or (trace.entity and GetAreEnemies(self, trace.entity)) then
                    bot.timeOfBlink = Shared.GetTime()
                    move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
                end
            end
        end
    else
        if disiredDiff:GetLengthSquared() > 16 and not player:GetIsBlinking()  then
            if player:GetVelocity():GetLength() / player:GetMaxSpeed() < 0.8 or player:GetIsOnGround() and
                Math.DotProduct(player:GetVelocity():GetUnit(), disiredDiff:GetUnit()) > 0.2 then
                if bot.timeOfJump == nil or bot.timeOfJump + .4 < Shared.GetTime() then
                
                    move.commands = AddMoveCommand( move.commands, Move.Jump )
                    if bot:GetPlayer():GetEnergy() > 50 then
                        move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
                    end
                    bot.timeOfJump = Shared.GetTime()
                end
            end
        end
        if bot:GetPlayer():GetIsOnGround() and player:GetVelocity():GetLength() / player:GetMaxSpeed() > 1.2 then
            move.commands = AddMoveCommand( move.commands, Move.Jump ) -- gotta stay off the ground!!
        end 
        
        if bot:GetPlayer():GetEnergy() < 30 or (bot.timeOfMeta or 0) < Shared.GetTime() then
            move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
            bot.timeOfMeta = Shared.GetTime() + kMetabolizeDelay * 2
        end
    end
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
        [kMinimapBlipType.Onos]   = true
    }
    if table.contains(kMinimapBlipType, "Prowler") then
        immediateThreats[kMinimapBlipType.Prowler] = 1
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
        [kMinimapBlipType.Marine] =             numOthers >= 2 and 0.6 or 1,
        [kMinimapBlipType.JetpackMarine] =      numOthers >= 2 and 0.7 or 1.1,
        [kMinimapBlipType.Exo] =                numOthers >= 2 and 0.8 or 1.2,

        [kMinimapBlipType.ARC] =                numOthers >= 1 and 0.4 or 0.9,
        [kMinimapBlipType.CommandStation] =     numOthers >= 2 and 0.3 or 0.75,
        [kMinimapBlipType.PhaseGate] =          numOthers >= 1 and 0.2 or 0.9,
        [kMinimapBlipType.Observatory] =        numOthers >= 1 and 0.2 or 0.8,
        [kMinimapBlipType.Extractor] =          numOthers >= 1 and 0.2 or 0.7,
        [kMinimapBlipType.InfantryPortal] =     numOthers >= 1 and 0.2 or 0.6,
        
        -- from marine
        [kMinimapBlipType.Embryo] = numOthers >= 1 and 0.1 or 1.0,
        [kMinimapBlipType.Hydra] = numOthers >= 2  and 0.1 or 2.0,
        [kMinimapBlipType.Whip] = numOthers >= 2   and 0.1 or 3.0,
        [kMinimapBlipType.Skulk] = numOthers >= 2  and 0.1 or 4.0,
        [kMinimapBlipType.Gorge] =  numOthers >= 2  and 0.1 or 3.0,
        [kMinimapBlipType.Lerk] = numOthers >= 2   and 0.1 or 5.0,
        [kMinimapBlipType.Fade] = numOthers >= 3   and 0.1 or 6.0,
        [kMinimapBlipType.Onos] =  numOthers >= 4  and 0.1 or 7.0,
        
        [kMinimapBlipType.Crag] = numOthers >= 1 and 0.2 or 0.7, -- kind of a special case
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
    if table.contains(kMinimapBlipType, "Prowler") then
        urgencies[kMinimapBlipType.Prowler] = numOthers >= 2 and 0.1 or 4.0
    end

    if urgencies[ mem.btype ] ~= nil then
        return urgencies[ mem.btype ]
    end

    return 0.0

end


local function PerformAttackEntity( eyePos, bestTarget, bot, brain, move )

    assert( bestTarget )

    local marinePos = GetBestAimPoint( bestTarget )
    local player = bot:GetPlayer()

    local doFire = false
    local isDodgeable = bestTarget:isa("Player") or bestTarget:isa("Babbler")
    PerformMove(eyePos, marinePos, bot, brain, move)
    
    local distance = eyePos:GetDistance(marinePos)
    if distance < 2.5 then
        doFire = true
    end
    local hasClearShot = distance < 45.0 and bot:GetBotCanSeeTarget( bestTarget )
                
    if doFire then
        -- jitter view target a little bit
        local jitter = Vector( math.random(), math.random(), math.random() ) * 0.1
        bot:GetMotion():SetDesiredViewTarget( bestTarget:GetEngagementPoint() + jitter )
        move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        
        if isDodgeable then
            -- Attacking a player
            if bot:GetPlayer():GetIsOnGround() and bestTarget:isa("Player") then
                move.commands = AddMoveCommand( move.commands, Move.Jump )
                -- wraith fade
                if not kFadeTeleportEnergyCost then
                    move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
                end
            end
        else
            -- Attacking a structure
            if GetDistanceToTouch(eyePos, bestTarget) < 1 then
                -- Stop running at the structure when close enough
                bot:GetMotion():SetDesiredMoveTarget(nil)
                move.commands = RemoveMoveCommand( move.commands, Move.Jump )
                move.commands = RemoveMoveCommand( move.commands, Move.SecondaryAttack )
            end
        end

    
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
    end
    
    if hasClearShot and distance > 4.0 and kFadeTeleportEnergyCost and bot:GetPlayer():GetEnergy() > kFadeTeleportEnergyCost
        and IsPointInCone(marinePos, player:GetEyePos(), player:GetCoords().zAxis, math.rad(15)) and math.random() < 0.5 then
        move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
    end
    
end

local function PerformAttack( eyePos, mem, bot, brain, move )

    assert( mem )

    local target = Shared.GetEntity(mem.entId)

    if target ~= nil then

        PerformAttackEntity( eyePos, target, bot, brain, move )

    else
    
        -- mem is too far to be relevant, so move towards it
        PerformMove(eyePos, mem.lastSeenPos, bot, brain, move)

    end
    
    brain.teamBrain:AssignBotToMemory(bot, mem)

end

------------------------------------------
--  Each want function should return the fuzzy weight,
-- along with a closure to perform the action
-- The order they are listed matters - actions near the beginning of the list get priority.
------------------------------------------
kFadeBrainActions =
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
    
                PerformMove(bot:GetPlayer():GetEyePos(),targetPos, bot, brain, move)
                
                end ),
    
    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        local name = "evolve"

        local weight = 0.0
        local player = bot:GetPlayer()
        local s = brain:GetSenses()
        local res = player:GetPersonalResources()

        local distanceToNearestThreat = s:Get("nearestThreat").distance
        local desiredUpgrades = {}

        if player:GetIsAllowedToBuy() and
                (distanceToNearestThreat == nil or distanceToNearestThreat > 15) and
                (player.GetIsInCombat == nil or not player:GetIsInCombat()) then

            -- Safe enough to try to evolve

            local existingUpgrades = player:GetUpgrades()

            local avaibleUpgrades = player.lifeformUpgrades

            if not avaibleUpgrades then
                avaibleUpgrades = {}

                local kUpgradeStructureTable = AlienTeam.GetUpgradeStructureTable()
                for i = 1, #kUpgradeStructureTable do
                    local upgrades = kUpgradeStructureTable[i].upgrades
                    table.insert(avaibleUpgrades, table.random(upgrades))
                end

                if player.lifeformEvolution then
                    table.insert(avaibleUpgrades, player.lifeformEvolution)
                end

                player.lifeformUpgrades = avaibleUpgrades
            end

            for i = 1, #avaibleUpgrades do
                local techId = avaibleUpgrades[i]
                local techNode = player:GetTechTree():GetTechNode(techId)

                local isAvailable = false
                local cost = 0
                if techNode ~= nil then
                    isAvailable = techNode:GetAvailable(player, techId, false)
                    cost = LookupTechData(techId, kTechDataGestateName) and GetCostForTech(techId) or LookupTechData(kTechId.Fade, kTechDataUpgradeCost, 0)
                end

                if not player:GetHasUpgrade(techId) and isAvailable and res - cost > 0 and
                        GetIsUpgradeAllowed(player, techId, existingUpgrades) and
                        GetIsUpgradeAllowed(player, techId, desiredUpgrades) then
                    res = res - cost
                    table.insert(desiredUpgrades, techId)
                end
            end

            if  #desiredUpgrades > 0 then
                weight = 100.0
            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                player:ProcessBuyAction( desiredUpgrades )
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
        local canAttack = weapon ~= nil and weapon:isa("SwipeBlink")

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
                    { 75.0, 0.0 } })
        end

        return { name = name, weight = weight,
            perform = function(move)
                brain.teamBrain:UnassignBot(bot)
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

        local pheromones = EntityListToTable(Shared.GetEntitiesWithClassname("Pheromone"))            
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
                PerformMove(eyePos, bestPheromoneLocation, bot, brain, move)
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
            weight = 10.0
        end

        return { name = name, weight = weight,
            perform = function(move)
                if order then

                    local target = Shared.GetEntity(order:GetParam())

                    if target ~= nil and order:GetType() == kTechId.Attack then

                        PerformAttackEntity( skulk:GetEyePos(), target, bot, brain, move )
                        
                    else

                        if brain.debug then
                            DebugPrint("unknown order type: %s", ToString(order:GetType()) )
                        end

                        PerformMove(skulk:GetEyePos(), order:GetLocation(), bot, brain, move)
                                        

                    end
                end
            end }
    end,

    function(bot, brain)

        local name = "retreat"
        local player = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local hive = sdb:Get("nearestHive")
        local hiveDist = hive and player:GetOrigin():GetDistance(hive:GetOrigin()) or 0
        local healthFraction = sdb:Get("healthFraction")
        local inCombat = player.GetIsInCombat and player:GetIsInCombat()

        -- If we are pretty close to the hive, stay with it a bit longer to encourage full-healing, etc.
        -- so pretend our situation is more dire than it is
        if hiveDist < 4.0 and healthFraction < 0.9 then
            healthFraction = healthFraction / 3.0
        end

        local weight = 0.0

        if hive then

            weight = EvalLPF( healthFraction, {
                { 0.0, 20.0 },
                { 0.6, 10.0 },
                { 0.8, 0.0 },
                { 1.0, 0.0 }
            })
            
            -- defend the hive! don't retreat!
            if not inCombat and hiveDist < 10 then
                weight = weight * 0.5
            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                if hive then

                    -- we are retreating, unassign ourselves from anything else, e.g. attack targets
                    brain.teamBrain:UnassignBot(bot)

                    local touchDist = GetDistanceToTouch( player:GetEyePos(), hive )
                    
                    
                    if kFadeTeleportEnergyCost then
                    
                        if inCombat and math.random() < 0.5 then
                            move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                        end
                    else
                        -- this is health NOT armor+health
                        if inCombat and healthFraction < 0.7 and (player:GetVelocity():GetLength() / player:GetMaxSpeed() < 0.9 or player:GetIsOnGround()) then
                            move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
                        end
                    end
                    
                    
                    if touchDist > 2.5 or inCombat then
                    
                        local jitter = Vector(math.random()-0.5, math.random()-0.5, math.random()-0.5) * 3
                        PerformMove(player:GetEyePos(), hive:GetEngagementPoint() + jitter, bot, brain, move)
                        
                        
                    else
                        -- sit and wait to heal
                        bot:GetMotion():SetDesiredViewTarget( hive:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                    end
                end

            end }

    end,

}

------------------------------------------
--
------------------------------------------
function CreateFadeBrainSenses()

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

    s:Add("nearestHive", function(db)
        local player = db.bot:GetPlayer()
        local playerPos = player:GetOrigin()

        local hives = GetEntitiesForTeam("Hive", player:GetTeamNumber())

        local builtHives = {}

        -- retreat only to built hives
        for _, hive in ipairs(hives) do

            if hive:GetIsBuilt() and hive:GetIsAlive() then
                table.insert(builtHives, hive)
            end

        end

        Shared.SortEntitiesByDistance(playerPos, builtHives)

        return builtHives[1]
    end)

    s:Add("healthFraction", function(db)
        local player = db.bot:GetPlayer()
        return player:GetHealthScalar()
    end)

    return s
end
