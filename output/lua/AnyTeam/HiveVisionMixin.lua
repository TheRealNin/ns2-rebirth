if Client then

    local function GetMaxDistanceFor(player)
    
        if player:isa("AlienCommander") then
            return 63
        end

        return 33
    
    end
    function HiveVisionMixin:OnUpdate(deltaTime)   
        PROFILE("HiveVisionMixin:OnUpdate")
        -- Determine if the entity should be visible on hive sight
        local parasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local visible = parasited
        local player = Client.GetLocalPlayer()
        local now = Shared.GetTime()
        
        if Client.GetLocalClientTeamNumber() == kSpectatorIndex
              and (self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index)
              and Client.GetOutlinePlayers()
              and not self.hiveSightVisible then

            local model = self:GetRenderModel()
            if model ~= nil then
                if self:GetTeamNumber() == kTeam2Index then
                    HiveVision_AddModel( model, kHiveVisionOutlineColor.KharaaOrange )
                else
                    HiveVision_AddModel( model, kHiveVisionOutlineColor.Blue )
                end
                self.hiveSightVisible = true    
                self.timeHiveVisionChanged = now
                
            end
        
        end
        
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
        if visible ~= self.hiveSightVisible and self.timeHiveVisionChanged + 1 < now then
        
            local model = self:GetRenderModel()
            if model ~= nil then
            
                if visible then
                    if GetAreFriends(self, player) then
                            HiveVision_AddModel( model, kHiveVisionOutlineColor.Blue )
                    else
                        if parasited then
                            HiveVision_AddModel( model, kHiveVisionOutlineColor.KharaaOrange )
                        else
                            HiveVision_RemoveModel( model )
                            --HiveVision_AddModel( model, kHiveVisionOutlineColor.KharaaOrange )
                        end
                    end
                    --DebugPrint("%s add model", self:GetClassName())
                else
                    HiveVision_RemoveModel( model )
                    --DebugPrint("%s remove model", self:GetClassName())
                end 
                   
                self.hiveSightVisible = visible    
                self.timeHiveVisionChanged = now
                
            end
            
        end
            
    end
end