

function OnCommandSwitchTeamTypes(message)
    
    kTeam1Type = message.team1Type
    kTeam2Type = message.team2Type
    
    kTeamIndexToType[kTeam1Index] = kTeam1Type
    kTeamIndexToType[kTeam2Index] = kTeam2Type
    
end


Predict.HookNetworkMessage("SwitchTeamTypes", OnCommandSwitchTeamTypes)