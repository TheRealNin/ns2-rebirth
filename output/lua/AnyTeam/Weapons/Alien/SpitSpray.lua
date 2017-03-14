
local function CreateSpitProjectile(self, player)   

    if not Predict then
        
        local eyePos = player:GetEyePos()        
        local viewCoords = player:GetViewCoords()
        
        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis * 1.5, Spit.kRadius, 0, CollisionRep.Damage, PhysicsMask.PredictedProjectileGroup, EntityFilterOneAndIsa(player, "Babbler"))
        local startPoint = startPointTrace.endPoint
        
        local spit = player:CreatePredictedProjectile("Spit", startPoint, viewCoords.zAxis * kSpitSpeed, 0, 0, 0 )
    
    end

end