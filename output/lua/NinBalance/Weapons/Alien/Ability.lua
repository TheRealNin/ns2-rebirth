
function Ability:GetEffectParams(tableParams)

    local player = self:GetParent()
    if player and (not self.IsAffectedBySilence or self:IsAffectedBySilence()) then
        local silenceLevel = player.silenceLevel or 0
        tableParams[kEffectFilterSilenceUpgrade] = silenceLevel == 3
        tableParams[kEffectParamVolume] = 1 - Clamp(silenceLevel / 3, 0, 1)
    end
    
end