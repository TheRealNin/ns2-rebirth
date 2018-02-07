
function Commander:SwitchTeamType()

    local team = self:GetTeam()
    local currentTeamType = team:GetTeamType()
    local newTeamType = currentTeamType == kMarineTeamType and kAlienTeamType or kMarineTeamType
    GetGamerules():SwitchTeamType(team:GetTeamNumber(), newTeamType)
    
end


function Commander:SetCommanderReady(newTeamType)

    local teamType = kMarineTeamType
    if newTeamType == "2" then
        teamType = kAlienTeamType
    end
    local team = self:GetTeam()
    local currentTeamType = team:GetTeamType()
    GetGamerules():SwitchTeamType(team:GetTeamNumber(), teamType)
    
end