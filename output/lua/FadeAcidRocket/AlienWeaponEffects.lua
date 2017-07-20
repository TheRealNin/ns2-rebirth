local newAlienWeaponEffects = {}
newAlienWeaponEffects["acidrocket_hit"] =
    {
        acidRocketHitEffects = 
        {
            {cinematic = "cinematics/acidrocket_impact.cinematic"},
            {parented_sound = "sound/NS2.fev/alien/gorge/bilebomb_hit", done = true},
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