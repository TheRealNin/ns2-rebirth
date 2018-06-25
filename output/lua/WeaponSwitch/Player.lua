
--[[
    Check to see if there's a ScriptActor we can use. Checks any usable points returned from
    GetUsablePoints() and if that fails, does a regular trace ray. Returns true if we processed the action.
]]
local function AttemptToUse(self, timePassed)

    PROFILE("Player:AttemptToUse")
    
    assert(timePassed >= 0)
    
    -- Cannot use anything unless playing the game (a non-spectating player).
    if
        Shared.GetTime() - self.timeOfLastUse < kUseInterval
        or self:isa("Spectator")
        then
        return false
    end
    
    -- don't allow Use and picking up a weapon at the same time
    local manualPickupWeapon = self.GetNearbyPickupableWeapon and self:GetNearbyPickupableWeapon()
    
    if not manualPickupWeapon then
    
        -- Trace to find use entity.
        local entity, usablePoint = self:PerformUseTrace()
        
        -- Use it.
        if entity then
        
            -- if the game isn't started yet, check if the entity is usuable in non-started game
            -- (allows players to select commanders before the game has started)
            if not self:GetGameStarted() and not (entity.GetUseAllowedBeforeGameStart and entity:GetUseAllowedBeforeGameStart()) then
                return false
            end
            
            -- Use it.
            if self:UseTarget(entity, kUseInterval) then
            
                self:SetIsUsing(true)
                self.timeOfLastUse = Shared.GetTime()
                return true
                
            end
            
        end
    end
    
end

debug.replaceupvalue( Player.HandleButtons, "AttemptToUse", AttemptToUse, true)