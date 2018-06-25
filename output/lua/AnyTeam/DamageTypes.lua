-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DamageTypes.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Contains all rules regarding damage types. New types behavior can be defined BuildDamageTypeRules().
--
--    Important callbacks for classes:
--
--    ComputeDamageAttackerOverride(attacker, damage, damageType)
--    ComputeDamageAttackerOverrideMixin(attacker, damage, damageType)
--
--    for target:
--    ComputeDamageOverride(attacker, damage, damageType)
--    ComputeDamageOverrideMixin(attacker, damage, damageType)
--    GetArmorUseFractionOverride(damageType, armorFractionUsed)
--    GetReceivesStructuralDamage(damageType)
--    GetReceivesBiologicalDamage(damageType)
--    GetHealthPerArmorOverride(damageType, healthPerArmor)
--
--
--
-- Damage types
--
-- In NS2 - Keep simple and mostly in regard to armor and non-armor. Can't see armor, but players
-- and structures spawn with an intuitive amount of armor.
-- http://www.unknownworlds.com/ns2/news/2010/6/damage_types_in_ns2
--
-- Normal - Regular damage
-- Light - Reduced vs. armor
-- Heavy - Extra damage vs. armor
-- Puncture - Extra vs. players
-- Structural - Double against structures
-- GrenadeLauncher - Double against structures with 20% reduction in player damage
-- Flamethrower - 5% increase for player damage from structures
-- Gas - Breathing targets only (Spores, Nerve Gas GL). Ignores armor.
-- StructuresOnly - Doesn't damage players or AI units (ARC)
-- Falling - Ignores armor for humans, no damage for some creatures or exosuit
-- Door - Like Structural but also does damage to Doors. Nothing else damages Doors.
-- Flame - Like normal but catches target on fire and plays special flinch animation
-- Corrode - deals normal damage to structures but armor only to non structures
-- ArmorOnly - always affects only armor
-- Biological - only organic, biological targets (non mechanical)
-- StructuresOnlyLight - same as light damage but will not harm players or units which are not valid for structural damage
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--globals for balance-extension tweaking
kAlienVampirismNotHealArmor = false

kDamageMarinesLessScalar = 0.25


-- utility functions

function GetReceivesStructuralDamage(entity)
    return entity.GetReceivesStructuralDamage and entity:GetReceivesStructuralDamage()
end

function GetReceivesBiologicalDamage(entity)
    return entity.GetReceivesBiologicalDamage and entity:GetReceivesBiologicalDamage()
end

function NS2Gamerules_GetUpgradedDamageScalar( attacker )

    if GetHasTech(attacker, kTechId.Weapons3, true) then            
        return kWeapons3DamageScalar                
    elseif GetHasTech(attacker, kTechId.Weapons2, true) then            
        return kWeapons2DamageScalar                
    elseif GetHasTech(attacker, kTechId.Weapons1, true) then            
        return kWeapons1DamageScalar                
    end
    
    return 1.0

end

-- Use this function to change damage according to current upgrades
function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)

    local damageScalar = 1

    if attacker ~= nil then
    
        -- Damage upgrades only affect weapons, not ARCs, Sentries, MACs, Mines, etc.
        if doer.GetIsAffectedByWeaponUpgrades and doer:GetIsAffectedByWeaponUpgrades() then
        
            damageScalar = NS2Gamerules_GetUpgradedDamageScalar( attacker )
            
        end
        
    end
        
    return damage * damageScalar
    
end



--Utility function to apply chamber-upgraded modifications to alien damage
--Note: this should _always_ be called BEFORE damage-type specific modifications are done (i.e. Light vs Normal vs Structural, etc)
function NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon )

    if not doer then return damage, armorFractionUsed end

    local teamNumber = attacker:GetTeamNumber()

    local isAffectedByCrush = doer.GetIsAffectedByCrush and attacker:GetHasUpgrade( kTechId.Crush ) and doer:GetIsAffectedByCrush()
    local isAffectedByVampirism = doer.GetVampiricLeechScalar and attacker:GetHasUpgrade( kTechId.Vampirism )
    local isAffectedByFocus = doer.GetIsAffectedByFocus and attacker:GetHasUpgrade( kTechId.Focus ) and doer:GetIsAffectedByFocus()

    if isAffectedByCrush then --Crush
        local crushLevel = attacker:GetSpurLevel()
        if crushLevel > 0 then
            if target:isa("Exo") or target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
                damage = damage + ( damage * ( crushLevel * kAlienCrushDamagePercentByLevel ) )
            elseif target:isa("Player") then
                armorFractionUsed = kBaseArmorUseFraction + ( crushLevel * kAlienCrushDamagePercentByLevel )
            end
        end
        
    end
    
    if Server then

        -- Vampirism
        if isAffectedByVampirism then
            local vampirismLevel = attacker:GetShellLevel()
            if vampirismLevel > 0 then
                if attacker:GetIsHealable() and target:isa("Player") then
                    local scalar = doer:GetVampiricLeechScalar()
                    if scalar > 0 then

                        local focusBonus = 1
                        if isAffectedByFocus then
                            focusBonus = 1 + doer:GetFocusAttackCooldown()
                        end

                        local maxHealth = attacker:GetMaxHealth()
                        local leechedHealth =  maxHealth * vampirismLevel * scalar * focusBonus
                        attacker:AddHealth( leechedHealth, true, kAlienVampirismNotHealArmor )

                    end
                end
            end
        end
        
    end

    --Focus
    if isAffectedByFocus then
        local veilLevel = attacker:GetVeilLevel()
        local damageBonus = doer:GetMaxFocusBonusDamage()
        damage = damage * (1 + (veilLevel/3) * damageBonus) --1.0, 1.333, 1.666, 2
    end
    
    --!!!Note: if more than damage and armor fraction modified, be certain the calling-point of this function is updated
    return damage, armorFractionUsed
    
end
-- only certain abilities should work with focus
-- global so mods can easily change this
function InitializeFocusAbilities()
    kFocusAbilities = {}
    kFocusAbilities[kTechId.Bite] = true
    kFocusAbilities[kTechId.Spit] = true
    kFocusAbilities[kTechId.LerkBite] = true
    kFocusAbilities[kTechId.Swipe] = true
    kFocusAbilities[kTechId.Stab] = true
    kFocusAbilities[kTechId.Gore] = true
end

function DoesFocusAffectAbility(abilityTech)
    if not kFocusAbilities then
        InitializeFocusAbilities()
    end
    
    if kFocusAbilities[abilityTech] == true then
        return true
    end
    
    return false
end

function Gamerules_GetDamageMultiplier()

    if Server and Shared.GetCheatsEnabled() then
        return GetGamerules():GetDamageMultiplier()
    end

    return 1
    
end

kDamageType = enum( 
{
    'Normal', 'Light', 'Heavy', 'Puncture', 
    'Structural', 'StructuralHeavy', 'Splash', 
    'Gas', 'NerveGas', 'StructuresOnly', 
    'Falling', 'Door', 'Flame', 'Flamethrower',
    'Corrode', 'ArmorOnly', 'Biological', 'StructuresOnlyLight', 
    'Spreading', 'GrenadeLauncher', 'MachineGun'
})

-- Describe damage types for tooltips
kDamageTypeDesc = {
    "",
    "Light: reduced vs. armor",
    "Heavy: extra vs. armor",
    "Puncture: extra vs. players",
    "Structural: Double vs. structures",
    "StructuralHeavy: Double vs. structures and double vs. armor",
    "Gas damage: affects breathing targets only",
    "NerveGas: affects biological units, player will take only armor damage",
    "Structures only: Doesn't damage players or AI units",
    "Falling: Ignores armor for humans, no damage for aliens",
    "Door: Can also affect Doors",
    "Flame: Deals 4.5x damage vs. flammable structures and double vs. all other structures",
    "Flamethrower: Reduced vs. armor, 4.5x damage vs. flammable structures and double vs. all other structures",
    "Corrode damage: Damage structures or armor only for non structures",
    "Armor damage: Will never reduce health",
    "Biological: Will only damage biological targets.",
    "StructuresOnlyLight: reduced vs. structures with armor",
    "Spreading: Does less damage against small targets.",
    "GrenadeLauncher: Double structure damage, 20% reduction in player damage",
    "MachineGun: Deals 1.5x amount of base damage vs. players"
}

kSpreadingDamageScalar = 0.75

kBaseArmorUseFraction = 0.7
kExosuitArmorUseFraction = 1 -- exos have no health
kStructuralDamageScalar = 2
kPuncturePlayerDamageScalar = 2
kGLPlayerDamageReduction = 0.8

kLightHealthPerArmor = 4
kHealthPointsPerArmor = 2
kHeavyHealthPerArmor = 1

kFlameableMultiplier = 2.5
kCorrodeDamagePlayerArmorScalar = 0.12
kCorrodeDamageExoArmorScalar = 0.4

kStructureLightHealthPerArmor = 9
kStructureLightArmorUseFraction = 0.9

-- deal only 33% of damage to friendlies
kFriendlyFireScalar = 0.33


local function ApplyDefaultArmorUseFraction(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, kBaseArmorUseFraction, healthPerArmor
end

local function ApplyHighArmorUseFractionForExos(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    
    if target:isa("Exo") then
        armorFractionUsed = kExosuitArmorUseFraction
    end
    
    return damage, armorFractionUsed, healthPerArmor
    
end

local function ApplyDefaultHealthPerArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, armorFractionUsed, kHealthPointsPerArmor
end

local function DoubleHealthPerArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, armorFractionUsed, healthPerArmor * (kLightHealthPerArmor / kHealthPointsPerArmor)
end

local function HalfHealthPerArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, armorFractionUsed, healthPerArmor * (kHeavyHealthPerArmor / kHealthPointsPerArmor)
end

local function ApplyAttackerModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    damage = NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
    damage = damage * Gamerules_GetDamageMultiplier()
    
    if attacker and attacker.ComputeDamageAttackerOverride then
        damage = attacker:ComputeDamageAttackerOverride(attacker, damage, damageType, doer, hitPoint)
    end
    
    if doer and doer.ComputeDamageAttackerOverride then
        damage = doer:ComputeDamageAttackerOverride(attacker, damage, damageType)
    end
    
    if attacker and attacker.ComputeDamageAttackerOverrideMixin then
        damage = attacker:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint)
    end
    
    if doer and doer.ComputeDamageAttackerOverrideMixin then
        damage = doer:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint)
    end
    
    return damage, armorFractionUsed, healthPerArmor

end

local function ApplyTeamModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor,  damageType, hitPoint)

    -- team vs team type damage multiplier
    local attackerType = attacker:GetTeamType()
    local targetType = target:GetTeamType()
    if kTeamVsTeamDamage[attackerType] then
        --Log("Multiplying damage by %s because %s attacked %s (was %s)", (kTeamVsTeamDamage[attackerType][targetType] or 1.0), attackerType, targetType, damage)
        damage = damage * (kTeamVsTeamDamage[attackerType][targetType] or 1.0)
    end
    
    
    return damage, armorFractionUsed, healthPerArmor
end

local function ApplyTargetModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor,  damageType, hitPoint)
    
    -- The host can provide an override for this function.
    if target.ComputeDamageOverride then
        damage = target:ComputeDamageOverride(attacker, damage, damageType, hitPoint)
    end

    -- Used by mixins.
    if target.ComputeDamageOverrideMixin then
        damage = target:ComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint)
    end
    
    if target.GetArmorUseFractionOverride then
        armorFractionUsed = target:GetArmorUseFractionOverride(damageType, armorFractionUsed, hitPoint)
    end
    
    if target.GetHealthPerArmorOverride then
        healthPerArmor = target:GetHealthPerArmorOverride(damageType, healthPerArmor, hitPoint)
    end
    
    local damageTable = {}
    damageTable.damage = damage
    damageTable.armorFractionUsed = armorFractionUsed
    damageTable.healthPerArmor = healthPerArmor
    
    if target.ModifyDamageTaken then
        target:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
    end
    
    
    return damageTable.damage, damageTable.armorFractionUsed, damageTable.healthPerArmor

end

local function ApplyFriendlyFireModifier(target, attacker, doer, damage, armorFractionUsed, healthPerArmor,  damageType, hitPoint)

    if target and attacker and target ~= attacker and HasMixin(target, "Team") and HasMixin(attacker, "Team") and target:GetTeamNumber() == attacker:GetTeamNumber() then
        damage = damage * kFriendlyFireScalar
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, 0, healthPerArmor
end

local function MaximizeArmorUseFraction(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, 1, healthPerArmor
end

local function MultiplyForStructures(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        damage = damage * kStructuralDamageScalar
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function ReduceForPlayersDoubleStructure(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        damage = damage * kStructuralDamageScalar
    elseif target:isa("Player") then
        damage = damage * kGLPlayerDamageReduction
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function MultiplyForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage * kPuncturePlayerDamageScalar, damage), armorFractionUsed, healthPerArmor
end

local function ReducedDamageAgainstSmall(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    if target.GetIsSmallTarget and target:GetIsSmallTarget() then
        damage = damage * kSpreadingDamageScalar
    end

    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreHealthForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Player") then    
        local maxDamagePossible = healthPerArmor * target.armor
        damage = math.min(damage, maxDamagePossible) 
        armorFractionUsed = 1
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreHealthForPlayersUnlessExo(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Player") and not target:isa("Exo") then
        local maxDamagePossible = healthPerArmor * target.armor
        damage = math.min(damage, maxDamagePossible) 
        armorFractionUsed = 1
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreHealth(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)  
    local maxDamagePossible = healthPerArmor * target.armor
    damage = math.min(damage, maxDamagePossible)
    
    return damage, 1, healthPerArmor
end

local function ReduceGreatlyForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Exo") or target:isa("Exosuit") or target:isa("Onos") then
        damage = damage * kCorrodeDamageExoArmorScalar
    elseif target:isa("Player") then
        damage = damage * kCorrodeDamagePlayerArmorScalar
    end
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnorePlayersUnlessExo(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") and not target:isa("Exo") , 0, damage), armorFractionUsed, healthPerArmor
end

local function IgnoreARCsAndMACs(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("ARC") or target:isa("MAC") , 0, damage), armorFractionUsed, healthPerArmor
end

local function IgnorePowerPoints(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("PowerPoint") , 0, damage), armorFractionUsed, healthPerArmor
end

local function DamagePlayersOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage, 0), armorFractionUsed, healthPerArmor
end

local function DamageAlienOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(HasMixin(target, "Team") and target:GetTeamType() == kAlienTeamType, damage, 0), armorFractionUsed, healthPerArmor
end

local function DamageMarinesLess(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if HasMixin(target, "Team") and target:GetTeamType() == kMarineTeamType then
        damage = kDamageMarinesLessScalar * damage
    end
    return damage, armorFractionUsed, healthPerArmor
end

local function DamageStructuresOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage(damageType) then
        damage = 0
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreDoors(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Door"), 0, damage), armorFractionUsed, healthPerArmor
end

local function DamageBiologicalOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if not target.GetReceivesBiologicalDamage or not target:GetReceivesBiologicalDamage(damageType) then
        damage = 0
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function DamageBreathingOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if not target.GetReceivesVaporousDamage or not target:GetReceivesVaporousDamage(damageType) then
        damage = 0
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function MultiplyFlameAble(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetIsFlameAble and target:GetIsFlameAble(damageType) then
        damage = damage * kFlameableMultiplier
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function DoubleHealthPerArmorForStructures(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        healthPerArmor = healthPerArmor * (kStructureLightHealthPerArmor / kHealthPointsPerArmor)
        armorFractionUsed = kStructureLightArmorUseFraction
    end
    return damage, armorFractionUsed, healthPerArmor
end

local function DoubleHealthPerArmorForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Player") then
        healthPerArmor = healthPerArmor * (kLightHealthPerArmor / kHealthPointsPerArmor)
    end
    return damage, armorFractionUsed, healthPerArmor
end

local kMachineGunPlayerDamageScalar = 1.5
local function MultiplyForMachineGun(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage * kMachineGunPlayerDamageScalar, damage), armorFractionUsed, healthPerArmor
end

kDamageTypeGlobalRules = nil
kDamageTypeRules = nil

--[[
 * Define any new damage type behavior in this function
 --]]
local function BuildDamageTypeRules()

    kDamageTypeGlobalRules = {}
    kDamageTypeRules = {}
    
    -- global rules
    table.insert(kDamageTypeGlobalRules, ApplyDefaultArmorUseFraction)
    table.insert(kDamageTypeGlobalRules, ApplyHighArmorUseFractionForExos)
    table.insert(kDamageTypeGlobalRules, ApplyDefaultHealthPerArmor)
    table.insert(kDamageTypeGlobalRules, ApplyAttackerModifiers)
    table.insert(kDamageTypeGlobalRules, ApplyTargetModifiers)
    table.insert(kDamageTypeGlobalRules, ApplyTeamModifiers)
    table.insert(kDamageTypeGlobalRules, ApplyFriendlyFireModifier)
    -- ------------------------------
    
    -- normal damage rules
    kDamageTypeRules[kDamageType.Normal] = {}
    
    -- light damage rules
    kDamageTypeRules[kDamageType.Light] = {}
    table.insert(kDamageTypeRules[kDamageType.Light], DoubleHealthPerArmor)
    -- ------------------------------
    
    -- heavy damage rules
    kDamageTypeRules[kDamageType.Heavy] = {}
    table.insert(kDamageTypeRules[kDamageType.Heavy], HalfHealthPerArmor)
    -- ------------------------------

    -- Puncture damage rules
    kDamageTypeRules[kDamageType.Puncture] = {}
    table.insert(kDamageTypeRules[kDamageType.Puncture], MultiplyForPlayers)
    -- ------------------------------
    
    -- Spreading damage rules
    kDamageTypeRules[kDamageType.Spreading] = {}
    table.insert(kDamageTypeRules[kDamageType.Spreading], ReducedDamageAgainstSmall)
    -- ------------------------------

    -- structural rules
    kDamageTypeRules[kDamageType.Structural] = {}
    table.insert(kDamageTypeRules[kDamageType.Structural], MultiplyForStructures)
    -- ------------------------------
    
    -- Grenade Launcher rules
    kDamageTypeRules[kDamageType.GrenadeLauncher] = {}
    table.insert(kDamageTypeRules[kDamageType.GrenadeLauncher], ReduceForPlayersDoubleStructure)
    -- ------------------------------
    
    -- Machine Gun rules
    kDamageTypeRules[kDamageType.MachineGun] = {}
    table.insert(kDamageTypeRules[kDamageType.MachineGun], MultiplyForMachineGun)
    -- ------------------------------
    -- structural heavy rules
    kDamageTypeRules[kDamageType.StructuralHeavy] = {}
    table.insert(kDamageTypeRules[kDamageType.StructuralHeavy], HalfHealthPerArmor)
    table.insert(kDamageTypeRules[kDamageType.StructuralHeavy], MultiplyForStructures)
    -- ------------------------------
    
    -- gas damage rules
    kDamageTypeRules[kDamageType.Gas] = {}
    table.insert(kDamageTypeRules[kDamageType.Gas], IgnoreArmor)
    table.insert(kDamageTypeRules[kDamageType.Gas], DamageBreathingOnly)
    -- ------------------------------
   
    -- structures only rules
    kDamageTypeRules[kDamageType.StructuresOnly] = {}
    table.insert(kDamageTypeRules[kDamageType.StructuresOnly], DamageStructuresOnly)
    -- ------------------------------
    
     -- Splash rules
    kDamageTypeRules[kDamageType.Splash] = {}
    table.insert(kDamageTypeRules[kDamageType.Splash], DamageStructuresOnly)
    table.insert(kDamageTypeRules[kDamageType.Splash], IgnoreARCsAndMACs)
    table.insert(kDamageTypeRules[kDamageType.Splash], IgnorePowerPoints)
    -- ------------------------------
 
    -- fall damage rules
    kDamageTypeRules[kDamageType.Falling] = {}
    table.insert(kDamageTypeRules[kDamageType.Falling], IgnoreArmor)
    -- ------------------------------

    -- Door damage rules
    kDamageTypeRules[kDamageType.Door] = {}
    table.insert(kDamageTypeRules[kDamageType.Door], MultiplyForStructures)
    table.insert(kDamageTypeRules[kDamageType.Door], HalfHealthPerArmor)
    -- ------------------------------
    
    -- Flame damage rules
    kDamageTypeRules[kDamageType.Flame] = {}
    table.insert(kDamageTypeRules[kDamageType.Flame], MultiplyFlameAble)
    table.insert(kDamageTypeRules[kDamageType.Flame], MultiplyForStructures)
    -- ------------------------------
    
    -- Flamethrower damage rules
    kDamageTypeRules[kDamageType.Flamethrower] = {}
    table.insert(kDamageTypeRules[kDamageType.Flame], MultiplyFlameAble)
    table.insert(kDamageTypeRules[kDamageType.Flame], MultiplyForStructures)
    table.insert(kDamageTypeRules[kDamageType.Flame], DoubleHealthPerArmorForPlayers)
    -- ------------------------------
    
    -- Corrode damage rules
    kDamageTypeRules[kDamageType.Corrode] = {}
    table.insert(kDamageTypeRules[kDamageType.Corrode], ReduceGreatlyForPlayers)
    table.insert(kDamageTypeRules[kDamageType.Corrode], IgnoreHealthForPlayersUnlessExo)
    -- ------------------------------
    
    -- nerve gas rules
    kDamageTypeRules[kDamageType.NerveGas] = {}
    --table.insert(kDamageTypeRules[kDamageType.NerveGas], DamageAlienOnly)
    table.insert(kDamageTypeRules[kDamageType.NerveGas], DamageMarinesLess)
    table.insert(kDamageTypeRules[kDamageType.NerveGas], IgnoreHealth)
    -- ------------------------------
    
    -- StructuresOnlyLight damage rules
    kDamageTypeRules[kDamageType.StructuresOnlyLight] = {}
    table.insert(kDamageTypeRules[kDamageType.StructuresOnlyLight], DoubleHealthPerArmorForStructures)
    -- ------------------------------
    
    -- ArmorOnly damage rules
    kDamageTypeRules[kDamageType.ArmorOnly] = {}
    table.insert(kDamageTypeRules[kDamageType.ArmorOnly], ReduceGreatlyForPlayers)
    table.insert(kDamageTypeRules[kDamageType.ArmorOnly], IgnoreHealth)    
    -- ------------------------------
    
    -- Biological damage rules
    kDamageTypeRules[kDamageType.Biological] = {}
    table.insert(kDamageTypeRules[kDamageType.Biological], DamageBiologicalOnly)
    -- ------------------------------
    
end

-- applies all rules and returns damage, armorUsed, healthUsed
function GetDamageByType(target, attacker, doer, damage, damageType, hitPoint, weapon)

    assert(target)
    
    if not kDamageTypeGlobalRules or not kDamageTypeRules then
        BuildDamageTypeRules()
    end
    
    -- at first check if damage is possible, if not we can skip the rest
    if not CanEntityDoDamageTo(attacker, target, Shared.GetCheatsEnabled(), Shared.GetDevMode(), GetFriendlyFire(), damageType) then
        return 0, 0, 0
    end
    
    local armorUsed = 0
    local healthUsed = 0
    
    local armorFractionUsed, healthPerArmor = 0
    
    -- apply global rules at first
    for _, rule in ipairs(kDamageTypeGlobalRules) do
        damage, armorFractionUsed, healthPerArmor = rule(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    end
    
    --Account for Alien Chamber Upgrades damage modifications (must be before damage-type rules)
    if attacker:GetTeamType() == kAlienTeamType and attacker:isa("Player") then
        damage, armorFractionUsed = NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon )
    end
    
    -- apply damage type specific rules
    for _, rule in ipairs(kDamageTypeRules[damageType]) do
        damage, armorFractionUsed, healthPerArmor = rule(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    end
    
    if damage > 0 and healthPerArmor > 0 then
        --Log("healthPerArmor: %s, armorFractionUsed: %s", healthPerArmor, armorFractionUsed)
        -- Each point of armor blocks a point of health but is only destroyed at half that rate (like NS1)
        -- Thanks Harimau!
        local healthPointsBlocked = math.min(healthPerArmor * target.armor, armorFractionUsed * damage)
        armorUsed = healthPointsBlocked / healthPerArmor
        
        -- Anything left over comes off of health
        healthUsed = damage - healthPointsBlocked

    end
    --Log("damage: %s, armorUsed: %s, healthUsed: %s", damage, armorUsed, healthUsed)
    return damage, armorUsed, healthUsed

end