
local kHMGReloadAnimationSpeedIncrease = 2
local kHMGSpeedModifier = 0.8
local kHMGAimTransitionTime = 0.5
-- kHeavyMachineGunSpread is Math.Radians(4)

local kHeavyMachineGunGroundSpread = Math.Radians(2.0) --rifle is 2.8
local kHeavyMachineGunAirSpread = Math.Radians(15)

function HeavyMachineGun:GetCatalystSpeedBase()
    return self:GetIsReloading() and kHMGReloadAnimationSpeedIncrease or 1
end

function HeavyMachineGun:GetSpeedModifier()
    return (self.primaryAttacking and not self:GetIsReloading()) and kHMGSpeedModifier or 1
end


function HeavyMachineGun:GetSpread()
    local player = self:GetParent()
    if player then
        if not player:GetIsOnGround() then
            return kHeavyMachineGunAirSpread
        else
            local groundFraction = Clamp( (Shared.GetTime() - player.timeGroundTouched) / kHMGAimTransitionTime, 0, 1) or 0
            return LerpNumber(kHeavyMachineGunAirSpread, kHeavyMachineGunGroundSpread, groundFraction)
        end
    end
    return kHeavyMachineGunGroundSpread
end


function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")
    
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("reload_speed", kRifleToHMGReloadSpeed * kHMGReloadAnimationSpeedIncrease)

end