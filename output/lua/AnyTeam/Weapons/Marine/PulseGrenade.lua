
local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.14

local function EnergyDamage(hitEntities, origin, radius, damage)

    for _, entity in ipairs(hitEntities) do
    
        if entity.GetEnergy and entity.SetEnergy then
        
            local targetPoint = HasMixin(entity, "Target") and entity:GetEngagementPoint() or entity:GetOrigin()
            local energyToDrain = damage *  (1 - Clamp( (targetPoint - origin):GetLength() / radius, 0, 1))
            entity:SetEnergy(entity:GetEnergy() - energyToDrain)
        
        end
    
        if GetAreEnemies(self, entity) and entity.SetElectrified then
            entity:SetElectrified(kElectrifiedDuration)
        end
    
    end

end

if Server then
    
    function PulseGrenade:Detonate(targetHit)

        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kPulseGrenadeEnergyDamageRadius)
        table.removevalue(hitEntities, self)

        if targetHit then
        
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(kPulseGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
            
            if GetAreEnemies(targetHit, self) and targetHit.SetElectrified then
                targetHit:SetElectrified(kElectrifiedDuration)
            end
            
        end
        
        RadiusDamage(hitEntities, self:GetOrigin(), kPulseGrenadeDamageRadius, kPulseGrenadeDamage, self)
        EnergyDamage(hitEntities, self:GetOrigin(), kPulseGrenadeEnergyDamageRadius, kPulseGrenadeEnergyDamage)

        local surface = GetSurfaceFromEntity(targetHit)
        
        if GetIsVortexed(self) then
            surface = "ethereal"
        end

        local params = { surface = surface }
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end
        
        self:TriggerEffects("pulse_grenade_explode", params)    
        CreateExplosionDecals(self)
        TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)
     
        DestroyEntity(self)

    end
end