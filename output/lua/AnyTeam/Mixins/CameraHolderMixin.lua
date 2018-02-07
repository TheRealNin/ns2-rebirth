
function CameraHolderMixin:GetEyePos()
    -- cameraYOffset is only set for the server and local player, so this is a hack
    local cameraYOffset = self.cameraYOffset
    if Client and self.GetIsLocalPlayer and self.GetCrouchShrinkAmount and self.GetCrouchAmount
        and not self:GetIsLocalPlayer() then
        cameraYOffset = -self:GetCrouchShrinkAmount() * self:GetCrouchAmount()  * 0.5
    end
    return self:GetOrigin() + self:GetViewOffset() + Vector(0, cameraYOffset, 0)
end