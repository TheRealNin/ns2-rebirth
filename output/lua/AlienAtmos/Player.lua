if Client then
	local oldOnGroundChanged = Player.OnGroundChanged
	function Player:OnGroundChanged(onGround, impactForce, normal, velocity)
		oldOnGroundChanged(self, onGround, impactForce, normal, velocity)
		
		if not self._GUI_shove then
			self._GUI_shove = 0
		end
		
		if (onGround and impactForce > 1) then
			self._GUI_shove = math.max(impactForce, self._GUI_shove)
		end
		
	end

	local jumpForce = 8
	local oldOnJump = Player.OnJumpRequest
	function Player:OnJumpRequest()
		if oldOnJump then
			oldOnJump(self)
		end
		
		if not self._GUI_shove then
			self._GUI_shove = 0
		end
		if self:GetIsOnGround() then
			self._GUI_shove = math.max(jumpForce, self._GUI_shove)
		end
	end
end