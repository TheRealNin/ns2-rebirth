
local kLargeFont = Fonts.kAgencyFB_Large
local kFont = Fonts.kAgencyFB_Small

local function CreateAbilityIcon(self, alienGraphicItem, techId)

    local graphicItem = GetGUIManager():CreateGraphicItem()
    graphicItem:SetTexture(GUIAlienBuyMenu.kAbilityIcons)
    graphicItem:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
    graphicItem:SetAnchor(GUIItem.Right, GUIItem.Top)
    graphicItem:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(techId, false)))
    graphicItem:SetColor(kIconColors[kAlienTeamType])
    
    local highLight = GetGUIManager():CreateGraphicItem()
    highLight:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
    highLight:SetIsVisible(false)
    highLight:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    highLight:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kUpgradeButtonBackgroundTextureCoordinates))
    
    graphicItem:AddChild(highLight)    
    alienGraphicItem:AddChild(graphicItem)
    
    return { Icon = graphicItem, TechId = techId, HighLight = highLight }

end

local function CreateAbilityIcons(self, alienGraphicItem, alienType)

    local lifeFormTechId = IndexToAlienTechId(alienType.Index)
    local availableAbilities = GetTechForCategory(lifeFormTechId)

    local numAbilities = #availableAbilities
    
    for i = 1, numAbilities do
    
        local techId = availableAbilities[#availableAbilities - i + 1]
        local ability = CreateAbilityIcon(self, alienGraphicItem, techId)
        local xPos = ((i-1) % 3 + 1) * -GUIAlienBuyMenu.kUpgradeButtonSize
        local yPos = (math.ceil(i/3)) * -GUIAlienBuyMenu.kUpgradeButtonSize
        
        ability.Icon:SetPosition(Vector(xPos, yPos, 0))    
        table.insert(self.abilityIcons, ability)
    
    end

end

function GUIAlienBuyMenu:_InitializeAlienButtons()

    self.alienButtons = { }

    for k, alienType in ipairs(GUIAlienBuyMenu.kAlienTypes) do
    
        -- The alien image.
        local alienGraphicItem = GUIManager:CreateGraphicItem()
        local ARAdjustedHeight = (alienType.Height / alienType.Width) * GUIAlienBuyMenu.kAlienButtonSize
        alienGraphicItem:SetSize(Vector(GUIAlienBuyMenu.kAlienButtonSize, ARAdjustedHeight, 0))
        alienGraphicItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
        alienGraphicItem:SetPosition(Vector(-GUIAlienBuyMenu.kAlienButtonSize / 2, -ARAdjustedHeight / 2, 0))
        alienGraphicItem:SetTexture("ui/" .. alienType.Name .. ".dds")
        alienGraphicItem:SetIsVisible(AlienBuy_IsAlienResearched(alienType.Index))
        
        -- Create the text that indicates how many players are playing as a specific alien type.
        local playersText = GUIManager:CreateTextItem()
        playersText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
        playersText:SetFontName(kLargeFont)
        playersText:SetScale(GetScaledVector())
        GUIMakeFontScale(playersText)
        playersText:SetTextAlignmentX(GUIItem.Align_Center)
        playersText:SetTextAlignmentY(GUIItem.Align_Min)
        playersText:SetText("x" .. ToString(ScoreboardUI_GetNumberOfAliensByType(alienType.Name)))
        playersText:SetColor(ColorIntToColor(kAlienTeamColor))
        playersText:SetPosition(Vector(0, -GUIAlienBuyMenu.kPlayersTextSize, 0))
        alienGraphicItem:AddChild(playersText)
        
        -- Create the text that indicates the research progress.
        local researchText = GUIManager:CreateTextItem()
        researchText:SetAnchor(GUIItem.Middle, GUIItem.Center)
        researchText:SetFontName(kFont)
        researchText:SetScale(GetScaledVector())
        GUIMakeFontScale(researchText)
        researchText:SetTextAlignmentX(GUIItem.Align_Center)
        researchText:SetTextAlignmentY(GUIItem.Align_Center)
        researchText:SetColor(ColorIntToColor(kAlienTeamColor))
        alienGraphicItem:AddChild(researchText)
        
        -- Create the selected background item for this alien item.
        local selectedBackground = GUIManager:CreateGraphicItem()
        selectedBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
        selectedBackground:SetSize(Vector(GUIAlienBuyMenu.kAlienSelectedButtonSize, GUIAlienBuyMenu.kAlienSelectedButtonSize, 0))
        selectedBackground:SetTexture(GUIAlienBuyMenu.kAlienSelectedBackground)
        -- Hide the selected background for now.
        selectedBackground:SetColor(Color(1, 1, 1, 0))
        selectedBackground:AddChild(alienGraphicItem)
        
        table.insert(self.alienButtons, { TypeData = alienType, Button = alienGraphicItem, SelectedBackground = selectedBackground, PlayersText = playersText, ResearchText = researchText, ARAdjustedHeight = ARAdjustedHeight })
        
        CreateAbilityIcons(self, alienGraphicItem, alienType)

        self.background:AddChild(selectedBackground)
        
    end
    
    self:_UpdateAlienButtons()

end

function GUIAlienBuyMenu:_UpdateAlienButtons()

    local numAlienTypes = self:_GetNumberOfAliensAvailable()
    local totalAlienButtonsWidth = GUIAlienBuyMenu.kAlienButtonSize * numAlienTypes
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    for k, alienButton in ipairs(self.alienButtons) do
    
        -- Info needed for the rest of this code.
        local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(alienButton.TypeData.Index)
        
        local buttonIsVisible = researched or researching
        alienButton.Button:SetIsVisible(buttonIsVisible)
        
        -- Don't bother updating anything else unless it is visible.
        if buttonIsVisible then
        
            local isCurrentAlien = AlienBuy_GetCurrentAlien() == alienButton.TypeData.Index
            if researched and (isCurrentAlien or self:_GetCanAffordAlienType(alienButton.TypeData.Index)) then
                alienButton.Button:SetColor(GUIAlienBuyMenu.kEnabledColor)
            elseif researched and not self:_GetCanAffordAlienType(alienButton.TypeData.Index) then
                alienButton.Button:SetColor(GUIAlienBuyMenu.kCannotBuyColor)
            elseif researching then
                alienButton.Button:SetColor(GUIAlienBuyMenu.kDisabledColor)
            end
            
            local mouseOver = self:_GetIsMouseOver(alienButton.Button)
            
            if mouseOver then
            
                local classStats = AlienBuy_GetClassStats(GUIAlienBuyMenu.kAlienTypes[alienButton.TypeData.Index].Index)
                local mouseOverName = GUIAlienBuyMenu.kAlienTypes[alienButton.TypeData.Index].LocaleName
                local health = classStats[2]
                local armor = classStats[3]
                self:_ShowMouseOverInfo(mouseOverName, GetTooltipInfoText(IndexToAlienTechId(alienButton.TypeData.Index)), classStats[4], health, armor)
                
            end
            
            -- Only show the background if the mouse is over this button.
            alienButton.SelectedBackground:SetColor(Color(1, 1, 1, ((mouseOver and 1) or 0)))

            local offset = Vector((((alienButton.TypeData.XPos - 1) / numAlienTypes) * (GUIAlienBuyMenu.kAlienButtonSize * numAlienTypes)) - (totalAlienButtonsWidth / 2), 0, 0)
            alienButton.SelectedBackground:SetPosition(Vector(-GUIAlienBuyMenu.kAlienButtonSize / 2, -GUIAlienBuyMenu.kAlienSelectedButtonSize / 2 - alienButton.ARAdjustedHeight / 2, 0) + offset)
            
            local numberOfAliens = ScoreboardUI_GetNumberOfAliensByType(alienButton.TypeData.Name)
            
            if numberOfAliens > 0 then
                alienButton.PlayersText:SetText("x" .. ToString(numberOfAliens))
            else
                alienButton.PlayersText:SetText("")
            end
            
            alienButton.ResearchText:SetIsVisible(researching)
            if researching then
                alienButton.ResearchText:SetText(string.format("%d%%", researchProgress * 100))
            end
            
        end
        
    end

end
