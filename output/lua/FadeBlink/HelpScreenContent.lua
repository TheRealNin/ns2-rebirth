
local helpScreenImages = 
{
    rifle               = PrecacheAsset("ui/helpScreen/icons/rifle.dds"),
    rifleButt           = PrecacheAsset("ui/helpScreen/icons/rifle_butt.dds"),
    pistol              = PrecacheAsset("ui/helpScreen/icons/pistol.dds"),
    axe                 = PrecacheAsset("ui/helpScreen/icons/axe.dds"),
    welder              = PrecacheAsset("ui/helpScreen/icons/welder.dds"),
    shotgun             = PrecacheAsset("ui/helpScreen/icons/shotgun.dds"),
    mines               = PrecacheAsset("ui/helpScreen/icons/mine.dds"),
    flamethrower        = PrecacheAsset("ui/helpScreen/icons/flamethrower.dds"),
    grenadeLauncher     = PrecacheAsset("ui/helpScreen/icons/grenade_launcher.dds"),
    machineGun          = PrecacheAsset("ui/helpScreen/icons/machine_gun.dds"),
    clusterGrenade      = PrecacheAsset("ui/helpScreen/icons/grenade_cluster.dds"),
    pulseGrenade        = PrecacheAsset("ui/helpScreen/icons/grenade_pulse.dds"),
    gasGrenade          = PrecacheAsset("ui/helpScreen/icons/grenade_gas.dds"),
    minigun             = PrecacheAsset("ui/helpScreen/icons/mini_gun.dds"),
    railgun             = PrecacheAsset("ui/helpScreen/icons/rail_gun.dds"),
    exoThrusters        = PrecacheAsset("ui/helpScreen/icons/thrusters.dds"),
    exoEject            = PrecacheAsset("ui/helpScreen/icons/exo_eject.dds"),
    eggStomp            = PrecacheAsset("ui/helpScreen/icons/egg_stomp.dds"),
    jetpack             = PrecacheAsset("ui/helpScreen/icons/jetpack.dds"),
    bite                = PrecacheAsset("ui/helpScreen/icons/bite.dds"),
    parasite            = PrecacheAsset("ui/helpScreen/icons/parasite.dds"),
    leap                = PrecacheAsset("ui/helpScreen/icons/leap.dds"),
    xenocide            = PrecacheAsset("ui/helpScreen/icons/xenocide.dds"),
    healSpray           = PrecacheAsset("ui/helpScreen/icons/heal_spray.dds"),
    spit                = PrecacheAsset("ui/helpScreen/icons/spit.dds"),
    gorgeStructures     = PrecacheAsset("ui/helpScreen/icons/gorge_structures.dds"),
    bileBomb            = PrecacheAsset("ui/helpScreen/icons/bile_bomb.dds"),
    baitBall            = PrecacheAsset("ui/helpScreen/icons/bait_ball.dds"),
    lerkBite            = PrecacheAsset("ui/helpScreen/icons/lerk_bite.dds"),
    spikes              = PrecacheAsset("ui/helpScreen/icons/spikes.dds"),
    umbra               = PrecacheAsset("ui/helpScreen/icons/umbra.dds"),
    spores              = PrecacheAsset("ui/helpScreen/icons/spores.dds"),
    swipe               = PrecacheAsset("ui/helpScreen/icons/swipe.dds"),
    blink               = PrecacheAsset("ui/helpScreen/icons/blink.dds"),
    advancedMetabolize  = PrecacheAsset("ui/helpScreen/icons/advanced_metabolize.dds"),
    metabolize          = PrecacheAsset("ui/helpScreen/icons/metabolize.dds"),
    stab                = PrecacheAsset("ui/helpScreen/icons/stab.dds"),
    gore                = PrecacheAsset("ui/helpScreen/icons/gore.dds"),
    charge              = PrecacheAsset("ui/helpScreen/icons/charge.dds"),
    boneShield          = PrecacheAsset("ui/helpScreen/icons/bone_shield.dds"),
    stomp               = PrecacheAsset("ui/helpScreen/icons/stomp.dds"),
}

local kBioMassLevelToHelpText = 
{
    [1] =   "",
    [2] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_2",
    [3] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_3",
    [4] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_4",
    [5] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_5",
    [6] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_6",
    [7] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_7",
    [8] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_8",
    [9] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_9",
}

local kTechToBiomassLevel = 
{
    [kTechId.BioMassOne]    = 1,
    [kTechId.BioMassTwo]    = 2,
    [kTechId.BioMassThree]  = 3,
    [kTechId.BioMassFour]   = 4,
    [kTechId.BioMassFive]   = 5,
    [kTechId.BioMassSix]    = 6,
    [kTechId.BioMassSeven]  = 7,
    [kTechId.BioMassEight]  = 8,
    [kTechId.BioMassNine]   = 9,
    [kTechId.BioMassTen]    = 10,
    [kTechId.BioMassEleven] = 11,
    [kTechId.BioMassTwelve] = 12,

    -- and inverse...
    [1]  = kTechId.BioMassOne,
    [2]  = kTechId.BioMassTwo,
    [3]  = kTechId.BioMassThree,
    [4]  = kTechId.BioMassFour,
    [5]  = kTechId.BioMassFive,
    [6]  = kTechId.BioMassSix,
    [7]  = kTechId.BioMassSeven,
    [8]  = kTechId.BioMassEight,
    [9]  = kTechId.BioMassNine,
    [10] = kTechId.BioMassTen,
    [11] = kTechId.BioMassEleven,
    [12] = kTechId.BioMassTwelve,
}
-- returns the biomass level required by this ability, or nil if it does not require biomass.
local function GetRequiresBiomass(techId)
    
    local techTree = GetTechTree(Client.GetLocalPlayer():GetTeamNumber())
    if not techTree then
        return nil
    end
    
    local techNode = techTree:GetTechNode(techId)
    if not techNode then
        return nil
    end
    
    local level_1 = techNode:GetPrereq1()
    local level_2 = techNode:GetPrereq2()
    
    if level_1 == kTechId.None then
        level_1 = nil
    else
        level_1 = kTechToBiomassLevel[level_1]
    end
    
    if level_2 == kTechId.None then
        level_2 = nil
    else
        level_2 = kTechToBiomassLevel[level_2]
    end
    
    if level_1 == nil and level_2 == nil then
        return nil
    else
        local level = 0
        if level_1 ~= nil then
            level = level_1
        end
        
        if level_2 ~= nil then
            level = math.max(level, level_2)
        end
        
        return level
    end
    
end
local function EvaluateTechAvailability(techId, requirementMessage)
    
    local player = Client.GetLocalPlayer()
    if GetIsTechUnlocked(player, techId) then
        return true, ""
    else
        local biomassRequirement = GetRequiresBiomass(techId)
        
        if biomassRequirement == nil then
            return false, requirementMessage
        end
        
        local techId = kTechToBiomassLevel[biomassRequirement]
        local techTree = GetTechTree()
        local techNode = techTree:GetTechNode(techId)
        if techNode:GetHasTech() then
            return false, requirementMessage
        else
            return false, kBioMassLevelToHelpText[biomassRequirement]
        end
    end
    
end

local oldHelpScreen_InitializeContent = HelpScreen_InitializeContent
function HelpScreen_InitializeContent()
    oldHelpScreen_InitializeContent()
    -- Metabolize
    -- ugly hack because bugs
    name = "Metabolize"
    HelpScreen_ReplaceContent({
        name = "Metabolize",
        title = "HELP_SCREEN_METABOLIZE",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.MetabolizeEnergy, "HELP_SCREEN_METABOLIZE_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_METABOLIZE_DESCRIPTION",
        imagePath = helpScreenImages.metabolize,
        actions = {
            { "MovementModifier", },
        },
        classNames = {"Fade"},
        theme = "alien",
        skipCards = nil,
        useLocale = true,
        })
        
    name = "AdvancedMetabolize"
    -- Advanced Metabolize
    HelpScreen_ReplaceContent({
        name = "AdvancedMetabolize",
        title = "HELP_SCREEN_METABOLIZE_ADV",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.MetabolizeHealth, "HELP_SCREEN_METABOLIZE_ADV_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_METABOLIZE_ADV_DESCRIPTION",
        imagePath = helpScreenImages.advancedMetabolize,
        actions = nil,
        classNames = {"Fade"},
        theme = "alien",
        hideIfLocked = true,
        useLocale = true,
        })
    name = nil
end