
Script.Load("lua/Prowler/ReplaceUpValue.lua")


local function newUpdateItemsGUIScale(self)

    local scaledVector = GetScaledVector()
    
    GUIAlienBuyMenu.kAlienTypes = { { LocaleName = Locale.ResolveString("FADE"), Name = "Fade", Width = GUIScale(188), Height = GUIScale(220), XPos = 5, Index = 1 },
                                { LocaleName = Locale.ResolveString("GORGE"), Name = "Gorge", Width = GUIScale(200), Height = GUIScale(167), XPos = 1, Index = 2 },
                                { LocaleName = Locale.ResolveString("LERK"), Name = "Lerk", Width = GUIScale(284), Height = GUIScale(253), XPos = 4, Index = 3 },
                                { LocaleName = Locale.ResolveString("ONOS"), Name = "Onos", Width = GUIScale(304), Height = GUIScale(326), XPos = 6, Index = 4 },
                                { LocaleName = Locale.ResolveString("SKULK"), Name = "Skulk", Width = GUIScale(240), Height = GUIScale(170), XPos = 2, Index = 5 },
                                { LocaleName = "Prowler", Name = "Prowler", Width = GUIScale(240), Height = GUIScale(170), XPos = 3, Index = 6 } }
    GUIAlienBuyMenu.kBackgroundWidth = GUIScale((GUIAlienBuyMenu.kBackgroundTextureCoordinates[3] - GUIAlienBuyMenu.kBackgroundTextureCoordinates[1]) * 0.80)
    GUIAlienBuyMenu.kBackgroundHeight = GUIScale((GUIAlienBuyMenu.kBackgroundTextureCoordinates[4] - GUIAlienBuyMenu.kBackgroundTextureCoordinates[2]) * 0.80)
    
    -- We want the background graphic to look centered around the circle even though there is the part coming off to the right.
    GUIAlienBuyMenu.kBackgroundXOffset = GUIScale(75)
    
    GUIAlienBuyMenu.kAlienButtonSize = GUIScale(150)
    GUIAlienBuyMenu.kPlayersTextSize = GUIScale(24)
    GUIAlienBuyMenu.kAlienSelectedButtonSize = GUIAlienBuyMenu.kAlienButtonSize * 2
    GUIAlienBuyMenu.kResearchTextSize = GUIScale(24)
    
    GUIAlienBuyMenu.kResourceIconWidth = GUIScale(33)
    GUIAlienBuyMenu.kResourceIconHeight = GUIScale(33)
    
    GUIAlienBuyMenu.kEvolveButtonWidth = GUIScale(250)
    GUIAlienBuyMenu.kEvolveButtonHeight = GUIScale(80)
    GUIAlienBuyMenu.kEvolveButtonYOffset = GUIScale(20)
    GUIAlienBuyMenu.kEvolveButtonTextSize = GUIScale(22)
    
    kVeinsMargin = GUIScale(4)
    
    GUIAlienBuyMenu.kSlotDistance = GUIScale(120)
    GUIAlienBuyMenu.kSlotSize = GUIScale(54)
    
    GUIAlienBuyMenu.kCurrentAlienSize = GUIScale(200)
    GUIAlienBuyMenu.kCurrentAlienTitleTextSize = GUIScale(32)
    GUIAlienBuyMenu.kCurrentAlienTitleOffset = Vector(0, GUIScale(25), 0)
    
    GUIAlienBuyMenu.kResourceDisplayWidth = GUIScale((GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[3] - GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[1]) * 1.2)
    GUIAlienBuyMenu.kResourceDisplayHeight = GUIScale((GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[4] - GUIAlienBuyMenu.kResourceDisplayBackgroundTextureCoordinates[2]) * 1.2)
    GUIAlienBuyMenu.kResourceFontSize = GUIScale(24)
    GUIAlienBuyMenu.kResourceTextYOffset = GUIScale(200)
    
    GUIAlienBuyMenu.kHealthIconWidth = GUIScale(GUIAlienBuyMenu.kHealthIconTextureCoordinates[3] - GUIAlienBuyMenu.kHealthIconTextureCoordinates[1])
    GUIAlienBuyMenu.kHealthIconHeight = GUIScale(GUIAlienBuyMenu.kHealthIconTextureCoordinates[4] - GUIAlienBuyMenu.kHealthIconTextureCoordinates[2])
    
    GUIAlienBuyMenu.kArmorIconWidth = GUIScale(GUIAlienBuyMenu.kArmorIconTextureCoordinates[3] - GUIAlienBuyMenu.kArmorIconTextureCoordinates[1])
    GUIAlienBuyMenu.kArmorIconHeight = GUIScale(GUIAlienBuyMenu.kArmorIconTextureCoordinates[4] - GUIAlienBuyMenu.kArmorIconTextureCoordinates[2])
    
    GUIAlienBuyMenu.kMouseOverTitleOffset = Vector(GUIScale(-25), GUIScale(-100), 0)
    GUIAlienBuyMenu.kMouseOverInfoResIconOffset = GUIScale(Vector(-34, 120, 0))
    GUIAlienBuyMenu.kMouseOverInfoTextSize = GUIScale(20)
    GUIAlienBuyMenu.kMouseOverInfoOffset = Vector(GUIScale(-25), GUIScale(-10), 0)
    
    kTooltipTextWidth = GUIScale(300)
    
    GUIAlienBuyMenu.kUpgradeButtonSize = GUIScale(54)
    GUIAlienBuyMenu.kUpgradeButtonDistance = GUIScale(198)
    -- The distance in pixels to move the button inside the embryo when selected.
    GUIAlienBuyMenu.kUpgradeButtonDistanceInside = GUIScale(74)
    
    GUIAlienBuyMenu.kCloseButtonSize = GUIScale(48)
    
    for location, texCoords in pairs(GUIAlienBuyMenu.kCornerTextureCoordinates) do
        GUIAlienBuyMenu.kCornerWidths[location] = GUIScale(texCoords[3] - texCoords[1])
        GUIAlienBuyMenu.kCornerHeights[location] = GUIScale(texCoords[4] - texCoords[2])
    end
    
end

ReplaceUpValue( GUIAlienBuyMenu.Initialize, "UpdateItemsGUIScale", newUpdateItemsGUIScale, { LocateRecurse = true; CopyUpValues = true; } )

