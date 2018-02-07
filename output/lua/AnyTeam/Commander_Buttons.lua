
function CommanderUI_SwitchTeamType()
    local commanderPlayer = Client.GetLocalPlayer()
    commanderPlayer:SwitchTeamType()
end

function CommanderUI_SetTeamTypeAndReady(teamType)
    local commanderPlayer = Client.GetLocalPlayer()
    commanderPlayer:SetCommanderReady(teamType)
end


function CommanderUI_GetIsReady()
    local commanderPlayer = Client.GetLocalPlayer()
    return commanderPlayer:GetIsReady()
end