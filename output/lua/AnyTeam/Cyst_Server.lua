
--
-- Try to find an actually connected parent. Connect to the closest entity (but bias hives).
--
function Cyst:TryToFindABetterParent()

    local parent, path = GetCystParentFromPoint(self:GetOrigin(), self:GetCoords().yAxis, "GetIsActuallyConnected", self, self:GetTeamNumber())
    
    if parent and path then
    
        self:ChangeParent(parent)
        return true
        
    end
    
    return false
    
end