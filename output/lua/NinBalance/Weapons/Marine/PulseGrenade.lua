
PulseGrenade.kDetonateRadius = 0.17
PulseGrenade.kClearOnImpact      = true
PulseGrenade.kClearOnEnemyImpact = true


function PulseGrenade:ProcessHit(targetHit)

    if Server then
        self:Detonate(targetHit)
    end    
    return true
end

function PulseGrenade:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:Detonate( targetHit )
        end
        return true
    end
end

if Server then
    function PulseGrenade:OnUpdate(deltaTime)
        PredictedProjectile.OnUpdate(self, deltaTime)
    end
end