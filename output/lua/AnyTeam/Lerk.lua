function Lerk:GetHeartOffset()
    return Vector(0, 0.7, 0)
end

local oldModifyVelocity = Lerk.ModifyVelocity
function Lerk:ModifyVelocity(input, velocity, deltaTime)
    
    if not self:GetIsWebbed() then
        oldModifyVelocity(self, input, velocity, deltaTime)
    else
        self.gliding = false
    end
end