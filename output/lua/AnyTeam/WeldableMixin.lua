
-- If entity is ready to be welded by buildbot right now, and in the future
function WeldableMixin:GetCanBeWelded(doer)

    -- Can't weld yourself!
    if doer == self then
        return false
    end
    
    local canBeWelded = true
    -- GetCanBeWeldedOverride() will return two booleans.
    -- The first will be true if self can be welded and
    -- the second will return true if the first should
    -- completely override the default behavior below.
    if self.GetCanBeWeldedOverride then
    
        local overrideWelded, overrideDefault = self:GetCanBeWeldedOverride(doer)
        if overrideDefault then
            return overrideWelded
        end
        canBeWelded = overrideWelded
        
    end
    
    canBeWelded = canBeWelded and self:GetIsAlive() and GetAreFriends(doer, self) and
                  self:GetWeldPercentage() < 1
    
    return canBeWelded
    
end