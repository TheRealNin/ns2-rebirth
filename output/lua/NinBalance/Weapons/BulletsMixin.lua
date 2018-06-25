

function BulletsMixin:GetBulletFalloffStart()
    return kBulletDamageFalloffStart
end

function BulletsMixin:GetBulletFalloffEnd()
    return kBulletDamageFalloffEnd
end

function BulletsMixin:GetBulletFalloffFraction()
    return kBulletDamageFalloffFraction
end


function BulletsMixin:ApplyBulletGameplayEffects(player, target, endPoint, direction, damage, surface, showTracer)
    
    local falloffStart = self:GetBulletFalloffStart()
    local falloffEnd = self:GetBulletFalloffEnd()
    local falloffFraction = self:GetBulletFalloffFraction()
    
    if player and endPoint and target and target:isa("Player") then
        local distance = (player:GetOrigin() - endPoint):GetLength()
        if distance >= falloffEnd then
            damage = damage * falloffFraction
        elseif (distance > falloffStart and distance < falloffEnd) then
            local fraction = (distance - falloffStart) / (falloffEnd - falloffStart)
            if fraction > 0 then
                damage = damage * (falloffFraction * fraction + (1 - fraction))
            end
        end
    end
    
    local blockedByUmbra = GetBlockedByUmbra(target)
    
    if blockedByUmbra then
        surface = "umbra"
    end

    -- deals damage or plays surface hit effects
    self:DoDamage(damage, target, endPoint, direction, surface, false, showTracer)
    
end