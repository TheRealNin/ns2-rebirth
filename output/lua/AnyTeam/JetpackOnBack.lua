
local kModelName = PrecacheAsset("models/marine/jetpack/jetpack.model")
local kAnimationGraph = PrecacheAsset("models/marine/jetpack/jetpack.animation_graph")

function JetpackOnBack:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
    -- can you believe this?
    --self:SetTeamNumber(kTeam1Index)
    
    self:SetUpdates(true)
    
    self.flying = false
    self.thrustersOpen = false
    self.timeFlyingEnd = 0
    
    self:SetModel(kModelName, kAnimationGraph)
    
end