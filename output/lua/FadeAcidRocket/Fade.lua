local oldCreate = Fade.OnCreate
function Fade:OnCreate()
    oldCreate(self)
    InitMixin(self, PredictedProjectileShooterMixin)
end

function Fade:ModifyAttackSpeed(attackSpeedTable)
  local activeWeapon = self:GetActiveWeapon()
  if activeWeapon and activeWeapon:isa("StabBlink") then
      attackSpeedTable.attackSpeed = attackSpeedTable.attackSpeed * 1.3
  end

end


function Fade:GetCanJump()
    return self:GetIsOnGround() and not self:GetIsBlinking()
end


if WraithFade then
	local oldCreate = WraithFade.OnCreate
	function WraithFade:OnCreate()
		oldCreate(self)
		InitMixin(self, PredictedProjectileShooterMixin)
	end
	
	function WraithFade:ModifyAttackSpeed(attackSpeedTable)
	  local activeWeapon = self:GetActiveWeapon()
	  if activeWeapon and activeWeapon:isa("StabTeleport") then
		  attackSpeedTable.attackSpeed = attackSpeedTable.attackSpeed * 1.3
	  end

	end

end