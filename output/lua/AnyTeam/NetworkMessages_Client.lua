

function OnCommandSwitchTeamTypes(message)
    
    kTeam1Type = message.team1Type
    kTeam2Type = message.team2Type
    kForcedByConfig = message.forced
    
    kTeamIndexToType[kTeam1Index] = kTeam1Type
    kTeamIndexToType[kTeam2Index] = kTeam2Type
    
end

function OnTeamConceded(message)

    if message.teamNumber == kTeam1Index then
        ChatUI_AddSystemMessage(kTeam1Name .. " have surrendered")
    else
        ChatUI_AddSystemMessage(kTeam2Name .. " have surrendered")
    end
    
end


Client.HookNetworkMessage("SwitchTeamTypes", OnCommandSwitchTeamTypes)