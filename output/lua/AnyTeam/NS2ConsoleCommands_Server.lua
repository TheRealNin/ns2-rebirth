
local function OnCommandSwitchTeamType(client)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() and GetCommanderSwitchTeamAllowed() then
    
        player:SwitchTeamType()
    
    end
end

local function OnCommandSetCommanderReady(client, arg)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() and GetCommanderSwitchTeamAllowed() then
    
        player:SetCommanderReady(arg)
    
    end
end


Event.Hook("Console_switchteamtype", OnCommandSwitchTeamType)
Event.Hook("Console_commanderready", OnCommandSetCommanderReady)
