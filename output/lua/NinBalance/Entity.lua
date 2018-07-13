
-- Fades damage linearly from center point to radius (0 at far end of radius)
function RadiusDamage(entities, centerOrigin, radius, fullDamage, doer, ignoreLOS, fallOffFunc)

    assert(HasMixin(doer, "Damage"))

    -- Do damage to every target in range
    for index, target in ipairs(entities) do
    
        -- Find most representative point to hit
        local targetOrigin = GetTargetOrigin(target)
        
        -- Trace line to each target to make sure it's not blocked by a wall
        local wallBetween = false
        local distanceFromTarget = (targetOrigin - centerOrigin):GetLength()
        
        if not ignoreLOS then
            wallBetween = GetWallBetween(centerOrigin, targetOrigin, target)
        end
        
        if (ignoreLOS or not wallBetween) and (distanceFromTarget <= radius) then
        
            -- Damage falloff
            local distanceFraction = distanceFromTarget / (radius * 2) -- half damage at max radius
            if fallOffFunc then
                distanceFraction = fallOffFunc(distanceFraction)
            end
            
            distanceFraction = Clamp(distanceFraction, 0, 1)        
            local damage = fullDamage * (1 - distanceFraction)

            local damageDirection = targetOrigin - centerOrigin
            damageDirection:Normalize()
            
            -- we can't hit world geometry, so don't pass any surface params and let DamageMixin decide
            doer:DoDamage(damage, target, centerOrigin, damageDirection, "none")

        end
        
    end
    
end