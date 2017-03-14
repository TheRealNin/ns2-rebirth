
if Server then

    -- 
    -- The Railgun explodes players. We must bypass the ragdoll here if we can
    -- 
    function Railgun:OnDamageDone(doer, target)
    
        if doer == self then
        
            if target:isa("Player") and not target:GetIsAlive() and target.SetBypassRagdoll then
                target:SetBypassRagdoll(true)
            end
            
        end
        
    end
    
end