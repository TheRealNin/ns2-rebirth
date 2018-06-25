
Script.Load("lua/bots/BotDebug.lua")
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")
Script.Load("lua/bots/BotAim.lua")


------------------------------------------
--  Data includes values, but also functions.
--  We put them in this file so we can easily hotload it and iterate live.
--  Nothing in this file should affect other game state, except where it is used.
------------------------------------------

------------------------------------------
--  Phase gates
------------------------------------------
local function FindNearestPhaseGate(marine, favoredGateId, fromPos)
    
    local gates = GetEntitiesForTeam( "PhaseGate", marine:GetTeamNumber() )

    return GetMinTableEntry( gates,
            function(gate)

                assert( gate ~= nil )

                if gate:GetIsBuilt() and gate:GetIsPowered() then

                    local dist = fromPos:GetDistance(gate:GetOrigin())
                    if gate:GetId() == favoredGateId then
                        return dist * 0.9
                    else
                        return dist
                    end

                else
                    return nil
                end

            end)

end

------------------------------------------
--  Returns the distance, maybe using phase gates.
------------------------------------------
local function GetPhaseDistanceForMarine(marine, to, lastNearestGateId )

    local marinePos = marine:GetOrigin()
    local p0Dist, p0 = FindNearestPhaseGate(marine, lastNearestGateId, marinePos)
    local p1Dist, p1 = FindNearestPhaseGate(marine, nil, to)
    local euclidDist = marinePos:GetDistance(to)

    -- Favor the euclid dist just a bit..to prevent thrashing
    if p0Dist ~= nil and p1Dist ~= nil and (p0Dist + p1Dist) < euclidDist*0.9 then
        return (p0Dist + p1Dist), p0
    else
        return euclidDist, nil
    end

end


------------------------------------------
--  Handles things like using phase gates
------------------------------------------
local function PerformMove( marinePos, targetPos, bot, brain, move )

    local dist, gate = GetPhaseDistanceForMarine( bot:GetPlayer(), targetPos, brain.lastGateId )

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
end

------------------------------------------
--
------------------------------------------
local function GetCanAttack(marine)
    local weapon = marine:GetActiveWeapon()
    if weapon ~= nil then
        if weapon:isa("ClipWeapon") then
            return weapon:GetAmmo() > 0
        else
            return true
        end
    else
        return false
    end
end

------------------------------------------
--
------------------------------------------
local function SwitchToPrimary(marine)
    if marine:GetWeapon( Rifle.kMapName ) then
        marine:SetActiveWeapon(Rifle.kMapName, true)
    elseif marine:GetWeapon( Shotgun.kMapName ) then
        marine:SetActiveWeapon(Shotgun.kMapName, true)
    elseif marine:GetWeapon( Flamethrower.kMapName ) then
        marine:SetActiveWeapon(Flamethrower.kMapName, true)
    elseif marine:GetWeapon( HeavyMachineGun.kMapName ) then
        marine:SetActiveWeapon(HeavyMachineGun.kMapName, true)
    elseif marine:GetWeapon( GrenadeLauncher.kMapName ) then
        marine:SetActiveWeapon(GrenadeLauncher.kMapName, true)
    end
end

local function SwitchToPistol(marine)
    local weapon = marine:GetWeapon( Pistol.kMapName )
    if weapon and weapon:GetAmmo() / weapon:GetMaxAmmo() > 0.0 then
        marine:SetActiveWeapon(Pistol.kMapName, true)
    else
        SwitchToPrimary(marine)
    end
end
------------------------------------------
--  Utility perform function used by multiple wants
------------------------------------------

local function GetEffectiveRangeForPrimary(marine)
    if marine:GetWeapon( Rifle.kMapName ) then
        return 20.0
    elseif marine:GetWeapon( Shotgun.kMapName ) then
        return 6.0
    elseif marine:GetWeapon( Flamethrower.kMapName ) then
        return 8.0
    elseif marine:GetWeapon( HeavyMachineGun.kMapName ) then
        return 15.0
    elseif marine:GetWeapon( GrenadeLauncher.kMapName ) then
        return 20.0
    end
    return 0.0
end

local function PerformAttackEntity( eyePos, target, lastSeenPos, bot, brain, move )

    assert(target ~= nil )
    
    local player = bot:GetPlayer()
    local time = Shared.GetTime()
    
    local sighted 
    if not target.GetIsSighted then
        -- Print("attack target has no GetIsSighted: %s", target:GetClassName() )
        sighted = true
    else
        sighted = target:GetIsSighted()
    end
    
    local aimPos = sighted and GetBestAimPoint( target ) or (lastSeenPos + Vector(0,0.1,0))
    local dist = GetDistanceToTouch( eyePos, target )
    local doFire = false
    local shouldStrafe = false
    local shouldStrafeForward = false
    local isDodgeable = target:isa("Player") or target:isa("Babbler")
    
    -- Avoid doing expensive vis check if we are too far
    local hasClearShot = dist < 45.0 and bot:GetBotCanSeeTarget( target )
    
    if (target.GetIsGhostStructure and target:GetIsGhostStructure()) then
    
        -- uses a gate
        PerformMove( eyePos, aimPos, bot, brain, move )
        doFire = false
        
    elseif not hasClearShot then
        
        local isNotDetected =  not (player:GetIsDetected() or player:GetIsSighted())
        if isNotDetected and bot.sneakyAbility and dist < 20.0 and dist > 4.0 and isDodgeable and
            (not bot.lastSeenEnemy or bot.lastSeenEnemy + 10 < time) and not sighted then
            
            move.commands = AddMoveCommand( move.commands, Move.Crouch )
        end
        -- uses a gate
        PerformMove( eyePos, aimPos, bot, brain, move )
        
        doFire = false

    else
        
        bot.lastSeenEnemy = time
        
        if dist > 45.0 then
            -- close in on it first without firing
            -- has a clear shot, but way too far and outside "relevancy" for normal players
            bot:GetMotion():SetDesiredMoveTarget( aimPos )
            doFire = false
        elseif dist > GetEffectiveRangeForPrimary(player) then
            -- move towards it while firing because we're not inside the effective range
            bot:GetMotion():SetDesiredMoveTarget( aimPos )
            shouldStrafe = true
            shouldStrafeForward = true
            doFire = true
        elseif dist > 4.0 then
        
            -- too close - back away while firing if health is still high
            local healthThreshold =  0.3 + bot.aggroAbility * 0.5
            if target.health / target.maxHealth >healthThreshold and isDodgeable then
                bot:GetMotion():SetDesiredMoveTarget( nil )
                bot:GetMotion():SetDesiredMoveDirection( -( aimPos-eyePos ) )
                shouldStrafe = true
            else
              -- or chase, since their health is low!
                bot:GetMotion():SetDesiredMoveTarget( aimPos )
            end

            doFire = true
        else
            shouldStrafe = true
            doFire = true
        end
        
        -- this is a hack because there's a bug somewhere...
        if doFire and (target:isa("Babbler") or target:isa("Clog")) and hasClearShot then
            doFire = true
            aimPos = target:GetEngagementPoint()
            bot:GetMotion():SetDesiredViewTarget( aimPos )
        else
            doFire = doFire and bot.aim:UpdateAim(target, aimPos)
        end
    end
    
    if shouldStrafe then
        if not isDodgeable then
            if shouldStrafeForward then
                bot:GetMotion():SetDesiredMoveTarget( aimPos )
            else
                bot:GetMotion():SetDesiredMoveTarget( nil )
            end
        else
            -- good distance, or panic mode
            -- strafe with some regularity, but somewhat random
            local strafeTarget = (eyePos - aimPos):CrossProduct(Vector(0,1,0))
            strafeTarget:Normalize()
            
            -- numbers chosen arbitrarily to give some appearance of random juking
            strafeTarget = strafeTarget * ConditionalValue( math.sin(time * 3.5 ) + math.sin(time * 2.2 ) > 0 , -1, 1)
            
            if shouldStrafeForward then
                strafeTarget = strafeTarget + ( aimPos-eyePos ):GetUnit()
                strafeTarget:Normalize()
            end
            
            if strafeTarget:GetLengthSquared() > 0 then
                bot:GetMotion():SetDesiredMoveDirection(strafeTarget)
                if not bot.lastJumpDodge or (bot.lastJumpDodge + 2 > time and bot.lastJumpDodge + 15 < time) then
                    bot.lastJumpDodge = Shared.GetTime()
                    move.commands = AddMoveCommand(move.commands, Move.Jump)
                end
            end
        end
    end
    
    
    local retreating = false
    local sdb = brain:GetSenses()
    local minFraction = math.min( sdb:Get("healthFraction"), sdb:Get("ammoFraction") )
    local armory = sdb:Get("nearestArmory").armory
    
    
    -- retreat! Ignore previous move order, but keep our aim
    if armory and minFraction < 0.3 and isDodgeable then
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
    
    
    
    if doFire then
    
        move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        bot.lastAimPos = aimPos
        brain.lastShootingTime = Shared.GetTime()
        
        if (not bot.lastHostilesTime or bot.lastHostilesTime < Shared.GetTime() - 45) and isDodgeable then
            CreateVoiceMessage( player, kVoiceId.MarineHostiles )
            --bot:SendTeamMessage("Enemy contact!", 60)
            bot.lastHostilesTime = Shared.GetTime()
        end
        
    else
    
        if (brain.lastShootingTime and brain.lastShootingTime > Shared.GetTime() - 0.5) then
            -- blindfire at same old spot
            if bot.lastAimPos then
                bot:GetMotion():SetDesiredViewTarget( bot.lastAimPos  )
                move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
            end
            
        elseif not retreating and dist < 15.0  then
            if not bot.lastAimCheatTime or bot.lastAimCheatTime + 0.5 < Shared.GetTime() then
                bot.lastAimCheatTime = Shared.GetTime()
                bot.lastAimPos = aimPos + Vector(math.random() * 4 - 2,math.random() * 2 - 1,math.random() * 4 - 2)
            end
            if bot.lastAimPos then
                bot:GetMotion():SetDesiredViewTarget(bot.lastAimPos)
            end
        else
            bot.lastAimPos = nil
        end
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

    else

        assert(false)
        -- This should never really happen..

    end

    brain.teamBrain:AssignBotToMemory(bot, mem)

end

------------------------------------------
--
------------------------------------------
local function PerformUse(marine, target, bot, brain, move)

    assert(target)
    local usePos = target:GetEngagementPoint()
    local dist = GetDistanceToTouch(marine:GetEyePos(), target)

    local hasClearShot = dist < 5 and bot:GetBotCanSeeTarget( target )
    
    if not hasClearShot or math.random() < 0.01 then
        -- cannot see it yet - keep moving
        PerformMove( marine:GetOrigin(), usePos, bot, brain, move )
        move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
    elseif dist < 1.4 then
        -- close enough to just use
        bot:GetMotion():SetDesiredViewTarget( usePos )
        bot:GetMotion():SetDesiredMoveTarget( nil )
        move.commands = AddMoveCommand( move.commands, Move.Use )
    else
        -- not close enough - keep moving, but also just do use to be safe.
        -- Robo factory still gives us issues
        move.commands = AddMoveCommand( move.commands, Move.Use )
        PerformMove( marine:GetOrigin(), usePos, bot, brain, move )
        bot:GetMotion():SetDesiredViewTarget(usePos )
    end

end

local function PerformWeld(marine, target, bot, brain, move)

    assert(target)
    
    local usePos = target:GetOrigin()
    local dist = GetDistanceToTouch(marine:GetEyePos(), target)

    local hasClearShot = dist < 5 and bot:GetBotCanSeeTarget( target )
    local weldPercent = (target.GetWeldPercentage and target:GetWeldPercentage())
    local wasWelded = weldPercent ~= brain.lastWeldPercent or (not brain.lastWeldTime or brain.lastWeldTime < Shared.GetTime() - 2)

    if not hasClearShot then
        -- cannot see it yet - keep moving
        PerformMove( marine:GetOrigin(), usePos, bot, brain, move )
    elseif dist < 2.3 and wasWelded then
        -- close enough to just PrimaryAttack
        bot:GetMotion():SetDesiredViewTarget( target:GetEngagementPoint() )
        bot:GetMotion():SetDesiredMoveTarget( nil )
        
        move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        
        if (not bot.lastCoveringTime or bot.lastCoveringTime < Shared.GetTime() - 45) and target:isa("Player") then
            CreateVoiceMessage( bot:GetPlayer(), kVoiceId.MarineCovering )
            bot.lastCoveringTime = Shared.GetTime()
        end
        
    else
        -- not close enough - keep moving, but also just do PrimaryAttack to be safe.
        -- Robo factory still gives us issues
        PerformMove( marine:GetOrigin(), usePos, bot, brain, move )
        move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
        
        if target:isa("Player") then
            bot:SendTeamMessage("Let me weld you, " .. target:GetName(), 70)
        end
    end
    
    if not brain.lastWeldTime or brain.lastWeldTime < Shared.GetTime() - 2 then
        brain.lastWeldPercent = weldPercent
        brain.lastWeldTime = Shared.GetTime()
    end
    
    -- no need not to sprint...
    move.commands = AddMoveCommand( move.commands, Move.MovementModifier )

    
end

------------------------------------------
--
------------------------------------------
local function GetIsUseOrder(order)
    return order:GetType() == kTechId.Construct 
            or order:GetType() == kTechId.AutoConstruct
            or order:GetType() == kTechId.Build
end

local function HasGoodWeapon(marine)
    return marine:GetWeapon( Shotgun.kMapName ) or marine:GetWeapon( HeavyMachineGun.kMapName ) or marine:GetWeapon( Flamethrower.kMapName )
end

------------------------------------------
--  Each want function should return the fuzzy weight or tree along with a closure to perform the action
--  The order they are listed should not really matter, but it is used to break ties (again, ties should be unlikely given we are using fuzzy, interpolated eval)
--  Must NOT be local, since MarineBrain uses it.
------------------------------------------
kMarineBrainActions =
{
    function(bot, brain)

        local name = "grabWeapons"

        local marine = bot:GetPlayer()
        local haveGoodWeapon = HasGoodWeapon(marine)
        local weapons = GetEntitiesWithinRangeAreVisible( "Shotgun", marine:GetOrigin(), 20, true )
        table.copy(GetEntitiesWithinRangeAreVisible( "HeavyMachineGun", marine:GetOrigin(), 20, true ), weapons, true)
        table.copy(GetEntitiesWithinRangeAreVisible( "Flamethrower", marine:GetOrigin(), 20, true ), weapons, true)

        -- ignore shotguns owned by someone already
        shotguns = FilterArray( weapons, function(ent) return ent:GetParent() == nil end )
        local bestDist, bestGun = GetNearestFiltered(marine:GetOrigin(), weapons)

        local weight = 0.0
        if not haveGoodWeapon and bestGun ~= nil then
            weight = EvalLPF( bestDist, {
                    {0.0  , 2.0} , 
                    {3.0  , 2.0} , 
                    {5.0  , 1.0}  , 
                    {20.0 , 0.0}
                    })
        end
        
        return { name = name, weight = weight,
                perform = function(move)
                    if bestGun ~= nil then
                        PerformMove( marine:GetOrigin(), bestGun:GetOrigin(), bot, brain, move )
                        bot:GetMotion():SetDesiredViewTarget( bestGun:GetOrigin() )
                        if bestDist < 1.0 then
                            SwitchToPrimary(marine)
                            move.commands = AddMoveCommand( move.commands, Move.Drop )
                        end
                    end
                end }
    end,

    function(bot, brain)

        local name = "medpack"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local weight = 0.0
        local health = sdb:Get("healthFraction")

        local pos = marine:GetOrigin()
        local meds 
        if table.contains(kTechId, "HealingField") then
            meds = GetEntitiesForTeamWithinRange( "HealingField", marine:GetTeamNumber(), pos, 15)
        else
            meds = GetEntitiesWithinRangeAreVisible( "MedPack", pos, 10, true )
        end
        local bestDist, bestMed = GetNearestFiltered( pos, meds )

        if bestMed ~= nil then
            if table.contains(kTechId, "HealingField") then
                weight = EvalLPF( bestDist, {
                        {0.0, 0.0},
                        {HealingField.kRadius - 2, 0.0},
                        {HealingField.kRadius - 1, EvalLPF(health, {
                            {0.0, 20.0},
                            {0.8, 0.5},
                            {1.0, 0.0}
                            })},
                        {10.0, EvalLPF(health, {
                            {0.0, 2.0},
                            {0.5, 0.5},
                            {1.0, 0.0}
                            })}
                        })
                        
            else
                weight = EvalLPF( bestDist, {
                        {0.0, EvalLPF(health, {
                            {0.0, 5.0},
                            {0.8, 1.0},
                            {1.0, 0.0}
                            })},
                        {5.0, EvalLPF(health, {
                            {0.0, 5.0},
                            {0.5, 1.0},
                            {1.0, 0.0}
                            })},
                        {10.0, EvalLPF(health, {
                            {0.0, 5.0},
                            {0.1, 1.0},
                            {1.0, 0.0}
                            })}
                        })
                        
            end
        end

        return { name = name, weight = weight,
                perform = function(move)
                    PerformMove( pos, bestMed:GetOrigin(), bot, brain, move )
                end }
    end,

    function(bot, brain)

        local name = "ammopack"
        local weight = 0.0
        local sdb = brain:GetSenses()
        local marine = bot:GetPlayer()
        local pos = marine:GetOrigin()

        local weapon = marine:GetActiveWeapon()
        local bestPack = nil
        local bestDist = nil

        if weapon ~= nil and weapon:isa("ClipWeapon") then

            local ammo = sdb:Get("ammoFraction")
            local packs = GetEntitiesWithinRangeAreVisible( "AmmoPack", pos, 10, true )

            local function IsPackForWeapon(pack)

                if pack:isa("WeaponAmmoPack") then
                    local weaponClass = pack:GetWeaponClassName()
                    return weapon:GetClassName() == weaponClass
                else
                    return true
                end

            end

            bestDist, bestPack = GetNearestFiltered( pos, packs, IsPackForWeapon )

            if bestPack ~= nil then
                weight = EvalLPF( bestDist, {
                        {0.0, EvalLPF(ammo, {
                            {0.0, 20.0},
                            {0.8, 1.0},
                            {1.0, 0.0}
                            })},
                        {5.0, EvalLPF(ammo, {
                            {0.0, 20.0},
                            {0.5, 1.0},
                            {1.0, 0.0}
                            })},
                        {10.0, EvalLPF(ammo, {
                            {0.0, 20.0},
                            {0.1, 1.0},
                            {1.0, 0.0}
                            })}
                        })
            end
        end

        return { name = name, weight = weight,
                perform = function(move)
                    PerformMove( pos, bestPack:GetOrigin(), bot, brain, move )
                end }
    end,

    function(bot, brain)

        local name = "reload"

        local marine = bot:GetPlayer()
        local weapon = marine:GetActiveWeapon()
        local s = brain:GetSenses()
        local weight = 0.0
        local threat 
        
        if weapon ~= nil and weapon:isa("ClipWeapon") and s:Get("ammoFraction") > 0.0 then

            threat = s:Get("biggestThreat")

            if threat ~= nil and threat.distance < 15 and 
                (s:Get("clipFraction") > 0.0 or s:Get('pistolClipFraction') > 0 ) then
                -- threat really close, and we have some ammo or a backup weapon, shoot it!
                weight = 0.01
            else
                weight = EvalLPF( s:Get("clipFraction"), {
                        { 0.0 , 8 } , 
                        { 0.6 , 0 }  , 
                        { 1.0 , 0 }
                        })
            end
        end

        return { name = name, weight = weight,
            perform = function(move)
            
                if threat then
                
                    local target = Shared.GetEntity(threat.memory.entId)
                    -- move away from biggest threat
                    if target and target:isa("Player") then
                        bot:GetMotion():SetDesiredMoveDirection(bot:GetPlayer():GetOrigin() - target:GetOrigin())
                        bot:GetMotion():SetDesiredViewTarget( target:GetEngagementPoint() )
                    end
                end
                if weapon:isa("ClipWeapon") and weapon:GetClip() / weapon:GetClipSize() > 0.9 then
                    SwitchToPrimary(marine)
                end
                move.commands = AddMoveCommand(move.commands, Move.Reload)
            end }
    end,

    function(bot, brain)

        local name = "attack"

        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local threat = sdb:Get("biggestThreat")
        local weight = 0.0

        if threat ~= nil and sdb:Get("weaponOrPistolReady") then

            weight = EvalLPF( threat.distance, {
                        { 0.0, EvalLPF( threat.urgency, {
                            {0, 0},
                            {10, 25}
                            })},
                        { 10.0, EvalLPF( threat.urgency, {
                            {0, 0},
                            {10, 5} })},
                        -- Never let it drop too low - ie. keep it always above explore
                        { 50.0, 0.06 } })
            

            weight = weight + weight * bot.aggroAbility
        end


        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
            
                local target = Shared.GetEntity(threat.memory.entId)
                if sdb:Get("clipFraction") > 0.0 or not target:isa("Player") then
                    SwitchToPrimary(marine)
                else
                    SwitchToPistol(marine)
                end
                
                PerformAttack( marine:GetEyePos(), threat.memory, bot, brain, move )
            end }
    end,
    
    function(bot, brain)

        local name = "getWelder"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0
        local weldData = sdb:Get("nearestWeldable")
        local weldTarget = weldData.target
        local weldDist = weldData.distance
        local armoryData = sdb:Get("nearestArmory")
        local armory = armoryData.armory
        local armoryDist = armoryData.distance
        
        local resources = marine:GetResources()
        
        if not sdb:Get("welder") and
            (brain.wantsWelder or 
             (weldTarget and armory and 
              weldDist + armoryDist < 30 and 
              resources >= LookupTechData(kTechId.Welder, kTechDataCostKey)) 
            ) then
            
            weight = 2.0 + bot.helpAbility
            
        end
        
        
        return { name = name, weight = weight,
            perform = function(move)

                if armory then
                    brain.wantsWelder = true

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), armory )
                    if touchDist > 1.5 then
                        PerformMove( marine:GetOrigin(), armory:GetEngagementPoint(), bot, brain, move )
                    else
                    
                        -- Buy the weapon!
                        brain.buyTargetId = nil
                        bot:GetMotion():SetDesiredViewTarget( armory:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                        bot:GetPlayer():ProcessBuyAction({ kTechId.Welder })
                        
                    end
                end

            end }

    end,
    
    function(bot, brain)

        local name = "weld"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0
        local weldData = sdb:Get("nearestWeldable")
        local weldTarget = weldData.target
        local weldDist = weldData.distance

        if sdb:Get("welder") ~= nil and weldTarget ~= nil then
            
            local numOthers = brain.teamBrain:GetNumOthersAssignedToEntity( weldTarget:GetId(), bot )
            if numOthers == nil or numOthers < 1 then
                weight = EvalLPF( weldDist, {
                        {0.0, 0.4},
                        {5.0, 0.4},
                        {10.0, 0.2},
                        {25.0, 0.0}
                        })
                        
                weight = weight + weight * bot.helpAbility
                        
                if weldTarget:isa("Exo") or weldTarget:isa("Exosuit") then
                    weight = weight * 2
                end
                if sdb:Get("welderReady") then
                    weight = weight * 2
                end
            end
        end

        return { name = name, weight = weight, 
            perform = function(move)
                if weldTarget then
                    
                    brain.teamBrain:UnassignBot(bot)
                    brain.teamBrain:AssignBotToEntity( bot, weldTarget:GetId() )
                    
                    if not sdb:Get("welderReady") then
                        -- switch to welder
                        marine:SetActiveWeapon( Welder.kMapName, true )
                    else
                        PerformWeld( marine, weldTarget, bot, brain , move )
                        -- PerformAttackEntity( marine:GetEyePos(), target, target:GetOrigin(), bot, brain, move )
                    end
                end

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

                -- Because construct orders are often given by the auto-system, do not necessarily obey them
                -- Load-balance them
                local numOthers = teamBrain:GetNumOthersAssignedToEntity( targetId, bot )
                if numOthers >= 1 then
                    weight = 0.0
                else
                    weight = 2.0
                end

            else

                -- Could be attack, weld, etc.
                weight = 3.0

            end

        end
        
        weight = weight + weight * bot.helpAbility
        
        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
                if order then

                    brain.teamBrain:UnassignBot(bot)


                    local target = Shared.GetEntity(order:GetParam())

                    if target ~= nil and order:GetType() == kTechId.Attack then

                        brain.teamBrain:AssignBotToEntity( bot, target:GetId() )
                        PerformAttackEntity( marine:GetEyePos(), target, order:GetLocation(), bot, brain, move )

                    elseif target ~= nil and GetIsUseOrder(order) then

                        brain.teamBrain:AssignBotToEntity( bot, target:GetId() )
                        PerformUse( marine, target, bot, brain , move )

                    elseif order:GetType() == kTechId.Move then

                        PerformMove( marine:GetOrigin(), order:GetLocation(), bot, brain, move )

                    else

                        DebugPrint("unknown order type: %d", order:GetType())
                        PerformMove( marine:GetOrigin(), order:GetLocation(), bot, brain, move )

                    end
                end
            end }
    end,
    
    
    function(bot, brain)

        local name = "repairpower"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0
        local powerInfo = sdb:Get("nearestPower")
        local powernode = powerInfo.entity

        
        if powernode ~= nil and
            not powernode:GetIsPowering() and
            powernode:IsPoweringFriendlyTo(marine) then

            local numOthers = brain.teamBrain:GetNumOthersAssignedToEntity( powernode:GetId(), bot )
            if numOthers >= 2 then
                weight = 0.7
            else
                weight = 3.1 -- should be higher than construct..
            end
        end
        
        weight = weight + weight * bot.helpAbility

        return { name = name, weight = weight,
            perform = function(move)

                if powernode then
        
                    brain.teamBrain:UnassignBot(bot)
                    brain.teamBrain:AssignBotToEntity( bot, powernode:GetId() )
                    
                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), powernode )
                    if touchDist > 1.5 then
                        move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                        PerformMove( marine:GetOrigin(), powernode:GetEngagementPoint(), bot, brain, move )
                    else
                        PerformUse( marine, powernode, bot, brain , move )
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
        local minFraction = math.min( sdb:Get("healthFraction"), sdb:Get("ammoFraction") )

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
                    { 0.0, 1.0 },
                    { 0.3, 0.0 },
                    { 1.0, 0.0 }
                    })
        end

        return { name = name, weight = weight,
            perform = function(move)
                if armory ~= nil then

                    -- we are retreating, unassign ourselves from anything else, e.g. attack targets
                    brain.teamBrain:UnassignBot(bot)

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), armory )
                    if touchDist > 1.5 then
                        if brain.debug then DebugPrint("going towards armory at %s", ToString(armory:GetEngagementPoint())) end
                        PerformMove( marine:GetOrigin(), armory:GetEngagementPoint(), bot, brain, move )
                        move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                    else
                        -- sit and wait to heal, ammo, etc.
                        brain.retreatTargetId = nil
                        bot:GetMotion():SetDesiredViewTarget( armory:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                    end
                end

            end }

    end,

    function(bot, brain)

        local name = "clearCyst"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0

        if sdb:Get("attackNearestCyst") then
            weight = 0.5
        else
            weight = 0.0
        end

        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
                    local cyst = sdb:Get("nearestCyst")
                    assert(cyst ~= nil)
                    assert(cyst.entity ~= nil)
                    SwitchToPrimary(marine)
                    PerformAttackEntity( marine:GetEyePos(), cyst.entity, cyst.entity:GetEngagementPoint(), bot, brain, move )
            end }

    end,

    function(bot, brain)

        local name = "clearBabblers"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0

        local babblerData = sdb:Get("nearestBabbler")
        
        if babblerData and babblerData.entity then
            local babblerPos = babblerData.entity:GetOrigin()
            
            local dist = babblerPos:GetDistance(marine:GetOrigin())
            
            weight = EvalLPF( dist, {
                    {0.0, 3.5},
                    {3.0, 1.0},
                    {5.0, 1.0},
                    {15.0, 0.0}
                    })
        end
        

        return { name = name, weight = weight, fastUpdate = true,
            perform = function(move)
                if babblerData and babblerData.entity then
                    local babbler = babblerData.entity
                    SwitchToPrimary(marine)
                    PerformAttackEntity(marine:GetEyePos(), babbler, babbler:GetEngagementPoint(), bot, brain, move )
                end
            end
            }

    end,
    
    function(bot, brain)

        local name = "buyWeapon"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local armory = sdb:Get("nearestArmory").armory
        local armoryDist = sdb:Get("nearestArmory").distance
        
        -- Find all the weapons available for purchase.
        local availableWeapons = { }
        local weapons = enum({
            kTechId.HeavyMachineGun,
            kTechId.Shotgun,
            kTechId.Flamethrower,
            kTechId.GrenadeLauncher,
        })

        --Update this with techtree updates
        local weaponTechs = {
            [kTechId.Shotgun] = kTechId.ShotgunTech,
            [kTechId.Flamethrower] = kTechId.AdvancedWeaponry,
            [kTechId.GrenadeLauncher] = kTechId.AdvancedWeaponry,
            [kTechId.HeavyMachineGun] = kTechId.HeavyMachineGunTech,
        }

        local techTree = GetTechTree(marine:GetTeamNumber())
        if techTree then
            for _, weaponTechId in ipairs(weapons) do
                if techTree:GetHasTech(weaponTechs[weaponTechId], true) then
                    availableWeapons[#availableWeapons + 1] = weaponTechId
                    availableWeapons[weaponTechId] = true
                end
            end
        end
        
        -- Figure out if we have a good enough weapon.
        local bestWeaponTechId
        local weapons = marine:GetHUDOrderedWeaponList()
        for w = 1, #weapons do
        
            local weapon = weapons[w]
            local weaponTechId = weapon:GetTechId()
            bestWeaponTechId = bestWeaponTechId or weaponTechId
            -- As long as we have one of the availableWeapons for purchase, we are content.
            if availableWeapons[weaponTechId] then
            
                bestWeaponTechId = weaponTechId
                break
                
            end
            
        end
        
        -- See if the Marine can afford anything.
        local resources = marine:GetResources()
        
        if not bot.decidedIfSavingForExo then
            bot.decidedIfSavingForExo = true
            bot.wantsExo = math.random() < 0.4
        end
        
        if bot.wantsExo then
            -- always try to reserve enough for an exo
            resources = resources - LookupTechData(kTechId.DualMinigunExosuit, kTechDataCostKey)
        end
        
        local canAffordWeaponTechId
        for _, techId in ipairs(availableWeapons) do
            
            if resources >= LookupTechData(techId, kTechDataCostKey) then
            
                canAffordWeaponTechId = techId
                --Continue checking the other weapons with a 50% chance each
                if math.random() > 0.5 then
                    break
                end
                
            end
            
        end
        
        local wantNewWeapon = not availableWeapons[bestWeaponTechId] and canAffordWeaponTechId

        local weight = 0.0
        if armory and wantNewWeapon then
            weight = EvalLPF( armoryDist, {
                    {0.0, 20.0},
                    {3.0, 10.0},
                    {5.0, 1.0},
                    {10.0, 0.2}
                    })
        end
        
        return { name = name, weight = weight,
            perform = function(move)

                if armory then

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), armory )
                    if touchDist > 1.5 then
                        if brain.debug then DebugPrint("going towards armory at %s", ToString(armory:GetEngagementPoint())) end
                        PerformMove( marine:GetOrigin(), armory:GetEngagementPoint(), bot, brain, move )
                        move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                    else
                    
                        -- Buy the weapon!
                        brain.buyTargetId = nil
                        bot:GetMotion():SetDesiredViewTarget( armory:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                        bot:GetPlayer():ProcessBuyAction({ canAffordWeaponTechId })
                        
                    end
                end

            end }

    end,
    
    
    function(bot, brain)

        local name = "buyExo"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local data = sdb:Get("nearestProto")
        local proto = data.proto
        local protoDist = data.distance
        local weight = 0.0
        local resources = marine:GetResources()
        
        local techTree = GetTechTree(marine:GetTeamNumber())
        
        if not HasGoodWeapon(marine) and
            techTree:GetHasTech(kTechId.ExosuitTech, true) and 
            resources >= LookupTechData(kTechId.DualMinigunExosuit, kTechDataCostKey) then
            weight = EvalLPF( protoDist, {
                    {0.0, 10.0},
                    {3.0, 5.0},
                    {5.0, 1.0},
                    {10.0, 0.2}
                    })
            if bot.wantsExo then
                weight = weight * 5 -- gimme gimme gimme
            end
        end
        
        return { name = name, weight = weight,
            perform = function(move)

                if proto then

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), proto )
                    if touchDist > 1.5 then
                        --bot:SendTeamMessage("I really want an Exosuit!", 120)
                        PerformMove( marine:GetOrigin(), proto:GetEngagementPoint(), bot, brain, move )
                        move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                    else
                    
                        -- Buy the exo!
                        brain.buyTargetId = nil
                        bot:GetMotion():SetDesiredViewTarget( proto:GetEngagementPoint() )
                        
                        -- this is a hack because you can't buy an exo if there's a jetpack at your feet
                        bot:GetMotion():SetDesiredMoveTarget( proto:GetEngagementPoint() )
                        bot:GetPlayer():ProcessBuyAction({ kTechId.DualMinigunExosuit })
                        
                    end
                end

            end }

    end,
    
    function(bot, brain)

        local name = "useExo"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local data = sdb:Get("nearestExo")
        local exo = data.exo
        local exoDist = data.distance
        local weight = 0.0
        
        
        if exo and not HasGoodWeapon(marine) then
            weight = EvalLPF( exoDist, {
                    {0.0, 20.0},
                    {3.0, 10.0},
                    {5.0, 5.0},
                    {20.0, 0.2}
                    })
        end
        
        return { name = name, weight = weight,
            perform = function(move)

                if exo then

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), exo )
                    if touchDist > 1.0 then
                        PerformMove( marine:GetOrigin(), exo:GetEngagementPoint(), bot, brain, move )
                    else
                    
                        -- Buy the weapon!
                        brain.buyTargetId = nil
                        bot:GetMotion():SetDesiredViewTarget( exo:GetEngagementPoint() )
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                        move.commands = AddMoveCommand(move.commands, Move.Use)
                        
                    end
                end

            end }

    end,

    function(bot, brain)

        local name = "guardHumans"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0


        local targetData = sdb:Get("nearestHuman")
        local target = targetData.player
        local dist = targetData.distance
        
        if target and dist < 15 then
            local targetId = target:GetId()
            if targetId then
                local numOthers = brain.teamBrain:GetNumOthersAssignedToEntity( targetId, bot )
                if (numOthers == nil) or numOthers >= 1 then
                    weight = 0.0
                else
                    weight = 0.20 --  above buildThings
                end
            end
        end
        
        weight = weight + weight * bot.helpAbility

        return { name = name, weight = weight,
            perform = function(move)
                if target then 
                
                    SwitchToPrimary(marine)
                    brain.teamBrain:UnassignBot(bot)
                    brain.teamBrain:AssignBotToEntity( bot, target:GetId() )

                    local touchDist = GetDistanceToTouch( marine:GetEyePos(), target )
                    if touchDist > 5.0 then
                        PerformMove( marine:GetOrigin(), target:GetEngagementPoint(), bot, brain, move )
                    else
                        bot:GetMotion():SetDesiredMoveTarget( nil )
                        if not bot.lastLookAround or bot.lastLookAround + 2 < Shared.GetTime() then
                            bot.lastLookAround = Shared.GetTime()
                            local viewTarget = GetRandomDirXZ()
                            viewTarget.y = math.random()
                            viewTarget:Normalize()
                            bot.lastLookTarget = marine:GetEyePos()+viewTarget*30
                        end
                        if bot.lastLookTarget then
                            bot:GetMotion():SetDesiredViewTarget(bot.lastLookTarget)
                        end
                        if (not bot.lastCoveringTime or bot.lastCoveringTime < Shared.GetTime() - 120) and target:isa("Player") then
                            CreateVoiceMessage( bot:GetPlayer(), kVoiceId.MarineCovering )
                            bot.lastCoveringTime = Shared.GetTime()
                        end
                        
                    end
                    
                    
                end
            end }
    end,
    
    
    function(bot, brain)

        local name = "buildThings"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0


        local targetData = sdb:Get("nearestBuildable")
        local target = targetData.target
        local dist = targetData.distance
        
        if target then
            local targetId = target:GetId()
            if targetId then
                local numOthers = brain.teamBrain:GetNumOthersAssignedToEntity( targetId, bot )
                if (numOthers == nil) or numOthers >= 1 then
                    weight = 0.0
                else
                    weight = 0.06 -- slighty above explore
                end
            end
        end
        
        weight = weight + weight * bot.helpAbility

        return { name = name, weight = weight,
            perform = function(move)
                if target then 
                    brain.teamBrain:UnassignBot(bot)
                    brain.teamBrain:AssignBotToEntity( bot, target:GetId() )
                    PerformUse( marine, target, bot, brain , move )
                    bot:SendTeamMessage("I'll build the " .. target:GetMapName() .. " in " .. target:GetLocationName(), 120)
                    move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
                end
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
            move.commands = AddMoveCommand( move.commands, Move.MovementModifier )
            end ),

    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        return { name = "debug idle", weight = 0.01,
                perform = function(move)
                    -- Do a jump..for fun
                    move.commands = AddMoveCommand(move.commands, Move.Jump)
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
        [kMinimapBlipType.SentryBattery] = numOthers >= 2  and 0.2 or 0.95,
        [kMinimapBlipType.Hive] = numOthers >= 6           and 0.5 or 0.9,
        [kMinimapBlipType.Harvester] = numOthers >= 2      and 0.4 or 0.9,
        [kMinimapBlipType.Egg] = numOthers >= 1            and 0.2 or 0.5,
        [kMinimapBlipType.Shade] = numOthers >= 2          and 0.2 or 0.5,
        [kMinimapBlipType.Shift] = numOthers >= 2          and 0.2 or 0.5,
        [kMinimapBlipType.Shell] = numOthers >= 2          and 0.2 or 0.5,
        [kMinimapBlipType.Veil] = numOthers >= 2           and 0.2 or 0.5,
        [kMinimapBlipType.Spur] = numOthers >= 2           and 0.2 or 0.5,
        [kMinimapBlipType.TunnelEntrance] = numOthers >= 1 and 0.2 or 0.5,
        -- from skulk
        [kMinimapBlipType.ARC] =                numOthers >= 2 and 0.4 or 0.9,
        [kMinimapBlipType.CommandStation] =     numOthers >= 4 and 0.3 or 0.85,
        [kMinimapBlipType.PhaseGate] =          numOthers >= 2 and 0.2 or 0.9,
        [kMinimapBlipType.Observatory] =        numOthers >= 2 and 0.2 or 0.8,
        [kMinimapBlipType.Extractor] =          numOthers >= 2 and 0.2 or 0.9,
        [kMinimapBlipType.InfantryPortal] =     numOthers >= 2 and 0.2 or 0.6,
        [kMinimapBlipType.PrototypeLab] =       numOthers >= 1 and 0.2 or 0.55,
        [kMinimapBlipType.Armory] =             numOthers >= 2 and 0.2 or 0.5,
        [kMinimapBlipType.RoboticsFactory] =    numOthers >= 2 and 0.2 or 0.5,
        [kMinimapBlipType.ArmsLab] =            numOthers >= 3 and 0.2 or 0.6,
        [kMinimapBlipType.MAC] =                numOthers >= 1 and 0.2 or 0.4,
    }
    
    if table.contains(kMinimapBlipType, "HadesDevice") then
        passiveUrgencies[kMinimapBlipType.HadesDevice] = numOthers >= 2  and 0.2 or 0.95
    end

    if bot.brain.debug then
        if mem.btype == kMinimapBlipType.Hive then
            Print("got Hive, urgency = %f", passiveUrgencies[mem.btype])
        end
    end
    

    if passiveUrgencies[ mem.btype ] ~= nil then
        -- ignore blueprints unless extractors or ccs, since those block your team
        if target.GetIsGhostStructure and target:GetIsGhostStructure() and 
            (mem.btype ~= kMinimapBlipType.Extractor and mem.btype ~= kMinimapBlipType.CommandStation) then
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
            [kMinimapBlipType.Marine] = numOthers >= 2 and 0.1 or 6.0,
            [kMinimapBlipType.JetpackMarine] = numOthers >= 2 and 0.1 or 5.0,
            [kMinimapBlipType.Exo] =  numOthers >= 4  and 0.1 or 4.0,
            [kMinimapBlipType.Sentry]  = numOthers >= 2   and 0.1 or 5.0
        }
        if table.contains(kMinimapBlipType, "Prowler") then
            activeUrgencies[kMinimapBlipType.Prowler] = numOthers >= 2 and 0.1 or 4.0
        end
        
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

function CreateMarineBrainSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("clipFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetWeaponInHUDSlot(1)
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
        
    s:Add("pistolClipFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetWeapon(Pistol.kMapName)
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
            local weapon = marine:GetWeaponInHUDSlot(1)
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

    s:Add("pistolAmmoFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetWeapon(Pistol.kMapName)
            if weapon ~= nil then
                if weapon:isa("ClipWeapon") then
                    return weapon:GetAmmo() / weapon:GetMaxAmmo()
                else
                    return 0.0
                end
            else
                return 0.0
            end
        end
        )
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

    s:Add("weaponOrPistolReady", function(db)
            return db:Get("ammoFraction") > 0 or db:Get("pistolAmmoFraction") > 0
            end)
            
    s:Add("healthFraction", function(db)
            local marine = db.bot:GetPlayer()
            return marine:GetHealthFraction()
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
                --dist = marine:GetEyePos():GetDistance(maxMem.lastSeenPos)
                
                local dist, gate = GetPhaseDistanceForMarine( marine, maxMem.lastSeenPos, db.bot.brain.lastGateId )
                return {urgency = maxUrgency, memory = maxMem, distance = dist}
            else
                return nil
            end
            end)

    s:Add("nearestArmory", function(db)

            local marine = db.bot:GetPlayer()
            local armories = GetEntitiesForTeam( "Armory", marine:GetTeamNumber() )

            local dist, armory = GetMinTableEntry( armories,
                function(armory)
                    assert( armory ~= nil )
                    if armory:GetIsBuilt() and armory:GetIsPowered() then
                        local dist,_ = GetPhaseDistanceForMarine( marine, armory:GetOrigin(), db.bot.brain.lastGateId )

                        -- Weigh our previous nearest a bit better, to prevent thrashing
                        if armory:GetId() == db.lastNearestArmoryId then
                            return dist * 0.9
                        else
                            return dist
                        end
                    end
                end)

            if armory ~= nil then db.lastNearestArmoryId = armory:GetId() end
            return {armory = armory, distance = dist}

            end)
            
    s:Add("nearestHuman", function(db)

            local marine = db.bot:GetPlayer()
            local players = GetEntitiesForTeam( "Player", marine:GetTeamNumber() )

            local dist, player = GetMinTableEntry( players,
                function(player)
                    assert( player ~= nil )
                    if not player.is_a_robot  then
                        local dist,_ = GetPhaseDistanceForMarine( marine, player:GetOrigin(), db.bot.brain.lastGateId )

                        return dist
                    end
                end)

            return {player = player, distance = dist}

            end)
            
    s:Add("nearestProto", function(db)

            local marine = db.bot:GetPlayer()
            local protos = GetEntitiesForTeam( "PrototypeLab", marine:GetTeamNumber() )

            local dist, proto = GetMinTableEntry( protos,
                function(proto)
                    assert( proto ~= nil )
                    if proto:GetIsBuilt() and proto:GetIsPowered() then
                        local dist,_ = GetPhaseDistanceForMarine( marine, proto:GetOrigin(), db.bot.brain.lastGateId )

                        -- Weigh our previous nearest a bit better, to prevent thrashing
                        if proto:GetId() == db.lastNearestProtoId then
                            return dist * 0.9
                        else
                            return dist
                        end
                    end
                end)

            if proto ~= nil then db.lastNearestProtoId = proto:GetId() end
            return {proto = proto, distance = dist}

            end)
    s:Add("nearestExo", function(db)

            local marine = db.bot:GetPlayer()
            local exos = GetEntitiesForTeam( "Exosuit", marine:GetTeamNumber())

            local dist, exo = GetMinTableEntry( exos,
                function(exo)
                    assert( exo ~= nil )
                    if exo:GetIsValidRecipient(marine) and exo:GetHealthScalar() > 0.8 then
                        local dist,_ = GetPhaseDistanceForMarine( marine, exo:GetOrigin(), db.bot.brain.lastGateId )

                        -- Weigh our previous nearest a bit better, to prevent thrashing
                        if exo:GetId() == db.lastNearestExoId then
                            return dist * 0.9
                        else
                            return dist
                        end
                    end
                end)

            if exo ~= nil then db.lastNearestExoId = exo:GetId() end
            return {exo = exo, distance = dist}

            end)

    s:Add("nearestPower", function(db)

            local marine = db.bot:GetPlayer()
            local marinePos = marine:GetOrigin()
            local powers = GetEntities( "PowerPoint" )

            local dist, power = GetMinTableEntry( powers,
                function(power)
                    return marinePos:GetDistance( power:GetOrigin() )
                end)

            return {entity = power, distance = dist}
            end)

    s:Add("nearestWeldable", function(db)

            local marine = db.bot:GetPlayer()
            local targets = GetEntitiesWithMixinForTeamWithinRange( "Weldable", marine:GetTeamNumber(), marine:GetOrigin(), 20.0 )

            local dist, target = GetMinTableEntry( targets,
                function(target)
                    assert( target ~= nil )
                    if target~= marine and target:GetCanBeWelded(marine) and 
                        (not target.GetIsBuilt or target:GetIsBuilt()) then
                        return marine:GetOrigin():GetDistance( target:GetOrigin() )
                    end
                end)

            return {target = target, distance = dist}

            end)
            
    s:Add("nearestBuildable", function(db)

            local marine = db.bot:GetPlayer()
            local targets = (GetEntitiesWithMixinForTeam("Construct", marine:GetTeamNumber()))

            local dist, target = GetMinTableEntry( targets,
                function(target)
                    assert( target ~= nil )
                    if not target:GetIsBuilt() then
                        local dist,_ = GetPhaseDistanceForMarine( marine, target:GetOrigin(), db.bot.brain.lastGateId )
                        return dist
                    end
                end)

            return {target = target, distance = dist}

            end)

    s:Add("nearestCyst", function(db)

            local marine = db.bot:GetPlayer()
            local marinePos = marine:GetOrigin()
            local cysts = GetEntitiesWithinRange("Cyst", marinePos, 25)

            local dist, cyst = GetMinTableEntry( cysts, function(cyst)
                if cyst:GetIsSighted() then
                    return marinePos:GetDistance( cyst:GetOrigin() )
                end
                return nil
                end)

            return {entity = cyst, distance = dist}
            end)
            
    s:Add("nearestBabbler", function(db)

            local marine = db.bot:GetPlayer()
            local marinePos = marine:GetOrigin()
            local babblers = GetEntitiesWithinRange("Babbler", marinePos, 15)

            local dist, babbler = GetMinTableEntry( babblers, function(babbler)
                -- TODO: Make sure we can see it...
                return marinePos:GetDistance( babbler:GetOrigin() )
            end)

            return {entity = babbler, distance = dist}
            end)

    s:Add("attackNearestCyst", function(db)
    
            local marine = db.bot:GetPlayer()
            local cyst = db:Get("nearestCyst")
            local power = db:Get("nearestPower")
            if cyst.entity ~= nil and power.entity ~= nil and power.entity:GetIsBuilt() then
                local cystPos = cyst.entity:GetOrigin()
                local powerPos = power.entity:GetOrigin()
                --DebugLine( cystPos, powerPos, 0.0, 1,1,0,1,  true )
                return cystPos:GetDistance(powerPos) < 15 or cystPos:GetDistance(marine:GetOrigin()) < 5
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
