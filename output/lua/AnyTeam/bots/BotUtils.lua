------------------------------------------
--  This is expensive.
--  It would be nice to piggy back off of LOSMixin, but that is delayed and also does not remember WHO can see what.
--  -- Fixed some bad logic.  Now, we simply look to see if the trace point is further away than the target, and if so,
--  It's a hit.  Previous logic seemed to assume that if the target itself wasn't hit (caused by the EngagementPoint not
--  being inside a collision solid -- the skulk for example moves around a lot) then it magically wasn't there anymore.
------------------------------------------
function GetBotCanSeeTarget(attacker, target)

    local p0 = attacker:GetEyePos()
    local p1 = target:GetEngagementPoint()
    local bias = 0.5 -- allow trace entity to be this much closer and still call a hit

    local trace = Shared.TraceCapsule( p0, p1, 0.2, 0,
            CollisionRep.Damage, PhysicsMask.Bullets,
            EntityFilterTwo(attacker, attacker:GetActiveWeapon()) )
    --return trace.entity == target
    return (trace.entity == target) or (((trace.endPoint - p0):GetLengthSquared()) >= ((p0-p1):GetLengthSquared() - bias))

end
