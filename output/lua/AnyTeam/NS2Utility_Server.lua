
function DestroyEntitiesForTeamWithinRange(className, teamNumber, origin, range, filterFunc)

    for index, entity in ipairs(GetEntitiesForTeamWithinRange(className, teamNumber, origin, range)) do
        if not filterFunc or not filterFunc(entity) then
            DestroyEntity(entity)
        end
    end

end