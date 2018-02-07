local kLevel1Tracer = PrecacheAsset("cinematics/marine/tracer1.cinematic")
local kLevel2Tracer = PrecacheAsset("cinematics/marine/tracer2.cinematic")
local kLevel3Tracer = PrecacheAsset("cinematics/marine/tracer3.cinematic")
--
-- Fires the specified number of bullets in a cone from the player's current view.
--
local function FireBullets(self, player)

    PROFILE("FireBullets")

    local viewAngles = player:GetViewAngles()
    local shootCoords = viewAngles:GetCoords()
    
    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    if GetIsVortexed(player) then
        range = 5
    end
    
    local numberBullets = self:GetBulletsPerShot()
    local startPoint = player:GetEyePos()
    local bulletSize = self:GetBulletSize()
    
    for bullet = 1, numberBullets do
    
        local spreadDirection = self:CalculateSpreadDirection(shootCoords, player)
        
        local endPoint = startPoint + spreadDirection * range
        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter)        
        local damage = self:GetBulletDamage()

        HandleHitregAnalysis(player, startPoint, endPoint, trace)        

        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        --local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = true --math.random() < effectFrequency

        local numTargets = #targets
        
        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, impactPoint)
        end
        
        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
            
            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end
        
        end
        
    end
    
end

function ClipWeapon:FirePrimary(player)
    self.fireTime = Shared.GetTime()
    FireBullets(self, player)
end

function ClipWeapon:GetTracerEffectName()
    local player = self:GetParent()
    if player and player.GetWeaponUpgradeLevel then
        local level = player:GetWeaponUpgradeLevel()
        if level == 3 then
            return kLevel3Tracer
        end
        if level == 2 then
            return kLevel2Tracer
        end
        if level == 1 then
            return kLevel1Tracer
        end
    end
    return kDefaultTracerEffectName
end