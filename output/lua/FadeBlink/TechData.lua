
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    
    for index,record in ipairs(techData) do 
        local currentField = record[kTechDataId]
        
        if(currentField == kTechId.MetabolizeEnergy) then
          
            record[kTechDataDisplayName] = "Backtrack"
            record[kTechDataTooltipInfo] = "The fade can teleport back to where they were 4 seconds ago. Has a long cooldown."
        end

        if(currentField == kTechId.MetabolizeHealth) then
          
            record[kTechDataDisplayName] = "Shadow Dance"
            record[kTechDataTooltipInfo] = "When not visible to the enemy team, the Fade gains bonus health regeneration. An icon appears if you are sighted. "
        end
        if(currentField == kTechId.Fade or currentField == kTechId.UpgradeFade or currentField == kTechId.FadeMenu) then
          
            record[kTechDataDisplayName] = "Wraith Fade"
            record[kTechDataTooltipInfo] = "The wraith can teleport short distances. Backtrack can teleport the wraith back in time to where it was 4 seconds ago. With Shadow Dance, the wraith regenerates health rapidly when out of sight."
        end
    end
    
    return techData
end
    