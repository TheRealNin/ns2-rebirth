
local kEyeTexture = PrecacheAsset("ui/ShadowDance.dds")
local kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
local kShadowDanceRegenTime = 1

local oldInitialize = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()
    oldInitialize(self)
    
    local kVisibilitylIconSize = GUIScale(60)
    local kVisibilityOffset = GUIScale(100)
    local visbilitySize = Vector(kVisibilitylIconSize, kVisibilitylIconSize, 0)
    self.visibilityBg = GUIManager:CreateGraphicItem()
    self.visibilityBg:SetSize(visbilitySize)
    self.visibilityBg:SetPosition(Vector(-kVisibilitylIconSize * 0.5, kVisibilitylIconSize * 0.25 + kVisibilityOffset, 0))
    self.visibilityBg:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.visibilityBg:SetLayer(kGUILayerPlayerHUDBackground)
    self.visibilityBg:SetColor(Color(0,0,0,0))
    self.visibilityBg:SetIsVisible(false)
    
    
    self.eyeBg = GUIManager:CreateGraphicItem()
    self.eyeBg:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.eyeBg:SetSize(visbilitySize)
    self.eyeBg:SetPosition(visbilitySize * -.5)
    self.eyeBg:SetShader("shaders/GUISmokeHUD.surface_shader")
    self.eyeBg:SetTexture("ui/alien_logout_smkmask.dds")
    self.eyeBg:SetAdditionalTexture("noise", "ui/alien_logout_smkmask.dds")
    self.eyeBg:SetFloatParameter("correctionX", 0.5)
    self.eyeBg:SetFloatParameter("correctionY", -0.5)
    self.eyeBg:SetIsVisible(false)
    
    self.eyeIcon = GUIManager:CreateGraphicItem()
    self.eyeIcon:SetSize(Vector(GUIScale(kVisibilitylIconSize*0.75), GUIScale(kVisibilitylIconSize*0.75), 0))
    self.eyeIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.eyeIcon:SetPosition(Vector(-GUIScale(kVisibilitylIconSize*0.75) / 2, -GUIScale(kVisibilitylIconSize*0.75) / 2, 0))
    self.eyeIcon:SetTexture(kEyeTexture)
    self.eyeIcon:SetIsVisible(false)
    
    self.visibilityBg:AddChild(self.eyeBg)
    self.visibilityBg:AddChild(self.eyeIcon)
    
end


local oldSetIsVisible = GUIAlienHUD.SetIsVisible
function GUIAlienHUD:SetIsVisible(isVisible)
    oldSetIsVisible(self, isVisible)
    if self.visibilityBg then
        self.visibilityBg:SetIsVisible(isVisible)
    end
end


local oldUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
    oldUpdate(self, deltaTime)
    if AlienUI_GetHasShadowDance() then
        self.visibilityBg:SetIsVisible(not AlienUI_GetIsSighted())
    else
        self.visibilityBg:SetIsVisible(false)
    end
end

local oldUninitialize = GUIAlienHUD.Uninitialize
function GUIAlienHUD:Uninitialize()
    oldUninitialize(self)
    
    GUI.DestroyItem(self.visibilityBg)
    self.visibilityBg = nil
    
end