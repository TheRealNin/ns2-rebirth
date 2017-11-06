
local oldReplace = Player.Replace
function Player:Replace(mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)
    local wasShielded = self.deservesShield
    local wasAlive = self:GetIsAlive()
    local teamChanged = newTeamNumber ~= nil and newTeamNumber ~= self:GetTeamNumber()
    
    local player = oldReplace(self, mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)
    
    if player ~= self and not teamChanged then
        if wasShielded and wasAlive and GetGamerules():GetGameState() ~= kGameState.NotStarted then
            player.deservesShield = true
            if player.ActivatePersonalShieldDelayed then
                player:ActivatePersonalShieldDelayed()
            end
        else
            player.deservesShield = false
        end
    end
    
    return player
end