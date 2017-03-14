
local function OnCommandSwitchTeamType(client)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() and GetCommanderSwitchTeamAllowed() then
    
        player:SwitchTeamType()
    
    end
end

Event.Hook("Console_switchteamtype", OnCommandSwitchTeamType)
