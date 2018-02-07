
Script.Load("lua/bots/BotDebug.lua")
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")
Script.Load("lua/bots/BotAim.lua")

local gMarineAimJitterAmount = 0.8

------------------------------------------
--  Handles things like using phase gates
------------------------------------------
local function PerformMove( marinePos, targetPos, bot, brain, move )

    bot:GetMotion():SetDesiredMoveTarget( targetPos )
    bot:GetMotion():SetDesiredViewTarget( nil )
    
end

------------------------------------------
--
------------------------------------------
local function GetCanAttack(marine)
    local weaponHolder = marine:GetActiveWeapon()
    if weaponHolder ~= nil then 
      
        local leftWeapon = weaponHolder:GetLeftSlotWeapon()
        local rightWeapon = weaponHolder:GetRightSlotWeapon()
        
        if leftWeapon:isa("Minigun") and not leftWeapon.overheated and rightWeapon:isa("Minigun") and not rightWeapon.overheated then
            return true
        else
            return false
        end
        
    else
        return false
    end
end

------------------------------------------
--  Utility perform function used by multiple wants
------------------------------------------

local function PerformAttackEntity( eyePos, target, lastSeenPos, bot, brain, move )

    assert(target ~= nil )

    if not target.GetIsSighted then
        Print("attack target has no GetIsSighted: %s", target:GetClassName() )
        return
    end

    local sighted = target:GetIsSighted()
    local aimPos = sighted and GetBestAimPoint( target ) or lastSeenPos
    local dist = GetDistanceToTouch( eyePos, target )
    local doFire = false

    -- Avoid doing expensive vis check if we are too far
    local hasClearShot = dist < 45.0 and bot:GetBotCanSeeTarget( target )

    if not hasClearShot then

        -- just keep moving along the path to find it
        PerformMove( eyePos, aimPos, bot, brain, move )
        doFire = false

    else

        if not bot.lastHostilesTime or bot.lastHostilesTime < Shared.GetTime() - 45 and target:isa("Player") then
            CreateVoiceMessage( bot:GetPlayer(), kVoiceId.MarineHostiles )
            bot.lastHostilesTime = Shared.GetTime()
        end
        
        if dist > 45.0 then
            -- close in on it first without firing
            bot:GetMotion():SetDesiredMoveTarget( aimPos )
            doFire = false
        elseif dist > 10.0 then
            -- move towards it while firing
            bot:GetMotion():SetDesiredMoveTarget( aimPos )
            doFire = true
        else
            
            -- good distance, or panic mode
            -- strafe with some regularity, but somewhat random
            local myOrigin = eyePos -- bot:GetPlayer():GetOrigin()
            local strafeTarget = (myOrigin - aimPos):CrossProduct(Vector(0,1,0))
            strafeTarget:Normalize()
            
            -- numbers chosen arbitrarily to give some appearance of random juking
            strafeTarget = strafeTarget * ConditionalValue( math.sin(Shared.GetTime() * 3.5 ) + math.sin(Shared.GetTime() * 2.2 ) > 0 , -1, 1)
            if strafeTarget:GetLengthSquared() > 0 and target:isa("Player") then
                bot:GetMotion():SetDesiredMoveTarget(strafeTarget + myOrigin)
            else
                bot:GetMotion():SetDesiredMoveTarget(nil)
            end
            --bot:GetMotion():SetDesiredMoveDirection(strafeTarget)
            doFire = true
        end
        
        doFire = doFire and bot.aim:UpdateAim(target, aimPos)
        
    end
    
    local retreating = false
    local sdb = brain:GetSenses()
    local minFraction = math.min( sdb:Get("healthFraction"), sdb:Get("ammoFraction") )
    local armory = sdb:Get("nearestArmory").armory
    
    -- retreat! Ignore previous move order
    if armory and minFraction < 0.4 and target:isa("Player") then
        local touchDist = GetDistanceToTouch( eyePos, armory )
        if touchDist > 2.0 then
            bot:GetMotion():SetDesiredMoveTarget( armory:GetEngagementPoint() )
        else
            -- sit and wait to heal, ammo, etc.
            brain.retreatTargetId = nil
            bot:GetMotion():SetDesiredViewTarget( armory:GetEngagementPoint() )
            bot:GetMotion():SetDesiredMoveTarget( nil )
            doFire = false
        end
        retreating = true
    end
    
    
    if doFire or (brain.lastShootingTime and brain.lastShootingTime > Shared.GetTime() - 0.5) then
    
        -- TODO: Make this work for both weapons....?
        local player = bot:GetPlayer()
        local weaponHolder = player:GetActiveWeapon()    
        local leftWeapon = weaponHolder:GetLeftSlotWeapon()
        local rightWeapon = weaponHolder:GetRightSlotWeapon()
        if not leftWeapon or not leftWeapon.heatAmount or leftWeapon.heatAmount < 0.95 then
            move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        end
        if not rightWeapon or not rightWeapon.heatAmount or rightWeapon.heatAmount < 0.95 then
            move.commands = AddMoveCommand( move.commands, Move.SecondaryAttack )
        end
    else
        if (brain.lastShootingTime and brain.lastShootingTime > Shared.GetTime() - 0.5) then
            -- blindfire at same old spot
            bot:GetMotion():SetDesiredViewTarget( bot:GetMotion().desiredViewTarget )
            move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        elseif not retreating and dist < 15.0  then
            bot:GetMotion():SetDesiredViewTarget( aimPos )
        elseif retreating then
            -- not shooting, wasn't shooting recently, and retreating
            move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
        end
    
    end
    
    if doFire then
        brain.lastShootingTime = Shared.GetTime()
    end
    
    -- Draw a red line to show what we are trying to attack
    if gBotDebug:Get("debugall") or brain.debug then

        if doFire then
            DebugLine( eyePos, aimPos, 0.0,   1,0,0,1, true)
        else
            DebugLine( eyePos, aimPos, 0.0,   1,0.5,0,1, true)
        end

    end

end

------------------------------------------
--
------------------------------------------
local function PerformAttack( eyePos, mem, bot, brain, move )

    assert( mem )

    local target = Shared.GetEntity(mem.entId)

    if target ~= nil then

        PerformAttackEntity( eyePos, target, mem.lastSeenPos, bot, brain, move )

    end

    brain.teamBrain:AssignBotToMemory(bot, mem)

end
local function GetIsUseOrder(order)
    return order:GetType() == kTechId.Construct 
            or order:GetType() == kTechId.AutoConstruct
            or order:GetType() == kTechId.Build
end

------------------------------------------
--  Each want function should return the fuzzy weight or tree along with a closure to perform the action
--  The order they are listed should not really matter, but it is used to break ties (again, ties should be unlikely given we are using fuzzy, interpolated eval)
--  Must NOT be local, since MarineBrain uses it.
------------------------------------------
kMinigunBrainActions =
{
    function(bot, brain)

        local name = "attack"

        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local threat = sdb:Get("biggestThreat")
        local weight = 0.0

        if threat ~= nil and sdb:Get("weaponReady") then

            weight = EvalLPF( threat.distance, {
                        { 0.0, EvalLPF( threat.urgency, {
                            {0, 0},
                            {10, 25}
                            })},
                        { 10.0, EvalLPF( threat.urgency, {
                            {0, 0},
                            {10, 5} })},
                        -- Never let it drop too low - ie. keep it always above explore
                        { 100.0, 0.1 } })
        end


        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
                PerformAttack( marine:GetEyePos(), threat.memory, bot, brain, move )
            end }
    end,
    
    function(bot, brain)

        local name = "order"

        local marine = bot:GetPlayer()
        local order = bot:GetPlayerOrder()
        local teamBrain = bot.brain.teamBrain

        local weight = 0.0

        if order ~= nil then

            local targetId = order:GetParam()
            local target = Shared.GetEntity(targetId)

            if target ~= nil and GetIsUseOrder(order) then

                    weight = 0.0

            else

                -- Could be attack
                weight = 3.0

            end

        end

        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
                if order then

                    brain.teamBrain:UnassignBot(bot)

                    local target = Shared.GetEntity(order:GetParam())

                    if target ~= nil and order:GetType() == kTechId.Attack then

                        PerformAttackEntity( marine:GetEyePos(), target, order:GetLocation(), bot, brain, move )

                    elseif order:GetType() == kTechId.Move then

                        PerformMove( marine:GetOrigin(), order:GetLocation(), bot, brain, move )

                    else

                        DebugPrint("unknown order type: %d", order:GetType())
                        PerformMove( marine:GetOrigin(), order:GetLocation(), bot, brain, move )

                    end
                end
            end }
    end,
    
    

    function( bot, brain )

        local name = "ping"
        local weight = 0.0
        local marine = bot:GetPlayer()
        local db = brain:GetSenses()
        local pos = marine:GetOrigin()

        local kPingLifeTime = 30.0
        local pingPos = db:Get("comPingPosition")

        if pingPos ~= nil and db:Get("comPingElapsed") ~= nil and db:Get("comPingElapsed") < kPingLifeTime then


            if brain.lastReachedPingPos ~= nil and pingPos:GetDistance(brain.lastReachedPingPos) < 1e-2 then
                -- we already reached this ping - ignore it
            elseif db:Get("comPingXZDist") > 5 then
                -- respond to ping with fairly high priority
                -- but allow direct orders to override
                weight = 1.5
            else
                -- we got close enough, remember to ignore this ping
                brain.lastReachedPingPos = db:Get("comPingPosition")
            end

        end

        return { name = name, weight = weight,
            perform = function(move)
                local pingPos = db:Get("comPingPosition")
                assert(pingPos ~= nil)
                PerformMove( marine:GetOrigin(), pingPos, bot, brain, move )
            end}

    end,

    function(bot, brain)

        local name = "retreat"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local armory = sdb:Get("nearestArmory").armory
        local armoryDist = sdb:Get("nearestArmory").distance
        local minFraction = sdb:Get("healthFraction")

        -- If we are pretty close to the armory, stay with it a bit longer to encourage full-healing, etc.
        -- so pretend our situation is more dire than it is
        if armory ~= nil and armoryDist < 4.0 and minFraction < 0.8 then
            if brain.debug then
                Print("close to armory, being less risky")
            end
            minFraction = minFraction / 3.0
        end

        local weight = 0.0

        if armory ~= nil then

            weight = EvalLPF( minFraction, {
                    { 0.0, 0.5 },
                    { 0.4, 0.0 },
                    { 1.0, 0.0 }
                    })
        end
        

        return { name = name, weight = weight,
            perform = function(move)
                if armory ~= nil then

                    -- we are retreating, unassign ourselves from anything else, e.g. attack targets
                    brain.teamBrain:UnassignBot(bot)

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), armory )
                    if touchDist > 6.0 then
                        if brain.debug then DebugPrint("going towards armory at %s", ToString(armory:GetEngagementPoint())) end
                        PerformMove( marine:GetOrigin(), armory:GetEngagementPoint(), bot, brain, move )
                        move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                        if touchDist > 15.0 then
                            bot:SendTeamMessage("I could really use some welds!")
                        end
                    else
                        -- try to find a place to get out
                        brain.retreatTargetId = nil
                        local armoryPoint = armory:GetEngagementPoint() + Vector(math.random() * 6 - 3, 0, math.random() * 6 - 3 )
                        PerformMove( marine:GetOrigin(), armoryPoint, bot, brain, move )
                        
                        move.commands = AddMoveCommand(move.commands, Move.Drop)
                    end
                end

            end }

    end,

    function(bot, brain)

        local name = "clearCyst"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0

        if sdb:Get("weaponReady") and sdb:Get("attackNearestCyst") then
            weight = 0.5
        else
            weight = 0.0
        end

        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
                    local cyst = sdb:Get("nearestCyst")
                    assert(cyst ~= nil)
                    assert(cyst.entity ~= nil)
                    PerformAttackEntity( marine:GetEyePos(), cyst.entity, cyst.entity:GetOrigin(), bot, brain, move )
            end }

    end,
    
    ------------------------------------------
    --
    ------------------------------------------
    CreateExploreAction( 0.05, function( pos, targetPos, bot, brain, move )
            if gBotDebug:Get("debugall") or brain.debug then
                DebugLine(bot:GetPlayer():GetEyePos(), targetPos+Vector(0,1,0), 0.0,     0,0,1,1, true)
            end
            PerformMove(pos, targetPos, bot, brain, move)
            end ),

    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        return { name = "debug idle", weight = 0.01,
                perform = function(move)
                    -- Do a jump..for fun
                    move.commands = AddMoveCommand(move.commands, Move.Jump)
                    self.lastJumpTime = Shared.GetTime()
                    bot:GetMotion():SetDesiredViewTarget(nil)
                    bot:GetMotion():SetDesiredMoveTarget(nil)
                end }
    end

}

------------------------------------------
--  More urgent == should really attack it ASAP
------------------------------------------
local function GetAttackUrgency(bot, mem)

    local teamBrain = bot.brain.teamBrain

    -- See if we know whether if it is alive or not
    local target = Shared.GetEntity(mem.entId)
    if not HasMixin(target, "Live") or not target:GetIsAlive() or (target.GetTeamNumber and target:GetTeamNumber() == bot:GetTeamNumber()) then
        return nil
    end

    -- for load-balancing
    local numOthers = teamBrain:GetNumAssignedTo( mem,
            function(otherId)
                if otherId ~= bot:GetPlayer():GetId() then
                    return true
                end
                return false
            end)

    -- Closer --> more urgent

    local closeBonus = 0
    local dist = bot:GetPlayer():GetOrigin():GetDistance( mem.lastSeenPos )

    if dist < 15 then
        -- Do not modify numOthers here
        closeBonus = 10/math.max(1.0, dist)
    end

    ------------------------------------------
    -- Passives - not an immediate threat, but attack them if you got nothing better to do
    ------------------------------------------
    local passiveUrgencies =
    {
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
        -- from skulk
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
    }

    if bot.brain.debug then
        if mem.btype == kMinimapBlipType.Hive then
            Print("got Hive, urgency = %f", passiveUrgencies[mem.btype])
        end
    end

    if passiveUrgencies[ mem.btype ] ~= nil then
        if target.GetIsGhostStructure and target:GetIsGhostStructure() and 
            mem.btype ~= kMinimapBlipType.Extractor then
            return nil
        end
        return passiveUrgencies[ mem.btype ] + closeBonus * 0.3
    end

    ------------------------------------------
    --  Active threats - ie. they can hurt you
    --  Only load balance if we cannot see the target
    ------------------------------------------
    function EvalActiveUrgenciesTable(numOthers)
        local activeUrgencies =
        {
            [kMinimapBlipType.Embryo] = numOthers >= 1 and 0.1 or 1.0,
            [kMinimapBlipType.Hydra] = numOthers >= 2  and 0.1 or 2.0,
            [kMinimapBlipType.Whip] = numOthers >= 2   and 0.1 or 3.0,
            [kMinimapBlipType.Skulk] = numOthers >= 2  and 0.1 or 4.0,
            [kMinimapBlipType.Gorge] =  numOthers >= 2  and 0.1 or 3.0,
            [kMinimapBlipType.Drifter] = numOthers >= 1  and 0.1 or 1.0,
            [kMinimapBlipType.Lerk] = numOthers >= 2   and 0.1 or 5.0,
            [kMinimapBlipType.Fade] = numOthers >= 3   and 0.1 or 6.0,
            [kMinimapBlipType.Onos] =  numOthers >= 4  and 0.1 or 7.0,
            [kMinimapBlipType.Marine] = numOthers >= 2 and 0.1 or 5.0,
            [kMinimapBlipType.JetpackMarine] = numOthers >= 2 and 0.1 or 5.0,
            [kMinimapBlipType.Exo] =  numOthers >= 4  and 0.1 or 5.0,
            [kMinimapBlipType.Sentry]  = numOthers >= 2   and 0.1 or 5.0
        }
        return activeUrgencies
    end

    -- Optimization: we only need to do visibilty check if the entity type is active
    -- So get the table first with 0 others
    local urgTable = EvalActiveUrgenciesTable(0)

    if urgTable[ mem.btype ] then

        -- For nearby active threads, respond no matter what - regardless of how many others are around
        if dist < 15 then
            numOthers = 0
        end

        urgTable = EvalActiveUrgenciesTable(numOthers)
        return urgTable[ mem.btype ] + closeBonus

    end

    return nil

end

------------------------------------------
--  Build the senses database
------------------------------------------

function CreateMinigunBrainsSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("clipFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetActiveWeapon()
            if weapon ~= nil then
                if weapon:isa("ClipWeapon") then
                    return weapon:GetClip() / weapon:GetClipSize()
                else
                    return 1.0
                end
            else
                return 0.0
            end
            end)

    s:Add("ammoFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetActiveWeapon()
            if weapon ~= nil then
                if weapon:isa("ClipWeapon") then
                    return weapon:GetAmmo() / weapon:GetMaxAmmo()
                else
                    return 1.0
                end
            else
                return 0.0
            end
            end)

    s:Add("welder", function(db)
            local marine = db.bot:GetPlayer()
            return marine:GetWeapon( Welder.kMapName )
            end)

    s:Add("welderReady", function(db)
            local marine = db.bot:GetPlayer()
            return marine:GetActiveWeapon():GetMapName() == Welder.kMapName
            end)

    s:Add("weaponReady", function(db)
            return db:Get("ammoFraction") > 0
            end)

    s:Add("healthFraction", function(db)
            local marine = db.bot:GetPlayer()
            return marine:GetHealthScalar()
            end)

    s:Add("biggestThreat", function(db)
            local marine = db.bot:GetPlayer()
            local memories = GetTeamMemories( marine:GetTeamNumber() )
            local maxUrgency, maxMem = GetMaxTableEntry( memories,
                function( mem )
                    return GetAttackUrgency( db.bot, mem )
                end)
            local dist = nil
            if maxMem ~= nil then
                if db.bot.brain.debug then
                    Print("max mem type = %s", EnumToString(kMinimapBlipType, maxMem.btype))
                end
                dist = marine:GetEyePos():GetDistance(maxMem.lastSeenPos)
                return {urgency = maxUrgency, memory = maxMem, distance = dist}
            else
                return nil
            end
            end)

    s:Add("nearestArmory", function(db)

            local marine = db.bot:GetPlayer()
            local armories = GetEntitiesForTeam( "Armory", marine:GetTeamNumber() )

            local dist, armory = GetMinTableEntry( armories,
                function(arm)
                    assert( arm ~= nil )
                    if arm:GetIsBuilt() and arm:GetIsPowered() then
                        local dist = marine:GetOrigin():GetDistance(arm:GetOrigin())
                        -- Weigh our previous nearest a bit better, to prevent thrashing
                        if arm:GetId() == db.lastNearestArmoryId then
                            return dist * 0.9
                        else
                            return dist
                        end
                    end
                end)

            if armory ~= nil then db.lastNearestArmoryId = armory:GetId() end
            return {armory = armory, distance = dist}

            end)
            
    s:Add("nearestProto", function(db)

            local marine = db.bot:GetPlayer()
            local protos = GetEntitiesForTeam( "PrototypeLab", marine:GetTeamNumber() )

            local dist, proto = GetMinTableEntry( protos,
                function(pro)
                    assert( pro ~= nil )
                    if pro:GetIsBuilt() and pro:GetIsPowered() then
                        local dist = marine:GetOrigin():GetDistance(pro:GetOrigin())
                        -- Weigh our previous nearest a bit better, to prevent thrashing
                        if pro:GetId() == db.lastNearestProtoId then
                            return dist * 0.9
                        else
                            return dist
                        end
                    end
                end)

            if proto ~= nil then db.lastNearestProtoId = proto:GetId() end
            return {proto = proto, distance = dist}

            end)

    s:Add("nearestPower", function(db)

            local marine = db.bot:GetPlayer()
            local marinePos = marine:GetOrigin()
            local powers = GetEntities( "PowerPoint" )

            local dist, power = GetMinTableEntry( powers,
                function(power)
                    if power:GetIsBuilt() then
                        return marinePos:GetDistance( power:GetOrigin() )
                    end
                end)

            return {entity = power, distance = dist}
            end)

    s:Add("nearestCyst", function(db)

            local marine = db.bot:GetPlayer()
            local marinePos = marine:GetOrigin()
            local cysts = GetEntitiesWithinRange("Cyst", marinePos, 20)

            local dist, cyst = GetMinTableEntry( cysts, function(cyst)
                if cyst:GetIsSighted() then
                    return marinePos:GetDistance( cyst:GetOrigin() )
                end
                return nil
                end)

            return {entity = cyst, distance = dist}
            end)

    s:Add("attackNearestCyst", function(db)
            local cyst = db:Get("nearestCyst")
            local power = db:Get("nearestPower")
            if cyst.entity ~= nil and power.entity ~= nil then
                local cystPos = cyst.entity:GetOrigin()
                local powerPos = power.entity:GetOrigin()
                --DebugLine( cystPos, powerPos, 0.0, 1,1,0,1,  true )
                return cystPos:GetDistance(powerPos) < 15
            else
                return false
            end
            end)

    s:Add("comPingElapsed", function(db)

            local marine = db.bot:GetPlayer()
            local pingTime = GetGamerules():GetTeam(marine:GetTeamNumber()):GetCommanderPingTime()

            if pingTime > 0 and pingTime ~= nil and pingTime < Shared.GetTime() then
                return Shared.GetTime() - pingTime
            else
                return nil
            end

            end)

    s:Add("comPingPosition", function(db)
            
            local marine = db.bot:GetPlayer()
            local rawPos = GetGamerules():GetTeam(marine:GetTeamNumber()):GetCommanderPingPosition()
            -- the position is usually up in the air somewhere, so pretend we did a commander pick to put it somewhere sensible
            local trace = GetCommanderPickTarget(
                db.bot:GetPlayer(), -- not right, but whatever
                rawPos,
                true, -- worldCoords Specified
                false, -- isBuild
                true -- ignoreEntities
                )

            if trace ~= nil and trace.fraction < 1 then
                return trace.endPoint
            else
                return  nil
            end

            end)

    s:Add("comPingXZDist", function(db)
            local marine = db.bot:GetPlayer()
            if db:Get("comPingPosition") ~= nil then
                local delta = db:Get("comPingPosition") - marine:GetOrigin()
                return delta:GetLengthXZ()
            end
            end)

    return s

end

if Server then
Event.Hook("Console_marinejitter", function(client, arg)
        gMarineAimJitterAmount = tonumber(arg)
        Print("gMarineAimJitterAmount = %f", gMarineAimJitterAmount)
        end
        )
end
