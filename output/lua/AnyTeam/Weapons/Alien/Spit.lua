
if Server then
          
    function Spit:ProcessHit(targetHit, surface, normal, hitPoint)

        if self:GetOwner() ~= targetHit then
            self:DoDamage(Spit.kDamage, targetHit, hitPoint, normal, "none", false, false)
        elseif self:GetOwner() == targetHit then
            --a little hacky
            local player = self:GetOwner()
            if player then
                local eyePos = player:GetEyePos()        
                local viewCoords = player:GetViewCoords()
                local trace = Shared.TraceRay(eyePos, eyePos + viewCoords.zAxis * 1.5, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
                if trace.fraction ~= 1 then
                    local entity = trace.entity
                    self:DoDamage(Spit.kDamage, entity, hitPoint, normal, "none", false, false)
                end
            end
        end
        
        GetEffectManager():TriggerEffects("spit_hit", { effecthostcoords = self:GetCoords() })

        DestroyEntity(self)
        
    end
end