
local kSwipeRange = 2.1
local kMaxSpeed = 8.0
local kBlinkSpeed = 100
local kshadowStepTime = 0.15
local kMinEnterEtherealTime = 0.35
local kFadeScanDuration = 4


local kFadeShadowDanceHealthRegen = 8
local kFadeShadowDanceDelay = 1.0

local kViewOffsetHeight = 1.4
Fade.YExtents = 0.80 -- was 1.05

local networkVars =
{
    startBlinkLocation = "compensated vector",
    startVelocity = "compensated vector",
    endBlinkLocation = "compensated vector",
    etherealStartTime = "compensated time",
}

function SwipeBlink:GetMeleeBase()
    -- Width of box, height of box
    return 1.4, 1.6
    
end

-- since the fade loses some it's mobility, it gains speed
ReplaceLocals( Fade.GetMaxSpeed, { kMaxSpeed = kMaxSpeed} )
ReplaceLocals( Fade.GetRecentlyBlinked, { kMinEnterEtherealTime = kMinEnterEtherealTime} )
ReplaceLocals( Fade.GetMaxViewOffsetHeight, { kViewOffsetHeight = kViewOffsetHeight} )

-- reduce this to prevent air-dodging
function Fade:GetAirControl()
    return 14 -- was 40
end   

function Fade:GetCrouchShrinkAmount()
    return 0.6
end

function Fade:GetExtentsCrouchShrinkAmount()
    return 0.5
end

-- Absolute maximum which never can be exceeded. We exceeed the default 30.
function Player:GetClampedMaxSpeed()
    return 100
end


function Fade:GetIsBlinking()
    return self.ethereal
end

function Fade:ModifyVelocity(input, velocity, deltaTime)

    if self.ethereal then
        local maxSpeedTable = { maxSpeed = kBlinkSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)  
    end

end

function Fade:GetMaxSpeed(possible)
    
    if self.ethereal then
        return kBlinkSpeed
    end
    
    if possible then
        return kMaxSpeed
    end
    
    return kMaxSpeed
    
end




function SwipeBlink:PerformMeleeAttack()

    local player = self:GetParent()
    if player then    
        AttackMeleeCapsule(self, player, SwipeBlink.kDamage, kSwipeRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
    end
    
end


function Fade:OnProcessMove(input)

    local player = self
    Alien.OnProcessMove(self, input)
    
    if Server then
    
        if self.isScanned and self.timeLastScan + kFadeScanDuration < Shared.GetTime() then
            self.isScanned = false
        end

    end
    if self.ethereal then
      if Shared.GetTime() - self.etherealStartTime < kshadowStepTime and player.OnBlinkEnd and self.endBlinkLocation then
        --player.blinkAmount = 1
        local shadowStepFraction = Clamp((Shared.GetTime() - self.etherealStartTime) / kshadowStepTime, 0, 1) * 0.5 + 0.5
        local newPos = self.startBlinkLocation * (1-shadowStepFraction) + self.endBlinkLocation * shadowStepFraction
        --player:SetOrigin(newPos)
        player:UpdateControllerFromEntity()
        player.controller:Move(newPos - player:GetOrigin(), CollisionRep.Move, CollisionRep.Move, PhysicsMask.None)
        player:UpdateOriginFromController()
      elseif player.OnBlinkEnd then
        player:SetOrigin(player.endBlinkLocation)
        player:SetVelocity(player.startVelocity) 
        player.crouching = true
        Blink:SetEthereal(player, false)
      end
    
    end
        
    if not self:GetHasMetabolizeAnimationDelay() and self.previousweapon ~= nil then
        self:SetActiveWeapon(self.previousweapon)
        self.previousweapon = nil
    end
    
    if self:GetCanMetabolizeHealth() and not self:GetIsSighted() and self:GetHealthScalar() ~= 1 then
        if self.timeOfLastPhase + kFadeShadowDanceDelay < Shared.GetTime() then
            self.timeOfLastPhase = Shared.GetTime()
            
            local totalHealed = self:AddHealth(kFadeShadowDanceHealthRegen, false, false)
            if Client and totalHealed > 0 then
                local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
                GUIRegenerationFeedback:TriggerRegenEffect()
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kRegenerationViewCinematic)
            end
        end
    end
end

function Fade:MovementModifierChanged(newMovementModifierState, input)

    if newMovementModifierState and self:GetActiveWeapon() ~= nil then
        local weaponMapName = self:GetActiveWeapon():GetMapName()
        local metabweapon = self:GetWeapon(Metabolize.kMapName)
        if metabweapon then
            if self:GetEnergy() >= metabweapon:GetEnergyCost() and not metabweapon:GetHasAttackDelay() then
                self:SetActiveWeapon(Metabolize.kMapName)
                self:PrimaryAttack()
                if weaponMapName ~= Metabolize.kMapName then
                    self.previousweapon = weaponMapName
                end
            else
                self:TriggerInvalidSound()
            end
        end
    end
    
end

-- health regen comes from another passive ability now
function Fade:GetMovementSpecialTechId()
    return kTechId.MetabolizeEnergy
    --[[
    if self:GetCanMetabolizeHealth() then
        return kTechId.MetabolizeHealth
    else
        return kTechId.MetabolizeEnergy
    end
    ]]--
end

function Fade:OnUpdateAnimationInput(modelMixin)

    if not self:GetHasMetabolizeAnimationDelay() then
        Alien.OnUpdateAnimationInput(self, modelMixin)

        --if self.timeOfLastPhase + 0.5 > Shared.GetTime() then
        --    modelMixin:SetAnimationInput("move", "teleport")
        --end
    else
        local weapon = self:GetActiveWeapon()
        if weapon ~= nil and weapon.OnUpdateAnimationInput and weapon:GetMapName() == Metabolize.kMapName then
            weapon:OnUpdateAnimationInput(modelMixin)
        end
    end

end

if Client then
    function Fade:OnUpdateRender()
        if self.ethereal then
            local player = self
            if Shared.GetTime() - self.etherealStartTime < kshadowStepTime and player.OnBlinkEnd and player.controller then
                --player.blinkAmount = 1
                local shadowStepFraction = Clamp((Shared.GetTime() - self.etherealStartTime) / kshadowStepTime, 0, 1)
                local newPos = self.startBlinkLocation * (1-shadowStepFraction) + self.endBlinkLocation * shadowStepFraction
                --player:SetOrigin(newPos)
                player:UpdateControllerFromEntity()
                player.controller:Move(newPos - player:GetOrigin(), CollisionRep.Move, CollisionRep.Move, PhysicsMask.None)
                player:UpdateOriginFromController()
            end
        end
    end
end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars, true)
