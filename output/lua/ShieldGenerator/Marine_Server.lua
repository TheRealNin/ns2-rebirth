
local oldAttemptToBuy = Marine.AttemptToBuy
function Marine:AttemptToBuy(techIds)
    local techId = techIds[1]
    
    local hostStructure = GetHostStructureFor(self, techId)

    
    if hostStructure then
    
        if techId == kTechId.ShieldGenerator then
            if not self:GetIsPersonalShielded() then
                Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
                
                -- Need to apply this here since we just change a mixin value
                self:AddResources(-GetCostForTech(techId))
                self:GiveShieldGenerator()
                
            end
            return false
        end
        
        
    end
    
    return oldAttemptToBuy(self, techIds)
    
    
end

function Marine:GiveShieldGenerator()

    self:ActivatePersonalShield()
    
end
