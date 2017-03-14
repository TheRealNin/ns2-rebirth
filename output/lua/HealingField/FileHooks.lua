
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/HealingField/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/HealingField/BalanceMisc.lua", "post" )
ModLoader.SetupFileHook( "lua/Shared.lua", "lua/HealingField/Shared.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/HealingField/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/HealingField/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/HealingField/TechTreeButtons.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/HealingField/Globals.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/HealingField/NS2Utility.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineCommander.lua", "lua/HealingField/MarineCommander.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineCommander_Server.lua", "lua/HealingField/MarineCommander_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/HealingField/MarineTeam.lua", "post" )


if AddModPanel then
    local kHealingFieldMaterial = PrecacheAsset("materials/healingfield/healingfield.material")
    AddModPanel(kHealingFieldMaterial, "http://steamcommunity.com/sharedfiles/filedetails/?id=882752783")

end