

-- from http://stackoverflow.com/questions/10768142/verify-if-point-is-inside-a-cone-in-3d-space
local function IsPointInCone(point, cone_origin, cone_dir, angle)
    
    -- Vector pointing to camera point from cone point
    local apexToXVect = cone_origin - point;

    -- Vector pointing from apex to circle-center point.
    local axisVect = - cone_dir;

    -- X is lying in cone only if it's lying in 
    -- infinite version of its cone -- that is, 
    -- not limited by "round basement".
    -- We'll use Math.DotProduct() to 
    -- determine angle between apexToXVect and axis.
    local isInInfiniteCone = Math.DotProduct(apexToXVect,axisVect)
                               /apexToXVect:GetLength()/axisVect:GetLength()
                                 >
                               -- We can safely compare cos() of angles 
                               -- between vectors instead of bare angles.
                               math.cos(angle);


    return isInInfiniteCone;
end

local origOnUpdateRender = Marine.OnUpdateRender
function Marine:OnUpdateRender()
    origOnUpdateRender(self)
    if self.flashlightOn then
        -- Only display atmospherics for third person players.
        local density =  0 -- was 0.01
        local radius = 30
        local intensity = 10
        local isLocal = self:GetIsLocalPlayer()
        if isLocal and not self:GetIsThirdPerson() then
            density = 0
            if not self._fake_reflection then
            
                self._fake_reflection = Client.CreateRenderLight()
                
                self._fake_reflection:SetType( RenderLight.Type_Point )
                self._fake_reflection:SetColor( Color(1, 1, 1) )
                self._fake_reflection:SetIntensity( 0.15 )
                self._fake_reflection:SetRadius( 12 ) 
                self._fake_reflection:SetSpecular( false ) 
                self._fake_reflection:SetCastsShadows( false )
            end
            
            local coords = Coords(self:GetViewCoords())
            local newOrigin = coords.origin
            local checkDir = Vector(0,0,6)
            local maxCheck = 1.0
            local stepSize = 0.33
            local xDir = -maxCheck
            local yDir = -maxCheck+1 -- special case so we don't care about the ground as much
            while xDir <= maxCheck do
                checkDir.x = xDir
                xDir = xDir + stepSize
                    
                while yDir <= maxCheck do
                    checkDir.y = yDir
                    yDir = yDir + stepSize
                    
                    local endPoint = coords.origin + coords.xAxis * checkDir.x + coords.yAxis * checkDir.y + coords.zAxis * checkDir.z
                    local trace = Shared.TraceRay(coords.origin, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
                    if trace.fraction < 1 and trace.endPoint then
                        newOrigin = (newOrigin + trace.endPoint) * 0.5
                    else
                        newOrigin = (newOrigin + endPoint) * 0.5
                    end
                end
            end
            coords.origin = (newOrigin + coords.origin) * 0.5
            self._fake_reflection:SetCoords(coords)
            
        else
        
            
            radius = 10
            self.flashlight:SetCastsShadows( false )
            
            if self._fake_reflection ~= nil then
                Client.DestroyRenderLight(self._fake_reflection)
                self._fake_reflection = nil
            end
            
        end
        self.flashlight:SetAtmosphericDensity(density)
        self.flashlight:SetRadius( radius ) 
        self.flashlight:SetIntensity( intensity )
        
        if not isLocal then
            local cameraCoords = GetRenderCameraCoords()
            local coneCoords = self.flashlight:GetCoords()
            local isInSmallCone = IsPointInCone(cameraCoords.origin, coneCoords.origin, coneCoords.zAxis, math.rad(47))
            local isInLargeCone = IsPointInCone(cameraCoords.origin, coneCoords.origin, coneCoords.zAxis, math.rad(90))
            if isInSmallCone then
                self.flashlight_cinematic:SetIsVisible(true)
                self.flashlight_cinematic:SetIsActive(true)
                local coords = Coords(self.flashlight:GetCoords())
                
                coords.origin = self:GetAttachPointOrigin("Head") - coords.yAxis * 0.18 + coords.zAxis * 0.7
                self.flashlight_cinematic:SetCoords(coords)
            else
                self.flashlight_cinematic:SetIsVisible(false)
                self.flashlight_cinematic:SetIsActive(false)
            end
            
            if isInLargeCone and not isInSmallCone then
                self.flashlight_cinematic_small:SetIsVisible(true)
                self.flashlight_cinematic_small:SetIsActive(true)
                local coords = Coords(self.flashlight:GetCoords())
                
                coords.origin = self:GetAttachPointOrigin("Head") - coords.yAxis * 0.18 + coords.zAxis * 0.7
                self.flashlight_cinematic_small:SetCoords(coords)
            else
                self.flashlight_cinematic_small:SetIsVisible(false)
                self.flashlight_cinematic_small:SetIsActive(false)
            end
        end
    else
        self.flashlight_cinematic:SetIsVisible(false)
        self.flashlight_cinematic:SetIsActive(false)
        self.flashlight_cinematic_small:SetIsVisible(false)
        self.flashlight_cinematic_small:SetIsActive(false)
        
        if self._fake_reflection ~= nil then
            Client.DestroyRenderLight(self._fake_reflection)
            self._fake_reflection = nil
        end
    end
end