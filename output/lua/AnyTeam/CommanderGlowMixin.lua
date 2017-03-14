if Client then

function CommanderGlowMixin:UpdateHighlight()

    -- Show glowing outline for commander, to pick it out of the darkness
    local player = Client.GetLocalPlayer()
    local visible = player ~= nil -- make it so all players see the glow
    local isCommander = visible and (player:isa("Commander"))
    
    -- Don't show enemy structures as glowing
    if visible and self.GetTeamNumber and (player:GetTeamNumber() == GetEnemyTeamNumber(self:GetTeamNumber())) then
        visible = false
    end
    
    -- don't show neutral stuff to players
    if not isCommander and not self.GetTeamType or (self.GetTeamType and self:GetTeamNumber() ~= kTeam1Index and self:GetTeamNumber() ~= kTeam2Index) then
        visible = false
    end
    
    -- Update the visibility status.
    if visible ~= self.commanderGlowOutline then
    
        local model = self:GetRenderModel()
        if model ~= nil then

            local isAlien = GetIsAlienUnit(player)        
            if visible then
                if isAlien then
                    HiveVision_AddModel( model )
                else
                    EquipmentOutline_AddModel( model )
                end
            else
                HiveVision_RemoveModel( model )
                EquipmentOutline_RemoveModel( model )
            end
         
            self.commanderGlowOutline = visible    
            
        end
        
    end
    
end


end