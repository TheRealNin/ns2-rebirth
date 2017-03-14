
local kSwipeRange = 2.1
local kMaxSpeed = 7.5
local kBlinkSpeed = 100
local kshadowStepTime = 0.1
local kMinEnterEtherealTime = 0.35
local kFadeScanDuration = 4

local kViewOffsetHeight = 1.4
Fade.YExtents = 0.80 -- was 1.05


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
      if Shared.GetTime() - self.etherealStartTime < kshadowStepTime and player.OnBlinkEnd then
        --player.blinkAmount = 1
        local shadowStepFraction = Clamp((Shared.GetTime() - self.etherealStartTime) / kshadowStepTime, 0, 1)
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
    
end

if Client then
    function Fade:OnUpdateRender()
        if self.ethereal then
            local player = self
            if Shared.GetTime() - self.etherealStartTime < kshadowStepTime and player.OnBlinkEnd then
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
