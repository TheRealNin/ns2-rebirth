
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    table.insert(techData, { [kTechDataId] = kTechId.ShieldGenerator,   [kTechDataHint] = "Shield Generator hint",    [kTechDataDisplayName] = "Shield Generator", [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = Marine.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kMarinePointValue, [kTechDataCostKey] = kShieldGeneratorCost, [kTechDataMapName] = "shieldgenerator"})
    table.insert(techData, { [kTechDataId] = kTechId.ShieldGeneratorTech, [kTechDataCostKey] = kShieldGeneratorResearchCost, [kTechDataResearchTimeKey] = kShieldGeneratorTechResearchTime, [kTechDataDisplayName] = "Shield Generator #1", [kTechDataTooltipInfo] =  "Allows purchasing shield generators from armories. They improve armor effectiveness, give +10 armor, and auto-repair."})
    table.insert(techData, { [kTechDataId] = kTechId.ShieldGeneratorTech2,[kTechDataCostKey] = kShieldGenerator2ResearchCost,[kTechDataResearchTimeKey] = kShieldGenerator2TechResearchTime, [kTechDataDisplayName] = "Shield Generator #2", [kTechDataTooltipInfo] =  "Improves shield generator armor bonus to +20 and speeds up regeneration."})
    table.insert(techData, { [kTechDataId] = kTechId.ShieldGeneratorTech3,[kTechDataCostKey] = kShieldGenerator3ResearchCost,[kTechDataResearchTimeKey] = kShieldGenerator3TechResearchTime, [kTechDataDisplayName] = "Shield Generator #3", [kTechDataTooltipInfo] =  "Improves shield generator armor bonus to +30 and speeds up regeneration."})

    return techData

end
