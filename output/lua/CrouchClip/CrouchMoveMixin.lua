

CrouchMoveMixin.networkVars["crouchScalarAtTime"] = "compensated float"

local function GetDeltaTimeNetvar(startTime, rateOfChange, initialValue)
    local deltaTime = Shared.GetTime() - startTime
    return initialValue + rateOfChange * deltaTime
end

local kCrouchAnimationTime = 0.25
local kAirCrouchTransistionTime = 0.25 -- kCrouchAnimationTime is 0.25

local oldinit = CrouchMoveMixin.__initmixin
function CrouchMoveMixin:__initmixin()
    
	oldinit(self)
    self.crouchScalarAtTime = 0

end

-- this is *not* the amount crouched, it's how far in the animation we are
function CrouchMoveMixin:GetCrouchScalar()
	local rateOfChange = self.crouching and 1/kCrouchAnimationTime or -1/kCrouchAnimationTime
	return Clamp(GetDeltaTimeNetvar(self.timeOfCrouchChange, rateOfChange, self.crouchScalarAtTime), 0, 1)
end

function CrouchMoveMixin:GetCrouchAmount()
     
    -- Get 0-1 scalar of time since crouch changed
    local crouchScalar = 0
	if self.GetCanCrouchOverride then
		if not self:GetCanCrouchOverride() then
			return 0
		end
	end
	
    if self.timeOfCrouchChange > 0 then
        
		-- this is needed because the crouch amount does not follow a linear rate of change 
		local delta = Shared.GetTime() - self.timeOfCrouchChange
		if (delta >= kCrouchAnimationTime) then
			return self.crouching and 1 or 0
		end
		
		local rateOfChange = self.crouching and 1/kCrouchAnimationTime or -1/kCrouchAnimationTime
		
		-- todo: remove clamp after making sure it's not required
		crouchScalar = Clamp(math.sin(math.pi * 0.5 * GetDeltaTimeNetvar(self.timeOfCrouchChange, rateOfChange, self.crouchScalarAtTime)), 0, 1)
		
    end
    
    return crouchScalar

end

function CrouchMoveMixin:HandleButtons(input)

    PROFILE("CrouchMoveMixin:SetCrouchState")

	if self.GetCanCrouchOverride then
		if not self:GetCanCrouchOverride() then
			return
		end
	end
	
    local crouchDesired = bit.band(input.commands, Move.Crouch) ~= 0
    if crouchDesired == self.crouching then
        return
    end
   
    if not crouchDesired then
        local scalar = self:GetCrouchScalar()
        -- Check if there is room for us to stand up.
        self.crouching = crouchDesired
        self:UpdateControllerFromEntity()
        
        if self:GetIsColliding() then
            self.crouching = true
            self:UpdateControllerFromEntity()
        else
			self.crouchScalarAtTime = scalar
            self.timeOfCrouchChange = Shared.GetTime()
        end
        
    elseif self:GetCanCrouch() then
		self.crouchScalarAtTime = self:GetCrouchScalar()
        self.crouching = crouchDesired
        self.timeOfCrouchChange = Shared.GetTime()
        self:UpdateControllerFromEntity()
    end
    
end

function CrouchMoveMixin:GetCrouchAirFraction()
    local transistionTime = kAirCrouchTransistionTime
    local groundFraction = Clamp( (Shared.GetTime() - self.timeGroundTouched) / transistionTime, 0, 1)
    return groundFraction
end

function CrouchMoveMixin:OnAdjustModelCoords(modelCoords)
    if not self:GetIsOnGround() then
        modelCoords.origin = modelCoords.origin - Vector(0,self:GetExtentsCrouchShrinkAmount()*self:GetCrouchAirFraction() * self:GetCrouchAmount(),0)
    end
    return modelCoords
end