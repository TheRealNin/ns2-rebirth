
local kLineTextureCoord = {0, 0, 64, 16}

function GUIMinimapConnection:UpdateAnimation(teamNumber, modeIsMini, teamType)
    
    local isMarine = teamType == kMarineTeamType
    local hasLines = #GetEntitiesForTeam("MapConnector", teamNumber) > 2

    local animatedArrows = not modeIsMini and isMarine and hasLines

    local animation = ConditionalValue(animatedArrows, (Shared.GetTime() % 1) / 1, 0)
                
    local x1Coord = kLineTextureCoord[1] - animation * (kLineTextureCoord[3] - kLineTextureCoord[1])
    local x2Coord = x1Coord + (self.length or 0)
    
    -- Don't draw arrows for just 2 PGs, the direction is clear here
    -- Gorge tunnels also don't need this since it is limited to entrance/exit
    local textureIndex = ConditionalValue(animatedArrows, 1, 0) * 16
    
    self.line:SetTexturePixelCoordinates(x1Coord, textureIndex, x2Coord, textureIndex + 16)
    self.line:SetColor(GetColorCustomColorForTeamNumber(teamNumber, kMarineFontColor, kAlienFontColor, kMarineFontColor))
    self.line:SetSize(Vector(self.length, GUIScale(ConditionalValue(modeIsMini, 6, 10)), 0))

end