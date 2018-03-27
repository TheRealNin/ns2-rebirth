--[[
local oldUpdate = GUIScoreboard.Update
function GUIScoreboard:Update(deltaTime)
    
    oldUpdate(self, deltaTime)
    
    local vis = self.visible and not self.hiddenOverride
    
    
    if vis then
    
        local gameTime = PlayerUI_GetGameLengthTime()
        local minutes = math.floor( gameTime / 60 )
        local seconds = math.floor( gameTime - minutes * 60 )

        local serverName = Client.GetServerIsHidden() and "Hidden" or Client.GetConnectedServerName()
        local gameTimeText = serverName .. " (Marine versus Marine) | mvm_" .. Shared.GetMapName() .. string.format( " - %d:%02d", minutes, seconds)
        
        self.gameTime:SetText(gameTimeText)
        
    end
end
]]--