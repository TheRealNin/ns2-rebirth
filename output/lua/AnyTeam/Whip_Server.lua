
function Whip:TryAttack(selector)

    return selector:AcquireTarget()

end

-- Whip.kRange and Whip.kBombardRange
function Whip:CanAttack(targetEntity, range)

    
    if not HasMixin(targetEntity, "Target") and targetEntity:GetEngagementPoint() then
        Log("Warning! Whip target is using GetOrigin() instead of an engagement point! If whips are missing, this is why.")
    end
    
    local targetOrigin = HasMixin(targetEntity, "Target") and targetEntity:GetEngagementPoint() or targetEntity:GetOrigin()
    local eyePos = self:GetEyePos()
    
    if (eyePos - targetOrigin):GetLength() > range then
        -- Not in range, no point in wasting a trace
        return false
    end
    
    local filter = EntityFilterAllButIsa("Door")-- EntityFilterAll()
   -- See if there's something blocking our view of the entity.
    local trace = Shared.TraceRay(eyePos, targetOrigin, CollisionRep.LOS, PhysicsMask.All, filter)
    
    if trace.fraction == 1 then
        -- nothing in the way!
        return true
    end

    return false
    
end


function Whip:OnAttackHit(target)

    self:SetOrigin(self:GetOrigin())
    if target and self.slapping then
        if not self:GetIsOnFire() and self:CanAttack(target, Whip.kRange) then
            self:SlapTarget(target)                           
        end
    end
    
    if target and self.bombarding then
        if not self:GetIsOnFire() and self.bombardTargetSelector:ValidateTarget(target) then
            self:BombardTarget(target)
        end        
    end
    -- Stop trigger new attacks
    self.slapping = false
    self.bombarding = false    
    -- mark that we are waiting for the end of an attack
    self.waitingForEndAttack = true
    
end


local whipImpactForce = 400

local oldSlapTarget = Whip.SlapTarget
function Whip:SlapTarget(target)
    oldSlapTarget(self, target)
    
    local mass = (target.GetMass and target:GetMass() or Player.kMass)
    
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()
    
    if target.GetVelocity then
        local slapVel = hitDirection * (whipImpactForce / mass)
        target:SetVelocity(target:GetVelocity() + slapVel)
    end
    if target.DisableGroundMove then
        target:DisableGroundMove(0.3)
    end
    if target.gliding then
        target.gliding = false
    end
end

