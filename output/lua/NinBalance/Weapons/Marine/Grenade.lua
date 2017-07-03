

Grenade.kMinLifeTime = 0.0 -- allow marines to kill themselves - it's hilarious!
Grenade.kRadius = nil -- geez this was large before
Grenade.kClearOnEnemyImpact = false

local oldOnCreate = Grenade.OnCreate
function Grenade:OnCreate()

    oldOnCreate(self)
    self.hasNotBounced = true
    
end

function Grenade:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) and self.hasNotBounced then
        
        if Server then
            self:Detonate( targetHit )
        end
        return true
    end
    self.hasNotBounced = false
end


if Server then
        
    function Grenade:ProcessHit(targetHit, surface, normal, endPoint )

        if targetHit and GetAreEnemies(self, targetHit) and self.hasNotBounced then
            
            self:Detonate(targetHit, hitPoint )
                
        else
            self.hasNotBounced = false
            
            if self:GetVelocity():GetLength() > 2 then
                
                self:TriggerEffects("grenade_bounce")
                
            end
        end
        
    end
end