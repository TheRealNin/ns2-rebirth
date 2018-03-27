
Script.Load("lua/Prowler/BiteHowl.lua")
Script.Load("lua/Prowler/XenocideHowl.lua")

Script.Load("lua/Utility.lua")
--Script.Load("lua/Weapons/Alien/Parasite.lua")
Script.Load("lua/Weapons/Alien/ReadyRoomLeap.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
--Script.Load("lua/WallMovementMixin.lua")
Script.Load("lua/DissolveMixin.lua")
--Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
--Script.Load("lua/SkulkVariantMixin.lua")

class 'Prowler' (Alien)

Prowler.kMapName = "prowler"

Prowler.kMaxSpeed = 7.25 -- skulk is 7.25
Prowler.kWallJumpForce = 3.1 -- skulk was 6.4 -- scales down the faster you are
Prowler.kWallJumpMaxSpeed = 11 -- skulk is 11
Prowler.kMinWallJumpForce = 0.1
Prowler.kWallJumpMaxSpeedCelerityBonus = 1.2 -- skulk is 1.2
Prowler.kWallJumpInterval = 0.4
Prowler.kHorizontalJumpForce = 4.3
Prowler.kSneakSpeedModifier = 0.66

Prowler.kHealth = kProwlerHealth
Prowler.kArmor  = kProwlerArmor

local kProwlerScale = 1.25
local kProwlerVertAdjust = 0.05
local kProwlerForwardAdjust = -0.15
local kProwlerAttackVertAdjust = 0.25
local kMass = 60
local kLeapTime = 0.2

local kViewModelName = PrecacheAsset("models/alien/skulk/skulk_view.model")
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")
local kDrifterAnimationGraph = PrecacheAsset("models/alien/drifter/drifter.animation_graph")
local kOnosAnimationGraph = PrecacheAsset("models/alien/onos/onos.animation_graph")
Prowler.kModelName = PrecacheAsset("models/alien/drifter/drifter.model")
Prowler.kAnimationGraph = PrecacheAsset("models/alien/prowler/prowler.animation_graph")


Prowler.kXExtents = .45 -- * kProwlerScale
Prowler.kYExtents = .45 -- * kProwlerScale
Prowler.kZExtents = .45 -- * kProwlerScale
Prowler.kViewOffsetHeight = .55 * kProwlerScale

Prowler.kHowlCooldown = 15 -- seconds
Prowler.kHowlEnergyCost = 45 

if Server then
    Script.Load("lua/Prowler/Prowler_Server.lua", true)
elseif Client then
    Script.Load("lua/Prowler/Prowler_Client.lua", true)
end


local networkVars =
{
    timeOfLastJumpLand = "private compensated time",
    jumpLandSpeed = "private compensated float",
    timeOfLastHowl = "private compensated time",
    timeLastJumped = "private compensated time"
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
--AddMixinNetworkVars( WallMovementMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
--AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
--AddMixinNetworkVars(SkulkVariantMixin, networkVars)


function Prowler:OnCreate()
    

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kProwlerFov })
    --InitMixin(self, WallMovementMixin)
    --InitMixin(self, SkulkVariantMixin)
    
    Alien.OnCreate(self)

    InitMixin(self, DissolveMixin)
    --InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
        self.timeDashChanged = 0
    end
    
    self.timeOfLastHowl = 0
    self.variant = kDefaultSkulkVariant
    self.timeLastJumped = 0
    self.runDist = 0
    self.sneakOffset = 0
    
end

function Prowler:OnInitialized()

    Alien.OnInitialized(self)
    
    
    self:SetModel(Prowler.kModelName, Prowler.kAnimationGraph)
    
    if Client then
    
        self.currentCameraRoll = 0
        self.goalCameraRoll = 0
        
        self:AddHelpWidget("GUIEvolveHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end

    InitMixin(self, IdleMixin)
    
end
function Prowler:GetViewModelName()
    return kViewModelName
end

-- these two are for third person mod
function Prowler:GetThirdPersonOffset()
  local z = -1.8 - self:GetVelocityLength() / self:GetMaxSpeed(true) * 0.4
  return Vector(0, 0.6, z) 
end

function Prowler:GetHeartOffset()
    return Vector(0, 0.6, 0)
end

function Prowler:GetFirstPersonFov()
  return kProwlerFov
end

function Prowler:GetStepLength()
    return 0.6
end

function Prowler:GetAirControl()
    return 47 -- skulk is 27
end

function Prowler:GetAirAcceleration()
    return 7 -- skulk is 9
end

function Prowler:GetCollisionSlowdownFraction()
    return 0.15
end
function Prowler:GetGroundTransistionTime()
    return 0.1
end
function Prowler:GetIsSmallTarget()
    return true
end

function Prowler:GetGroundFriction()
    return 11
end

function Prowler:GetAirFriction()
    return 0.045 - (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.004 -- skulk was 0.055 - (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.009
end

local kProwlerEngageOffset = Vector(0, 0.5, 0)
function Prowler:GetEngagementPointOverride()
    return self:GetOrigin() + kProwlerEngageOffset
end

-- we, uh, don't have variants 
function Prowler:SetVariant()
end
function Prowler:GetVariant()
end
function Prowler:GetCrouchShrinkAmount()
    return 0
end
function Prowler:GetExtentsCrouchShrinkAmount()
    return 0
end
function Prowler:GetCrouchSpeedScalar()
    return 0
end

-- Tilt the camera based on the wall the Prowler is attached to.
function Prowler:PlayerCameraCoordsAdjustment(cameraCoords)

    local viewModelTiltAngles = Angles()
    viewModelTiltAngles:BuildFromCoords(Alien.PlayerCameraCoordsAdjustment(self, cameraCoords))

    if self.currentCameraRoll then
        viewModelTiltAngles.roll = viewModelTiltAngles.roll + self.currentCameraRoll
    end

    local viewModelTiltCoords = viewModelTiltAngles:GetCoords()
    viewModelTiltCoords.origin = cameraCoords.origin

    return viewModelTiltCoords

end

function Prowler:GetMaxSpeed(possible)

    if possible then
        return Prowler.kMaxSpeed
    end
    
    local maxspeed = Prowler.kMaxSpeed
    
    if self.movementModiferState then
        maxspeed = maxspeed * Prowler.kSneakSpeedModifier
    end
    
    return maxspeed
    
end

function Prowler:OnProcessMove(input)

    Alien.OnProcessMove(self, input)
    
    if self:GetPlayFootsteps() and Client then
        local delta = self:GetVelocity():GetLength() * input.time
        self.runDist = self.runDist + delta
        local i = 0
        while self.runDist > 0 and i < 5 do
            i = i + 1
            self.runDist = self.runDist - self:GetStepLength()
            self:TriggerFootstep()
        end
    end

end

function Prowler:GetMaxViewOffsetHeight()
    return Prowler.kViewOffsetHeight
end

function Prowler:ModifyJump(input, velocity, jumpVelocity)

    local direction = Clamp(input.move.z, 0, 1)

    -- we add the bonus in the direction the move is going
    local viewCoords = self:GetViewAngles():GetCoords()
    self.bonusVec = viewCoords.zAxis * direction
    self.bonusVec.y = 0
    self.bonusVec:Normalize()
    
    --jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

    local fraction = 1 - Clamp( velocity:GetLengthXZ() / self:GetMaxWallJumpSpeed(), 0, 1)        
    
    local force = math.max(Prowler.kMinWallJumpForce, Prowler.kWallJumpForce * fraction)
      
    self.bonusVec:Scale(force)      

    if not self:GetRecentlyWallJumped() then
    
        self.bonusVec.y = viewCoords.zAxis.y * Prowler.kHorizontalJumpForce
        jumpVelocity:Add(self.bonusVec)

    end
    
    self.timeLastJumped = Shared.GetTime()
    
end

function Prowler:OnJump( modifiedVelocity )

    local material = self:GetMaterialBelowPlayer()    
    
    local currentSpeed = modifiedVelocity:GetLengthXZ()
    local maxWallJumpSpeed = self:GetMaxWallJumpSpeed()
            
    if currentSpeed > maxWallJumpSpeed * 0.95 then
        self:TriggerEffects("jump_best", {surface = material})          
    elseif currentSpeed > maxWallJumpSpeed * 0.75 then
        self:TriggerEffects("jump_good", {surface = material})       
    end
    
    self:TriggerEffects("jump", {surface = material})

    
end

function Prowler:GetRecentlyWallJumped()
    return self.timeLastJumped + Prowler.kWallJumpInterval > Shared.GetTime()
end
function Prowler:ModifyCelerityBonus(celerityBonus)
    
    if self.movementModiferState then
        celerityBonus = celerityBonus * Prowler.kSneakSpeedModifier
    end
    
    return celerityBonus
    
end


function Prowler:GetJumpHeight()
    return Skulk.kJumpHeight + 0.4
end
function Prowler:GetMaxWallJumpSpeed()
    local celerityMod = (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * Prowler.kWallJumpMaxSpeedCelerityBonus/3.0
    return Prowler.kWallJumpMaxSpeed + celerityMod
end

--local oldOnAdjustModelCoords = Prowler.OnAdjustModelCoords
function Prowler:OnAdjustModelCoords(modelCoords)
    --modelCoords = oldOnAdjustModelCoords(self, modelCoords)
    modelCoords.xAxis = modelCoords.xAxis * kProwlerScale
    modelCoords.yAxis = modelCoords.yAxis * kProwlerScale
    modelCoords.zAxis = modelCoords.zAxis * kProwlerScale
    modelCoords.origin.y = modelCoords.origin.y + kProwlerVertAdjust
    if self.primaryAttacking then
        modelCoords.origin.y = modelCoords.origin.y + kProwlerAttackVertAdjust
    end
    return modelCoords
end

function Prowler:GetCanWallJump()

    return false

end

function Prowler:GetDesiredAngles(deltaTime)

    local desiredAngles = Angles()
    if self.onGround then
        desiredAngles.pitch = 0
    else
        desiredAngles.pitch = self.viewPitch
    end
    desiredAngles.roll = self.viewRoll
    desiredAngles.yaw = self.viewYaw
    
    return desiredAngles

end
-- Update wall-walking from current origin
function Prowler:PreUpdateMove(input, runningPrediction)

    PROFILE("Prowler:PreUpdateMove")
    
end

function Prowler:OnUpdateAnimationInput(modelMixin)

    PROFILE("Prowler:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
end

function Prowler:GetPlayFootsteps()
    return self:GetVelocityLength() > .75 and self:GetIsOnGround() and self:GetIsAlive() and not self.movementModiferState
end


function Prowler:GetMass()
    return kMass
end

function Prowler:GetBaseHealth()
    return Prowler.kHealth
end

function Prowler:GetBaseArmor()
    return Prowler.kArmor
end

function Prowler:GetHealthPerBioMass()
    return kProwlerHealthPerBioMass
end


function Prowler:SpawnCloud(techId)

    local position = self:GetOrigin()
    
    local mapName = LookupTechData(techId, kTechDataMapName)
    if mapName and Server then
    
        local cloudEntity = CreateEntity(mapName, position, self:GetTeamNumber())
        
    end

end


function Prowler:OnHowl()

    local shotWeb = false
    
    if GetHasTech(self, kTechId.ShiftHive, true) then
        self:SpawnCloud(kTechId.EnzymeCloud)
        shotWeb = true
    end
    if GetHasTech(self, kTechId.ShadeHive, true) then
        if Server then
            local newAlienExtents = LookupTechData(self:GetTechId(), kTechDataMaxExtents)
            local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents) 
            
            local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, self:GetModelOrigin(), 0.5, 5)
            
            if spawnPoint then

                local hallucinatedPlayer = CreateEntity(Skulk.kMapName, spawnPoint, self:GetTeamNumber())
                
                hallucinatedPlayer:SetVariant(kSkulkVariant.normal)
                hallucinatedPlayer.isHallucination = true
                InitMixin(hallucinatedPlayer, PlayerHallucinationMixin)                
                InitMixin(hallucinatedPlayer, SoftTargetMixin)                
                InitMixin(hallucinatedPlayer, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance }) 

                hallucinatedPlayer:SetName(self:GetName())
                hallucinatedPlayer:SetHallucinatedClientIndex(self:GetClientIndex())
            
            end 
        end
        shotWeb = true
    end
    if GetHasTech(self, kTechId.CragHive, true) then
        self:SpawnCloud(kTechId.MucousMembrane)
        shotWeb = true
    end
    
    if shotWeb and Server then
        --self:TriggerEffects("drifter_shoot_enzyme", {effecthostcoords = self:GetCoords() } )
        self:TriggerEffects("drifter_shoot_enzyme", {effecthostcoords = Coords.GetLookIn(self:GetEyePos(), GetNormalizedVectorXZ(self:GetViewAngles():GetCoords().zAxis * 5 )) } )
    end
    
end


if Server then
    function Prowler:OnKill(attacker, doer, point, direction)
    
        Alien.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death", { classname = self:GetClassName(), effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
        
        
    end
end

function Prowler:GetArmorFullyUpgradedAmount()
    return kSkulkArmorFullyUpgradedAmount
end

function Prowler:GetAnimateDeathCamera()
    return false
end

Shared.LinkClassToMap("Prowler", Prowler.kMapName, networkVars, true)