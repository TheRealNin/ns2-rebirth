
local kExoFlashlightPosition = Vector(0, 1.5, 0.75)

if Client then
  local originalMakeFlashlight = Exosuit.MakeFlashlight
  function Exosuit:MakeFlashlight()
      originalMakeFlashlight(self)
      
      self.flashlight:SetColor(Color(.8, .8, 1))
      self.flashlight:SetInnerCone(math.rad(2))
      self.flashlight:SetOuterCone(math.rad(60))
      self.flashlight:SetIntensity(16)
      self.flashlight:SetRadius(15)
      self.flashlight:SetAtmosphericDensity(0.03)
  end
  
  
  local originalOnUpdate = Exosuit.OnUpdate
  function Exosuit:OnUpdate()
      originalOnUpdate(self)
      if self.flashlightOn then
      
          local coords = self:GetCoords()
          coords.origin = coords.origin + coords.zAxis * kExoFlashlightPosition.z + coords.xAxis * kExoFlashlightPosition.x + coords.yAxis * kExoFlashlightPosition.y
          
          self.flashlight:SetCoords(coords)
          
      end
  end
end