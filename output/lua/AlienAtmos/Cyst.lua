
local effectName = PrecacheAsset("cinematics/alien/cyst/infestation_mist.cinematic")
local cystIdleSound = PrecacheAsset("sound/NS2.fev/alien/structures/shift/idle")
cystIdleSound = PrecacheAsset("sound/NS2.fev/alien/common/gestate")
local soundMin = 10
local soundMax = 25


function Cyst:GetPlayIdleSound()
    return self:GetIsBuilt()
end

if Client then
    local originalOnTimedUpdate = Cyst.OnTimedUpdate
    function Cyst:OnTimedUpdate(deltaTime)
        originalOnTimedUpdate(self, deltaTime)
        if self:GetIsAlive() then
        
            local isVisible = not self:GetIsCloaked()

            if self:GetIsBuilt() then
              local coords = self:GetCoords()
              local mistVisible = isVisible and self.connectedFraction > 0 and Client.GetOptionInteger("graphics/lightQuality", 2) ~= 1
              self:AttachEffect(effectName, coords, Cinematic.Repeat_Endless)
              self:SetEffectVisible(effectName, mistVisible)
            end
            
            
            if not self.soundTime or self.soundTime < 0 then
              self.soundTime = 0
            end
            self.soundTime = self.soundTime - deltaTime
            if self.soundTime <= 0 then
              self.soundTime =  math.random() * (soundMax - soundMin) + soundMin
              local soundEffectName = cystIdleSound
              StartSoundEffectOnEntity(soundEffectName, self, 0.5, nil)
            end
        end
        return kUpdateIntervalLow
        
    end
end
