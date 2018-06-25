

if AddModPanel then 
    local kProwlerMaterial = PrecacheAsset("materials/prowler/prowler.material")
    AddModPanel(kProwlerMaterial)
end

kPlayerStatus =  enum( { "Hidden", "Dead", "Evolving", "Embryo", "Commander", "Exo", "GrenadeLauncher", "Rifle", "HeavyMachineGun", "Shotgun", "Flamethrower", "Void", "Spectator", "Skulk", "Gorge", "Fade", "Lerk", "Onos", "SkulkEgg", "GorgeEgg", "FadeEgg", "LerkEgg", "OnosEgg", "Prowler", "ProwlerEgg" } )


kMinimapBlipType = enum( { 'Undefined', 'TechPoint', 'ResourcePoint', 'Scan', 'EtherealGate', 'HighlightWorld',
                           'Sentry', 'CommandStation',
                           'Extractor', 'InfantryPortal', 'Armory', 'AdvancedArmory', 'PhaseGate', 'Observatory',
                           'RoboticsFactory', 'ArmsLab', 'PrototypeLab',
                           'Hive', 'Harvester', 'Hydra', 'Egg', 'Embryo', 'Crag', 'Whip', 'Shade', 'Shift', 'Shell', 'Veil', 'Spur', 'TunnelEntrance', 'BoneWall',
                           'Marine', 'JetpackMarine', 'Exo', 'Skulk', 'Lerk', 'Onos', 'Fade', 'Gorge',
                           'Door', 'PowerPoint', 'DestroyedPowerPoint', 'UnsocketedPowerPoint', 
                           'BlueprintPowerPoint', 'ARC', 'Drifter', 'MAC', 'Infestation', 'InfestationDying', 'MoveOrder', 'AttackOrder', 'BuildOrder', 'SensorBlip', 'SentryBattery',
                           "Prowler"} )