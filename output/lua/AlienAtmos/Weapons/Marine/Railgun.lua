
function Railgun:GetBarrelPoint()

    local player = self:GetParent()
    if player then
    
        if player:GetIsLocalPlayer() then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return self:GetOrigin()
    
end