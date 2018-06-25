
Grenade.kMinLifeTime = 0.0
Grenade.kRadius = 0.02-- was 0.05
local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.02
local kGrenadeMaxShakeIntensity = 0.13

function Grenade:GetIsAffectedByWeaponUpgrades()
    return true
end
if Client then
    
    function Grenade:StopSimulationCallback(targetHit)
            
        -- TODO: use what is defined in the material file
        local surface = GetSurfaceFromEntity(targetHit)
        
        local params = { surface = surface }
        params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        
        GetEffectManager():TriggerEffects("grenade_explode", params)
        
        self.stoppedSimulating = true
    end
end

if Server then
    function Grenade:Detonate(targetHit)
    
        -- Do damage to nearby targets.
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius)
        
        -- Remove grenade and add firing player.
        table.removevalue(hitEntities, self)
        
        local damage = self.hasBounced and kGrenadeLauncherGrenadeDamageAfterBounce or kGrenadeLauncherGrenadeDamage
        
        -- full damage on direct impact
        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(damage, targetHit, self:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end

        RadiusDamage(hitEntities, self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius, damage, self)
        
        CreateExplosionDecals(self)
        
        TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)
        
        DestroyEntity(self)
        
    end
end