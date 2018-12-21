
local oldOnUpdatePlayer = Player.OnUpdatePlayer
function Player:OnUpdatePlayer(deltaTime)
	oldOnUpdatePlayer(self, deltaTime)
	
    if self:GetIsAlive() then

		-- ultra hacky
        if self.combatTable and self.combatTable.hasShield then
            if self.ActivatePersonalShieldDelayed then
                self:ActivatePersonalShieldDelayed()
            end
		end
	end
        
end