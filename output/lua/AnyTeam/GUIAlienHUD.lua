

local NO_PARASITE = 1
local PARASITED = 2
local ON_INFESTATION = 3

GUIAlienHUD.kParasiteTextureName = PrecacheAsset("ui/parasite_hud.dds")
GUIAlienHUD.kParasiteTextureCoords = { 0, 0, 64, 64 }
GUIAlienHUD.kParasiteSize = Vector(54, 54, 0)
GUIAlienHUD.kParasitePos = Vector(70, 0, 0)
GUIAlienHUD.kStatusParasiteTexture = PrecacheAsset("ui/alien_hud_health.dds")
GUIAlienHUD.kParasiteColor = {}
GUIAlienHUD.kParasiteColor[NO_PARASITE] = Color(0,0,0,0)
GUIAlienHUD.kParasiteColor[PARASITED] = Color(0xFF / 0xFF, 0xFF / 0xFF, 0xFF / 0xFF, 0.8)
GUIAlienHUD.kParasiteColor[ON_INFESTATION] = Color(0.7, 0.4, 0.4, 0.8)
GUIAlienHUD.kParasiteTimerSize = 118
GUIAlienHUD.kParasiteTimerPosition = Vector( -GUIAlienHUD.kParasiteTimerSize * 0.505, GUIAlienHUD.kParasiteTimerSize * 0.505, 0)

local parasiteTimerSettings = {}
parasiteTimerSettings.BackgroundWidth = GUIScale( GUIAlienHUD.kParasiteTimerSize )
parasiteTimerSettings.BackgroundHeight = GUIScale( GUIAlienHUD.kParasiteTimerSize )
parasiteTimerSettings.BackgroundAnchorX = GUIItem.Middle
parasiteTimerSettings.BackgroundAnchorY = GUIItem.Center
parasiteTimerSettings.BackgroundOffset = GUIScale( GUIAlienHUD.kParasiteTimerPosition )
parasiteTimerSettings.BackgroundTextureName = nil
parasiteTimerSettings.BackgroundTextureX1 = 0
parasiteTimerSettings.BackgroundTextureY1 = 0
parasiteTimerSettings.BackgroundTextureX2 = 128
parasiteTimerSettings.BackgroundTextureY2 = 128
parasiteTimerSettings.ForegroundTextureName = GUIAlienHUD.kStatusParasiteTexture
parasiteTimerSettings.ForegroundTextureWidth = 128
parasiteTimerSettings.ForegroundTextureHeight = 128
parasiteTimerSettings.ForegroundTextureX1 = 0
parasiteTimerSettings.ForegroundTextureY1 = 128
parasiteTimerSettings.ForegroundTextureX2 = 128
parasiteTimerSettings.ForegroundTextureY2 = 256
parasiteTimerSettings.InheritParentAlpha = false

-- force our darkvision to take priority
local oldInitialize = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()

    self.lastParasiteState = NO_PARASITE
    
    
    -- this has to happen before the screeneffects override
    oldInitialize(self)
    
    self.parasiteState = self:CreateAnimatedGraphicItem()
    self.parasiteState:SetTexture(GUIAlienHUD.kParasiteTextureName)
    self.parasiteState:SetTexturePixelCoordinates(unpack(GUIAlienHUD.kParasiteTextureCoords))
    self.parasiteState:AddAsChildTo(self.babblerIndicationFrame)
    self.parasiteState:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.parasiteState:SetColor(GUIAlienHUD.kParasiteColor[NO_PARASITE])
    self.parasiteState:SetBlendTechnique(GUIItem.Add)
    --self.parasiteState:SetLayer(self.hudLayer + 1)
    
    self.parasiteTimer = GUIDial()
    parasiteTimerSettings.BackgroundWidth = GUIAlienHUD.kParasiteTimerSize * self.scale
    parasiteTimerSettings.BackgroundHeight = GUIAlienHUD.kParasiteTimerSize * self.scale
    parasiteTimerSettings.BackgroundOffset = GUIAlienHUD.kParasiteTimerPosition * self.scale
    self.parasiteTimer:Initialize( parasiteTimerSettings )
    self.parasiteState:AddChild( self.parasiteTimer:GetBackground() )
    
	Client.DestroyScreenEffect(Player.screenEffects.darkVision)
    Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/AnyTeamVision.screenfx")
    
    self:Reset()
    self:SetIsVisible(not HelpScreen_GetHelpScreen():GetIsBeingDisplayed())
    
end

local oldUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
    oldUpdate(self, deltaTime)
    
    -- update parasite state
    
    if self.lastParasiteState ~= parasiteState then

        self.parasiteState:DestroyAnimations()
        self.parasiteState:SetColor(GUIAlienHUD.kParasiteColor[PlayerUI_GetPlayerParasiteState()], 0)
        
        if self.lastParasiteState < PlayerUI_GetPlayerParasiteState() then
            self.parasiteState:SetSize(GUIAlienHUD.kParasiteSize * 1.55)
            self.parasiteState:SetSize(GUIAlienHUD.kParasiteSize, 0.4)
        end
        
        self.lastParasiteState = PlayerUI_GetPlayerParasiteState()
    end
    
    if self.lastParasiteState then
        self.parasiteTimer:GetLeftSide():SetColor(GUIAlienHUD.kParasiteColor[PlayerUI_GetPlayerParasiteState()])
        self.parasiteTimer:GetRightSide():SetColor(GUIAlienHUD.kParasiteColor[PlayerUI_GetPlayerParasiteState()])
    else
        self.parasiteTimer:GetLeftSide():SetColor(GUIAlienHUD.kParasiteColor[NO_PARASITE])
        self.parasiteTimer:GetRightSide():SetColor(GUIAlienHUD.kParasiteColor[NO_PARASITE])
    end
    self.parasiteTimer:SetPercentage( PlayerUI_GetPlayerParasiteTimeRemaining() )
    self.parasiteTimer:SetIsVisible( PlayerUI_GetPlayerParasiteTimeRemaining() > 0 )
    self.parasiteTimer:Update(deltaTime)
    
end

local oldReset = GUIAlienHUD.Reset
function GUIAlienHUD:Reset()
    oldReset(self)
    if self.parasiteState then
        --Print("Resetting the parasite state")
        self.parasiteState:SetUniformScale(self.scale)
        self.parasiteState:SetSize(GUIAlienHUD.kParasiteSize)
        self.parasiteState:SetPosition(GUIAlienHUD.kParasitePos)
        
        self.parasiteTimer:Uninitialize()
        parasiteTimerSettings.BackgroundWidth = GUIAlienHUD.kParasiteTimerSize * self.scale
        parasiteTimerSettings.BackgroundHeight = GUIAlienHUD.kParasiteTimerSize * self.scale
        parasiteTimerSettings.BackgroundOffset = GUIAlienHUD.kParasiteTimerPosition * self.scale
        self.parasiteTimer:Initialize( parasiteTimerSettings )
        self.parasiteState:AddChild( self.parasiteTimer:GetBackground() )
    end
end