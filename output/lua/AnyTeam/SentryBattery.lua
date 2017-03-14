
function GetRoomHasNoSentryBattery(techId, origin, normal, commander)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local validRoom = false
    local teamNum = commander:GetTeamNumber()
    
    if locationName then
    
        validRoom = true
    
        for index, sentryBattery in ipairs(GetEntitiesForTeam("SentryBattery", teamNum)) do
            
            if sentryBattery:GetLocationName() == locationName then
                validRoom = false
                break
            end
            
        end
    
    end
    
    return validRoom

end


function GetSentryBatteryInRoom(origin, commander)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local teamNum = commander:GetTeamNumber()
    
    if locationName then
    
        for index, sentryBattery in ipairs(GetEntitiesForTeam("SentryBattery", teamNum)) do
            
            if sentryBattery:GetLocationName() == locationName then
                return sentryBattery
            end
            
        end
        
    end
    
    return nil
    
end