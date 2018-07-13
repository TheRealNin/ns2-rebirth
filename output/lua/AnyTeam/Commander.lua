

local networkVars =
{
    isReady         = "private boolean",
}

local oldOnCreate = Commander.OnCreate
function Commander:OnCreate()
    oldOnCreate(self)
    self.isReady = false
end

function Commander:SetIsReady(ready)
    self.isReady = ready
end

function Commander:GetIsReady()
    return self.isReady or kForceMvM or kForceAvA or kForcedByConfig
end


Shared.LinkClassToMap("Commander", Commander.kMapName, networkVars)