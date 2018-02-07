
if Client then

    function Rifle:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            if Client and Client.GetIsControllingPlayer() then
            
                return origin + viewCoords.zAxis * 0.22 + viewCoords.xAxis * -0.19 + viewCoords.yAxis * -0.16
                
            end
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.24
            
        end
        
        return self:GetOrigin()
        
    end
    
end