
--[[
function TriggerFirstPersonTracer(weapon, endPosition)

    if weapon and weapon:GetParent() then
    
        local player = weapon:GetParent()
        local tracerStart = weapon.GetBarrelPoint and weapon:GetBarrelPoint() or weapon:GetOrigin()
        local tracerVelocity = GetNormalizedVector(endPosition - tracerStart) * kTracerSpeed
        CreateTracer(tracerStart, endPosition, tracerVelocity, weapon)
    
    end

end
]]--