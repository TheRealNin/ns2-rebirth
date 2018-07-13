
if Client then

    function TeamMixin:OnGetIsVisible(visibleTable, viewerTeamNumber)

        local player = Client.GetLocalPlayer()
        
        if player and player:isa("Commander") and viewerTeamNumber == GetEnemyTeamNumber(self:GetTeamNumber()) and HasMixin(self, "LOS") and not self:GetIsSpotted() then
            visibleTable.Visible = false
        end
        
    end
    
end