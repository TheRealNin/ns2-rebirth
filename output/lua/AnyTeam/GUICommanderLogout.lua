-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUICommanderLogout.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Manages displaying and animating the commander logout button in addition to logging the
-- commander out when pressed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUICommanderLogout' (GUIScript)

GUICommanderLogout.kMouseOverColor = Color(0.8, 0.8, 1, 1)
GUICommanderLogout.kDefaultColor = Color(1, 1, 1, 1)

GUICommanderLogout.kFrameHeight = 107
GUICommanderLogout.kLogoutMarineTextureName = "ui/marine_commander_logout.dds"
GUICommanderLogout.kLogoutAlienTextureName = "ui/alien_commander_logout.dds"

GUICommanderLogout.kChooseMarineTextureName = "ui/marine_commander_button.dds"
GUICommanderLogout.kChooseAlienTextureName = "ui/alien_commander_button.dds"

GUICommanderLogout.kFontName = Fonts.kAgencyFB_Large

local kBackgroundNoiseTexture = "ui/alien_commander_bg_smoke.dds"
local kSmokeyBackgroundSize

local kArrowAnimationDuration = 0.75
local kNumFrames = 7

local function GetLogoutFontColor()

    if CommanderUI_IsAlienCommander() then
        return kAlienFontColor
    else
        return kMarineFontColor
    end
    
end

local function UpdateItemsGUIScale(self)
    GUICommanderLogout.kBackgroundWidth = 208 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kBackgroundHeight = 107 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kBackgroundScaleDefault = GUIScale(Vector(1, 1, 1))
    GUICommanderLogout.kBackgroundScalePressed = GUIScale(Vector(0.9, 0.9, 0.9))
    GUICommanderLogout.kArrowWidth = 37 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kArrowHeight = 45 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kFontScale = Vector(1, 1, 0) * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kTooltipPos = Vector(56, -4, 0) * GUIScale(kCommanderGUIsGlobalScale)
    --GUICommanderLogout.kSwitchPos = Vector(-46, 168, 0) * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kSwitchPos = Vector(0, 180, 0) * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kSwitchSize = Vector(300, 90, 0) * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kLogoutOffset = GUIScale(2)
    kSmokeyBackgroundSize = GUIScale(Vector(186, 96, 0))
    
    
    GUICommanderLogout.kTeamButtonWidth = 571 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kTeamButtonHeight = 143 * GUIScale(kCommanderGUIsGlobalScale)
    GUICommanderLogout.kTeamButtonSpacing = 20 * GUIScale(kCommanderGUIsGlobalScale)
end

function GUICommanderLogout:Initialize()

    UpdateItemsGUIScale(self)
    
    if PlayerUI_GetTeamType() == kAlienTeamType then
        self:InitSmokeyBackground()
    end

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUICommanderLogout.kBackgroundWidth, GUICommanderLogout.kBackgroundHeight, 0))
    self.background:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.background:SetPosition(Vector(-GUICommanderLogout.kBackgroundWidth - GUICommanderLogout.kLogoutOffset, GUICommanderLogout.kLogoutOffset, 0))
    self.background:SetLayer(kGUILayerPlayerHUD)

    if CommanderUI_IsAlienCommander() then
        self.background:SetTexture(GUICommanderLogout.kLogoutAlienTextureName)
    else
        self.background:SetTexture(GUICommanderLogout.kLogoutMarineTextureName)
    end
    
    self.tooltip = GUIManager:CreateTextItem()
    self.tooltip:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.tooltip:SetTextAlignmentX(GUIItem.Align_Min)
    self.tooltip:SetTextAlignmentY(GUIItem.Align_Center)
    self.tooltip:SetPosition(GUICommanderLogout.kTooltipPos)
    self.tooltip:SetFontName(GUICommanderLogout.kFontName)
    self.tooltip:SetScale(GUICommanderLogout.kFontScale)
    GUIMakeFontScale(self.tooltip)
    self.tooltip:SetText(Locale.ResolveString("LOGOUT"))
    self.tooltip:SetColor(GetLogoutFontColor())
    self.background:AddChild(self.tooltip)
    
    
    self.readyTeam = GUIManager:CreateGraphicItem()
    self.readyTeam:SetPosition(GUICommanderLogout.kSwitchPos - GUICommanderLogout.kSwitchSize.x*0.5)
    self.readyTeam:SetLayer(kGUILayerPlayerHUD)
    self.readyTeam:SetSize(GUICommanderLogout.kSwitchSize)
    self.readyTeam:SetColor(Color(0.1,0.1,0.1,0.9))
    self.readyTeam:SetTextAlignmentX(GUIItem.Align_Center)
    self.readyTeam:SetTextAlignmentY(GUIItem.Align_Center)
    self.readyTeam:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    
    self.readyTeamText = GUIManager:CreateTextItem()
    self.readyTeamText:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    self.readyTeamText:SetTextAlignmentX(GUIItem.Align_Center)
    self.readyTeamText:SetTextAlignmentY(GUIItem.Align_Center)
    self.readyTeamText:SetFontName(GUICommanderLogout.kFontName)
    self.readyTeamText:SetScale(GUICommanderLogout.kFontScale)
    GUIMakeFontScale(self.readyTeamText)
    self.readyTeam:AddChild(self.readyTeamText)
    
    if CommanderUI_GetIsReady() then
        self.readyTeamText:SetText(Locale.ResolveString("Your team is ready."))
    else
        self.readyTeamText:SetText(Locale.ResolveString("Ready?"))
    end
    self.readyTeamText:SetColor(Color(1,1,1,1))
    
    
    self.marineTeam = GUIManager:CreateGraphicItem()
    self.marineTeam:SetSize(Vector(GUICommanderLogout.kTeamButtonWidth, GUICommanderLogout.kTeamButtonHeight, 0))
    self.marineTeam:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    self.marineTeam:SetPosition(Vector(-GUICommanderLogout.kTeamButtonWidth - GUICommanderLogout.kTeamButtonSpacing, -GUICommanderLogout.kTeamButtonHeight, 0))
    self.marineTeam:SetLayer(kGUILayerPlayerHUD)
    self.marineTeam:SetTexture(GUICommanderLogout.kChooseMarineTextureName)
    self.marineTeam:SetColor(Color(0.4,0.4,0.4))
    --self.marineTeam:SetColor(ConditionalValue(CommanderUI_IsAlienCommander(), Color(0.4,0.4,0.4), Color(1,1,1)))
    
    local marineName = GUIManager:CreateTextItem()
    marineName:SetFontName(GUICommanderLogout.kFontName)
    marineName:SetScale(GUICommanderLogout.kFontScale)
    marineName:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    marineName:SetTextAlignmentX(GUIItem.Align_Center)
    marineName:SetTextAlignmentY(GUIItem.Align_Center)
    marineName:SetPosition(Vector(GUICommanderLogout.kTeamButtonSpacing,0, 0))
    GUIMakeFontScale(marineName)
    marineName:SetText(Locale.ResolveString("Team type: Marine"))
    marineName:SetColor(kMarineFontColor)
    self.marineTeam:AddChild(marineName)
    
    self.alienTeam = GUIManager:CreateGraphicItem()
    self.alienTeam:SetSize(Vector(GUICommanderLogout.kTeamButtonWidth, GUICommanderLogout.kTeamButtonHeight, 0))
    self.alienTeam:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    self.alienTeam:SetPosition(Vector(GUICommanderLogout.kTeamButtonSpacing, -GUICommanderLogout.kTeamButtonHeight, 0))
    self.alienTeam:SetLayer(kGUILayerPlayerHUD)
    self.alienTeam:SetTexture(GUICommanderLogout.kChooseAlienTextureName)
    self.alienTeam:SetColor(Color(0.4,0.4,0.4))
    --self.alienTeam:SetColor(ConditionalValue(CommanderUI_IsAlienCommander(), Color(1,1,1), Color(0.4,0.4,0.4)))
    
    local alienName = GUIManager:CreateTextItem()
    alienName:SetFontName(GUICommanderLogout.kFontName)
    alienName:SetScale(GUICommanderLogout.kFontScale)
    alienName:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    alienName:SetTextAlignmentX(GUIItem.Align_Center)
    alienName:SetTextAlignmentY(GUIItem.Align_Center)
    alienName:SetPosition(Vector(-GUICommanderLogout.kTeamButtonSpacing,0, 0))
    GUIMakeFontScale(alienName)
    alienName:SetText(Locale.ResolveString("Team type: Alien"))
    alienName:SetColor(kAlienFontColor)
    self.alienTeam:AddChild(alienName)
    
    self.selectedTeam = nil --ConditionalValue(CommanderUI_IsAlienCommander(), kAlienTeamType, kMarineTeamType)
    
    self:Update(0)
    
end

function GUICommanderLogout:InitSmokeyBackground()

    self.smokeyBackground = GUIManager:CreateGraphicItem()
    self.smokeyBackground:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.smokeyBackground:SetSize(kSmokeyBackgroundSize)
    self.smokeyBackground:SetLayer(kGUILayerPlayerHUDBackground)
    
    local backgroundPos = Vector(-GUICommanderLogout.kBackgroundWidth - GUICommanderLogout.kLogoutOffset, GUICommanderLogout.kLogoutOffset, 0)
    self.smokeyBackground:SetPosition(backgroundPos)
    self.smokeyBackground:SetShader("shaders/GUISmoke.surface_shader")
    self.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
    self.smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
    self.smokeyBackground:SetFloatParameter("correctionX", 0.6)
    self.smokeyBackground:SetFloatParameter("correctionY", 0.4)

end

function GUICommanderLogout:Uninitialize()

    if self.background then
    
        GUI.DestroyItem(self.background)
        self.background = nil
        
    end
    
    if self.smokeyBackground  then
        GUI.DestroyItem(self.smokeyBackground)
        self.smokeyBackground = nil
    end
    
    if self.readyTeam  then
        GUI.DestroyItem(self.readyTeam)
        self.readyTeam = nil
    end
    
    if self.marineTeam  then
        GUI.DestroyItem(self.marineTeam)
        self.marineTeam = nil
    end
    
    if self.alienTeam  then
        GUI.DestroyItem(self.alienTeam)
        self.alienTeam = nil
    end
end

function GUICommanderLogout:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUICommanderLogout:SendKeyEvent(key, down)

    if key == InputKey.MouseButton0 then

        local mouseX, mouseY = Client.GetCursorPosScreen()
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
        
        if containsPoint and GetCommanderLogoutAllowed() then
            -- Check if the button was pressed.
            if not down then
                CommanderUI_Logout()
                return false
            end
            return true
        end
        
        if GetCommanderSwitchTeamAllowed() and not CommanderUI_GetIsReady() then
            
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.readyTeam, mouseX, mouseY)
            
            if self.selectedTeam and containsPoint then
                -- Check if the button was pressed.
                if not down then
                    CommanderUI_SetTeamTypeAndReady(self.selectedTeam)
                    return false
                end
                return true
            end
            
            
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.marineTeam, mouseX, mouseY)
            
            if containsPoint  then
                self.selectedTeam = kMarineTeamType
            end
            
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.alienTeam, mouseX, mouseY)
            
            if containsPoint then
                self.selectedTeam = kAlienTeamType
            end
        end
        
    end
    
    return false
    
end

local function GetCoordsForFrame(frame)

    local x1 = 0
    local x2 = 208
    local y1 = frame * GUICommanderLogout.kFrameHeight
    local y2 = (frame + 1) * GUICommanderLogout.kFrameHeight
    
    return x1, y1, x2, y2
    
end

function GUICommanderLogout:Update(deltaTime)

    PROFILE("GUICommanderLogout:Update")
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    local animateArrows = false
    
    self.tooltip:SetColor(LerpColor(GetLogoutFontColor(), Color(0, 0, 0), 0.25))
    
    -- Animate arrows when the mouse is hovering over.
    local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
    if containsPoint then
    
        animateArrows = true
        self.tooltip:SetColor(GetLogoutFontColor())
        
    end
    
    
    local switchTeamAllowed = GetCommanderSwitchTeamAllowed()
    local showOptions = switchTeamAllowed and not CommanderUI_GetIsReady()
    self.readyTeam:SetIsVisible(switchTeamAllowed)
    if switchTeamAllowed then
        self.readyTeamText:SetColor(LerpColor(kMarineFontColor, Color(0, 0, 0), 0.25))
        
        if showOptions then
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.readyTeam, mouseX, mouseY)
            if containsPoint then
                self.readyTeamText:SetColor(kMarineFontColor)
            end
        end
    end
    
    self.marineTeam:SetIsVisible(showOptions)
    self.alienTeam:SetIsVisible(showOptions)
    if showOptions then
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.marineTeam, mouseX, mouseY)
        self.marineTeam:SetColor(ConditionalValue(containsPoint or self.selectedTeam == kMarineTeamType, Color(1,1,1), Color(0.4,0.4,0.4)))
        
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.alienTeam, mouseX, mouseY)
        self.alienTeam:SetColor(ConditionalValue(containsPoint or self.selectedTeam == kAlienTeamType, Color(1,1,1), Color(0.4,0.4,0.4)))
        
    end
    
    if not self.animatingArrows and animateArrows then
        self.arrowAnimationStartTime = Shared.GetTime()
    end
    
    self.animatingArrows = animateArrows
    
    -- Update background pixel coords.
    if self.animatingArrows then
    
        local frame = math.floor(kNumFrames * (((Shared.GetTime() - self.arrowAnimationStartTime) % kArrowAnimationDuration) / kArrowAnimationDuration))
        self.background:SetTexturePixelCoordinates(GetCoordsForFrame(frame))
        
    else
        self.background:SetTexturePixelCoordinates(GetCoordsForFrame(0))
    end
    
    local logoutAllowed = GetCommanderLogoutAllowed()
    self.background:SetIsVisible(logoutAllowed)
    if self.smokeyBackground then
        self.smokeyBackground:SetIsVisible(logoutAllowed)
    end
    
    
end

function GUICommanderLogout:ContainsPoint(pointX, pointY)
    return GUIItemContainsPoint(self.background, pointX, pointY)
end