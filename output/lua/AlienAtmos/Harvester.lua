
local effectName = PrecacheAsset("cinematics/alien/harvester/glow.cinematic")
local kGlowIntensity = 1

if Client then
    function Harvester:OnUpdate(deltaTime)
    
        ResourceTower.OnUpdate(self, deltaTime)
        
        if self:GetIsBuilt() then
        
            local isVisible = not self:GetIsCloaked() and Client.GetOptionInteger("graphics/lightQuality", 2) ~= 1
            
            local growRatio = math.min(1, self.glowIntensity + deltaTime)
            local healthRatio = self:GetHealthScalar()
            self.glowIntensity = growRatio * healthRatio * kGlowIntensity
            
            local coords = self:GetCoords()
            self:AttachEffect(effectName, coords, Cinematic.Repeat_Endless)
            self:SetEffectVisible(effectName, isVisible)
            
        end
        
    end   

end
