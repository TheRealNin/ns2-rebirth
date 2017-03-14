
function Commander:SwitchTeamType()

    local team = self:GetTeam()
    local currentTeamType = team:GetTeamType()
    local newTeamType = currentTeamType == kMarineTeamType and kAlienTeamType or kMarineTeamType
    GetGamerules():SwitchTeamType(team:GetTeamNumber(), newTeamType)
    
end