
ModLoader.SetupFileHook( "lua/PowerPointLightHandler.lua", "lua/AlienAtmos/PowerPointLightHandler.lua", "post" )


ModLoader.SetupFileHook( "lua/MapEntityLoader.lua", "lua/AlienAtmos/MapEntityLoader.lua", "post" )

-- barrel fixes
ModLoader.SetupFileHook( "lua/Weapons/Marine/Rifle.lua", "lua/AlienAtmos/Weapons/Marine/Rifle.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Shotgun.lua", "lua/AlienAtmos/Weapons/Marine/Rifle.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Pistol.lua", "lua/AlienAtmos/Weapons/Marine/Pistol.lua", "post" )

ModLoader.SetupFileHook( "lua/Weapons/Marine/ClipWeapon.lua", "lua/AlienAtmos/Weapons/Marine/ClipWeapon.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Minigun.lua", "lua/AlienAtmos/Weapons/Marine/Minigun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Railgun.lua", "lua/AlienAtmos/Weapons/Marine/Railgun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/HeavyMachineGun.lua", "lua/AlienAtmos/Weapons/Marine/HeavyMachineGun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Grenade.lua", "lua/AlienAtmos/Weapons/Marine/Grenade.lua", "post" )

ModLoader.SetupFileHook( "lua/Cyst.lua", "lua/AlienAtmos/Cyst.lua", "post" )
ModLoader.SetupFileHook( "lua/Harvester.lua", "lua/AlienAtmos/Harvester.lua", "post" )
ModLoader.SetupFileHook( "lua/Hive.lua", "lua/AlienAtmos/Hive.lua", "post" )
ModLoader.SetupFileHook( "lua/DissolveMixin.lua", "lua/AlienAtmos/DissolveMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Hive_Client.lua", "lua/AlienAtmos/Hive_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/PowerPoint.lua", "lua/AlienAtmos/PowerPoint.lua", "post" )
ModLoader.SetupFileHook( "lua/PowerPoint_Client.lua", "lua/AlienAtmos/PowerPoint_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/AlienAtmos/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine_Client.lua", "lua/AlienAtmos/Marine_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/Exo.lua", "lua/AlienAtmos/Exo.lua", "post" )
ModLoader.SetupFileHook( "lua/Exosuit.lua", "lua/AlienAtmos/Exosuit.lua", "post" )
ModLoader.SetupFileHook( "lua/Render.lua", "lua/AlienAtmos/Render.lua", "post" )
ModLoader.SetupFileHook( "lua/EffectManager.lua", "lua/AlienAtmos/EffectManager.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineWeaponEffects.lua", "lua/AlienAtmos/MarineWeaponEffects.lua", "post" )

ModLoader.SetupFileHook( "lua/Ragdoll.lua", "lua/AlienAtmos/Ragdoll.lua", "post" )
ModLoader.SetupFileHook( "lua/DamageMixin.lua", "lua/AlienAtmos/DamageMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/RagdollMixin.lua", "lua/AlienAtmos/RagdollMixin.lua", "post" )

ModLoader.SetupFileHook( "lua/Player_Client.lua", "lua/AlienAtmos/Player_Client.lua", "post" )


ModLoader.SetupFileHook( "lua/IdleMixin.lua", "lua/AlienAtmos/IdleMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Lerk.lua", "lua/AlienAtmos/Lerk.lua", "post" )


ModLoader.SetupFileHook( "lua/Globals.lua", "lua/AlienAtmos/Globals.lua", "post" )

ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/AlienAtmos/NS2Utility.lua", "post" )

-- this basically removes the flinch mixin
ModLoader.SetupFileHook( "lua/FlinchMixin.lua", "lua/AlienAtmos/FlinchMixin.lua", "replace" )

