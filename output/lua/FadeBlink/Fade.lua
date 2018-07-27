
class 'WraithFade' (Fade)

WraithFade.kMapName = "wraithfade"

local kMaxSpeed = 8.5
local kBlinkSpeed = 100
local kShadowStepTime = 0.15
local kMinEnterEtherealTime = 0.35
local kWraithFadeScanDuration = 4


local kWraithFadeShadowDanceHealthRegen = 8
local kWraithFadeShadowDanceEnergyRegen = 6
local kWraithFadeShadowDanceDelay = 0.5

local kViewOffsetHeight = 1.4
WraithFade.YExtents = 0.80 -- was 1.05

local networkVars =
{
    isScanned = "boolean",
    shadowStepping = "compensated boolean",
    timeShadowStep = "private compensated time",
    shadowStepDirection = "private compensated vector",
    shadowStepSpeed = "private compensated interpolated float",
    
    etherealStartTime = "private time",
    etherealEndTime = "private time",
    
    -- True when we're moving quickly "through the ether"
    ethereal = "compensated boolean",
    
    landedAfterBlink = "private compensated boolean",  
    
    timeMetabolize = "private compensated time",
    
    timeOfLastPhase = "time",
    
	-- new wraith fade vars
    startBlinkLocation = "compensated vector",
    startVelocity = "compensated vector",
    endBlinkLocation = "compensated vector",
    etherealStartTime = "compensated time",
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(FadeVariantMixin, networkVars)

-- since the fade loses some it's mobility, it gains speed
function WraithFade:GetMaxSpeed(possible)

    if possible then
        return kMaxSpeed
    end
    
    if self:GetIsBlinking() then
        return kBlinkSpeed
    end
    
    -- Take into account crouching.
    return kMaxSpeed
    
end

function Fade:GetAcceleration()
    return 13
end


function WraithFade:GetRecentlyBlinked(player)
    return Shared.GetTime() - self.etherealEndTime < kMinEnterEtherealTime
end

function WraithFade:GetMaxViewOffsetHeight()
    return kViewOffsetHeight
end
-- reduce this to prevent air-dodging
function WraithFade:GetAirControl()
    return 14 -- was 40
end   

function WraithFade:GetCrouchShrinkAmount()
    return 0.6
end

function WraithFade:GetExtentsCrouchShrinkAmount()
    return 0.5
end

function WraithFade:GetAirFriction()
    return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or (0.09  - (GetHasCelerityUpgrade(self) and self:GetSpurLevel() or 0) * 0.005)
end 

-- Absolute maximum which never can be exceeded. We exceeed the default 30.
function WraithFade:GetClampedMaxSpeed()
    return 100
end


function WraithFade:GetIsBlinking()
    return self.ethereal
end

function WraithFade:ModifyVelocity(input, velocity, deltaTime)

    if self.ethereal then
        local maxSpeedTable = { maxSpeed = kBlinkSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)  
    end

end

function WraithFade:GetMaxSpeed(possible)
    
    if self.ethereal then
        return kBlinkSpeed
    end
    
    if possible then
        return kMaxSpeed
    end
    
    return kMaxSpeed
    
end

function WraithFade:GetIsStabbing()

    local stabWeapon = self:GetWeapon(StabTeleport.kMapName)
    return stabWeapon and stabWeapon:GetIsStabbing()    

end

function WraithFade:OnProcessMove(input)

    local player = self
    Alien.OnProcessMove(self, input)
    
    if Server then
    
        if self.isScanned and self.timeLastScan + kWraithFadeScanDuration < Shared.GetTime() then
            self.isScanned = false
        end

    end
    if self.ethereal then
      if Shared.GetTime() - self.etherealStartTime < kShadowStepTime and player.OnBlinkEnd and self.endBlinkLocation then
        --player.blinkAmount = 1
        local shadowStepFraction = Clamp((Shared.GetTime() - self.etherealStartTime) / kShadowStepTime, 0, 1) * 0.5 + 0.5
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
    
    if self:GetCanMetabolizeHealth() and not self:GetIsSighted() then
        if self.timeOfLastPhase + kWraithFadeShadowDanceDelay < Shared.GetTime() then
            self.timeOfLastPhase = Shared.GetTime()
            
            self:AddEnergy(kWraithFadeShadowDanceEnergyRegen)
            
            if self:GetHealthScalar() ~= 1 then
                local totalHealed = self:AddHealth(kWraithFadeShadowDanceHealthRegen, false, false)
                
                if Client and totalHealed > 0 then
                    local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
                    GUIRegenerationFeedback:TriggerRegenEffect()
                    local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                    cinematic:SetCinematic(kRegenerationViewCinematic)
                end
            end
        end
    end
end

function WraithFade:MovementModifierChanged(newMovementModifierState, input)

    if newMovementModifierState and self:GetActiveWeapon() ~= nil then
        local weaponMapName = self:GetActiveWeapon():GetMapName()
        local metabweapon = self:GetWeapon(Backtrack.kMapName)
        if metabweapon then
            if self:GetEnergy() >= metabweapon:GetEnergyCost() and not metabweapon:GetHasAttackDelay() then
                self:SetActiveWeapon(Backtrack.kMapName)
                self:PrimaryAttack()
                if weaponMapName ~= Backtrack.kMapName then
                    self.previousweapon = weaponMapName
                end
            else
                self:TriggerInvalidSound()
            end
        end
    end
    
end

-- health regen comes from another passive ability now
function WraithFade:GetMovementSpecialTechId()
    return kTechId.Backtrack
    --[[
    if self:GetCanMetabolizeHealth() then
        return kTechId.MetabolizeHealth
    else
        return kTechId.MetabolizeEnergy
    end
    ]]--
end

function WraithFade:OnUpdateAnimationInput(modelMixin)

    if not self:GetHasMetabolizeAnimationDelay() then
        Alien.OnUpdateAnimationInput(self, modelMixin)

        --if self.timeOfLastPhase + 0.5 > Shared.GetTime() then
        --    modelMixin:SetAnimationInput("move", "teleport")
        --end
    else
        local weapon = self:GetActiveWeapon()
        if weapon ~= nil and weapon.OnUpdateAnimationInput and weapon:GetMapName() == Backtrack.kMapName then
            weapon:OnUpdateAnimationInput(modelMixin)
        end
    end

end

if Server then
	function WraithFade:InitWeapons()

		Alien.InitWeapons(self)
		
		self:GiveItem(SwipeTeleport.kMapName)
		self:SetActiveWeapon(SwipeTeleport.kMapName)
		
	end

	function WraithFade:InitWeaponsForReadyRoom()
		
		Alien.InitWeaponsForReadyRoom(self)
		
		self:GiveItem(ReadyRoomBlink.kMapName)
		self:SetActiveWeapon(ReadyRoomBlink.kMapName)
		
	end

	function WraithFade:GetTierOneTechId()
		return kTechId.Backtrack
	end

	function WraithFade:GetTierTwoTechId()
		return kTechId.MetabolizeHealth
	end

	function WraithFade:GetTierThreeTechId()
		return kTechId.StabTeleport
	end
end
if Client then
    function WraithFade:OnUpdateRender()
        if self.ethereal then
            local player = self
            if Shared.GetTime() - self.etherealStartTime < kShadowStepTime and player.OnBlinkEnd and player.controller then
                --player.blinkAmount = 1
                local shadowStepFraction = Clamp((Shared.GetTime() - self.etherealStartTime) / kShadowStepTime, 0, 1) * 0.5 + 0.5
                local newPos = self.startBlinkLocation * (1-shadowStepFraction) + self.endBlinkLocation * shadowStepFraction
                --player:SetOrigin(newPos)
                player:UpdateControllerFromEntity()
                player.controller:Move(newPos - player:GetOrigin(), CollisionRep.Move, CollisionRep.Default, PhysicsMask.None)
                player:UpdateOriginFromController()
            end
        end
    end
end

Shared.LinkClassToMap("WraithFade", WraithFade.kMapName, networkVars, true)
