
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    table.insert(techData, { 
		[kTechDataId] = kTechId.WraithFade, 
		[kTechDataUpgradeCost] = kFadeUpgradeCost, 
		[kTechDataMapName] = WraithFade.kMapName, 
		[kTechDataGestateName] = WraithFade.kMapName,                       
		[kTechDataGestateTime] = kFadeGestateTime, 
		[kTechDataDisplayName] = "Wraith Fade",   
		[kTechDataTooltipInfo] = "The wraith can teleport short distances. Backtrack can teleport the wraith back in time to where it was 4 seconds ago. With Shadow Dance, the wraith regenerates health rapidly when out of sight.",         
		[kTechDataModel] = Fade.kModelName,
		[kTechDataCostKey] = kWraithFadeCost, 
		[kTechDataMaxHealth] = kWraithFadeHealth, 
		[kTechDataMaxArmor] = kWraithFadeArmor, 
		[kTechDataEngagementDistance] = kPlayerEngagementDistance, 
		[kTechDataMaxExtents] = Vector(Fade.XZExtents, Fade.YExtents, Fade.XZExtents), 
		[kTechDataPointValue] = kFadePointValue
		})
		
	table.insert(techData, { 
		[kTechDataId] = kTechId.Backtrack,     
		[kTechDataCategory] = kTechId.WraithFade,   
		[kTechDataCostKey] = kMetabolizeEnergyResearchCost, 
		[kTechDataMapName] = Backtrack.kMapName, 
		[kTechDataResearchTimeKey] = kMetabolizeEnergyResearchTime,      
		[kTechDataDisplayName] = "Backtrack",  
		[kTechDataTooltipInfo] = "The fade can teleport back to where they were 4 seconds ago. Has a long cooldown."
		})
		
	table.insert(techData, { 
		[kTechDataId] = kTechId.StabTeleport,     
		[kTechDataCategory] = kTechId.WraithFade,   
		[kTechDataCostKey] = kStabResearchCost, 
		[kTechDataMapName] = StabTeleport.kMapName, 
		[kTechDataResearchTimeKey] = kStabResearchTime,      
		[kTechDataDamageType] = kStabDamageType,  
		[kTechDataDisplayName] = "STAB_BLINK",  
		[kTechDataTooltipInfo] = "STAB_TOOLTIP"
		})
		
    for index,record in ipairs(techData) do 
        local currentField = record[kTechDataId]
        
		--[[
        if(currentField == kTechId.MetabolizeEnergy) then
          
            record[kTechDataDisplayName] = "Backtrack"
            record[kTechDataTooltipInfo] = "The fade can teleport back to where they were 4 seconds ago. Has a long cooldown."
        end
		]]--

        if(currentField == kTechId.MetabolizeHealth) then
          
            record[kTechDataDisplayName] = "Shadow Dance"
            record[kTechDataTooltipInfo] = "When not visible to the enemy team, the Fade gains bonus health regeneration. An icon appears if you are sighted. "
        end
    end
    
    return techData
end
    