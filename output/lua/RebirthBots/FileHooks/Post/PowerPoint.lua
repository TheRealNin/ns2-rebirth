
-- new function!
function PowerPoint:IsPoweringFriendlyTo(entity)

    for _, powerUser in ipairs(GetEntitiesWithMixinForTeam("PowerConsumer", entity:GetTeamNumber())) do
        if powerUser.GetIsAlive 
        and powerUser:GetIsAlive() 
        and powerUser.GetLocationId 
        and powerUser:GetLocationId() == self:GetLocationId() 
        and powerUser.GetRequiresPower
        and powerUser:GetRequiresPower() 
        then
            return true
        end
    end
    return false
end
