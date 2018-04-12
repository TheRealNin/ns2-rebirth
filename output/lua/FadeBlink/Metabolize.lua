--
-- lua\Weapons\Alien\Metabolize.lua


class 'Metabolize' (Blink)

local kVortexDestroy = PrecacheAsset("cinematics/alien/fade/vortex_destroy.cinematic")

Metabolize.kMapName = "metabolize"


local kBacktrackDelay = 12.0
local kBacktrackDuration = 1.25
local kBacktrackMaxRewind = 4.0
local kBacktrackSaveInterval = 0.25

local _backtrackSaveNum = math.round(kBacktrackMaxRewind / kBacktrackSaveInterval) + 1

kMetabolizeDelay = kBacktrackDelay -- was 2.0




local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")

local networkVars =
{
    lastPrimaryAttackTime = "time",
    backtrackPosition = "private integer (0 to " .. ToString(_backtrackSaveNum) .. ")"
}

function Metabolize:OnCreate()

    Blink.OnCreate(self)
    
    self.primaryAttacking = false
    self.lastPrimaryAttackTime = 0
    self.backtrackPosition = 0
    self.backtrackEntries = {}
    for i = 0, _backtrackSaveNum do
      self.backtrackEntries[i] = {}
    end
    -- this is supposed to make predict do the callback, but it's not
    Entity.AddTimedCallbackActual(self, Metabolize.SaveState, kBacktrackSaveInterval, false)
    --self:AddTimedCallbackActual(Metabolize.SaveState, kBacktrackSaveInterval, false)
end

function Metabolize:SaveState()
    --Log("%s",  "Metabolize:SaveState")
    local player = self:GetParent()
    -- for some reason it tries to sometimes save the state when we don't have GetCrouching.
    if player and player.GetCrouching then
      self.backtrackPosition = (self.backtrackPosition + 1) % _backtrackSaveNum
      self.backtrackEntries[self.backtrackPosition] = 
      {
        origin = player:GetOrigin(), 
        lookin = GetYawFromVector(player:GetCoords().zAxis),  
        health = player:GetHealthFraction(),
        armor  = player:GetArmorScalar(),
        crouching = player:GetCrouching()
      }
    end
    return true
end

function Metabolize:GetOldestState()
    local oldestPos = (self.backtrackPosition + 1) % _backtrackSaveNum
    local currentPos = self.backtrackPosition
    while currentPos ~= oldestPos do
      local newPos = (currentPos - 1 + _backtrackSaveNum) % _backtrackSaveNum
      if not self.backtrackEntries[newPos] or not self.backtrackEntries[newPos].origin then
        --Print("Found the oldest due to a nil")
        oldestPos = currentPos
        break
      end
      -- go backwards, circularly
      currentPos = newPos
    end
    
    return self.backtrackEntries[oldestPos]
end

function Metabolize:GetAnimationGraphName()
    return kAnimationGraph
end

function Metabolize:GetEnergyCost(player)
    return kMetabolizeEnergyCost
end

function Metabolize:GetHUDSlot()
    return kNoWeaponSlot
end

function Metabolize:GetDeathIconIndex()
    return kDeathMessageIcon.Metabolize
end

function Metabolize:GetBlinkAllowed()
    return true
end

function Metabolize:GetAttackDelay()
    return kMetabolizeDelay
end

function Metabolize:GetLastAttackTime()
    return self.lastPrimaryAttackTime
end

function Metabolize:GetSecondaryTechId()
    return kTechId.Blink
end

function Metabolize:GetHasAttackDelay()
	local parent = self:GetParent()
    return self.lastPrimaryAttackTime + kMetabolizeDelay > Shared.GetTime() or parent and parent:GetIsStabbing()
end

function Metabolize:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() and not self:GetHasAttackDelay() then
        self.primaryAttacking = true
        player.timeMetabolize = Shared.GetTime()
    else
        self:OnPrimaryAttackEnd()
    end
    
end

function Metabolize:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    self.primaryAttacking = false
    
end

function Metabolize:OnHolster(player)

    Blink.OnHolster(self, player)
    self.primaryAttacking = false
    
end

function Metabolize:OnTag(tagName)

    PROFILE("Metabolize:OnTag")

    if tagName == "metabolize" and not self:GetHasAttackDelay() then
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(kMetabolizeEnergyCost)
            player:TriggerEffects("metabolize")
            player:TriggerEffects("vortexed_end", {effecthostcoords = Coords.GetLookIn(player:GetOrigin() + Vector(0,0.8,0),  player:GetViewAngles():GetCoords().zAxis)})
            player:SetVelocity(Vector(0,0,0)) 
            
            local state = self:GetOldestState()
            if state and Server then

                --if HasMixin(self, "SmoothedRelevancy") then
                --    player:StartSmoothedRelevancy(state.origin)
                --end
                
                player:SetOrigin(state.origin)
                
                local newAngles = Angles(0, 0, 0)                      
                newAngles.yaw = state.lookin
                player:SetOffsetAngles(newAngles)
                
                player.crouching = state.crouching

                --[[
                --if player:GetCanMetabolizeHealth() then
                  local oldHealth = player:GetHealthFraction()
                  local oldArmor = player:GetArmorScalar()
                  
                  local newHealth = Clamp(state.health, oldHealth, 1)
                  local newArmor = Clamp(state.armor, oldArmor, 1)
                  
                  local totalHealed = newHealth - oldHealth
                  local totalArmored = newArmor - oldArmor
                  
                  if Client and (totalHealed > 0 or totalArmored > 0) then
                    local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
                    GUIRegenerationFeedback:TriggerRegenEffect()
                    local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                    cinematic:SetCinematic(kRegenerationViewCinematic)
                  end
                  if Server then
                    player:SetArmor(newArmor * player:GetMaxArmor())
                    player:SetHealth(newHealth * player:GetMaxHealth())
                  end
                --end 
                ]]--
            end
            
            self.lastPrimaryAttackTime = Shared.GetTime()
            self.primaryAttacking = false
        end
    elseif tagName == "metabolize_end" then
        local player = self:GetParent()
        if player then
            self.primaryAttacking = false
        end
    end
    
    if tagName == "hit" then
    
        local stabWep = self:GetParent():GetWeapon(StabBlink.kMapName)
        if stabWep and stabWep.stabbing then
            stabWep:DoAttack()
        end
    end
    
end

function Metabolize:OnUpdateAnimationInput(modelMixin)

    PROFILE("Metabolize:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "vortex")
    
    local player = self:GetParent()
    local activityString = (self.primaryAttacking and "primary") or "none"
    if player and player:GetHasMetabolizeAnimationDelay() then
        activityString = "primary"
    end
    
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("Metabolize", Metabolize.kMapName, networkVars)