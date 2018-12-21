if Client then
    
    function HiveVisionMixin:OnModelChanged(index)
        if self.hiveSightVisible then
            local model = self:GetRenderModel()
            if model then
                HiveVision_RemoveModel( model )
            end
        end
        self.hiveSightVisible = false
    end
    
    local function GetMaxDistanceFor(player)
    
        if player:isa("AlienCommander") or player:isa("Spectator") then
            return 63
        end

        return 40
    
    end
    
    -- this actually is used for equipment outlines too
    function HiveVisionMixin:OnUpdate(deltaTime)   
        PROFILE("HiveVisionMixin:OnUpdate")
        -- Determine if the entity should be visible on hive sight
        local parasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local visible = parasited
        local player = Client.GetLocalPlayer()
        local now = Shared.GetTime()
		local model = self:GetRenderModel()
        
        
		if model then
			local showTint = player ~= nil and GetAreEnemies(player, self)
			
			if Client.GetLocalClientTeamNumber() == kSpectatorIndex and self:GetTeamNumber() == kTeam1Index and 
				player.specMode ~= nil and player.specMode ~= kSpectatorMode.Following and player.specMode ~= kSpectatorMode.FirstPerson then
				showTint = false
			end

			if showTint then
				model:SetMaterialParameter("tint", 1)
			else
				model:SetMaterialParameter("tint", 0)
			end
		end
		
        -- for spectators
        if Client.GetLocalClientTeamNumber() == kSpectatorIndex
              and (self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index or self:GetTeamNumber() == kNeutralTeamNumber)
              and Client.GetOutlinePlayers() then
              
            local visible = player ~= nil and (player:GetOrigin() - self:GetOrigin()):GetLength() <= GetMaxDistanceFor(player)
            
            if visible ~= self.hiveSightVisible then
                
                if visible and model ~= nil then
                    if self:GetTeamNumber() == kTeam2Index then
                        HiveVision_AddModel( model, kHiveVisionOutlineColor.KharaaOrange )
                    elseif  self:GetTeamNumber() == kNeutralTeamNumber then
                        HiveVision_AddModel( model, kHiveVisionOutlineColor.Green )
                    else
                        HiveVision_AddModel( model, kHiveVisionOutlineColor.Blue )
                    end
                    self.hiveSightVisible = true
                    
                else
                    HiveVision_RemoveModel( model )
                    self.hiveSightVisible = false
                end
            end
        
        else
            
            -- check the distance here as well. seems that the render mask is not correct for newly created models or models which get destroyed in the same frame
            local playerCanSeeHiveVision = player ~= nil and (player:GetOrigin() - self:GetOrigin()):GetLength() <= GetMaxDistanceFor(player) and (player:isa("Alien") or player:isa("AlienCommander") or player:isa("AlienSpectator"))

            if not visible and playerCanSeeHiveVision and self:isa("Player") then
            
                -- Make friendly players always show up - even if not obscured
                visible = player ~= self and GetAreFriends(self, player)
                
            end
            
            if visible and not playerCanSeeHiveVision then
                visible = false
            end
            
            -- Update the visibility status.
            if visible ~= self.hiveSightVisible then
            
                local addModelColor = nil
                if model ~= nil then
					
					
                    if visible then
                        if not GetAreEnemies(self, player) then
                            addModelColor = kHiveVisionOutlineColor.Blue
                        else
                            if parasited then
                                addModelColor = kHiveVisionOutlineColor.KharaaOrange
                            else
                                addModelColor = kHiveVisionOutlineColor.Green
                            end
                        end
                        --DebugPrint("%s add model", self:GetClassName())
                    else
                        HiveVision_RemoveModel( model )
                        --DebugPrint("%s remove model", self:GetClassName())
                    end 
                    
                    if addModelColor then
                        HiveVision_AddModel( model, addModelColor)
                    end
                    self.hiveSightVisible = visible
                    
                else
                
                    self.hiveSightVisible = false
                end
                
            end
        end
    end
end