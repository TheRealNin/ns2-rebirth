

function Infestation:GetIsPointOnInfestation(point)

    local onInfestation = false
    
    -- Check radius
    local radius = point:GetDistanceTo(self.coords.origin)
    if radius <= self:GetRadius() then
    
		local dist = GetPathDistance(self.coords.origin, point)
		if dist and dist < self:GetRadius() * 1.3 then
			onInfestation = true
		end
        -- we remove this weird dotproduct thing... it causes a TON of bugs
        --[[
        -- Check dot product
        local toPoint = point - self.coords.origin
        local verticalProjection = math.abs( self.coords.yAxis:DotProduct( toPoint ) )
        
        onInfestation = (verticalProjection < 1)
        ]]--
    end
    
    return onInfestation
   
end

function CreateStructureInfestation(parent, coords, teamNumber, infestationRadius, blobMultiplier)

    local infestation = Infestation()
    infestation:Initialize()
    infestation:SetCoords(coords)    
    infestation:SetMaxRadius(infestationRadius)
    infestation:SetBlobMultiplier(blobMultiplier)
    infestation:SetTeamNumber(teamNumber)
    
    return infestation
    
end

function Infestation:SetTeamNumber(teamNumber)
    self.teamNumber = teamNumber
end

function Infestation:GetTeamNumber()
    return self.teamNumber
end
-- only called when the infestation actually changed
function Infestation:UpdateInfestables()

    PROFILE("Infestation:UpdateInfestables")

    local smallestRadius = self.radius
    local biggestRadius = self.lastRadius
    -- point is guaranteed on infestation when growing, only shrinking requires another check
    local onInfestation = self.radius > self.lastRadius

    if smallestRadius > biggestRadius then
        smallestRadius, biggestRadius = biggestRadius, smallestRadius
    end
    
    local origin = self.coords.origin
    -- don't specify team number here since marine buildings take damage from infestation
    for _, entity in ipairs(GetEntitiesWithMixinWithinRange("InfestationTracker",  self.coords.origin, biggestRadius)) do
    
        local range = (origin - entity:GetOrigin()):GetLength()
        if range >= smallestRadius and range <= biggestRadius then
			
			local dist = GetPathDistance(self.coords.origin, entity:GetOrigin())
			if dist then
				if dist < self:GetRadius() * 1.3 then
					entity:UpdateInfestedState(onInfestation)
				else
					entity:UpdateInfestedState(false)
				end
			else
				entity:UpdateInfestedState(onInfestation)
			end
        end
        
    end

end
