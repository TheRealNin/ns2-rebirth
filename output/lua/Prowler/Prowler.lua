
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
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
--Script.Load("lua/SkulkVariantMixin.lua")

class 'Prowler' (Skulk)

Prowler.kMapName = "prowler"

Prowler.kMaxSpeed = 7.25 -- skulk is 7.25
Prowler.kWallJumpForce = 3.1 -- skulk was 6.4 -- scales down the faster you are
Prowler.kWallJumpMaxSpeed = 11 -- skulk is 11
Prowler.kWallJumpMaxSpeedCelerityBonus = 1.2 -- skulk is 1.2
Prowler.kWallJumpInterval = 0.8

Prowler.kHealth = kProwlerHealth
Prowler.kArmor  = kProwlerArmor

local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3

local kProwlerScale = 1.25
local kProwlerVertAdjust = 0.05
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
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
    leaping = "compensated boolean",
    timeOfLeap = "private compensated time",
    timeOfLastJumpLand = "private compensated time",
    timeLastWallJump = "private compensated time",
    jumpLandSpeed = "private compensated float",
    dashing = "compensated boolean",    
    timeOfLastPhase = "private time",
    timeOfLastHowl = "private compensated time",
    -- sneaking (movement modifier) skulks starts to trail their body behind them
    sneakOffset = "compensated interpolated float (0 to 1 by 0.04)",
    variant = "enum kSkulkVariant", -- why do we need this??
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
--AddMixinNetworkVars( WallMovementMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
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
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
        self.timeDashChanged = 0
    end
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    self.leaping = false
    self.timeLastWallJump = 0
    self.timeOfLastHowl = 0
    self.variant = kDefaultSkulkVariant
     
    self.sneakOffset = 0
    
end

function Prowler:OnInitialized()

    Alien.OnInitialized(self)
    
    -- Note: This needs to be initialized BEFORE calling SetModel() below
    -- as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    -- which will cause a script error if the Skulk is wall walking BEFORE
    -- the Skulk is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    
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
function Prowler:GetFirstPersonFov()
  return kProwlerFov
end
function Prowler:GetAirControl()
    return 47 -- skulk is 27
end
function Prowler:GetAirAcceleration()
    return 7 -- skulk is 9
end
function Prowler:GetAirFriction()
    return 0.045 - (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.004 -- skulk was 0.055 - (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.009
end
-- we, uh, don't have variants 
function Prowler:SetVariant()
end
function Prowler:GetVariant()
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
    
        self.bonusVec.y = viewCoords.zAxis.y * Prowler.kVerticalWallJumpForce
        jumpVelocity:Add(self.bonusVec)

    end
    
    self.timeLastWallJump = Shared.GetTime()
        
    
end
function Prowler:ModifyCelerityBonus(celerityBonus)
    
    if self.movementModiferState then
        celerityBonus = celerityBonus * Prowler.kSneakSpeedModifier
    end
    
    return celerityBonus
    
end

function Prowler:GetIsWallWalking()
    return false
end

function Prowler:GetJumpHeight()
    return Skulk.kJumpHeight + 0.4
end

function Prowler:GetIsWallWalkingPossible() 
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end

function Prowler:GetMaxWallJumpSpeed()
    local celerityMod = (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * Prowler.kWallJumpMaxSpeedCelerityBonus/3.0
    return Prowler.kWallJumpMaxSpeed + celerityMod
end

local oldOnAdjustModelCoords = Prowler.OnAdjustModelCoords
function Prowler:OnAdjustModelCoords(modelCoords)
    modelCoords = oldOnAdjustModelCoords(self, modelCoords)
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
    
    if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        self.wallWalking = false
    
    end
    
    if not self:GetIsWallWalking() then
        -- When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end

    if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
        self.leaping = false
    end
        
    self.currentWallWalkingAngles = self.GetAnglesFromWallNormal and self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles

    -- adjust the sneakOffset so sneaking skulks can look around corners without having to expose themselves too much
    local delta = input.time * math.min(1, self:GetVelocityLength())
    if self.movementModiferState then
        if self.sneakOffset < Prowler.kMaxSneakOffset then
            self.sneakOffset = math.min(Prowler.kMaxSneakOffset, self.sneakOffset + delta)
        end
    else
        if self.sneakOffset > 0 then
            self.sneakOffset = math.max(0, self.sneakOffset - delta)
        end
    end
    
end

function Prowler:OnUpdateAnimationInput(modelMixin)

    PROFILE("Prowler:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
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
        self:SpawnCloud(kTechId.Hallucinate)
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


Shared.LinkClassToMap("Prowler", Prowler.kMapName, networkVars, true)