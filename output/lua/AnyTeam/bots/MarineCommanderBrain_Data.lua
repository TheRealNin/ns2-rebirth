Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kStationBuildDist = 15.0
local kPhaseBuildDist = 25.0
local kBeaconNearbyDist = 20.0
local kBeaconNearbyFriendlyDist = 25.0

local function CreateBuildNearStationAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureAction(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "CommandStation",
            kStationBuildDist )
end
local function CreateBuildNearEachStationAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureActionForEach(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "CommandStation",
            kStationBuildDist )
end
local function CreateBuildNearControlledTechpointAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureActionNearTechpoints(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            } )
end
local function CreateBuildNearEachPhaseAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureActionForEach(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "PhaseGate",
            kPhaseBuildDist )
end


kMarineComBrainActions =
{
    CreateBuildNearStationAction( kTechId.Armory         , "Armory"         , 1 , 3+math.random() ),
    CreateBuildNearStationAction( kTechId.Observatory    , "Observatory"    , 1 , 1.5+math.random() ) ,
    CreateBuildNearStationAction( kTechId.ArmsLab        , "ArmsLab"        , 1 , 3+math.random() ) ,
    CreateBuildNearStationAction( kTechId.PrototypeLab   , "PrototypeLab"   , 1 , 2+math.random() ) ,
    
    CreateBuildNearEachStationAction( kTechId.InfantryPortal  , "InfantryPortal"      , 1 , 0.8 ) ,
    CreateBuildNearEachStationAction( kTechId.PhaseGate  , "PhaseGate"      , 1 , 3 ) ,
    CreateBuildNearEachStationAction( kTechId.Observatory, "Observatory"      , 1 , 3 ) ,

    CreateBuildNearControlledTechpointAction( kTechId.PhaseGate      , "PhaseGate"      , 1 , 3 ) ,
    CreateBuildNearEachPhaseAction( kTechId.Armory         , "Armory"         , 1 , 0.8 ),
    CreateBuildNearEachPhaseAction( kTechId.Observatory    , "Observatory"    , 1 , 1.2 ),
    
    -- Upgrades from structures
    CreateUpgradeStructureAction( kTechId.ShotgunTech           , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.JetpackTech           , 2.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.ExosuitTech           , 2.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.MinesTech             , 0.5+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.AdvancedArmoryUpgrade , 1.0+math.random(), kTechId.AdvancedArmoryUpgrade) , -- TODO: Make it so only ONE armory gets this
    CreateUpgradeStructureAction( kTechId.HeavyMachineGunTech   , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.GrenadeTech           , 1.0+math.random() ) ,

    CreateUpgradeStructureAction( kTechId.PhaseTech , 3.0+math.random()), -- you have a phase gate - research this!!

    CreateUpgradeStructureAction( kTechId.Weapons1 , 2.5+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Weapons2 , 1.75+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Weapons3 , 1.5+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Armor1   , 4.0 ) , -- you have an arms lab, research this!
    CreateUpgradeStructureAction( kTechId.Armor2   , 2.5+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Armor3   , 1.5+math.random() ) ,
    
    --CreateUpgradeStructureAction( kTechId.PowerSurgeTech , 0.05 ), -- TODO: Fix this immediatly always researching
    CreateUpgradeStructureAction( kTechId.CatPackTech    , 0.01 ),
    CreateUpgradeStructureAction( kTechId.NanoShieldTech , 0.01 ),

    function(bot, brain)

        local name = "commandstation"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetTP

        -- Find a cc slot
        targetTP = sdb:Get("techPointToTake")

        if targetTP and doables[kTechId.CommandStation] and (not bot.nextCCDrop or bot.nextCCDrop < Shared.GetTime()) then
            local ccs = GetEntitiesForTeam("CommandStation", com:GetTeamNumber())
            weight = EvalLPF( #ccs,
                {
                {1, 0.2},
                {2, 0.1},
                {3, 0.05},
                })
            if #ccs <= 1 then
                -- check if the health is super low
                if ccs[1]:GetHealthScalar() < 0.5 then
                    weight = 5
                end
            end
        end
        
        if (sdb:Get("gameMinutes") < 4) then
            weight = 0
        end

        return { name = name, weight = weight,
            perform = function(move)
                if doables[kTechId.CommandStation] and targetTP then
                    local sucess = brain:ExecuteTechId( com, kTechId.CommandStation, targetTP:GetOrigin(), com )
                    if sucess then
                        bot.nextCCDrop = Shared.GetTime() + 5
                    end
                end
            end}
    end,
    
    function(bot, brain)

        local name = "beacon"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local obsToUse
        
        local blipUrgency = {
            [kMinimapBlipType.Skulk] = 1,
            [kMinimapBlipType.SensorBlip] = 1,
            [kMinimapBlipType.Gorge] = 3,
            [kMinimapBlipType.Lerk] = 1,
            [kMinimapBlipType.Fade] = 0.5,
            [kMinimapBlipType.Onos] = 2,
            [kMinimapBlipType.Marine] = 1.5,
            [kMinimapBlipType.JetpackMarine] = 1,
            [kMinimapBlipType.Exo] = 3
        }
        if table.contains(kMinimapBlipType, "Prowler") then
            blipUrgency[kMinimapBlipType.Prowler] = 1
        end

        if doables[kTechId.DistressBeacon] and (not bot.nextBeaconTime or bot.nextBeaconTime < Shared.GetTime()) then
            local ccs = sdb:Get("stations")
            local memories = GetTeamMemories( com:GetTeamNumber() )
            for _,cc in ipairs(ccs) do
                if cc:GetIsBuilt() and cc:GetIsAlive() then
                    local newWeight = 0
                    local enemyWeight = 0
                    local friendlyWeight = #GetEntitiesForTeamWithinRange("Player", com:GetTeamNumber(), cc:GetOrigin(), kBeaconNearbyFriendlyDist)
                    for _,mem in ipairs(memories) do
                        local target = Shared.GetEntity(mem.entId)
                        if HasMixin(target, "Live") and target:GetIsAlive() and com:GetTeamNumber() ~= target:GetTeamNumber() then
                            local dist = cc:GetOrigin():GetDistance( mem.lastSeenPos )
                            if dist < kBeaconNearbyDist and blipUrgency[mem.btype] ~= nil then
                                enemyWeight = enemyWeight + blipUrgency[mem.btype]
                            end
                        end
                    end
                    if #ccs == 1 then
                        -- increase the threat level if we only have 1 CC and it has low health
                        enemyWeight = enemyWeight + enemyWeight * (1 - cc:GetHealthFraction()) * 4.0
                    end
                    newWeight = EvalLPF( enemyWeight/(friendlyWeight+1),
                        {
                        {0, 0.0},
                        {1, 0.0},
                        {2, 10.0},
                        })
                    
                    if newWeight > weight then
                        
                        local observatories = GetEntitiesForTeam("Observatory", com:GetTeamNumber())
                        Shared.SortEntitiesByDistance(com:GetOrigin(), observatories)
                        
                        for _, obs in ipairs(observatories) do
                            
                            if GetIsUnitActive(obs) then
                                local nearest = GetNearest(obs:GetOrigin(), "CommandStation", com:GetTeamNumber(), function(ent) return ent:GetIsBuilt() and ent:GetIsAlive() end)
                                if nearest == cc then
                                    obsToUse = obs
                                    weight = newWeight
                                    break
                                end
                            end
                        
                        end
                    end
                end
            end
        end
        --[[
        if (sdb:Get("gameMinutes") < 1) then
            weight = 0
        end
        --]]

        return { name = name, weight = weight,
            perform = function(move)
                if doables[kTechId.DistressBeacon] and obsToUse then
                    local sucess = brain:ExecuteTechId( com, kTechId.DistressBeacon, Vector(0,0,0), obsToUse )
                    if sucess then
                        bot.nextBeaconTime = Shared.GetTime() + 20
                    end
                end
            end}
    end,
    
    function(bot, brain)

        local weight = 0
        local team = bot:GetPlayer():GetTeam()
        local numDead = team:GetNumPlayersInQueue()
        if numDead > 1 then
            weight = 5.0
        end

        return CreateBuildNearStationAction( kTechId.InfantryPortal , "InfantryPortal" , 3 , weight )(bot, brain)
    end,
    
    function(bot, brain)

        local name = "dropjetpacks"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0
        local maxJetpacks = 10
        local team = bot:GetPlayer():GetTeam()
        
        local jetpacks = GetEntitiesForTeam("Jetpack", bot:GetPlayer():GetTeamNumber())
        
        local doables = sdb:Get("doableTechIds")
        if doables[kTechId.DropJetpack] then
            weight = EvalLPF( #jetpacks,
                    {
                    {0, 0.6},
                    {1, 0.1},
                    {10,0.0},
                    })
        end
        
        if #jetpacks > maxJetpacks then 
            weight = 0
        end
        
        local protoLabs = GetEntitiesForTeam("PrototypeLab", bot:GetPlayer():GetTeamNumber())
        if #protoLabs <= 0 then 
            weight = 0
        end
        local proto = protoLabs[math.random(#protoLabs)]
        if not proto or not proto:GetIsBuilt() or not proto:GetIsAlive() then
            weight = 0
        end
        
        return { name = name, weight = weight,
            perform = function(move)
                
                --if (sdb:Get("gameMinutes") < 5) then
                --    return
                --end
                local aroundPos = proto:GetOrigin()
                
                local targetPos = GetRandomSpawnForCapsule(0.4, 0.4, aroundPos, 0.01, kArmoryWeaponAttachRange * 0.5, EntityFilterAll(), nil)
                if targetPos then
                    local sucess = brain:ExecuteTechId(com, kTechId.DropJetpack, targetPos, com, proto:GetId())
                end
            end}
    end,

    function(bot, brain)

        local name = "extractor"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetRP

        if doables[kTechId.Extractor] then

            targetRP = sdb:Get("resPointToTake")
            local numExtractors = sdb:Get("numExtractors")

            if targetRP ~= nil then
                weight = EvalLPF(numExtractors,
                    {
                        {0, 10.0},
                        {1, 6.0},
                        {2, 4.0},
                        {3, 3.0},
                        {4, 2.0},
                        {5, 1.5},
                        {6, 1.0},
                        })

            end
            
            local data = sdb:Get("resPointWithNearbyMarines")
            local marineRP = data.rp
            local dist = data.dist
            if marineRP ~= nil and dist and dist < 10 then
                targetRP = marineRP
                weight = EvalLPF(numExtractors,
                    {
                        {0, 10.0},
                        {1, 6.0},
                        {2, 4.0},
                        })
            end
            
        end

        return { name = name, weight = weight,
            perform = function(move)
                if targetRP ~= nil and (not bot.nextRTDrop or bot.nextRTDrop < Shared.GetTime()) then
                    local success = brain:ExecuteTechId( com, kTechId.Extractor, targetRP:GetOrigin(), com )
                    if success then
                        bot.nextRTDrop =  Shared.GetTime() + 5
                    end
                end
            end}
    end,

    function(bot, brain)

        local name = "scan"
        local com = bot:GetPlayer()
        local weight = 0
        local scanTarget
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local time = Shared.GetTime()
        
        
        if doables[kTechId.Scan] and (not bot.nextScan or bot.nextScan > time)  then
        
            local alertqueue = com:GetAlertQueue()
            
            local reactWeight = {
                [kTechId.MarineAlertExtractorUnderAttack] = 0.5,
                [kTechId.MarineAlertInfantryPortalUnderAttack] = 6,
                [kTechId.MarineAlertCommandStationUnderAttack] = 6,
                [kTechId.MarineAlertStructureUnderAttack] = 5,
            }
            
            for i, alert in ipairs(alertqueue) do
                local aTechId = alert.techId
                local targetWeight = reactWeight[aTechId]
                local target
                if targetWeight and targetWeight > weight and time - alert.time < 5 then
                    table.remove(alertqueue, i)
                    target = Shared.GetEntity(alert.entityId)
                    if target.GetHealthScalar then
                        targetWeight = targetWeight + targetWeight * (1 - target:GetHealthScalar())
                    end
                    local scans = #GetEntitiesWithMixinForTeamWithinXZRange("Scan", com:GetTeamNumber(), target:GetOrigin(), Scan.kScanDistance)
                    if scans <= 0 then
                        local nearbyFriendlies = #GetEntitiesForTeamWithinRange("Player", com:GetTeamNumber(), target:GetOrigin(), Scan.kScanDistance*0.4)
                        if nearbyFriendlies <= 0 then
                            weight = targetWeight
                            scanTarget = target
                        end
                    end
                elseif time - alert.time > 5 then
                    table.remove(alertqueue, i)
                end
            end
            
            com:SetAlertQueue(alertqueue)
        end

        return { name = name, weight = weight,
            perform = function(move)
                if scanTarget then
                    local origin = scanTarget:GetOrigin()
                    local groundTrace = Shared.TraceRay(origin + Vector(0, 10, 0), origin + Vector(0, -15, 0), CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))
                    local sucess = brain:ExecuteTechId( com, kTechId.Scan, origin, com, scanTarget:GetId(), groundTrace)
                    if sucess then
                        bot.nextScan = Shared.GetTime() + 15
                    end
                end
            end}
    end,
    
    function(bot, brain)

        local name = "droppacks"
        local com = bot:GetPlayer()
        local alertqueue = com:GetAlertQueue()

        --save times of having players last served to ignore spam
        bot.lastServedDropPack = bot.lastServedDropPack or {}

        local reactTechIds = {
            [kTechId.MarineAlertNeedAmmo] = kTechId.AmmoPack,
            [kTechId.MarineAlertNeedMedpack] = kTechId.MedPack
        }
        if table.contains(kTechId, "HealingField") then
            reactTechIds[kTechId.MarineAlertNeedMedpack] = kTechId.HealingField
        end

        local techCheckFunction = {
            [kTechId.MarineAlertNeedAmmo] = function(target)
                local weapon = target:GetActiveWeapon()

                local ammoPercentage = 1
                if weapon and weapon:isa("ClipWeapon") then
                    local max = weapon:GetMaxAmmo()
                    if max > 0 then
                        ammoPercentage = weapon:GetAmmo() / max
                    end
                end

                return ammoPercentage
            end,
            [kTechId.MarineAlertNeedMedpack] = function(target)
                return target:GetHealthFraction() end
        }
        
        if table.contains(kTechId, "HealingField") then
            techCheckFunction[kTechId.MarineAlertNeedMedpack] = function(target)
                if #GetEntitiesForTeamWithinXZRange("HealingField", target:GetTeamNumber(), target:GetOrigin(), HealingField.kRadius*1.9) > 0 then
                    return 1.0 -- 1 means you don't need it
                end
                return target:GetHealthFraction()
            end
        end

        local weight = 0.0
        local targetPos, targetId
        local techId
        local actualTarget

        local time = Shared.GetTime()

        for i, alert in ipairs(alertqueue) do
            local aTechId = alert.techId
            local targetTechId = reactTechIds[aTechId]
            local target
            if targetTechId and time - alert.time < 1 then
                table.remove(alertqueue, i)
                target = Shared.GetEntity(alert.entityId)

                local lastServerd = bot.lastServedDropPack[alert.entityId]
                local servedTime = lastServerd and lastServerd.time or time
                local servedCount = lastServerd and lastServerd.count or 0

                --reset count if last served drop pack is more than 15 secs ago
                if servedCount > 0 and time - servedTime > 15 then
                    servedCount = 0
                    bot.lastServedDropPack[alert.entityId] = nil
                end

                if target and servedCount < 3 and time - servedTime < 3 then
                    local alertPiority = EvalLPF( techCheckFunction[aTechId](target),
                    {
                        {0, 6.0},
                        {0.5, 4.0},
                        {1, 0.0},
                    })

                    if alertPiority == 0 then
                        target = nil
                    elseif alertPiority > weight then
                        techId = targetTechId
                        weight = alertPiority
                        targetPos = target:GetOrigin() --Todo Add jitter to position
                        targetId = target:GetId()
                        actualTarget = target
                    end
                end
            end
        end

        com:SetAlertQueue(alertqueue)

        return { name = name, weight = weight,
            perform = function(move)
                if targetId then
                    local sucess = brain:ExecuteTechId( com, techId, targetPos, com, targetId )
                    if sucess then
                        bot.lastServedDropPack[targetId] = bot.lastServedDropPack[targetId] or {}
                        local count = bot.lastServedDropPack[targetId].count or 0

                        bot.lastServedDropPack[targetId].time = Shared.GetTime()
                        bot.lastServedDropPack[targetId].count = count + 1
                        
                        local target = actualTarget
                        
                        if target and bot:GetPlayer():GetTeam():GetTeamResources() > 40 then
                            
                            
                            if target.GetHasCatpackBoost and not target:GetHasCatpackBoost() then
                                brain:ExecuteTechId( com, kTechId.CatPack, targetPos, com, targetId )
                            end
                            if target.GetIsNanoShielded and not target:GetIsNanoShielded() then
                                brain:ExecuteTechId( com, kTechId.NanoShield, targetPos, com, targetId )
                            end
                            
                        end
                    end
                end
            end}
    end,

    function(bot, brain)

        return { name = "idle", weight = 1e-5,
            perform = function(move)
                if brain.debug then
                    DebugPrint("idling..")
                end 
            end}
    end
}



if table.contains(kTechId, "ShieldGenerator") then

    table.insert(kMarineComBrainActions, CreateUpgradeStructureAction( kTechId.ShieldGeneratorTech   , 0.9+math.random() ))
    table.insert(kMarineComBrainActions, CreateUpgradeStructureAction( kTechId.ShieldGeneratorTech2   , 0.8+math.random() ))
    table.insert(kMarineComBrainActions, CreateUpgradeStructureAction( kTechId.ShieldGeneratorTech3   , 0.7+math.random() ))
    
end
------------------------------------------
--  Build the senses database
------------------------------------------


function CreateMarineComSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("gameMinutes", function(db)
            return (Shared.GetTime() - GetGamerules():GetGameStartTime()) / 60.0
            end)

    s:Add("doableTechIds", function(db)
            return db.bot.brain:GetDoableTechIds( db.bot:GetPlayer() )
            end)

    s:Add("stations", function(db)
            return GetEntitiesForTeam("CommandStation", db.bot:GetTeamNumber())
            end)
            
    s:Add("marines", function(db)
            return GetEntitiesForTeam("Marine", db.bot:GetTeamNumber())
            end)

    s:Add("availResPoints", function(db)
            return GetAvailableResourcePoints()
            end)

    s:Add("numExtractors", function(db)
            return GetNumEntitiesOfType("ResourceTower", db.bot:GetTeamNumber())
            end)

    s:Add("numInfantryPortals", function(db)
        return GetNumEntitiesOfType("InfantryPortal", db.bot:GetTeamNumber())
    end)
    
    s:Add("macs", function(db)
            return GetEntitiesForTeam("MAC", db.bot:GetTeamNumber())
        end)
            
    s:Add("techPointToTake", function(db)
        local tps = GetAvailableTechPoints()
            local stations = db:Get("stations")
            local dist, tp = GetMinTableEntry( tps, function(tp)
                return GetMinPathDistToEntities( tp, stations )
                end)
            return tp
            end)


    s:Add("resPointToTake", function(db)
            local rps = db:Get("availResPoints")
            local stations = db:Get("stations")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                return GetMinPathDistToEntities( rp, stations )
                end)
            return rp
            end)
            
    s:Add("resPointWithNearbyMarines", function(db)
            local rps = db:Get("availResPoints")
            local marines = db:Get("marines")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                return GetMinDistToEntities( rp, marines )
                end)
            return {rp = rp, dist = dist}
            end)

    return s

end