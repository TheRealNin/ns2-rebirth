local newAlienWeaponEffects = {}
newAlienWeaponEffects["acidrocket_hit"] =
    {
        acidRocketHitEffects = 
        {
            {cinematic = "cinematics/acidrocket_impact.cinematic"},
            {sound = "sound/NS2.fev/alien/gorge/spit_hit", done = true},
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