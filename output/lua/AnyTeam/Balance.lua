
kExoBulletModifier = 0.5
--kAxeDamage = 50 -- was 25
--kAxeDamageType = kDamageType.StructuralHeavy -- was kDamageType.Structural
--kWelderDamagePerSecond = 60 -- was 30
--kWelderDamageType = kDamageType.Flame
kMedpackHeal = 0 -- was 25, now you regen slowly instead of "suddenly health!"
kMarineRegenerationHeal = 50 --"Amount of hp per second" was the comment???, was 25. This is actually how much you heal as "regen"

kTeamVsTeamDamage = {}
kTeamVsTeamDamage[kMarineTeamType] = {}
kTeamVsTeamDamage[kMarineTeamType][kMarineTeamType]  = 1.33
kTeamVsTeamDamage[kMarineTeamType][kNeutralTeamType] = 1.33
    
kTeamVsTeamDamage[kAlienTeamType] = {}
kTeamVsTeamDamage[kAlienTeamType][kAlienTeamType] = 0.85


-- Jetpack THIS IS TEMPORARY AND JUST FOR JON
--kJetpackUseFuelRate = .105 -- was .21
--kJetpackReplenishFuelRate = .055 -- was .11