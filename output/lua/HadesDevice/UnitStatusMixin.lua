
local oldGetUnitStatusFraction = UnitStatusMixin.GetUnitStatusFraction
function UnitStatusMixin:GetUnitStatusFraction(forEntity)
    if GetAreFriends(forEntity, self) and self:isa("HadesDevice") and self.GetIsDetonating and self:GetIsDetonating() and self.GetDetonateRatio then
        return self:GetDetonateRatio()
    end
    
    return oldGetUnitStatusFraction(self, forEntity)
end