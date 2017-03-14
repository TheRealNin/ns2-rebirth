
if Server then

    -- sort always by distance first (increases the chance that we find a suitable source faster)

    function FindNewPowerConsumers(powerSource)
    
        -- allow passing of nil (to handle map change or unexpected destruction of some ojects)
        if not powerSource then
            return nil
        end
    
        local consumers = GetEntitiesWithMixin("PowerConsumer")
        -- there might not be any if alien versus alien
        if consumers and #consumers > 0 then
            --Shared.SortEntitiesByDistance(powerSource:GetOrigin(), consumers)
            
            local canPower = false
            local stopSearch = false

            for index, consumer in ipairs(consumers) do

                canPower, stopSearch = powerSource:GetCanPower(consumer)
            
                if canPower then
                    powerSource:AddConsumer(consumer)
                    consumer:SetPowerOn()
                    consumer.powerSourceId = powerSource:GetId()
                end
                
                if stopSearch then
                    break
                end
                
            end
        end
    end
end