
kExoBulletModifier = 0.55
kExoAllMarineDmagmageModifier = 0.66

kMarineRailgunModifier =  1.0 -- was 0.94 

kTeamVsTeamDamage = {}
kTeamVsTeamDamage[kMarineTeamType] = {}
kTeamVsTeamDamage[kMarineTeamType][kMarineTeamType]  = 1.33

-- this would be for powernodes. Nothing else is neutral that can take damage, really....
--kTeamVsTeamDamage[kMarineTeamType][kNeutralTeamType] = 1.33
    
kTeamVsTeamDamage[kAlienTeamType] = {}
kTeamVsTeamDamage[kAlienTeamType][kAlienTeamType] = 1.0

-- this is the exo speed modifier when you get hit by a shock grenade
kElectrifiedSpeedScalar = 0.5
kExoElectrifiedMult = 1.5