

LOSMixin.networkVars["spotted"] = "boolean"


local old__initmixin = LOSMixin.__initmixin
function LOSMixin:__initmixin()
    old__initmixin(self)
    
    if Server then
    
        self.spotted = false
    end
end

function LOSMixin:GetIsSpottable()
    return self:isa("Hive") or 
    self:isa("CommandStation") or 
    self:isa("InfantryPortal") or 
    self:isa("Harvester") or 
    self:isa("Extractor") or 
    self:isa("Armory") or 
    self:isa("AdvancedArmory") or 
    self:isa("PrototypeLab") or
    self:isa("PhaseGate") or
    self:isa("ArmsLab") or
    self:isa("Observatory") or
    self:isa("RoboticsFactory") or
    self:isa("SentryBattery") or
    self:isa("Sentry") or
    self:isa("Cyst") or
    self:isa("Hydra") or
    self:isa("Infestation") or
    self:isa("Shell") or
    self:isa("Veil") or 
    self:isa("Spur") or
    self:isa("TunnelEntrance")
end

function LOSMixin:GetIsSpotted()
    if self:GetIsSpottable() then
        return self.spotted
    else
        return self:GetIsSighted()
    end
end

function LOSMixin:OnSighted()
    if self:GetIsSpottable() then
        self.spotted = true
    end
end
