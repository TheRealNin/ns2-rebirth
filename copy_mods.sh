#!/usr/bin/bash
dest="/c/Users/Adam/Documents/Rebirth/output/"

rm -r $dest*

cp -R ../AlienAtmos/output/* $dest
cp -R ../AnyTeam/output/* $dest
cp -R ../EggSpawn/output/* $dest
cp -R ../FadeBlink/output/* $dest
cp -R ../HadesDevice/output/* $dest
cp -R ../HealingField/output/* $dest
cp -R ../ModPanels/output/* $dest
cp -R ../Prowler/output/* $dest
cp -R ../ThirdPerson/output/* $dest
cp -R ../WhipRebalance/output/* $dest
cp -R ../NinBalance/output/* $dest
cp -R ../FadeAcidRocket/output/* $dest
cp -R ../ArmoryGUI/output/* $dest
cp -R ../MinimapBuildings/output/* $dest
cp -R ../ShieldGenerator/output/* $dest
cp -R ../FasterHMGReload/output/* $dest
cp -R ../SgShine/output/* $dest
cp -R ../CrouchClip/output/* $dest
cp -R ../WeaponSwitch/output/* $dest

# finally, call this mod rebirth
cp game_setup.xml $dest