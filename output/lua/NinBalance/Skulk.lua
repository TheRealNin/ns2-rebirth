Skulk.kMaxSpeed = 8.25 -- was 7.25
Skulk.kSneakSpeedModifier = 0.58 -- was 0.66

function Skulk:GetAcceleration()
    return 8 -- was 13
end

function Skulk:GetGroundFriction()
    return 6 -- was 11
end