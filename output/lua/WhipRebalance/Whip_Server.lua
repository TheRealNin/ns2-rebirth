
-- copied from vanilla
local kWhipAttackScanInterval = 0.33
local kSlapAfterBombardTimeout = 2
local kBombardAfterBombardTimeout = 5.3

local whipImpactForce = 400

local oldUnroot = Whip.Unroot
function Whip:Unroot()
    oldUnroot(self)
    self.attackStartTime = nil
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

    -- You have to set the origin periodically to work around broken entity stuff
    self:SetOrigin(self:GetOrigin())

    if target and self.slapping then
        if not self:GetIsOnFire() and self:CanAttack(target, Whip.kRange) then
            target:SetOrigin(target:GetOrigin())
            self:SlapTarget(target)                           
        end
    end
    
    if target and self.bombarding then
        if not self:GetIsOnFire() and self.bombardTargetSelector:ValidateTarget(target) then
            target:SetOrigin(target:GetOrigin())
            self:BombardTarget(target)
        end        
    end
    -- Stop trigger new attacks
    self.slapping = false
    self.bombarding = false    
    -- mark that we are waiting for the end of an attack
    self.waitingForEndAttack = true
    
end

function Whip:EndAttack()

    self.targetId = Entity.invalidId
    self.slapping = false
    self.bombarding = false

end

function Whip:OnAttackStart() 

    -- attack animation has started, so the attack has started
    if HasMixin(self, "Cloakable") then
        self:TriggerUncloak() 
    end

    if self.bombarding then
        self:TriggerEffects("whip_bombard")
    end
    
end

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
    
    self.nextSlapStartTime    = Shared.GetTime() + kSlapAfterBombardTimeout
    self.nextBombardStartTime = Shared.GetTime() + kSlapAfterBombardTimeout
    
end

local oldBombardTarget = Whip.BombardTarget
function Whip:BombardTarget(target)
    oldBombardTarget(self, target)
    
    self.nextSlapStartTime    = Shared.GetTime() + kSlapAfterBombardTimeout
    self.nextBombardStartTime = Shared.GetTime() + kBombardAfterBombardTimeout
end

function Whip:UpdateAttack(deltaTime)
    local now = Shared.GetTime()
    
    if not self.nextAttackScanTime or now > self.nextAttackScanTime then
        self:UpdateAttacks()
    end
    
   
end

function Whip:UpdateAttacks()

    if self:GetCanStartSlapAttack() then
        local newTarget = self:TryAttack(self.slapTargetSelector)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.slapping = true
            self.bombarding = false
        end
    end

    if not self.slapping and self:GetCanStartBombardAttack() then
        local newTarget = self:TryAttack(self.bombardTargetSelector)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.bombarding = true
            self.slapping = false;
        end
    end

end

function Whip:GetCanStartSlapAttack()

    if not self.rooted or self:GetIsOnFire() then
        return false
    end
    
    return Shared.GetTime() > self.nextSlapStartTime
    
end


function Whip:GetCanStartBombardAttack()

    if not self:GetIsMature() then
        return false
    end

    if not self.rooted or self:GetIsOnFire() then
        return false
    end
    
    
    return Shared.GetTime() > self.nextBombardStartTime

end


function Whip:TryAttack(selector)

    return selector:AcquireTarget()

end

