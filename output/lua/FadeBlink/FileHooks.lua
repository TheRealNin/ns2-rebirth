
Script.Load( "lua/FadeBlink/ReplaceUpValue.lua" )

ModLoader.SetupFileHook( "lua/Globals.lua", "lua/FadeBlink/Globals.lua", "post" )

ModLoader.SetupFileHook( "lua/Shared.lua", "lua/FadeBlink/Shared.lua", "post" )
ModLoader.SetupFileHook( "lua/Fade.lua", "lua/FadeBlink/Fade.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/FadeBlink/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/Blink.lua", "lua/FadeBlink/Blink.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/Metabolize.lua", "lua/FadeBlink/Metabolize.lua", "post" )
--ModLoader.SetupFileHook( "lua/Mixins/BaseMoveMixin.lua", "lua/FadeBlink/BaseMoveMixin.lua", "post" )