
local kHMGReloadAnimationSpeedIncrease = 2
local kHMGSpeedModifier = 0.8

function HeavyMachineGun:GetCatalystSpeedBase()
    return self:GetIsReloading() and kHMGReloadAnimationSpeedIncrease or 1
end

function HeavyMachineGun:GetSpeedModifier()
    return (self.primaryAttacking and not self:GetIsReloading()) and kHMGSpeedModifier or 1
end


function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")
    
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("reload_speed", kRifleToHMGReloadSpeed * kHMGReloadAnimationSpeedIncrease)

end