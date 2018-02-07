 
if Client then

    function Pistol:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            if Client and Client.GetIsControllingPlayer() then
            
                return origin + viewCoords.zAxis * 0.22 + viewCoords.xAxis * -0.13 + viewCoords.yAxis * -0.16
                
            end
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.1 + viewCoords.yAxis * -0.22
        end
        
        return self:GetOrigin()
        
    end
    
end