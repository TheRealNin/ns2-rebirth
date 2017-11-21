
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/NinBalance/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceHealth.lua", "lua/NinBalance/BalanceHealth.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/NinBalance/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/Hydra.lua", "lua/NinBalance/Hydra.lua", "post" )
ModLoader.SetupFileHook( "lua/Hydra_Server.lua", "lua/NinBalance/Hydra_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/NinBalance/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Player.lua", "lua/NinBalance/Player.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/BulletsMixin.lua", "lua/NinBalance/Weapons/BulletsMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Shotgun.lua", "lua/NinBalance/Weapons/Marine/Shotgun.lua", "post" )


--ModLoader.SetupFileHook( "lua/Weapons/Marine/Grenade.lua", "lua/NinBalance/Weapons/Marine/Grenade.lua", "post" )

-- this is incompatible with alienatmos :(
ModLoader.SetupFileHook( "lua/Weapons/Marine/Railgun.lua", "lua/NinBalance/Weapons/Marine/Railgun.lua", "post" )

ModLoader.SetupFileHook( "lua/Armory_Server.lua", "lua/NinBalance/Armory_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Babbler.lua", "lua/NinBalance/Babbler.lua", "post" )


ModLoader.SetupFileHook( "lua/GUIAlienBuyMenu.lua", "lua/NinBalance/GUIAlienBuyMenu.lua", "post" )


-- shamelessly stole Ghoul's autoselect upgrades
ModLoader.SetupFileHook( "lua/Egg.lua", "lua/NinBalance/Egg.lua", "post" )

-- remove sentry battery requirement
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/NinBalance/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineCommander.lua", "lua/NinBalance/MarineCommander.lua", "post" )
ModLoader.SetupFileHook( "lua/Sentry.lua", "lua/NinBalance/Sentry.lua", "post" )

-- jetpack rebalance
ModLoader.SetupFileHook( "lua/JetpackMarine.lua", "lua/NinBalance/JetpackMarine.lua", "post" )

-- animation fixes
ModLoader.SetupFileHook( "lua/Mixins/BaseMoveMixin.lua", "lua/NinBalance/BaseMoveMixin.lua", "replace" )
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/NinBalance/NS2Utility.lua", "post" )