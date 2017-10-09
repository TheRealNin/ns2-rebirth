
ModLoader.SetupFileHook( "lua/MarineBuy_Client.lua", "lua/ArmoryGUI/MarineBuy_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Armory.lua", "lua/ArmoryGUI/Armory.lua", "post" )
ModLoader.SetupFileHook( "lua/PrototypeLab.lua", "lua/ArmoryGUI/PrototypeLab.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/ArmoryGUI/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine_Server.lua", "lua/ArmoryGUI/Marine_Server.lua", "post" )

-- GUI replacements
ModLoader.SetupFileHook( "lua/GUIMarineBuyMenu.lua", "lua/ArmoryGUI/GUIMarineBuyMenu.lua", "replace" )
-- ModLoader.SetupFileHook( "lua/Scoreboard.lua", "lua/ArmoryGUI/Scoreboard.lua", "replace" )
