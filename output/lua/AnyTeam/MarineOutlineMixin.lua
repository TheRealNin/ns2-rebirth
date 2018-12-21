
if Client then


    function MarineOutlineMixin:OnUpdate(deltaTime)   
	
        PROFILE("MarineOutlineMixin:OnUpdate")
		
        local player = Client.GetLocalPlayer()
        local model = self:GetRenderModel()
		
        if model ~= nil then 
		
            local outlineModel = Client.GetOutlinePlayers() and 
                                    ( ( Client.GetLocalClientTeamNumber() == kSpectatorIndex ) or 
                                      ( player:GetTeamType() == kMarineTeamType and not GetAreEnemies(player, self)) )
       
            
            local outlineColor
            if self.catpackboost then
                outlineColor = kEquipmentOutlineColor.Fuchsia
            elseif HasMixin(self, "ParasiteAble") and self:GetIsParasited() then
                outlineColor = kEquipmentOutlineColor.Yellow
            else
                outlineColor = kEquipmentOutlineColor.TSFBlue
            end

            if outlineModel ~= self.marineOutlineVisible or outlineColor ~= self.marineOutlineColor then

                EquipmentOutline_RemoveModel( model )
                if outlineModel then
                    EquipmentOutline_AddModel( model, outlineColor )
                    self.marineOutlineColor = outlineColor
                end

                self.marineOutlineVisible = outlineModel
            end

        end
            
    end

end