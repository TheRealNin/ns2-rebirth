
if Server then

    function JoinRandomTeam(player)
        
        -- Join team with less players or random.
        local team1Players, _, team1Bots = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
        local team2Players, _, team2Bots = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
        
        team1Players = team1Players - team1Bots
        team2Players = team2Players - team2Bots
        
        -- Join team with least.
        if team1Players < team2Players then
            Server.ClientCommand(player, "jointeamone")
        elseif team2Players < team1Players then
            Server.ClientCommand(player, "jointeamtwo")
        else
        
            -- Join random otherwise.
            if math.random() < 0.5 then
                Server.ClientCommand(player, "jointeamone")
            else
                Server.ClientCommand(player, "jointeamtwo")
            end
            
        end
        
    end
    
    function TeamJoin:OnTriggerEntered(enterEnt, triggerEnt)

        if enterEnt:isa("Player") then
        
            if self.teamNumber == kTeamReadyRoom then
                Server.ClientCommand(enterEnt, "spectate")
            elseif self.teamNumber == kTeam1Index then
                Server.ClientCommand(enterEnt, "jointeamone")
            elseif self.teamNumber == kTeam2Index then
                Server.ClientCommand(enterEnt, "jointeamtwo")
            else
                JoinRandomTeam(enterEnt)
            end
            
        end
        
    end
end