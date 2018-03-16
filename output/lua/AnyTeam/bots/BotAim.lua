
-- from http://stackoverflow.com/questions/10768142/verify-if-point-is-inside-a-cone-in-3d-space
local function IsPointInCone(point, cone_origin, cone_dir, angle)
    
    -- Vector pointing to camera point from cone point
    local apexToXVect = cone_origin - point;

    -- Vector pointing from apex to circle-center point.
    local axisVect = - cone_dir;

    -- X is lying in cone only if it's lying in 
    -- infinite version of its cone -- that is, 
    -- not limited by "round basement".
    -- We'll use Math.DotProduct() to 
    -- determine angle between apexToXVect and axis.
    local isInInfiniteCone = Math.DotProduct(apexToXVect,axisVect)
                               /apexToXVect:GetLength()/axisVect:GetLength()
                                 >
                               -- We can safely compare cos() of angles 
                               -- between vectors instead of bare angles.
                               math.cos(angle);


    return isInInfiniteCone;
end

BotAim.viewAngle = math.rad(47)
BotAim.reactionTime = 0.4 -- was 0.3

function BotAim:UpdateAim(target, targetAimPoint)
    PROFILE("BotAim:UpdateAim")
    local player = self.owner:GetPlayer()
    if player and IsPointInCone(targetAimPoint, player:GetEngagementPoint(), player:GetCoords().zAxis, BotAim.viewAngle) then
        return BotAim_UpdateAim(self, target, targetAimPoint)
    else
        -- try to view the target anyways, even though we can't directly see it
        self.owner:GetMotion():SetDesiredViewTarget( targetAimPoint )
        return false
    end
end

function BotAim:GetReactionTime()
    local reducedReaction = self.owner.aimAbility * 0.2
    return BotAim.reactionTime - reducedReaction
end

function BotAim_GetAimPoint(self, now, aimPoint)
    if gBotDebug:Get("aim") and gBotDebug:Get("spam") then
        Log("%s: getting aim point", self.owner)
    end

    while #self.targetTrack > 1 do
        -- search for a pair of tracks where the oldest is old enough for us to shoot from
        local targetData1 = self.targetTrack[1]
        local targetData2 = self.targetTrack[2]
        local p1, t1, target1 = targetData1[1], targetData1[2], targetData1[3]
        local p2, t2, target2 = targetData2[1], targetData2[2], targetData2[3]
               
        if target1 ~= target2 or now - t1 > self:GetReactionTime() + 0.1 or now - t2 > self:GetReactionTime()then
            -- t1 can't be used to shot on t2 due to different target
            -- OR t1 is uselessly old 
            -- OR we can use 2 because t2 is > reaction time
            table.remove(self.targetTrack, 1)
        else
            -- .. ending up here with [ (reactionTime + 0.1) > t1 > reactionTime > t2 ]
            local dt = now - t1
            if dt > self:GetReactionTime() then
                local mt = t2 - t1
                if mt > 0 then
                    local movementVector = (p2 - p1) / mt
                    local speed = movementVector:GetLength()
                    local result = p1 + movementVector * (dt)
                    local delta = result - aimPoint
                    if gBotDebug:Get("aim") then
                        Log("%s: Aiming at %s, off by %s, speed %s (%s tracks)", self.owner, target1, delta:GetLength(), speed, #self.targetTrack)
                    end
                    return result
                end
            end
            if gBotDebug:Get("aim") and gBotDebug:Get("spam") then
                Log("%s: waiting for reaction time", self.owner)
            end
            return null
        end
    end
    if gBotDebug:Get("aim") and gBotDebug:Get("spam") then
        Log("%s: no target", self.owner)
    end
    return nil
end