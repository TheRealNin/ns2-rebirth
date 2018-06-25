
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/WeaponSwitch/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Player.lua", "lua/WeaponSwitch/Player.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine_Server.lua", "lua/WeaponSwitch/Marine_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineBuy_Client.lua", "lua/WeaponSwitch/MarineBuy_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Player_Client.lua", "lua/WeaponSwitch/Player_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Axe.lua", "lua/WeaponSwitch/Axe.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Welder.lua", "lua/WeaponSwitch/Welder.lua", "post" )

ModLoader.SetupFileHook( "lua/AmmoPack.lua", "lua/WeaponSwitch/AmmoPack.lua", "post" )
ModLoader.SetupFileHook( "lua/DropPack.lua", "lua/WeaponSwitch/DropPack.lua", "post" )

ModLoader.SetupFileHook( "lua/Hud/GUIInventory.lua", "lua/WeaponSwitch/GUIInventory.lua", "post" )

ModLoader.SetupFileHook( "lua/MarineActionFinderMixin.lua", "lua/WeaponSwitch/MarineActionFinderMixin.lua", "replace" )

-- TODO: move this dependancy out of WeaponSwitch somehow to prevent duplication
ModLoader.SetupFileHook( "lua/Entity.lua", "lua/WeaponSwitch/Entity.lua", "post" )