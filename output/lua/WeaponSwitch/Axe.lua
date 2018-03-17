
local networkVars =
{
    hasWelder = "private boolean"
}
local oldOnCreate = Axe.OnCreate
function Axe:OnCreate()

    oldOnCreate(self)
    
    self.hasWelder = false
    
end

function Axe:GetHasSecondary(player)
    return self.hasWelder
end
function Axe:GetSecondaryAttackRequiresPress()
    return true
end

if Server then
    function Axe:SwitchToWelder(player)
        self.secondaryAttacking = false
        -- GiveItem removes axe by itself
        --player:RemoveWeapon(self)
        --DestroyEntity(self)
        
        local newWelder = player:GiveItem(Welder.kMapName)
        player:SetHUDSlotActive(newWelder:GetHUDSlot()) -- switch to it
    end
    
    function Axe:OnSecondaryAttack(player)
        self.secondaryAttacking = true
        Weapon.OnSecondaryAttack(self, player)
    end
    
    function Axe:OnSecondaryAttackEnd(player)
        if self.secondaryAttacking and self.hasWelder then
            self:SwitchToWelder(player)
        end
        self.secondaryAttacking = false
    end
end
if Client then

    function Axe:CreateSwitchInfo()
    
        if not self.switchInfo then        
            self.switchInfo = GetGUIManager():CreateGUIScript("WeaponSwitch/GUISwitchInfo")
            self.switchInfo:SetSwitchName("Welder")
        end
        
    end
    
    function Axe:DestroySwitchInfo()
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
            self.switchInfo:SetIsVisible(player and localPlayer == player and self.hasWelder and self:GetIsActive() and not HelpScreen_GetHelpScreen():GetIsBeingDisplayed())
        end
    end
    
    function Axe:OnUpdateRender()
        UpdateGUI(self, self:GetParent())    
    end
    
    function Axe:OnDestroy()
        self:DestroySwitchInfo()        
        Ability.OnDestroy(self)
    end

end

Shared.LinkClassToMap("Axe", Axe.kMapName, networkVars)