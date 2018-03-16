
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


function SelectableMixin:UpdateIncludeRelevancyMask()

    -- Make entities which are active for a commander relevant to all commanders
    -- on the same team.
    local includeMask = 0
    
    if bit.band(self.selectionMask, 1) ~= 0 or (self:GetTeamNumber() == 1 and self:GetHotGroupNumber() ~= 0) then
        includeMask = bit.bor(includeMask, kRelevantToTeam1Commander)
    end
    
    if bit.band(self.selectionMask, 2) ~= 0 or (self:GetTeamNumber() == 2 and self:GetHotGroupNumber() ~= 0) then
        includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
    end
    
    -- special hack for special stuff
    if self:isa("PowerPoint") then
    
        if kTeam1Type == kMarineTeamType then
            includeMask = bit.bor(includeMask, kRelevantToTeam1Commander)
        end
        if kTeam2Type == kMarineTeamType then
            includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
        end
        
    end
    
    self:SetIncludeRelevancyMask( includeMask )
    
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