
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/WeaponSwitch/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine_Server.lua", "lua/WeaponSwitch/Marine_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineBuy_Client.lua", "lua/WeaponSwitch/MarineBuy_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Player_Client.lua", "lua/WeaponSwitch/Player_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Axe.lua", "lua/WeaponSwitch/Axe.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Welder.lua", "lua/WeaponSwitch/Welder.lua", "post" )


ModLoader.SetupFileHook( "lua/MarineActionFinderMixin.lua", "lua/WeaponSwitch/MarineActionFinderMixin.lua", "replace" )