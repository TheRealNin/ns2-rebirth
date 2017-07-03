
Hydra.kUpdateInterval = .25


local function CreateSpikeProjectile(self)

    -- TODO: make hitscan at account for target velocity (more inaccurate at higher speed)
    
    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistanceSquared = directionToTarget:GetLengthSquared()
    local theTimeToReachEnemy = targetDistanceSquared / (Hydra.kSpikeSpeed * Hydra.kSpikeSpeed)
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * Hydra.kTargetVelocityFactor * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))
        
    end
    
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Hydra.kSpread, math.random)
    
    local endPoint = startPoint + spreadDirection * Hydra.kRange
    
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
    
    if trace.fraction < 1 then
    
        local surface = nil
        
        -- Disable friendly fire.
        trace.entity = (not trace.entity or GetAreEnemies(trace.entity, self)) and trace.entity or nil
        
        if not trace.entity then
            surface = trace.surface
        end
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        self:DoDamage(Hydra.kDamage, trace.entity, trace.endPoint, fireDirection, surface, false, true)
        
    end
    
end

function Hydra:AttackTarget()

    self:TriggerUncloak()
    
    CreateSpikeProjectile(self)    
    self:TriggerEffects("hydra_attack")
    
    self.timeOfNextFire = Shared.GetTime() + Hydra.kUpdateInterval -- this used to fire at 0.5 to 1.5 second intervals, somehow
    
end