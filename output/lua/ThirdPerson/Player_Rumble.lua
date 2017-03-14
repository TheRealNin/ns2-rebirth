local kRumbleSoundRadius = 25-- Look for nearby Oni and determine how much rumbling of the sound effect we should play-- Returns 0-1/0-1 for amount and speedfunction CalculateRumble(listenerOrigin)    local rumbleAmount = 0    local rumbleSpeed = 0        local oni = GetEntitiesWithinRange("Onos", listenerOrigin, kRumbleSoundRadius)    for index, onos in ipairs(oni) do            -- Rumble is cumulative, adding from each onos        local dist = (onos:GetOrigin() - listenerOrigin):GetLength()        local currentRumbleAmount = (1 - (dist / kRumbleSoundRadius))        rumbleAmount = Clamp(rumbleAmount + currentRumbleAmount, 0, 1)                -- Speed = the max speed of any onos        local currentRumbleSpeed = Clamp(onos:GetSpeedScalar(), 0, 1)        rumbleSpeed = math.max(rumbleSpeed, currentRumbleSpeed)            end    return rumbleAmount, rumbleSpeed    end