

function Hive:OnUpdate(deltaTime)

    CommandStructure.OnUpdate(self, deltaTime)
      
    
    local locallyFirstSight = self:GetIsSighted() == true and self:GetIsSighted() ~= self.clientHiveSighted
    
    if locallyFirstSight then
    
        self.clientHiveSighted = true
        local techPoint = self:GetAttached()
        if techPoint then
            techPoint:SetSmashScouted()
        end
        
    end
    local isVisible = not self:GetIsCloaked() and self:GetIsAlive()
    
    -- Disable other stuff :P
    self:SetEffectVisible(Hive.kSpecksEffect, isVisible)
    self:SetEffectVisible(Hive.kGlowEffect, isVisible)
    
    if self:GetIsBuilt() then
        -- was previously capped at 3, but now we vary it from 0.25 to 4.25 based on biomass level and health
        local glowIntensity = (self:GetHealthScalar() * self:GetBioMassLevel()) * 0.75 + 0.25
        self.glowIntensity = math.min(glowIntensity, self.glowIntensity + deltaTime)
        
        -- Attach mist effect if we don't have one already
        local coords = self:GetCoords()
        local effectName = Hive.kIdleMistEffect
        
        if self:GetTechId() == kTechId.Hive then
            effectName = Hive.kIdleMistEffect
        end
        
        self:AttachEffect(effectName, coords, Cinematic.Repeat_Endless)
        self:SetEffectVisible(effectName, isVisible)
    end
    
end