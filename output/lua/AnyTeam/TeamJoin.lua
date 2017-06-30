
if Server then
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