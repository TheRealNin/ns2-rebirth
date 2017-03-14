
function GUIDeathScreen:Update(deltaTime)

    PROFILE("GUIDeathScreen:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    local isDead = PlayerUI_GetIsDead() and not PlayerUI_GetIsSpecating()
    
    if isDead ~= self.lastIsDead then
    
        -- Check for the killer name as it will be nil if it hasn't been received yet.
        local killerName = nil
        local weaponIconIndex = nil
        if isDead then
        
            local player = Client.GetLocalPlayer()
            if player and not self.cinematic then
                self.cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                self.cinematic:SetCinematic(player:GetFirstPersonDeathEffect())
            end
            
            Client.TriggerItemDrop() -- If they've earned an item, give it now (because they're dead)
        
            killerName, weaponIconIndex = GetKillerNameAndWeaponIcon()
            if not killerName then
                return
            end
        
            local playerName = PlayerUI_GetPlayerName()
            local xOffset = DeathMsgUI_GetTechOffsetX(0)
            local yOffset = DeathMsgUI_GetTechOffsetY(weaponIconIndex)
            local iconWidth = DeathMsgUI_GetTechWidth(0)
            local iconHeight = DeathMsgUI_GetTechHeight(0)
            
            self.killerName:SetText(killerName)
            self.playerName:SetText(playerName)
            
            self.weaponIcon:SetTexturePixelCoordinates(xOffset, yOffset, xOffset + iconWidth, yOffset + iconHeight)
            self.weaponIcon:FadeIn(0.5, "FADE_DEATH_ICON")
            self.background:FadeIn(kFadeToBlackTime, "FADE_DEATH_SCREEN")
            
        else
            
            if self.cinematic then
                
                if IsValid(self.cinematic) then
                    self.cinematic:SetIsVisible(false)
                    Client.DestroyCinematic(self.cinematic)
                end
                self.cinematic = nil
                
            end
            
            self.background:FadeOut(0.5, "FADE_DEATH_SCREEN")
            self.weaponIcon:FadeOut(1.5, "FADE_DEATH_ICON")
            
        end
        
        self.lastIsDead = isDead
        
    end
    
end