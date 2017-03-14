

function GetOrderTargetIsConstructTarget(order, doerTeamNumber)

    if(order ~= nil) then
    
        local entity = Shared.GetEntity(order:GetParam())
                        
        if entity and (HasMixin(entity, "Construct") and ((entity:GetTeamNumber() == doerTeamNumber) or (entity:GetTeamNumber() == kTeamReadyRoom)) and not entity:GetIsBuilt()) then
        
            return entity
        end
        
    end
    
    return nil

end


function GetOrderTargetIsWeldTarget(order, doerTeamNumber)

    if(order ~= nil) then
    
        local entityId = order:GetParam()
        if(entityId > 0) then
        
            local entity = Shared.GetEntity(entityId)
            if entity ~= nil and HasMixin(entity, "Weldable") and (entity:GetTeamNumber() == doerTeamNumber or (entity:GetTeamNumber() == kTeamReadyRoom)) then
                return entity
            end
            
        end
        
    end
    
    return nil

end
