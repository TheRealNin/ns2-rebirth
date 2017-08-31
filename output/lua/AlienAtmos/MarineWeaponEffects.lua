

local kNewMarineWeaponEffects =
{
    railgun_weak_attack =
    {
        effects =
        {
            --{viewmodel_cinematic = "cinematics/marine/railgun/muzzle_flash.cinematic", attach_point = "fxnode_r_railgun_muzzle"},
            --{weapon_cinematic = "cinematics/marine/railgun/muzzle_flash.cinematic", attach_point = "fxnode_rrailgunmuzzle"},
            -- Sound effect
            {player_sound = "sound/NS2.fev/marine/heavy/jump"}
        },
    },
    
}

GetEffectManager():AddEffectData("RailgunWeaponEffects", kNewMarineWeaponEffects)