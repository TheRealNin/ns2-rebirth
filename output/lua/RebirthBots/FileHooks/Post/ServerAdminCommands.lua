

CreateServerAdminCommand("Console_sup_bots", function() admin_debug_bots = not admin_debug_bots end, "Toggles bots reporting what they are trying to do")



local function SetEvenTeamsWithBots(client, evenTeams)

    local gamerules = GetGamerules()
    if not gamerules then return end

    if not gamerules.SetEvenTeamsWithBots then
        ServerAdminPrint(client, "The current gamemode does not support dynamically evening the teams!")
        return
    end

    gamerules:SetEvenTeamsWithBots(evenTeams)
	if evenTeams then
		ServerAdminPrint(client, "Teams will now stay balanced using bots")
	else
		ServerAdminPrint(client, "Teams will NOT stay balanced using bots")
	end
end

CreateServerAdminCommand("Console_sv_bots_even_teams", SetEvenTeamsWithBots, "<max>, The server will balance the teams with bots")
