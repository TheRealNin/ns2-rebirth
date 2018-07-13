
local kSwitchTeamTypesMessage =
{
    team1Type = "integer (0 to 3)",
    team2Type = "integer (0 to 3)",
    forced = "boolean",
}
Shared.RegisterNetworkMessage("SwitchTeamTypes", kSwitchTeamTypesMessage)