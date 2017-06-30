
local kPlayerMaxCloak = 0.88
local kEnemyUncloakDistanceSquared = 1.5 ^ 2

function CloakableMixin:GetCanCloak()

    local canCloak = true
    
    if self.GetCanCloakOverride then
        canCloak = self:GetCanCloakOverride()
    end
    
    if (self.GetIsParasited and self:GetIsParasited()) then
        canCloak = false
    end
    
    return canCloak 

end

function CloakableMixin:GetCloakFraction()
    if (self.GetIsParasited and self:GetIsParasited()) then
        return 0
    end
    return self.cloakFraction
end