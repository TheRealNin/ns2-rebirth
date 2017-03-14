
function Commander:GetCystParentFromCursor()

    PROFILE("Commander:GetCystParentFromCursor")

    local x, y = Client.GetCursorPosScreen()           
    local trace = GetCommanderPickTarget(self, CreatePickRay(self, x, y), false, true)
    local endPoint = trace.endPoint
    local endNormal = trace.normal
    
    if trace.fraction == 1 then
    
        -- the pointer is not on the map. set the pointer to where it intersects y==0, so we can get a reasonable range to it
        local dy = trace.endPoint.y - self:GetOrigin().y
        local frac = self:GetOrigin().y / math.abs(dy)
        endPoint = self:GetOrigin() + (trace.endPoint - self:GetOrigin()) * frac          
        endNormal = Vector(0, 1, 0)
        
    end
    
    return GetCystParentFromPoint(endPoint, endNormal, "GetIsConnectedAndAlive", nil, self:GetTeamNumber())

end


function Commander:SwitchTeamType()
    Shared.ConsoleCommand("switchteamtype")
end