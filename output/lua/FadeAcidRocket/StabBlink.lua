 
Script.Load("lua/FadeAcidRocket/AcidRocket.lua")

-- acid rocket is not influenced by focus
StabBlink.cooldownInfluence = 0.0 -- 0 = no focus cooldown, 1 = same as kAttackDuration

local kRocketVelocity = 35

local kAttackDuration = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "stab")

local function CreateRocketProjectile( self, player )
    
    if not Predict then
        
        -- little bit of a hack to prevent exploitey behavior.  Prevent gorges from bile bombing
        -- through clogs they are trapped inside.
        local startPoint = nil
        local startVelocity = nil
        if GetIsPointInsideClogs(player:GetEyePos()) then
            startPoint = player:GetEyePos()
            startVelocity = Vector(0,0,0)
        else
            local viewCoords = player:GetViewAngles():GetCoords()
            startPoint = player:GetEyePos() + viewCoords.zAxis * 2.0
            startVelocity = viewCoords.zAxis * kRocketVelocity
            
            local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
            
            startPoint = startPointTrace.endPoint
        end
        
        player:CreatePredictedProjectile( "AcidRocket", startPoint, startVelocity, 0, 0, 0 )
        
    end
    
end

function StabBlink:DoAttack()
    self:TriggerEffects("stab_hit")
    self.stabbing = false

    local player = self:GetParent()
    if player then
        if Server or (Client and Client.GetIsControllingPlayer()) then
            CreateRocketProjectile(self, player)
        end
        
        self:OnAttack(player)
    end
end


function StabBlink:GetBlinkAllowed()
    return true
end