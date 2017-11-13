
local oldGetMaxSpeed = Marine.GetMaxSpeed
function Marine:GetMaxSpeed(possible)
    local oldVal = oldGetMaxSpeed(self, possible)
    if possible then
        return oldVal
    end
    
    local hmgModifier = 1
    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:GetMapName() == HeavyMachineGun.kMapName then
        hmgModifier = activeWeapon:GetSpeedModifier()
    end

    return oldVal * hmgModifier
    
end