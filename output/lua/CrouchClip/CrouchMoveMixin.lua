

local kEnableNewCrouch = true
local kCrouchAnimationTime = 0.25
local kAirCrouchTransistionTime = 0.25 -- kCrouchAnimationTime is 0.25

function CrouchMoveMixin:GetCrouchAirFraction()
    local transistionTime = kAirCrouchTransistionTime
    local groundFraction = Clamp( (Shared.GetTime() - self.timeGroundTouched) / transistionTime, 0, 1)
    return groundFraction
end

function CrouchMoveMixin:OnAdjustModelCoords(modelCoords)
    if not self:GetIsOnGround() and kEnableNewCrouch then
        modelCoords.origin = modelCoords.origin - Vector(0,self:GetExtentsCrouchShrinkAmount()*self:GetCrouchAirFraction() * self:GetCrouchAmount(),0)
    end
    return modelCoords
end


Event.Hook("Console_toggle_new_crouch", function() 
    kEnableNewCrouch = not kEnableNewCrouch 
    if kEnableNewCrouch then
        Log("New crouch enabled")
    else
        Log("New crouch disabled")
    end
end)