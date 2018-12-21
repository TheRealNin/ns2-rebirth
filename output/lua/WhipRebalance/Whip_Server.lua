
-- copied from vanilla
local kWhipAttackScanInterval = 0.33
local kSlapAfterBombardTimeout = 2
local kBombardAfterBombardTimeout = 5.3

local whipImpactForce = 1600
local whipImpactIncrease = Vector(0,2.5,0)
local maxWhipHitVel = 9.0

-- replace normal selector "validate target" with our own traceray
function Whip:GetCanAttackTarget(selector, targetEntity, rangeSquared)
    
    if not HasMixin(targetEntity, "Target") and targetEntity:GetEngagementPoint() then
        Log("Warning! Whip target is using GetOrigin() instead of an engagement point! If whips are missing, this is why.")
    end
    
    if targetEntity.GetIsAlive and not targetEntity:GetIsAlive() then
        return false
    end
    
    local targetOrigin = HasMixin(targetEntity, "Target") and targetEntity:GetEngagementPoint() or targetEntity:GetOrigin()
    local eyePos = self:GetEyePos()
    
    if (eyePos - targetOrigin):GetLengthSquared() > rangeSquared then
        -- Not in rangeSquared, no point in wasting a trace
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


local oldSlapTarget = Whip.SlapTarget
function Whip:SlapTarget(target)
    oldSlapTarget(self, target)
    
    -- this is the impact code
    local mass = (target.GetMass and target:GetMass() or Player.kMass)
    
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin + whipImpactIncrease
    hitDirection:Normalize()
    
    if target.GetVelocity then
        local slapVel = hitDirection * (whipImpactForce / mass)
		
		local newVel = target:GetVelocity() + slapVel
		
		if newVel:GetLength() > maxWhipHitVel then
			newVel:Normalize()
			newVel = newVel * maxWhipHitVel
		end
		
        target:SetVelocity(newVel)
    end
    if target.DisableGroundMove then
        target:DisableGroundMove(0.25)
    end
    if target.gliding then
        target.gliding = false
    end
    
    self.nextSlapStartTime    = Shared.GetTime() + kSlapAfterBombardTimeout
    self.nextBombardStartTime = Shared.GetTime() + kSlapAfterBombardTimeout
    
end

