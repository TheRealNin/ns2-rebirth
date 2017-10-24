
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    table.insert(techData, { [kTechDataId] = kTechId.ShieldGenerator,   [kTechDataHint] = "Shield Generator hint",    [kTechDataDisplayName] = "Shield Generator", [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = Marine.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kMarinePointValue, [kTechDataCostKey] = kShieldGeneratorCost, [kTechDataMapName] = "shieldgenerator"})
    table.insert(techData, { [kTechDataId] = kTechId.ShieldGeneratorTech,           [kTechDataCostKey] = kShieldGeneratorResearchCost,           [kTechDataResearchTimeKey] = kShieldGeneratorTechResearchTime, [kTechDataDisplayName] = "Shield Generator", [kTechDataTooltipInfo] =  "Allows purchasing shield generators from armories. They improve armor effectiveness and auto-repair."})

    return techData

end
