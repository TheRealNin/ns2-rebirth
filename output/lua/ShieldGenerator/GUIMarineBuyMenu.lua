if GUIMarineBuyMenu.kItemSlotForWeapon then
    GUIMarineBuyMenu.kItemSlotForWeapon["shieldgenerator"] = 3
end

local shieldTexture = PrecacheAsset("ui/shield.dds")
local shieldBigIcon = PrecacheAsset("ui/shield_bigicon.dds")
local smallIconHeight = 64
local smallIconWidth = 128
local bigIconWidth = 400
local bigIconHeight = 300

local old_InitializeItemButtons = GUIMarineBuyMenu._InitializeItemButtons
function GUIMarineBuyMenu:_InitializeItemButtons()
    old_InitializeItemButtons(self)
    
    
    if self.itemButtons then
        for i, item in ipairs(self.itemButtons) do
            if item.TechId == kTechId.ShieldGenerator then
                item.Button:SetTexture(shieldTexture)
                item.Button:SetTexturePixelCoordinates(0, 0, smallIconWidth, smallIconHeight)
            end
        end
    end
end

local old_UpdateContent = GUIMarineBuyMenu._UpdateContent
function GUIMarineBuyMenu:_UpdateContent(deltaTime)
    old_UpdateContent(self, deltaTime)
    local techId = self.hoverItem
    if not self.hoverItem then
        techId = self.selectedItem
    end
    if techId ~= nil and techId ~= kTechId.None then
        if techId == kTechId.ShieldGenerator then
            self.portrait:SetTexture(shieldBigIcon)
            self.portrait:SetTexturePixelCoordinates(0, 0, bigIconWidth, bigIconHeight)
        else
            self.portrait:SetTexture(GUIMarineBuyMenu.kBigIconTexture)
        end
    end
end