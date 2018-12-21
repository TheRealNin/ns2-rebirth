if Client then

function CommanderGlowMixin:OnModelChanged(index)
    if self.commanderGlowOutline then 
        local model = self:GetRenderModel()
        if model then
            HiveVision_RemoveModel( model )
            EquipmentOutline_RemoveModel( model )
        end
        self.commanderGlowOutline = false
    end
end

function CommanderGlowMixin:OnDestroy()

    if self.commanderGlowOutline then
        local model = self:GetRenderModel()
        if model then
            HiveVision_RemoveModel( model )
            EquipmentOutline_RemoveModel( model )
        end
        self.commanderGlowOutline = false
    end
    
end

local function GlowCustomFilter(entity1, entity2)
	-- return true to filter out ent
	return function(test, targetPoint)
		return (test == entity1 or test == entity2) or (not test:isa("Hive") and not test:isa("CommandStation") and not test:isa("Door") and not test:isa("Armory"))
	end
end

function CommanderGlowMixin:UpdateHighlight()

    -- Show glowing outline for commander, to pick it out of the darkness
    local player = Client.GetLocalPlayer()
    local visible = player ~= nil and Client.GetLocalClientTeamNumber() ~= kSpectatorIndex -- make it so all players see the glow, but spectators already see it
    local isCommander = visible and (player:isa("Commander"))
    local isAlienTeam = player:GetTeamType() == kAlienTeamType
    
    -- Don't show enemy structures as glowing
    if not GetAreFriends(player, self) then
        visible = false
    end
    
    -- don't show neutral stuff to aliens
    if not isCommander and isAlienTeam and (self.GetTeamNumber and self:GetTeamNumber() ~= kTeam1Index and self:GetTeamNumber() ~= kTeam2Index) then
        visible = false
    end
    
	if visible and not isCommander then
		-- do the expensive trace
		--visible = not GetCanSeeEntity(player, self)
		local targetOrigin = HasMixin(self, "Target") and self:GetEngagementPoint() or self:GetOrigin()
        local eyePos = GetEntityEyePos(player)
		local filter = GlowCustomFilter(player, self)
		local trace = Shared.TraceRay(eyePos, targetOrigin, CollisionRep.Move, PhysicsMask.Movement, filter)
		
		-- something is not blocking the way
		if trace.fraction > 0.99 then
			visible = false
		end
	end
	
    -- Update the visibility status.
    if visible ~= self.commanderGlowOutline then
        self.commanderGlowOutline = visible   
    
        local model = self:GetRenderModel()
        if model ~= nil then

            local isAlien = GetIsAlienUnit(player)        
            if visible then
                if isAlien then
                    HiveVision_AddModel( model, kHiveVisionOutlineColor.Blue)
                else
                    EquipmentOutline_AddModel( model )
                end
            else
                HiveVision_RemoveModel( model )
                EquipmentOutline_RemoveModel( model )
            end
          
            
        end
        
    end
    
end


end