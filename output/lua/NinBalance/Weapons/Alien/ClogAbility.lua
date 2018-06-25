
local oldGetIsPositionValid = ClogAbility.GetIsPositionValid
function ClogAbility:GetIsPositionValid(position, player, normal)
    local oldReturn = oldGetIsPositionValid(self, position, player, normal)
    
    local entities = GetEntitiesWithinRange("Hydra", position, 1)    
    for _, entity in ipairs(entities) do
    
        if entity.GetIsAlive and entity:GetIsAlive() then
            return false        
        end
    
    end
    
    return oldReturn
    

end