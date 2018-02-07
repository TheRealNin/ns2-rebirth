local kHMGTracerEffectName = PrecacheAsset("cinematics/marine/machinegun_tracer.cinematic")

function HeavyMachineGun:GetTracerEffectName()
    return kHMGTracerEffectName
end

 
if Client then

    function HeavyMachineGun:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            if Client and Client.GetIsControllingPlayer() then
            
                return origin + viewCoords.zAxis * 0.55 + viewCoords.xAxis * -0.19 + viewCoords.yAxis * -0.16
                
            end
            return origin + viewCoords.zAxis * 0.65 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.30
        end
        
        return self:GetOrigin()
        
    end
    
end