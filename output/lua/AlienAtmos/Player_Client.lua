

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
function Player:UpdateClientEffects(deltaTime, isLocal)

    if isLocal then
        self:UpdateCommanderPingSound()
    end

    -- Rumbling effects due to Onos
	-- Disabled because perf
    --self:UpdateShakingLights(deltaTime)
    --self:UpdateDirtFalling(deltaTime)
    --self:UpdateOnosRumble(deltaTime)
	if not self._GUI_shove then
		self._GUI_shove = 0
	end
	local speed = deltaTime * 30.0
	if self.GetIsOnGround and not self:GetIsOnGround() then
		speed = speed * 0.60
	end
	self._GUI_shove = math.max(0, self._GUI_shove - self._GUI_shove/4 * speed)
end
