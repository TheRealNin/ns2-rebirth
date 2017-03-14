
local oldOnParentChanged = Weapon.OnParentChanged
function Weapon:OnParentChanged(oldParent, newParent)

    oldOnParentChanged(self, oldParent, newParent)
    
    if newParent and newParent.GetTeamNumber then
        self:SetTeamNumber(newParent:GetTeamNumber())
    end

end