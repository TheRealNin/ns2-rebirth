
if Server then

    -- 
    -- The Railgun explodes players. We must bypass the ragdoll here if we can
    -- 
    function Railgun:OnDamageDone(doer, target)
    
        if doer == self then
        
            if target:isa("Player") and not target:GetIsAlive() and target.SetBypassRagdoll then
                target:SetBypassRagdoll(true)
                
                if target:isa("Marine") then
                    -- no explode animation, add bloodmist
                    target:TriggerEffects("bloodmist", {effecthostcoords = Coords.GetTranslation(target:GetOrigin())})
                end
            end
            
        end
        
    end
    
end