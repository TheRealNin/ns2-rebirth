

local function Precursors(client, team)

    local teamNumber = tonumber(team)
    if not teamNumber then
        --teamNumber = client:GetTeamNumber()
        Log("Need team number")
    end
    GetGamerules():SwitchTeamType(teamNumber, kPrecursorTeamType)
    
end


CreateServerAdminCommand("Console_precursors", Precursors, "Sets a team to precursors")