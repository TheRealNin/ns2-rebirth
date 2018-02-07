

local originalOnCreate = Exo.OnCreate
function Exo:OnCreate()
  originalOnCreate(self)
  if Client then
      self.flashlight:SetColor(Color(.8, .8, 1))
      self.flashlight:SetInnerCone(math.rad(25))
      self.flashlight:SetOuterCone(math.rad(55))
      self.flashlight:SetIntensity(9)
      self.flashlight:SetRadius(35)
  end
end


if Client then
    local oldOnUpdateRender = Exo.OnUpdateRender
    function Exo:OnUpdateRender()
        oldOnUpdateRender(self)
        if self.flashlightOn then
            local coords = Coords(self:GetViewCoords())
            coords.origin = coords.origin + coords.zAxis * 0.75
            coords.zAxis.y = Clamp(coords.zAxis.y * 0.5, -0.5, 0.5)
            coords.zAxis:Normalize()
            local isLocal = self:GetIsLocalPlayer()
            
            if isLocal and not self:GetIsThirdPerson() then
                self.flashlight:SetRadius(35)
            else
                self.flashlight:SetRadius(15)
            end
            
            self.flashlight:SetCoords(coords)
        end
        
    end
    
end