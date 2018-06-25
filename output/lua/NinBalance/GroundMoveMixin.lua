
function GroundMoveMixin:ModifyMaxSpeed(maxSpeedTable, input)

    PROFILE("GroundMoveMixin:ModifyMaxSpeed")

	local backwardsSpeedScalar = 1
	
	if input and input.move.z == -1 then
	
        backwardsSpeedScalar = self:GetMaxBackwardSpeedScalar()
		backwardsSpeedScalar = Clamp(backwardsSpeedScalar, 0, 1)
	
	end
	
    maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * backwardsSpeedScalar

end

local kStopFriction = 18
debug.setupvaluex( GroundMoveMixin.GetFriction, "kStopFriction", kStopFriction, true)