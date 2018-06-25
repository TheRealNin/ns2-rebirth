
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Prowler/HowlMixin.lua")


class 'BiteHowl' (BiteLeap)
BiteHowl.kMapName = "bitehowl"
BiteHowl.kStartOffset = -1.25

local kBiteHowlTracer = PrecacheAsset("cinematics/prowler/1p_tracer_residue.cinematic")
local kAttackDuration = Shared.GetAnimationLength("models/alien/skulk/skulk_view.model", "bite_attack")

-- higher numbers reduces the spread
local kSpreadDistance = 9.0
local kSpreadVertMult = 0.4
BiteHowl.kSpreadVectors =
{
    GetNormalizedVector(Vector(-0.01, 0.01, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, -0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.45, -0.45, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kSpreadDistance)),
    
}

local networkVars =
{
}

function BiteHowl:OnCreate()

    Ability.OnCreate(self)
    InitMixin(self, HowlMixin)
    InitMixin(self, BulletsMixin)
    
    self.primaryAttacking = false

end
function BiteHowl:GetTracerEffectName()
    return kBiteHowlTracer
end
function BiteHowl:GetTracerResidueEffectName()
    return kBiteHowlTracer
end
function BiteHowl:GetBulletsPerShot()
    return 15
end

function BiteHowl:GetEnergyCost(player)
    return kBiteEnergyCost
end
function BiteHowl:GetRange()
    return 100
end
function BiteHowl:GetBulletDamage()
    return kProwlerDamagePerPellet
end

function BiteHowl:GetBarrelPoint()
    local player = self:GetParent()
    return player:GetEyePos() + Vector(0, -0.25, 0)
end

function BiteHowl:GetDeathIconIndex()
    return kDeathMessageIcon.Spit
end

function BiteHowl:GetDamageType()
    return kBiteHowlDamageType
end

function BiteHowl:OnUpdateAnimationInput(modelMixin)

    PROFILE("BiteHowl:OnUpdateAnimationInput")

    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
    local player = self:GetParent()
    if player then
        
        local viewmodel = player:GetViewModelEntity()
        if viewmodel  then
            viewmodel:SetIsVisible(false)
        end
    end
    
end

function BiteHowl:OnTag(tagName)

    if tagName == "hit" then
        local player = self:GetParent()
        
        if player then
            local viewAngles = player:GetViewAngles()
            local roll = NetworkRandom() * math.pi * 2
            local rollAngles = Angles(0,0,roll):GetCoords()

            local shootCoords = viewAngles:GetCoords()
            shootCoords.yAxis = shootCoords.yAxis * kSpreadVertMult

            -- Filter ourself out of the trace so that we don't hit ourselves.
            local filter = EntityFilterTwo(player, self)
            local range = self:GetRange()
            
            local numberBullets = self:GetBulletsPerShot()
            local startPoint = player:GetEyePos()
            
            --self:TriggerEffects("shotgun_attack_sound")
            --self:TriggerEffects("shotgun_attack")
            
            for bullet = 1, math.min(numberBullets, #self.kSpreadVectors) do
            
                if not self.kSpreadVectors[bullet] then
                    break
                end    
                
                local spreadVector = self.kSpreadVectors[bullet]
                spreadVector = rollAngles:TransformVector(spreadVector)
            
                local spreadDirection = shootCoords:TransformVector(spreadVector)

                local endPoint = startPoint + spreadDirection * range
                startPoint = player:GetEyePos() + shootCoords.xAxis * spreadVector.x * self.kStartOffset + shootCoords.yAxis * spreadVector.y * self.kStartOffset
                
                local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, 0.1, filter)
                
                local damage = 0

                HandleHitregAnalysis(player, startPoint, endPoint, trace)        
                    
                local direction = (trace.endPoint - startPoint):GetUnit()
                local hitOffset = direction * kHitEffectOffset
                local impactPoint = trace.endPoint - hitOffset
                local showTracer = true
                
                local numTargets = #targets
                
                if numTargets == 0 then
                    self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, "rock", showTracer)
                end
                
                if Client and showTracer then
                    TriggerFirstPersonTracer(self, impactPoint)
                end
                
                for i = 1, numTargets do

                    local target = targets[i]
                    local hitPoint = hitPoints[i]

                    self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, self:GetBulletDamage(), "rock", showTracer and i == numTargets)
                    
                    local client = Server and player:GetClient() or Client
                    if not Shared.GetIsRunningPrediction() and client and client.hitRegEnabled then
                        RegisterHitEvent(player, bullet, startPoint, trace, damage)
                    end
                
                end
                
            end
            self.shootingSpikes = true
            player:DeductAbilityEnergy(self:GetEnergyCost())
            if Server then
                self:TriggerEffects("drifter_parasite_hit")
            end
            
            self:DoAbilityFocusCooldown(player, kAttackDuration)
        end
    end

end

function BiteHowl:GetSecondaryTechId()
    return kTechId.Howl
end

Shared.LinkClassToMap("BiteHowl", BiteHowl.kMapName, networkVars)