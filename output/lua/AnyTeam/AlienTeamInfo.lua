if Server then
    function AlienTeamInfo:UpdateAllLocationsSlotData()
        
        local statusEnts = GetEntitiesMatchAnyTypesForTeam( AlienTeamInfo.kLocationEntityTypes, self:GetTeamNumber() )
        
        for _, entity in ipairs(statusEnts) do
            
            if entity:GetIsAlive() then
                if entity:isa("Hive") then
                    self:UpdateLocationSlotHiveData( 
                        entity.locationId, 
                        entity:GetTechId(), 
                        entity:GetBuiltFraction(), 
                        entity:GetHealthScalar(),
                        entity:GetMaxHealth(),
                        entity:GetIsInCombat()
                    )
                elseif entity:isa("Egg") then
                    self:UpdateLocationEggCounts( entity.locationId, entity:GetIsInCombat() )
                end
            end
            
        end
        
    end
    
end --End-ServerOnly