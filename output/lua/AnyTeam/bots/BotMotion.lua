
function BotMotion:OnGenerateMove(player)
    PROFILE("BotMotion:OnGenerateMove")

    local currentPos = player:GetOrigin()
    local eyePos = player:GetEyePos()
    local doJump = false

    local delta = currentPos - self.lastMovedPos

    ------------------------------------------
    --  Update ground motion
    ------------------------------------------

    local moveTargetPos = self:ComputeLongTermTarget(player)

    if moveTargetPos ~= nil and not player:isa("Embryo") then

        local distToTarget = currentPos:GetDistance(moveTargetPos)

        if distToTarget <= 0.01 then

            -- Basically arrived, stay here
            self.currMoveDir = Vector(0,0,0)

        else

            local now = Shared.GetTime()
            local updateMoveDir = self.nextMoveUpdate < now
            local unstuckDuration = 0.4
            local isStuck = delta:GetLength() < 1e-2 or self.unstuckUntil > now
            
            if self.desiredMoveTarget then
                local moveTargetDelta = self.desiredMoveTarget - player:GetOrigin()
                local vertDist = math.abs(moveTargetDelta.y)
                if vertDist > 1.5 and vertDist > moveTargetDelta:GetLengthXZ() then
                    isStuck = true
                    self.unstuckUntil = now + unstuckDuration * 2
                end
            end
            if updateMoveDir then

               self.nextMoveUpdate = now + kPlayerBrainTickFrametime
                -- If we have not actually moved much since last frame, then maybe pathing is failing us
                -- So for now, move in a random direction for a bit and jump
               if isStuck
               then

                    if self.unstuckUntil < now then
                         -- Move randomly during Xs
                         self.unstuckUntil = now + unstuckDuration

                         self.currMoveDir = GetRandomDirXZ()
                         if not player:isa("Lerk") then
                             doJump = true
                             self.lastJumpTime = Shared.GetTime()
                         else
                             self.currMoveDir.y = -2
                         end
                    end

                elseif distToTarget <= 2.0 then

                    -- Optimization: If we are close enough to target, just shoot straight for it.
                    -- We assume that things like lava pits will be reasonably large so this shortcut will
                    -- not cause bots to fall in
                    -- NOTE NOTE STEVETEMP TODO: We should add a visiblity check here. Otherwise, units will try to go through walls
                    self.currMoveDir = (moveTargetPos - currentPos):GetUnit()

                else

                    -- We are pretty far - do the expensive pathing call
                    self:GetOptimalMoveDirection(currentPos, moveTargetPos)

                end

                self.currMoveTime = Shared.GetTime()

            end

            self.lastMovedPos = currentPos
        end


    else

        -- Did not want to move anywhere - stay still
        self.currMoveDir = Vector(0,0,0)

    end

    ------------------------------------------
    --  View direction
    ------------------------------------------
    local desiredDir
    if self.desiredViewTarget ~= nil then

        -- Look at target
        desiredDir = (self.desiredViewTarget - eyePos):GetUnit()

    elseif self.currMoveDir:GetLength() > 1e-4 then

        -- Look in move dir
        desiredDir = self.currMoveDir
        if doJump then
            desiredDir.y = 1.0
        else
            desiredDir.y = 0.0  -- pathing points are slightly above ground, which leads to funny looking-up
        end
        desiredDir = desiredDir:GetUnit()

    else
        -- leave it alone
    end
    
    if desiredDir then
        -- TODO: change the frametime to the actual time spent
        local slerpSpeed = kPlayerBrainTickFrametime * 2.0
        
        local currentYaw = GetYawFromVector(self.currViewDir)
        local targetYaw = GetYawFromVector(desiredDir)
        
        local newYaw = SlerpRadians(currentYaw, targetYaw, slerpSpeed)
        local inBetween = Vector(math.sin(newYaw), desiredDir.y, math.cos(newYaw))
        self.currViewDir = inBetween:GetUnit()
        
    end
    
    if player:isa("Exo") and (self.lastJumpTime and self.lastJumpTime > Shared.GetTime() - 2) then
        doJump = true
    end

    return self.currViewDir, self.currMoveDir, doJump

end

