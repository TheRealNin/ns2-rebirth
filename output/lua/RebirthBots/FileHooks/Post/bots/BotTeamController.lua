

local oldUpdateBots = BotTeamController.UpdateBots
function BotTeamController:UpdateBots()
	local oldMaxBots = self.MaxBots
	if self.EvenTeamsWithBots then
		
		local team1HumanNum = self:GetPlayerNumbersForTeam(kTeam1Index, true)
		local team2HumanNum = self:GetPlayerNumbersForTeam(kTeam2Index, true)
		
		local mostHumans = math.max(team1HumanNum, team2HumanNum)
		
		self.MaxBots = math.max(mostHumans * 2, oldMaxBots, 2) -- need a minimum of 2 since the update code "optimizes" if max is 0
		
	end
	
	--Log("updating bots num: %s, locked? %s", self.MaxBots, self.updateLock)
	oldUpdateBots(self)
	
	-- restore the "true" max
	self.MaxBots = oldMaxBots
end


function BotTeamController:SetEvenTeamsWithBots(evenTeams)
    self.EvenTeamsWithBots = evenTeams
end
