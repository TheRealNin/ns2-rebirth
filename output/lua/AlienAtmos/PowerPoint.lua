

local kUnsocketedSocketModelName = PrecacheAsset("models/system/editor/power_node_socket.model")
local kUnsocketedAnimationGraph = nil

local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")


local function NewSetupWithInitialSettings(self)

    if self.startSocketed then
        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetConstructionComplete()
        self:SetLightMode(kLightMode.Normal)
        self:SetPoweringState(true)
    
    else
        
        self:SetModel(kUnsocketedSocketModelName, kUnsocketedAnimationGraph)
        
        -- players got confused by this change
        --self:SetModel(kSocketedModelName, kSocketedAnimationGraph)
        
        self.lightMode = kLightMode.NoPower
        self.lastLightMode = kLightMode.NoPower
        self.timeOfLightModeChange = 0
        
        self.powerState = PowerPoint.kPowerState.unsocketed
        self.timeOfDestruction = 0
        
        if Server then
        
            self.startsBuilt = false
            self.attackTime = 0.0
            
        elseif Client then 
        
            self.unchangingLights = { }
            self.lightFlickers = { }
            
        end
    
    end
    
end


function PowerPoint:CanBeCompletedByScriptActor( player )

    PROFILE("PowerPoint:CanBeCompletedByScriptActor")

    if player:isa("MAC") then
        -- MAC can always build if it was issued a new build command after the power was primed
        local macHasConfirmed = player.timeLastOrder and player:GetCurrentOrder()
            and self.timeLastConstruct < player.timeLastOrder 
            and player:GetCurrentOrder():GetType() == kTechId.Construct        
        if macHasConfirmed then
            return true
        end
    end
    
    if player:isa("Marine") then
        return true
    end

    if not self:RequirePrimedNodes() then
        -- If the server doesn't requires priming nodes in all circumstances, only require that a blueprint exists
        if self:HasUnbuiltConsumerRequiringPower() then
            return true
        end
    else
        -- Otherwise, power can only be completed when there is a fully built structure which requires power in the vicinity
        if self:HasConsumerRequiringPower() then
            return true
        end
    end
    
    return false
end

local originalOnCreate = PowerPoint.OnCreate
function PowerPoint:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PowerSourceMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    InitMixin(self, ParasiteMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    --self.lightMode = kLightMode.Normal
    self.lightMode = kLightMode.NoPower
    self.powerState = PowerPoint.kPowerState.unsocketed
    
    if Client then 
        self:AddTimedCallback(PowerPoint.OnTimedUpdate, kUpdateIntervalLow)
    end
    
    NewSetupWithInitialSettings(self)
    
end



