

-- Set light shake amount due to nearby roaming Onos
-- disable for perf
function Player:SetLightShakeAmount(amount, duration, scalar)
    --[[
    if scalar == nil then
        scalar = 1
    end

    -- So lights start moving in time with footsteps
    self:ResetShakingLights()

    self.lightShakeAmount = Clamp(amount, 0, 1)

    -- Save off original amount so we can have it fall off nicely
    self.savedLightShakeAmount = self.lightShakeAmount

    self.lightShakeEndTime = Shared.GetTime() + duration

    self.lightShakeScalar = scalar
    ]]--
end

local originalUpdateClientEffects = Player.UpdateClientEffects
-- Disabled because perf
function Player:UpdateClientEffects(deltaTime, isLocal)

    if isLocal then
        self:UpdateCommanderPingSound()
    end

    -- Rumbling effects due to Onos
    --self:UpdateShakingLights(deltaTime)
    --self:UpdateDirtFalling(deltaTime)
    --self:UpdateOnosRumble(deltaTime)

end

