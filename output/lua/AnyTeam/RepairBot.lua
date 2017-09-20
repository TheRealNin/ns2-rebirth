
class 'RepairBot' (Player)

RepairBot.kMapName = "repairbot"

RepairBot.kModelName = PrecacheAsset("models/props/descent/descent_repairdroid.model")
RepairBot.kAnimationGraph = PrecacheAsset("models/marine/mac/mac.animation_graph")
RepairBot.kHoverHeight = .4
RepairBot.kXZExtents = 0.5
RepairBot.kYExtents = 0.475
local kMaxGroundSpeed = 6
local kGravityFraction = 0.3
local kRepairBotScale = 0.7
local kRepairBotVertAdjust = 2.0
RepairBot.kJumpHeight = 0.3
RepairBot.kJumpVelMult = 0.3

RepairBot.kWalkBackwardSpeedScalar = 1

local networkVars =
{
}


AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(RegenerationMixin, networkVars)
if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end


function RepairBot:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    
    Player.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, PredictedProjectileShooterMixin)

    InitMixin(self, RegenerationMixin)

    if Server then
    
    elseif Client then
      
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
    
    end
    
end

function RepairBot:OnInitialized()
    InitMixin(self, WeldableMixin)
    Player.OnInitialized(self)
    
    self:SetModel(RepairBot.kModelName, kGorgeAnimationGraph)
    if Server then
    
        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
       
    elseif Client then
    
        InitMixin(self, HiveVisionMixin)
        
    end

    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
end

function RepairBot:OnAdjustModelCoords(modelCoords)
    modelCoords.xAxis = modelCoords.xAxis * kRepairBotScale
    modelCoords.yAxis = modelCoords.yAxis * kRepairBotScale
    modelCoords.zAxis = modelCoords.zAxis * kRepairBotScale
    modelCoords.origin.y = modelCoords.origin.y + kRepairBotVertAdjust
    return modelCoords
end
-- for marquee selection
function RepairBot:GetIsMoveable()
    return true
end
function RepairBot:GetMaxSpeed(possible)
    return kMaxGroundSpeed
end
function RepairBot:GetMaxBackwardSpeedScalar()
    return 1.0
end
-- avoid the MAC hovering inside (as that shows the MAC through the factory top)
function RepairBot:GetHoverHeight()
    return RepairBot.kHoverHeight
end
function RepairBot:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, self:GetHoverHeight(), 0)
end
function RepairBot:ModifyGravityForce(gravityTable)
    gravityTable.gravity = 0
end

function RepairBot:ModifyJump(input, velocity, jumpVelocity)
    jumpVelocity.y = jumpVelocity.y * RepairBot.kJumpVelMult
end
function RepairBot:GetJumpHeight()
    return RepairBot.kJumpHeight
end

function RepairBot:HandleButtons(input)

    PROFILE("RepairBot:HandleButtons")   
    
    Player.HandleButtons(self, input)
    
    -- Update alien movement ability
    local newMovementState = bit.band(input.commands, Move.MovementModifier) ~= 0
    if newMovementState ~= self.movementModiferState and self.movementModiferState ~= nil then
        self:MovementModifierChanged(newMovementState, input)
    end
    
    self.movementModiferState = newMovementState
    
end
Shared.LinkClassToMap("RepairBot", RepairBot.kMapName, networkVars, true)