
-- set armor/health and trigger effects accordingly (armor bar particles)


GUIMarineStatus.kArmorShieldBarColor = Color(183/255, 137/255, 245/255, 0.8)

local oldUpdate = GUIMarineStatus.Update
function GUIMarineStatus:Update(deltaTime, parameters)
    local currentArmor= parameters[3]
    local updatePlz = false
    if self.lastArmor ~= currentArmor then
        updatePlz = true
    end
    
    oldUpdate(self, deltaTime, parameters)
    
    if updatePlz then
    
        local player = Client.GetLocalPlayer()
        if player and player.personalShielded then
        
            self.armorText:SetColor(GUIMarineStatus.kArmorShieldBarColor)
            --[[
            local description = " (shield #1)"
            if GetHasTech(self, kTechId.ShieldGeneratorTech3, true) then
                description = " (shield #3)"
            elseif GetHasTech(self, kTechId.ShieldGeneratorTech2, true) then
                description = " (shield #2)"
            end
            self.armorText:SetText(tostring(math.ceil(currentArmor)) .. description)
            ]]--
            
            self.armorBarGlow:DestroyAnimations()
            self.armorBarGlow:SetColor( GUIMarineStatus.kArmorShieldBarColor ) 
            self.armorBarGlow:FadeOut(1, nil, AnimateLinear)
        else
            self.armorText:SetColor(GUIMarineStatus.kArmorBarColor)
        end
    end
end