
function Bot:UpdateTeam()
    PROFILE("Bot:UpdateTeam")

    local player = self:GetPlayer()

    -- Join random team (could force join if needed but will enter respawn queue if game already started)
    if player and player:GetTeamNumber() == 0 then
    
        if not self.team then
            self.team = ConditionalValue(math.random() < .5, 1, 2)
        end
        
        if GetGamerules():GetCanJoinTeamNumber(player, self.team) or Shared.GetCheatsEnabled() then
            GetGamerules():JoinTeam(player, self.team, true, true)
        end
        
    end

end