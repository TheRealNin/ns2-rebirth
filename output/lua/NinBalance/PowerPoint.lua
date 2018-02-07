

-- NOTE: This does not work yet.

local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")

local function NinSetupWithInitialSettings(self)

    if self.startSocketed then

        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetConstructionComplete()
        self:SetLightMode(kLightMode.Normal)
        self:SetPoweringState(true)
    
    else

        self:SetModel(kSocketedModelName, kSocketedAnimationGraph)
        
        self.lightMode = kLightMode.NoPower
        self.lastLightMode = kLightMode.NoPower
        self.powerState = PowerPoint.kPowerState.destroyed
        self.timeOfDestruction = 0
        
        if Server then
        
            self.startsBuilt = false
            self.attackTime = 0.0
            self.underConstruction = false
            
        elseif Client then 
        
            self.unchangingLights = { }
            self.lightFlickers = { }
            
        end
    
    end
    
end

local oldOnInitialized = PowerPoint.OnInitialized
function PowerPoint:OnInitialized()
    oldOnInitialized(self)
    NinSetupWithInitialSettings(self)
end


if Server then
    function PowerPoint:Reset()
    
        NinSetupWithInitialSettings(self)
        
        ScriptActor.Reset(self)
        
        self:MarkBlipDirty()
        
    end
end