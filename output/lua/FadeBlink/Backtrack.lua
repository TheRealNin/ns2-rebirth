--
-- lua\Weapons\Alien\Backtrack.lua

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Blink.lua")

class 'Backtrack' (Blink)

Backtrack.kMapName = "backtrack"

local networkVars =
{
    lastPrimaryAttackTime = "time"
}

kBacktrackDelay = 12.0
kBacktrackDuration = 1.25
kBacktrackMaxRewind = 3.0

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")

function Backtrack:OnCreate()

    Blink.OnCreate(self)
    
    self.primaryAttacking = false
    self.lastPrimaryAttackTime = 0
end

function Backtrack:GetAnimationGraphName()
    return kAnimationGraph
end

function Backtrack:GetEnergyCost(player)
    return kBacktrackEnergyCost
end

function Backtrack:GetHUDSlot()
    return 2
end

function Backtrack:GetDeathIconIndex()
    return kDeathMessageIcon.Backtrack
end

function Backtrack:GetBlinkAllowed()
    return true
end

function Backtrack:GetAttackDelay()
    return kBacktrackDelay
end

function Backtrack:GetLastAttackTime()
    return self.lastPrimaryAttackTime
end

function Backtrack:GetSecondaryTechId()
    return kTechId.Blink
end

function Backtrack:GetHasAttackDelay()
	local parent = self:GetParent()
    return self.lastPrimaryAttackTime + kBacktrackDelay > Shared.GetTime() or parent and parent:GetIsStabbing()
end

function Backtrack:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() and not self:GetHasAttackDelay() then
        self.primaryAttacking = true
        player.timeBacktrack = Shared.GetTime()
    else
        self:OnPrimaryAttackEnd()
    end
    
end

function Backtrack:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    self.primaryAttacking = false
    
end

function Backtrack:OnHolster(player)

    Blink.OnHolster(self, player)
    self.primaryAttacking = false
    
end

function Backtrack:OnTag(tagName)

    PROFILE("Backtrack:OnTag")

    if tagName == "backtrack" and not self:GetHasAttackDelay() then
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(kBacktrackEnergyCost)
            player:TriggerEffects("metabolize")
            if player:GetCanBacktrackHealth() then
                local totalHealed = player:AddHealth(kBacktrackHealthRegain, false, false)
				if Client and totalHealed > 0 then
					local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
					GUIRegenerationFeedback:TriggerRegenEffect()
					local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
					cinematic:SetCinematic(kRegenerationViewCinematic)
				end
            end 
            player:AddEnergy(kBacktrackEnergyRegain)
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

function Backtrack:OnUpdateAnimationInput(modelMixin)

    PROFILE("Backtrack:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "vortex")
    
    local player = self:GetParent()
    local activityString = (self.primaryAttacking and "primary") or "none"
    if player and player:GetHasBacktrackAnimationDelay() then
        activityString = "primary"
    end
    
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("Backtrack", Backtrack.kMapName, networkVars)