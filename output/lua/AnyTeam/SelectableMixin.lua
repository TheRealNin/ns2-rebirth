
function SelectableMixin:OnSighted(sighted)

    if not sighted then
    
        local selectedByTeamOne = bit.band(self.selectionMask, 1) ~= 0
        local selectedByTeamTwo = bit.band(self.selectionMask, 2) ~= 0
        
        if (self:GetTeamNumber() == 2 or self:GetTeamNumber() == 0) and selectedByTeamOne then
        
            if Server then
                self:SetSelected(1, false)
            end
            
        elseif (self:GetTeamNumber() == 1 or self:GetTeamNumber() == 0) and selectedByTeamTwo then
        
            if Server then
                self:SetSelected(2, false)
            end
            
        end
        
    end
    
end


function SelectableMixin:GetIsSelectable(byTeamNumber)

    local isValid = HasMixin(self, "LOS") and self:GetIsSighted() or HasMixin(self, "Team") and (byTeamNumber == self:GetTeamNumber() or self:GetTeamNumber() == kNeutralTeamType)
    
    if isValid and self.OnGetIsSelectable then
    
        -- A table is passed in so that all the OnGetIsSelectable functions
        -- have a say in the matter.
        local resultTable = { selectable = true }
        self:OnGetIsSelectable(resultTable, byTeamNumber)
        isValid = resultTable.selectable
        
    end
    
    return isValid
    
end