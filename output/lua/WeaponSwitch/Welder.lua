
function Welder:GetHasSecondary(player)
    return true
end
function Welder:GetSecondaryAttackRequiresPress()
    return true
end

if Server then
    function Welder:OnSecondaryAttack(player)
        self.secondaryAttacking = true
        Weapon.OnSecondaryAttack(self, player)
    end
    function Welder:OnSecondaryAttackEnd(player)
        if self.secondaryAttacking then
            self.secondaryAttacking = false
            -- remove us first
            player:RemoveWeapon(self)
            DestroyEntity(self)
            
            local newAxe = player:GiveItem(Axe.kMapName)
            newAxe.hasWelder = true
            player:SetHUDSlotActive(newAxe:GetHUDSlot()) -- switch to it
        end
        self.secondaryAttacking = false
    end
end

if Client then

    function Welder:CreateSwitchInfo()
    
        if not self.switchInfo then        
            self.switchInfo = GetGUIManager():CreateGUIScript("WeaponSwitch/GUISwitchInfo")
            self.switchInfo:SetSwitchName("Axe")
        end
        
    end
    
    function Welder:DestroySwitchInfo()
        if self.switchInfo ~= nil then
            GetGUIManager():DestroyGUIScript(self.switchInfo)
            self.switchInfo = nil
        end
    end
    
    local function UpdateGUI(self, player)
        local localPlayer = Client.GetLocalPlayer()
        if localPlayer == player then
            self:CreateSwitchInfo()
        end
        
        if self.switchInfo then
            self.switchInfo:SetIsVisible(player and localPlayer == player and self:GetIsActive() and not HelpScreen_GetHelpScreen():GetIsBeingDisplayed())
        end
    end
    
    local origOnUpdateRender = Welder.OnUpdateRender
    function Welder:OnUpdateRender()
        origOnUpdateRender(self)
        UpdateGUI(self, self:GetParent())    
    end
    
    function Welder:OnDestroy()
        self:DestroySwitchInfo()        
        Ability.OnDestroy(self)
    end

end
