
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    
    for index,record in ipairs(techData) do 
        local currentField = record[kTechDataId]
        
        if currentField == kTechId.Sentry then
          
          -- patch the tech data to allow sentries from being built anywhere
            record[kStructureBuildNearClass] = nil
            record[kTechDataGhostGuidesMethod] = nil
            
        end

    end
    
    return techData
end
