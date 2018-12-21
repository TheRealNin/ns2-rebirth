
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    table.insert(techData, { [kTechDataId] = kTechId.ProwlerMenu,            [kTechDataDisplayName] = "UPGRADE_PROWLER",  [kTechDataTooltipInfo] = "UPGRADE_PROWLER_TOOLTIP", })
    table.insert(techData, { [kTechDataId] = kTechId.UpgradeProwler,  [kTechDataCostKey] = kUpgradeProwlerResearchCost,  [kTechDataResearchTimeKey] = kUpgradeProwlerResearchTime,   [kTechDataDisplayName] = "UPGRADE_PROWLER", [kTechDataTooltipInfo] = "UPGRADE_PROWLER_TOOLTIP",    [kTechDataMenuPriority] = -1 })
    table.insert(techData, { [kTechDataId] = kTechId.Howl,           [kTechDataCategory] = kTechId.Prowler, [kTechDataDisplayName] = "Howl", [kTechDataCostKey] = kHowlResearchCost, [kTechDataResearchTimeKey] = kHowlResearchTime, [kTechDataTooltipInfo] = "With the correct Hive upgrade, Prowlers gain additional abilities. Shift: Enzyme, Shade: A skulk hallucination, Crag: Mucous membrane." })
    table.insert(techData,  { 
		[kTechDataId] = kTechId.Prowler, 
		[kTechDataUpgradeCost] = kProwlerUpgradeCost, 
		[kTechDataMapName] = Prowler.kMapName, 
		[kTechDataGestateName] = Prowler.kMapName,                      
		[kTechDataGestateTime] = kProwlerGestateTime, 
		[kTechDataDisplayName] = "Prowler",  
		[kTechDataTooltipInfo] = "Ground support and pack leader. Has a low damage acid spray attack, and can buff nearby allies with Hive evolutions.",        
		[kTechDataModel] = Prowler.kModelName, 
		[kTechDataCostKey] = kProwlerCost, 
		[kTechDataMaxHealth] = Prowler.kHealth, 
		[kTechDataMaxArmor] = Prowler.kArmor, 
		[kTechDataEngagementDistance] = kPlayerEngagementDistance, 
		[kTechDataMaxExtents] = Vector(Prowler.kXExtents, Prowler.kYExtents, Prowler.kZExtents), 
		[kTechDataPointValue] = kProwlerPointValue
	})
	
    table.insert(techData, { [kTechDataId] = kTechId.HallucinateProwler, [kTechDataRequiresMature] = true, [kTechDataDisplayName] = "HALLUCINATE_DRIFTER", [kTechDataTooltipInfo] = "HALLUCINATE_DRIFTER_TOOLTIP", [kTechDataCostKey] = kHallucinateDrifterEnergyCost })
    return techData

end
