
ModLoader.SetupFileHook( "lua/Skulk.lua", "lua/Prowler/Skulk.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienTeam.lua", "lua/Prowler/AlienTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIAlienBuyMenu.lua", "lua/Prowler/GUIAlienBuyMenu.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienBuy_Client.lua", "lua/Prowler/AlienBuy_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Shared.lua", "lua/Prowler/Shared.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/Prowler/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/Prowler/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/Prowler/Globals.lua", "post" )
ModLoader.SetupFileHook( "lua/Drifter.lua", "lua/Prowler/Drifter.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/Prowler/NS2Utility.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2ConsoleCommands_Server.lua", "lua/Prowler/NS2ConsoleCommands_Server.lua", "post" )

-- REPLACEMENTS because UWE hotfix
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/Prowler/TechData.lua", "replace" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/Prowler/TechTreeConstants.lua", "replace" )