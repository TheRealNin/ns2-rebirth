

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
        local density = 0.05
        local radius = 30
        local intensity = 9
        local isLocal = self:GetIsLocalPlayer()
        if isLocal and not self:GetIsThirdPerson() then
            density = 0
        else
            radius = 10
            intensity = 5
        end
        self.flashlight:SetAtmosphericDensity(density)
        self.flashlight:SetRadius( radius ) 
        self.flashlight:SetIntensity( intensity )
        
        if not isLocal then
            local cameraCoords = GetRenderCameraCoords()
            local coneCoords = self.flashlight:GetCoords()
            if IsPointInCone(cameraCoords.origin, coneCoords.origin, coneCoords.zAxis, math.rad(47)) then
                self.flashlight_cinematic:SetIsVisible(true)
                self.flashlight_cinematic:SetIsActive(true)
                local coords = Coords(self.flashlight:GetCoords())
                
                coords.origin = self:GetAttachPointOrigin("Head") - coords.yAxis * 0.18 + coords.zAxis * 0.7
                self.flashlight_cinematic:SetCoords(coords)
            else
                self.flashlight_cinematic:SetIsVisible(false)
                self.flashlight_cinematic:SetIsActive(false)
            end
        end
    else
        self.flashlight_cinematic:SetIsVisible(false)
        self.flashlight_cinematic:SetIsActive(false)
    end
end