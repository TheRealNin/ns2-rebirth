local newAlienWeaponEffects = {}
newAlienWeaponEffects["acidrocket_hit"] =
    {
        acidRocketHitEffects = 
        {
            --{cinematic = "cinematics/acidrocket_impact.cinematic"},
            {cinematic = "cinematics/alien/fade/vortex_destroy.cinematic"},
            {sound = "sound/NS2.fev/alien/fade/vortex_start", done = true},
        },
    }
    
newAlienWeaponEffects["acidrocket_decal"] =
    {
        acidRocketDecal =
        {
        }    
    }
-- "false" means play all effects in each block
GetEffectManager():AddEffectData("AlienWeaponEffects", newAlienWeaponEffects)