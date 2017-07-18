 
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


function GetCommanderSwitchTeamAllowed()

    if kForceMvM or kForceAvA then
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