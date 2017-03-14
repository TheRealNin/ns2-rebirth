-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PrecursorTechMap.lua
--
-- Created by: Andreas Urwalek (and@unknownworlds.com)
--
-- Formatted Precursor tech tree.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kPrecursorTechMapYStart = 2
kPrecursorTechMap =
{

        { kTechId.Extractor, 5, 1 },{ kTechId.CommandStation, 7, 1 },{ kTechId.InfantryPortal, 9, 1 },
        
        { kTechId.RoboticsFactory, 9, 3 },{ kTechId.ARCRoboticsFactory, 10, 2 },{ kTechId.ARC, 11, 2 },
                                          { kTechId.MAC, 10, 3 },
                                          { kTechId.SentryBattery, 10, 4 },{ kTechId.Sentry, 11, 4 },
                                          
                                          
        { kTechId.GrenadeTech, 2, 3 },{ kTechId.MinesTech, 3, 3 },{ kTechId.ShotgunTech, 4, 3 },{ kTechId.Welder, 5, 3 },
        
        { kTechId.Armory, 3.5, 4 }, 
         
        { kTechId.AdvancedWeaponry, 2.5, 5.5 }, { kTechId.AdvancedArmory, 3.5, 5.5 },

        { kTechId.HeavyMachineGunTech, 4.5, 5.5 },
        
        { kTechId.PrototypeLab, 3.5, 7 },

        { kTechId.ExosuitTech, 3, 8 },{ kTechId.JetpackTech, 4, 8 },
        
        
        { kTechId.ArmsLab, 9, 7 },{ kTechId.Weapons1, 10, 6.5 },{ kTechId.Weapons2, 11, 6.5 },{ kTechId.Weapons3, 12, 6.5 },
                                  { kTechId.Armor1, 10, 7.5 },{ kTechId.Armor2, 11, 7.5 },{ kTechId.Armor3, 12, 7.5 },
                                  
                                  
        { kTechId.NanoShieldTech, 8, 4.5 },
        { kTechId.CatPackTech, 8, 5.5 },
        { kTechId.PowerSurgeTech, 8, 6.5 },

        { kTechId.Observatory, 6, 5 },{ kTechId.PhaseTech, 6, 6 },{ kTechId.PhaseGate, 6, 7 },
                 

}

kPrecursorLines = 
{
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.CommandStation, kTechId.Extractor),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.CommandStation, kTechId.InfantryPortal),
    
    { 7, 1, 7, 7 },
    { 7, 4, 3.5, 4 },
    -- observatory:
    { 6, 5, 7, 5 },
    { 7, 7, 9, 7 },
    -- nano shield:
    { 7, 4.5, 8, 4.5},
    -- cat pack tech:
    { 7, 5.5, 8, 5.5},

    -- power surge tech
    { 7, 6.5, 8, 6.5},

    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armory, kTechId.GrenadeTech),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armory, kTechId.MinesTech),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armory, kTechId.ShotgunTech),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armory, kTechId.Welder),

    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armory, kTechId.AdvancedArmory),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.AdvancedArmory, kTechId.AdvancedWeaponry),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.AdvancedArmory, kTechId.HeavyMachineGunTech),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.AdvancedArmory, kTechId.PrototypeLab),
    
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.PrototypeLab, kTechId.ExosuitTech),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.PrototypeLab, kTechId.JetpackTech),
    
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Observatory, kTechId.PhaseTech),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.PhaseTech, kTechId.PhaseGate),
    
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.ArmsLab, kTechId.Weapons1),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Weapons1, kTechId.Weapons2),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Weapons2, kTechId.Weapons3),
    
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.ArmsLab, kTechId.Armor1),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armor1, kTechId.Armor2),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.Armor2, kTechId.Armor3),
    
    { 7, 3, 9, 3 },
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.ARCRoboticsFactory, kTechId.ARC),

    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.RoboticsFactory, kTechId.MAC),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.RoboticsFactory, kTechId.SentryBattery),
    GetLinePositionForTechMap(kPrecursorTechMap, kTechId.SentryBattery, kTechId.Sentry),
    
}