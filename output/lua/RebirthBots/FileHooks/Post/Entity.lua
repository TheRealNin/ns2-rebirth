
function GetEntitiesAliveForTeam(className, teamNumber)

    assert(type(className) == "string")
    assert(type(teamNumber) == "number")
    
    local function teamFilterFunction(entity)
        return HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber and HasMixin(entity, "Live") and entity:GetIsAlive()
    end
    return GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(className), teamFilterFunction)
    
end