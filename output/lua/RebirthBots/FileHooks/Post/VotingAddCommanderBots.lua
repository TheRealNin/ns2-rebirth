
if Server then

    function VotingAddCommanderBotsAllowed()
        return GetGamemode() == "ns2" or kAnyTeamEnabled
    end
    
end