
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
    end
    
    return techData
end
    