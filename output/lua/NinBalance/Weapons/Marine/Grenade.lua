

Grenade.kMinLifeTime = 0.0 -- this is a lie. We handle the min lifetime in ProcessHit
local actualMinLifetime = 0.15
Grenade.kRadius = nil -- geez this was large before
Grenade.kClearOnEnemyImpact = false

local oldOnCreate = Grenade.OnCreate
function Grenade:OnCreate()

    oldOnCreate(self)
    self.hasNotBounced = true
    self.creationTime = Shared.GetTime()
    
end

function Grenade:ProcessNearMiss( targetHit, endPoint )

    local oldEnough = actualMinLifetime + self.creationTime <= Shared.GetTime()
    if targetHit and GetAreEnemies(self, targetHit) and self.hasNotBounced and oldEnough then
        
        if Server then
            self:Detonate( targetHit )
        end
        self.clearOnImpact = true
        return true
    end
    self.clearOnImpact = false
    self.hasNotBounced = false
end


if Server then
        
    function Grenade:ProcessHit(targetHit, surface, normal, endPoint )

        local oldEnough = actualMinLifetime + self.creationTime <= Shared.GetTime()
        
        if targetHit and GetAreEnemies(self, targetHit) and self.hasNotBounced and oldEnough then
            
            self.clearOnImpact = true
            self:Detonate(targetHit, hitPoint )
                
        else
            self.hasNotBounced = false
            self.clearOnImpact = false
            
            if self:GetVelocity():GetLength() > 2 then
                
                self:TriggerEffects("grenade_bounce")
                
            end
        end
        
    end
end