
ModLoader.SetupFileHook( "lua/Alien.lua", "lua/NinBalance/Alien.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/NinBalance/Globals.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/NinBalance/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceHealth.lua", "lua/NinBalance/BalanceHealth.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/NinBalance/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/Hydra.lua", "lua/NinBalance/Hydra.lua", "post" )
ModLoader.SetupFileHook( "lua/Hydra_Server.lua", "lua/NinBalance/Hydra_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/NinBalance/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine_Server.lua", "lua/NinBalance/Marine_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Gorge.lua", "lua/NinBalance/Gorge.lua", "post" )
ModLoader.SetupFileHook( "lua/Skulk.lua", "lua/NinBalance/Skulk.lua", "post" )
ModLoader.SetupFileHook( "lua/Fade.lua", "lua/NinBalance/Fade.lua", "post" )
ModLoader.SetupFileHook( "lua/Player.lua", "lua/NinBalance/Player.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2Gamerules.lua", "lua/NinBalance/NS2Gamerules.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/BulletsMixin.lua", "lua/NinBalance/Weapons/BulletsMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Shotgun.lua", "lua/NinBalance/Weapons/Marine/Shotgun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Minigun.lua", "lua/NinBalance/Weapons/Marine/Minigun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Axe.lua", "lua/NinBalance/Weapons/Marine/Axe.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Pistol.lua", "lua/NinBalance/Weapons/Marine/Pistol.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/PulseGrenade.lua", "lua/NinBalance/Weapons/Marine/PulseGrenade.lua", "post" )


ModLoader.SetupFileHook( "lua/Weapons/Alien/Gore.lua", "lua/NinBalance/Weapons/Alien/Gore.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/ClogAbility.lua", "lua/NinBalance/Weapons/Alien/ClogAbility.lua", "post" )


ModLoader.SetupFileHook( "lua/Weapons/Marine/Grenade.lua", "lua/NinBalance/Weapons/Marine/Grenade.lua", "post" )

-- this is incompatible with alienatmos :(
ModLoader.SetupFileHook( "lua/Weapons/Marine/Railgun.lua", "lua/NinBalance/Weapons/Marine/Railgun.lua", "post" )

ModLoader.SetupFileHook( "lua/Armory_Server.lua", "lua/NinBalance/Armory_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Babbler.lua", "lua/NinBalance/Babbler.lua", "post" )

-- TODO: powerpoints start destroyed
--ModLoader.SetupFileHook( "lua/PowerPoint.lua", "lua/NinBalance/PowerPoint.lua", "post" )


ModLoader.SetupFileHook( "lua/GUIAlienBuyMenu.lua", "lua/NinBalance/GUIAlienBuyMenu.lua", "post" )

-- fix projectiless
ModLoader.SetupFileHook( "lua/Weapons/PredictedProjectile.lua", "lua/NinBalance/Weapons/PredictedProjectile.lua", "replace" )
--ModLoader.SetupFileHook( "lua/Weapons/Projectile_Server.lua", "lua/NinBalance/Weapons/Projectile_Server.lua", "replace" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/GrenadeThrower.lua", "lua/NinBalance/Weapons/Marine/GrenadeThrower.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/GrenadeLauncher.lua", "lua/NinBalance/Weapons/Marine/GrenadeLauncher.lua", "post" )

-- shamelessly stole Ghoul's autoselect upgrades
ModLoader.SetupFileHook( "lua/Egg.lua", "lua/NinBalance/Egg.lua", "post" )
ModLoader.SetupFileHook( "lua/Embryo.lua", "lua/NinBalance/Embryo.lua", "post" )

-- remove sentry battery requirement
ModLoader.SetupFileHook( "lua/MarineCommander.lua", "lua/NinBalance/MarineCommander.lua", "post" )
ModLoader.SetupFileHook( "lua/Sentry.lua", "lua/NinBalance/Sentry.lua", "post" )

-- jetpack rebalance
ModLoader.SetupFileHook( "lua/JetpackMarine.lua", "lua/NinBalance/JetpackMarine.lua", "post" )

-- animation fixes
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/NinBalance/NS2Utility.lua", "post" )

-- invis thing
ModLoader.SetupFileHook( "lua/CloakableMixin.lua", "lua/NinBalance/CloakableMixin.lua", "post" )


-- fix backwards move scalar
ModLoader.SetupFileHook( "lua/Mixins/GroundMoveMixin.lua", "lua/NinBalance/GroundMoveMixin.lua", "post" )

-- fix radius damage
ModLoader.SetupFileHook( "lua/Entity.lua", "lua/NinBalance/Entity.lua", "post" )

-- Silence!!
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/NinBalance/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/NinBalance/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/NinBalance/TechTreeButtons.lua", "post" )
ModLoader.SetupFileHook( "lua/PlayerInfoEntity.lua", "lua/NinBalance/PlayerInfoEntity.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienTeam.lua", "lua/NinBalance/AlienTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/AlienTechMap.lua", "lua/NinBalance/AlienTechMap.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIUpgradeChamberDisplay.lua", "lua/NinBalance/GUIUpgradeChamberDisplay.lua", "post" )
ModLoader.SetupFileHook( "lua/Alien_Upgrade.lua", "lua/NinBalance/Alien_Upgrade.lua", "post" )
ModLoader.SetupFileHook( "lua/Alien_Server.lua", "lua/NinBalance/Alien_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/EffectManager.lua", "lua/NinBalance/EffectManager.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/Ability.lua", "lua/NinBalance/Weapons/Alien/Ability.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/BileBomb.lua", "lua/NinBalance/Weapons/Alien/BileBomb.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/BiteLeap.lua", "lua/NinBalance/Weapons/Alien/BiteLeap.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/LerkBite.lua", "lua/NinBalance/Weapons/Alien/LerkBite.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/SpitSpray.lua", "lua/NinBalance/Weapons/Alien/SpitSpray.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/SwipeBlink.lua", "lua/NinBalance/Weapons/Alien/SwipeBlink.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/Spores.lua", "lua/NinBalance/Weapons/Alien/Spores.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/StabBlink.lua", "lua/NinBalance/Weapons/Alien/StabBlink.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/SpikesMixin.lua", "lua/NinBalance/Weapons/Alien/SpikesMixin.lua", "post" )