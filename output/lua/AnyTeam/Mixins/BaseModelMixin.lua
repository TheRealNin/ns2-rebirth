

local function SetHighlight(self)

    PROFILE("BaseModelMixin:SetHighlight")
    
    if self:GetIsHighlightEnabled() == 1 then
        if HasMixin(self, "Team") then 
            if self:GetTeamNumber() == kTeam2Index then
                if self:isa("Gorge") then
                    self._renderModel:SetMaterialParameter("highlight", 0.95)
                else
                    self._renderModel:SetMaterialParameter("highlight", 1.0)
                end
            elseif self:GetTeamNumber() == kTeam1Index then
                if self:isa("Gorge") then
                    self._renderModel:SetMaterialParameter("highlight", 0.85)
                else
                    self._renderModel:SetMaterialParameter("highlight", 0.9)
                end
            else
                self._renderModel:SetMaterialParameter("highlight", 0.8)
            end
        else
            self._renderModel:SetMaterialParameter("highlight", 0.7)
        end
    elseif self:GetIsHighlightEnabled() == 0.5 then
        self._renderModel:SetMaterialParameter("highlight", 0.5)
    end
end
debug.replaceupvalue( BaseModelMixin.GetRenderModel, "SetHighlight", SetHighlight, true)