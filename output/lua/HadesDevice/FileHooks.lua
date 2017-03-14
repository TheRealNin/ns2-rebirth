
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/HadesDevice/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/HadesDevice/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/Shared.lua", "lua/HadesDevice/Shared.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/HadesDevice/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/HadesDevice/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/HadesDevice/TechTreeButtons.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/HadesDevice/Globals.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/HadesDevice/NS2Utility.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineCommander.lua", "lua/HadesDevice/MarineCommander.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/HadesDevice/MarineTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineStructureEffects.lua", "lua/HadesDevice/MarineStructureEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/UnitStatusMixin.lua", "lua/HadesDevice/UnitStatusMixin.lua", "post" )

if AddModPanel then
    local kHadesDeviceMaterial = PrecacheAsset("materials/hadesdevice/hd.material")
    AddModPanel(kHadesDeviceMaterial, "http://steamcommunity.com/sharedfiles/filedetails/?id=873978863")

end