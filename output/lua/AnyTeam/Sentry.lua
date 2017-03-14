
function GetCheckSentryLimit(techId, origin, normal, commander)

    -- Prevent the case where a Sentry in one room is being placed next to a
    -- SentryBattery in another room.
    local battery = GetSentryBatteryInRoom(origin, commander)
    if battery then
    
        if (battery:GetOrigin() - origin):GetLength() > SentryBattery.kRange then
            return false
        end
        
    else
        return false
    end
    
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    local teamNum = commander:GetTeamNumber()
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ipairs(GetEntitiesForTeam("Sentry", teamNum)) do
        
            if sentry:GetLocationName() == locationName then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kSentriesPerBattery
    
end
