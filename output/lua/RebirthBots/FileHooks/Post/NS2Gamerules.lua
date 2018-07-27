
if Server then


    function NS2Gamerules:OnCommanderLogout(commandStructure, oldCommander)
        if (self.gameInfo:GetRookieMode() or self.removeCommanderBots)and self:GetGameState() > kGameState.NotStarted and
                self:GetGameState() < kGameState.Team1Won and
                not self.botTeamController:GetCommanderBot(commandStructure:GetTeamNumber()) then
            OnConsoleAddBots(nil, 1, commandStructure:GetTeamNumber(), "com")
        end
    end
    
    local oldEndGame = NS2Gamerules.EndGame
    function NS2Gamerules:EndGame(winningTeam, autoConceded)
    
        if self:GetGameState() == kGameState.Started then

            --remove commander bots that where added via the comm bot vote
            if self.removeCommanderBots then
                self.botTeamController:RemoveCommanderBots()
                self.removeCommanderBots = false
            end
            
        end
        oldEndGame(self, winningTeam, autoConceded)
    end

    
    
    
    function NS2Gamerules:GetCanJoinTeamNumber(player, teamNumber)

            
        if player:isa("Commander") then
            return true
        end
        
        local forceEvenTeams = Server.GetConfigSetting("force_even_teams_on_join")
        if forceEvenTeams then
            
            local team1Players, _, team1Bots = self.team1:GetNumPlayers()
            local team2Players, _, team2Bots = self.team2:GetNumPlayers()
            --Log("player.is_a_robot: %s", player.is_a_robot)
            
            if not player.is_a_robot then
              team1Players = team1Players - team1Bots
              team2Players = team2Players - team2Bots
            end
            
            if (team1Players > team2Players) and (teamNumber == self.team1:GetTeamNumber()) then
                return false, 0
            elseif (team2Players > team1Players) and (teamNumber == self.team2:GetTeamNumber()) then
                return false, 0
            end

        end

        if not Shared.GetCheatsEnabled() and Server.IsDedicated() and
                not self.botTraining and player:GetPlayerLevel() ~= -1 then
            if self.gameInfo:GetRookieMode() and player:GetPlayerLevel() >= kRookieAllowedLevel then
                return false, 2
            end
        end
        
        return true
        
    end
    
    --TODO: Remove this hack
    local oldUpdate = NS2Gamerules.OnUpdate
    local lastBotUpdate = 0
    function NS2Gamerules:OnUpdate(timePassed)
        oldUpdate(self, timePassed)
        if lastBotUpdate + 10 < Shared.GetTime() then
            lastBotUpdate = Shared.GetTime()
            self:UpdateBots()
        end
    end
end