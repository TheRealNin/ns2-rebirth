
function GetAliveEntitiesForTeam(class, teamNumber)
    local ents = GetEntitiesForTeam( class, teamNumber )
    
    for _,ent in ipairs(ents) do
        if ent.GetIsAlive and not ent:GetIsAlive() then
            table.remove(ents, _)
        end
    end
    
    return ents
end


function CreateBuildStructureActionForEach( techId, className, numExistingToWeightLPF, buildNearClass, maxDist)

    return function(bot, brain)

        local name = "build"..EnumToString( kTechId, techId )
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local coms = doables[techId]

        -- find structures we can build near
        local hosts = GetAliveEntitiesForTeam( buildNearClass, com:GetTeamNumber() )
        local mainHost
        if coms ~= nil and #coms > 0
        and hosts ~= nil and #hosts > 0 then
            assert( coms[1] == com )
            
            local team = com:GetTeam()
            
            for _,host in ipairs(hosts) do
                
                if host:GetIsBuilt() and host:GetIsAlive() then
                    local existingEnts = GetEntitiesForTeamWithinRange( className, com:GetTeamNumber(), host:GetOrigin(), maxDist + 1)
                    local newWeight = EvalLPF( #existingEnts, numExistingToWeightLPF )
                    if newWeight > weight then
                        weight = newWeight
                        mainHost = host
                    end
                end
            end
        end

        return { name = name, weight = weight,
            perform = function(move)

                if mainHost then
                    if mainHost:GetIsBuilt() and mainHost:GetIsAlive() then
                    
                        local pos = GetRandomBuildPosition( techId, mainHost:GetOrigin(), maxDist )
                        if pos ~= nil then
                            brain:ExecuteTechId( com, techId, pos, com )
                        end
                            
                    end
                end

            end }
    end

end


local function GetEmptyTechPoints( conditionFunc, TechId )

    local resultList = {}

    for _, techPoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
    
        local attached = techPoint:GetAttached()
    
        if ( not attached ) and 
           ( not conditionFunc or conditionFunc(techPoint) ) then
           
            table.insert(resultList, techPoint)
            
        end
    
    end
    

    return resultList
    
end

local techpointDist = 15.0
local friendlyDist = 15.0
function CreateBuildStructureActionNearTechpoints( techId, className, numExistingToWeightLPF)

    return function(bot, brain)

        local name = "build"..EnumToString( kTechId, techId )
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local coms = doables[techId]

        -- find techpoints we can build near
        local conditionFunc = function(techPoint)
            return #GetEntitiesForTeamWithinRange("Player", com:GetTeamNumber(), techPoint:GetOrigin(), friendlyDist) > 0
        end
        
        local hosts = GetEmptyTechPoints( conditionFunc )
        local mainHost
        if coms ~= nil and #coms > 0
        and hosts ~= nil and #hosts > 0 then
            assert( coms[1] == com )
            
            local team = com:GetTeam()
            
            for _,host in ipairs(hosts) do
                
                local existingEnts = GetEntitiesForTeamWithinRange( className, com:GetTeamNumber(), host:GetOrigin(), techpointDist + 1)
                local newWeight = EvalLPF( #existingEnts, numExistingToWeightLPF )
                if newWeight > weight then
                    weight = newWeight
                    mainHost = host
                end
            end
        end

        return { name = name, weight = weight,
            perform = function(move)

                if mainHost then
                    local pos = GetRandomBuildPosition( techId, mainHost:GetOrigin(), techpointDist )
                    if pos ~= nil then
                        brain:ExecuteTechId( com, techId, pos, com )
                    end
                end

            end }
    end

end



function CreateUpgradeStructureAction( techId, weightIfCanDo, existingTechId )

    return function(bot, brain)

        local name = EnumToString( kTechId, techId )
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local structures = doables[techId]

        if structures ~= nil then

            weight = weightIfCanDo

            if existingTechId ~= nil then
                if GetTechTree(com:GetTeamNumber()):GetHasTech(existingTechId) then
                    weight = weight * 0.3
                end
            end

        end

        return {
            name = name, weight = weight,
            perform = function(move)

                if structures == nil then return end
                -- choose a random host
                local host = structures[ math.random(#structures) ]
                local success = brain:ExecuteTechId( com, techId, Vector(0,0,0), host )
                if success then
                    local researchTime = LookupTechData(techId, kTechDataResearchTimeKey, 0)
                    if researchTime and researchTime > 0 then
                        local name = LookupTechData(techId, kTechDataDisplayName, "something")
                        bot:SendTeamMessage("Starting research: " .. name, 10)
                    end
                end
            end }
    end

end
