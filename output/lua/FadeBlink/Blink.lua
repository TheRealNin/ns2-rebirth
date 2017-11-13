
local kMapName = "vortex"
local kModelName = PrecacheAsset("models/alien/fade/vortex.model")
local shadowStepDistance = 14
local maxShadowStepBonus = 7

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
PrecacheAsset("cinematics/vfx_materials/vortex.surface_shader")

local kVortexCinematic = PrecacheAsset("cinematics/alien/fade/vortex_fast.cinematic")
local kLandingCinematic = PrecacheAsset("cinematics/alien/fade/vortex_landing.cinematic")
local kCreateVortex = PrecacheAsset("cinematics/alien/fade/use_vortex.cinematic")


local function TriggerBlinkOutEffects(self, player)

    player:TriggerEffects("blink_in", { effecthostcoords = Coords.GetLookIn(player:GetOrigin(),  player:GetViewAngles():GetCoords().zAxis) })
    
end

local function TriggerBlinkInEffects(self, player)

    -- Play particle effect at vanishing position.
    player:TriggerEffects("blink_out", {effecthostcoords = Coords.GetLookIn(player:GetOrigin(),  player:GetViewAngles():GetCoords().zAxis)})
    if not Shared.GetIsRunningPrediction() and not player:GetIsThirdPerson() then
        player.blinkAmount = 0.25
        if Client and player:GetIsLocalPlayer() then
            player:TriggerEffects("blink_out_local", { effecthostcoords = Coords.GetLookIn(player:GetOrigin(),  player:GetViewAngles():GetCoords().zAxis) })
        end
        
    end

end

function Blink:GetShadowStepDistance()
    local player = self:GetParent()
    return shadowStepDistance + (player.celeritySpeedScalar or 0) * maxShadowStepBonus
end

function OldBlinkEndTarget(self)  
  local player = self:GetParent()
  
  local lookedAtPoint = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * self:GetShadowStepDistance()
        
  local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
  
  -- figure out the crouch capusle (since we will crouch at the end)
  -- sometimes players don't have GetCrouching(). Wtf?
  if not player.crouching then
    capsuleHeight = capsuleHeight * player:GetExtentsCrouchShrinkAmount()
  end
  local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
  
  local traceStart = player:GetOrigin() + Vector(0, capsuleRadius, 0)
  local traceEnd = lookedAtPoint  + Vector(0, capsuleRadius * 0.5, 0)
  
  
  local trace = Shared.TraceCapsule( traceStart, traceEnd, capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(player))
  
  local coords = self:GetCoords()
  
  -- did we fail to find any points?
  if trace.fraction <= 0.01 then
    coords.origin = player:GetOrigin() 
    return coords
  end
  
  coords.origin = traceStart * (1-trace.fraction) + traceEnd * trace.fraction - center
  return coords
end

function BlinkEndTarget(self)  
  local player = self:GetParent()
  
  local lookedAtPoint = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * self:GetShadowStepDistance()
  
  local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
  
  if not player.crouching then
    capsuleHeight = capsuleHeight * player:GetExtentsCrouchShrinkAmount()
  end
  
  -- use a sphere capsule
  local sphereCenter = Vector(0,  capsuleRadius * 1.0, 0)
  local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
  
  local numStarts = 2
  for startStep=0,numStarts,1 do
    local traceStart = player:GetEyePos() + sphereCenter - startStep * capsuleHeight * 0.5
    local traceEnd = lookedAtPoint + sphereCenter
    
    local trace = Shared.TraceCapsule( traceStart, traceEnd, capsuleRadius * 1.0, 0, CollisionRep.Move, PhysicsMask.All, EntityFilterOneAndIsa(player, "Babbler"))
    -- trace is now the furthest point we can see with the mini sphere
    
    local coords = self:GetCoords()
    
    -- did we fail to find any points?
    --[[
    if trace.fraction <= 0.01 then
      coords.origin = player:GetOrigin() 
      return coords
    end
    ]]
    
    -- now test points to see if there is a spot we can spawn the player using the real capsuleHeight
    local numSteps = 10
    for i=0,numSteps,1 do
      local newFraction = trace.fraction * ((numSteps - i) / numSteps)
      local spherePoint = traceStart * (1-newFraction) + traceEnd * newFraction
      local sphereStart = spherePoint + center
      local sphereBottomEnd = spherePoint - center
      local sphereEnd = spherePoint
      local capsuleTrace = Shared.TraceCapsule(sphereStart, sphereEnd, capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOneAndIsa(player, "Babbler"))
      if capsuleTrace.fraction > 0.05 then
        local newOrigin = sphereStart * (1-capsuleTrace.fraction) + sphereEnd * capsuleTrace.fraction  - center
        coords.origin =newOrigin
        return coords
      end
      local capsuleBottomTrace = Shared.TraceCapsule(sphereStart, sphereBottomEnd, capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.Movement,  EntityFilterOneAndIsa(player, "Babbler"))
      if capsuleBottomTrace.fraction > 0.05 then
        local newOrigin = sphereStart * (1-capsuleBottomTrace.fraction) + sphereBottomEnd * capsuleBottomTrace.fraction  - center
        coords.origin =newOrigin
        return coords
      end
      capsuleBottomTrace = Shared.TraceCapsule(sphereBottomEnd, sphereStart, capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.Movement,  EntityFilterOneAndIsa(player, "Babbler"))
      if capsuleBottomTrace.fraction > 0.05 then
        local newOrigin = sphereBottomEnd * (1-capsuleBottomTrace.fraction) + sphereStart * capsuleBottomTrace.fraction  - center
        coords.origin =newOrigin
        return coords
      end
    end
  end
  -- we failed, so lets try the older, safer version to see if it finds a coord?
  return OldBlinkEndTarget(self)
end

function Blink:OnSecondaryAttack(player)

    local minTimePassed = not player:GetRecentlyBlinked()
    local hasEnoughEnergy = player:GetEnergy() > kFadeTeleportEnergyCost
    if (not player.etherealStartTime or minTimePassed  and player:GetBlinkAllowed()) and hasEnoughEnergy then
    
        if not self.secondaryAttacking then
        
            
            self.timeBlinkStarted = Shared.GetTime()
            
            self.secondaryAttacking = true
            
  
            if self.vortexCinematic then
            
                Client.DestroyCinematic(self.vortexCinematic)
                self.vortexCinematic = nil
                
            end
            if self.landingCinematic then
            
                Client.DestroyCinematic(self.landingCinematic)
                self.landingCinematic = nil
                
            end
            if Client and Client.GetLocalPlayer() == player then
                
              self.vortexCinematic = Client.CreateCinematic(RenderScene.Zone_Default)    
              self.vortexCinematic:SetCinematic(kVortexCinematic)
              self.vortexCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
              
              self.landingCinematic = Client.CreateCinematic(RenderScene.Zone_Default)    
              self.landingCinematic:SetCinematic(kLandingCinematic)
              self.landingCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
              
                
            end
            
        end
        
    else
      player:TriggerInvalidSound()
    end
    
    Ability.OnSecondaryAttack(self, player)
    
end


function Blink:OnSecondaryAttackEnd(player)
      
  
    if self.vortexCinematic then
    
        Client.DestroyCinematic(self.vortexCinematic)
        self.vortexCinematic = nil
        
    end
    if self.landingCinematic then
    
        Client.DestroyCinematic(self.landingCinematic)
        self.landingCinematic = nil
        
    end

    -- A case where GetRecentlyBlinked() does not exist is when a Fade becomes Commanders
    if player.GetRecentlyBlinked then
      local minTimePassed = not player:GetRecentlyBlinked()
      local hasEnoughEnergy = player:GetEnergy() > kFadeTeleportEnergyCost
      if (not player.etherealStartTime or minTimePassed and player:GetBlinkAllowed() ) and hasEnoughEnergy then
      
        self:SetEthereal(player, true)
  
      end
      
      
      Ability.OnSecondaryAttackEnd(self, player)
      
      self.secondaryAttacking = false
    end
end


function Blink:SetEthereal(player, state)

    -- Enter or leave ethereal mode.
    if player.ethereal ~= state then
    
        player.ethereal = state  
              

        if player.ethereal then
          player:DeductAbilityEnergy(kFadeTeleportEnergyCost)
          player.etherealStartTime = Shared.GetTime()
          TriggerBlinkOutEffects(self, player)
          self:TriggerEffects("shadow_step", { effecthostcoords = Coords.GetLookIn(player:GetOrigin(),  player:GetViewAngles():GetCoords().zAxis) })
          
          player.startBlinkLocation = player:GetOrigin() 
          player.startVelocity = player:GetVelocity() 
          player.endBlinkLocation = BlinkEndTarget(self).origin
          
        elseif player.OnBlinkEnd then
        -- A case where OnBlinkEnd() does not exist is when a Fade becomes Commanders and
        -- then a new ability becomes available through research which calls AddWeapon()
        -- which calls OnHolster() which calls this function. The Commander doesn't have
        -- a OnBlinkEnd() function but the new ability is still added to the Commander for
        -- when they log out and become a Fade again.
          player:OnBlinkEnd()
          player.etherealEndTime = Shared.GetTime()
          TriggerBlinkInEffects(self, player)
          
          if Client and Client.GetLocalPlayer() == player and player:GetIsFirstPerson() then
              
              local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
              cinematic:SetCinematic(kCreateVortex)
              
          end
        end
        
    end
end


function Blink:OnUpdateAnimationInput(modelMixin)

    local player = self:GetParent()
    if player.ethereal and (not self.GetHasMetabolizeAnimationDelay or not self:GetHasMetabolizeAnimationDelay()) then
        modelMixin:SetAnimationInput("move", "blink")
    end
    
    if self.vortexCinematic then
        player.blinkAmount = 0.25
        local endTarget = BlinkEndTarget(self)
        self.vortexCinematic:SetCoords(endTarget)
        local player = self:GetParent()
        
        local tooClose = not (player:GetEyePos():GetDistanceTo(endTarget.origin) < 1)
        self.vortexCinematic:SetIsVisible(tooClose)
        
        if self.landingCinematic then
                
            local capsuleHeight, capsuleRadius = player:GetTraceCapsule()

            if not player.crouching then
                capsuleHeight = capsuleHeight * player:GetExtentsCrouchShrinkAmount()
            end

            -- use a sphere capsule
            local sphereCenter = Vector(0,  capsuleRadius * 1.0, 0)
            local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)

            local traceStart = endTarget.origin + Vector(0,1,0)
            local traceEnd = endTarget.origin + Vector(0,-20,0)
            
            local trace = Shared.TraceCapsule( traceStart, traceEnd, capsuleRadius * 1.0, 0, CollisionRep.Move, PhysicsMask.All, EntityFilterOneAndIsa(player, "Babbler"))
            
            local coords = self:GetCoords()
            coords.origin = trace.endPoint + Vector(0,-capsuleHeight * 0.5,0)
            
            
            self.landingCinematic:SetCoords(coords)
            
            local landingVisible = (trace.fraction > 0.05)
            self.landingCinematic:SetIsVisible(landingVisible)
        
        end
    end
    
    
end



function Blink:OnHolster(player)

    if self.vortexCinematic then
    
        Client.DestroyCinematic(self.vortexCinematic)
        self.vortexCinematic = nil
        
    end
    Ability.OnHolster(self, player)
    
    
end

function Blink:ProcessMoveOnWeapon(player, input)
 
    -- End blink mode if out of energy or when dead
    if (not player:GetIsAlive()) then
    
        self:SetEthereal(player, false)

    end
end


local originalOnDestroy = Blink.OnDestroy
function Blink:OnDestroy()

    if self.vortexCinematic then
    
        Client.DestroyCinematic(self.vortexCinematic)
        self.vortexCinematic = nil
        
    end
    originalOnDestroy(self)
end
