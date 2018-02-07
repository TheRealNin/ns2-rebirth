
-- auto-shoot
function Pistol:OnMaxFireRateExceeded()
    --self.queuedShots = Clamp(self.queuedShots + 1, 0, 10)
end
function Pistol:GetPrimaryAttackRequiresPress()
    return false
end
