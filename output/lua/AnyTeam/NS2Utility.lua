 
function GetAreEnemies(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and entityOne:GetTeamNumber() ~= entityTwo:GetTeamNumber()
end

function GetAreFriends(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and
            (entityOne:GetTeamNumber() == entityTwo:GetTeamNumber() or entityOne:GetTeamNumber() == kNeutralTeamNumber or entityTwo:GetTeamNumber() == kNeutralTeamNumber)
end

function GetEnemyTeamNumber(entityTeamNumber)

    if(entityTeamNumber == kTeam1Index) then
        return kTeam2Index
    elseif(entityTeamNumber == kTeam2Index) then
        return kTeam1Index
    else
        return kTeamInvalid
    end    
    
end

function GetTeamType(teamNumber)
    if teamNumber == kTeam1Index then
        return kTeam1Type
    elseif teamNumber == kTeam2Index then
        return kTeam2Type
    end
    return kNeutralTeamType
end


function GetCommanderSwitchTeamAllowed()

    if kForceMvM or kForceAvA or kForcedByConfig then
        return false
    end

    local gameState = kGameState.PreGame

    if Server then   

        local gamerules = GetGamerules()
        if gamerules then
        
            gameState = gamerules:GetGameState()
        
        end

    else  
    
        local gameInfo = GetGameInfoEntity()
        
        if gameInfo then
        
            gameState = gameInfo:GetState()
            
        end

    end

    return ( gameState == kGameState.NotStarted or gameState == kGameState.WarmUp or gameState == kGameState.PreGame )
    

end

local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()

    local ClassToGrid = oldBuildClassToGrid()
    
    ClassToGrid["RepairBot"] = { 4, 2 }
    
    return ClassToGrid
    
end

function GetIsPointOffInfestation(point, teamNumber)
    return not GetIsPointOnInfestation(point, teamNumber)
end

local kInfestationSearchRange = 25
function GetIsPointOnInfestation(point, teamNumber)
    local onInfestation = false
    if not teamNumber then
        --Print("waning: you should probably be calling GetIsPointOnInfestation() with a team number")
    end

    -- See if entity is on infestation
    local infestationEntities
    if teamNumber then
        infestationEntities = GetEntitiesWithMixinForTeam("Infestation", teamNumber, point, kInfestationSearchRange)
    else
        infestationEntities = GetEntitiesWithMixinWithinRange("Infestation", point, kInfestationSearchRange)
    end
    for infestationIndex = 1, #infestationEntities do

        local infestation = infestationEntities[infestationIndex]
        if infestation:GetIsPointOnInfestation(point) then

            onInfestation = true
            break

        end

    end

    -- count being inside of a gorge tunnel as on infestation
    if not onInfestation then

        local tunnelEntities = GetEntitiesWithinRange("Tunnel", point, 40)
        onInfestation = #tunnelEntities > 0

    end

    return onInfestation

end


function GetInfestationRequirementsMet(techId, position, teamNumber)

    local requirementsMet = true

    -- Check infestation requirements
    if LookupTechData(techId, kTechDataRequiresInfestation) then

        if not GetIsPointOnInfestation(position, teamNumber) then
            requirementsMet = false
        end

        -- SA: Note that we don't check kTechDataNotOnInfestation anymore.
        -- This function should only be used for stuff that REQUIRES infestation.
    end

    return requirementsMet

end


function GetPlayerSkillTier(skill, isRookie, adagradSum)
    return 7, "SKILLTIER_SANJISURVIVOR"
end