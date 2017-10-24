
Marine.kFlashlightCinematic = PrecacheAsset("cinematics/marine/marine/flashlight.cinematic")
Marine.kFlashlightAttachPoint = "BodyArmor_Chest2_Ctrl"

local originalOnCreate = Marine.OnCreate
function Marine:OnCreate()
  originalOnCreate(self)
  if Client then
      self.flashlight:SetInnerCone( math.rad(1) )
      self.flashlight:SetOuterCone( math.rad(47) )
      self.flashlight:SetColor( Color(.9, .9, 1.0) )
      self.flashlight:SetIntensity( 9 )
      self.flashlight:SetRadius( 30 ) 
      self.flashlight:SetShadowFadeRate(1)
      self.flashlight:SetAtmosphericDensity(0)
      
      self.flashlight_cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
      self.flashlight_cinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
      self.flashlight_cinematic:SetCinematic(Marine.kFlashlightCinematic)
      --self.flashlight_cinematic:SetParent(self)
      --self.flashlight_cinematic:SetAttachPoint(2)
      self.flashlight_cinematic:SetCoords(Coords.GetIdentity())
      self.flashlight_cinematic:SetIsVisible(false)
      self.flashlight_cinematic:SetIsActive(false)
  end
end

local oldOnDestroy = Marine.OnDestroy
function Marine:OnDestroy()

    oldOnDestroy(self)
    
    if Client then

        if self.flashlight_cinematic ~= nil then
            Client.DestroyCinematic(self.flashlight_cinematic)
        end

    end
    
end