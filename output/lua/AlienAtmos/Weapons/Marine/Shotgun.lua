
if Client then

    function Shotgun:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            if Client and Client.GetIsControllingPlayer() then
            
                return origin + viewCoords.zAxis * 0.22 + viewCoords.xAxis * -0.26 + viewCoords.yAxis * -0.12
                
            end
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.18 + viewCoords.yAxis * -0.24
        end
        
        return self:GetOrigin()
        
    end
    
end