  
function TechTree:GetSpecialTechSupported(techId, structureTechIdList, techIdCount)

    local supportingIds = nil
    
    if techId == kTechId.TwoShells or techId == kTechId.ThreeShells then
        supportingIds = { kTechId.Shell }
        
    elseif techId == kTechId.TwoSpurs or techId == kTechId.ThreeSpurs then
        supportingIds = { kTechId.Spur }
        
    elseif techId == kTechId.TwoVeils or techId == kTechId.ThreeVeils then
        supportingIds = { kTechId.Veil }
    
    elseif techId == kTechId.TwoCommandStations or techId == kTechId.ThreeCommandStations then    
        supportingIds = { kTechId.CommandStation }
        
    elseif techId == kTechId.TwoHives or techId == kTechId.ThreeHives then
        supportingIds = { kTechId.Hive, kTechId.ShadeHive, kTechId.ShiftHive, kTechId.CragHive }
        
    else
    
        local bioMassLevel = BioMassTechToLevel(techId)
        if bioMassLevel > 0 then
    
            -- check if alien team reached the bio mass level, mark the tech as available if level is equal or above
            local alienTeam = GetGamerules():GetTeam(self:GetTeamNumber())
            if alienTeam and alienTeam.GetBioMassLevel and alienTeam.GetMaxBioMassLevel then
            
                local effectiveBioMassLevel = math.min(alienTeam:GetBioMassLevel(), alienTeam:GetMaxBioMassLevel())
            
                if effectiveBioMassLevel >= bioMassLevel then
                    return true
                else
                    return false
                end
            end
        
        end
    
    end
    
    if not supportingIds then
        return false
    end    
    
    local numBuiltSpecials = 0
    
    for _, supportingId in ipairs(supportingIds) do
    
        if techIdCount[supportingId] then
            numBuiltSpecials = numBuiltSpecials + techIdCount[supportingId]
        end
    
    end
    
    --[[
    local structureTechIdListText = ""
    for _, structureTechId in ipairs(structureTechIdList) do
        structureTechIdListText = structureTechIdListText .. ", " .. EnumToString(kTechId, structureTechId) .. "(" .. ToString(techIdCount[structureTechId]) .. ")"
    end
    
    Print(structureTechIdListText)
    Print("TechTree:GetSpecialTechSupported(%s), numBuiltSpecials: %s", EnumToString(kTechId, techId), ToString(numBuiltSpecials))
    --]]
    
    if techId == kTechId.TwoCommandStations or 
       techId == kTechId.TwoHives or 
       techId == kTechId.TwoShells or 
       techId == kTechId.TwoSpurs or 
       techId == kTechId.TwoVeils then
       
        return numBuiltSpecials >= 2
    else
        return numBuiltSpecials >= 3
    end
    
end