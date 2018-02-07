
local oldGetUnitStatus = UnitStatusMixin.GetUnitStatus
function UnitStatusMixin:GetUnitStatus(forEntity)

    local unitStatus = oldGetUnitStatus(self, forEntity)

    -- don't show status of opposing team
    if GetAreFriends(forEntity, self) then

        if GetIsUnitActive(self) then
            if HasMixin(self, "Live") and self:GetHealthScalar() < 1 and self:GetIsAlive() and (not forEntity.GetCanSeeDamagedIcon or forEntity:GetCanSeeDamagedIcon(self)) then
            
                if forEntity:isa("Marine") and self:isa("Marine") and self:GetArmor() < self:GetMaxArmor() and self:GetIsPersonalShielded() then
                    unitStatus = kUnitStatus.None
                end
                
            end
        
        end
    
    end

    return unitStatus

end