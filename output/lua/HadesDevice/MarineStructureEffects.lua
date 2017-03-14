kMarineHadesEffects =
{
    hades_explosion = 
    {
        effects =
        {  
            {sound = "sound/hades_sounds.fev/hades/explosion"},
            {cinematic = "cinematics/hades_explosion.cinematic"}
        }
    },
    death =
    {
        marineStructureDeathCinematics =
        {
            {cinematic = "cinematics/marine/structures/death_small.cinematic", classname = "HadesDevice", done = true}
        },
        
        marineStructureDeathSounds =
        {
            {sound = "sound/NS2.fev/marine/structures/generic_death", classname = "HadesDevice", done = true}
        },
    }
}
GetEffectManager():AddEffectData("HadesEffects", kMarineHadesEffects)