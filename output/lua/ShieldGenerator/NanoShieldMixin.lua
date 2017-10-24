NanoShieldMixin.networkVars =
{
    nanoShielded = "boolean",
    permanent = "boolean"
}


local function UpdateClientNanoShieldEffects(self)

    assert(Client)
    
    if self:GetIsNanoShielded() and self:GetIsAlive() then
        self:_CreateEffect()
    else
        self:_RemoveEffect() 
    end
    
end

local function SharedUpdate(self)

    if Server then
    
        if not self:GetIsNanoShielded() then
            return
        end
        
        -- See if nano shield time is over
        if self.timeNanoShieldInit + kNanoShieldDuration < Shared.GetTime() and not self.permanent then
            ClearNanoShield(self, true)
        end
       
    elseif Client and not Shared.GetIsRunningPrediction() then
        UpdateClientNanoShieldEffects(self)
    end
    
end


function NanoShieldMixin:OnUpdate(deltaTime)   
    SharedUpdate(self)
end

function NanoShieldMixin:OnProcessMove(input)   
    SharedUpdate(self)
end

function NanoShieldMixin:GetIsNanoShielded()
    return self.nanoShielded or self.permanent
end
