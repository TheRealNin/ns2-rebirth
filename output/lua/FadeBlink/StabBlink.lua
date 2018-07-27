

class 'StabTeleport' (WraithTeleport)
StabTeleport.kMapName = "stabteleport"

local networkVars =
{
    stabbing = "compensated boolean"
}

local kRange = 1.9

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
local kAttackDuration = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "stab")
StabTeleport.cooldownInfluence = 0.5 -- 0 = no focus cooldown, 1 = same as kAttackDuration

function StabTeleport:OnCreate()

    WraithTeleport.OnCreate(self)

    self.primaryAttacking = false

end

function StabTeleport:GetAnimationGraphName()
    return kAnimationGraph
end

function StabTeleport:GetEnergyCost()
    return kStabEnergyCost
end

function StabTeleport:GetHUDSlot()
    return 3
end

function StabTeleport:GetPrimaryAttackRequiresPress()
    return false
end

function StabTeleport:GetMeleeBase()
    -- Width of box, height of box
    return .7, 1.2
end

function StabTeleport:GetDeathIconIndex()
    return kDeathMessageIcon.Stab
end

function StabTeleport:GetSecondaryTechId()
    return kTechId.WraithTeleport
end

function StabTeleport:GetBlinkAllowed()
    return not self.stabbing
end

function StabTeleport:OnPrimaryAttack(player)
    local notWraithTeleporting = not self:GetIsBlinking()
    local hasEnergy = player:GetEnergy() >= self:GetEnergyCost()
    local cooledDown = (not self.nextAttackTime) or (Shared.GetTime() >= self.nextAttackTime)
    if notWraithTeleporting and hasEnergy and cooledDown then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function StabTeleport:OnPrimaryAttackEnd()
    
    WraithTeleport.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function StabTeleport:OnHolster(player)

    WraithTeleport.OnHolster(self, player)
    
    self.primaryAttacking = false
    --self.stabbing = false
    -- disabling this b/c it means stab will do swipe damage if stab completes after user switches
    -- weapons to swipe.
    
end

function StabTeleport:OnDraw(player,previousWeaponMapName)

    WraithTeleport.OnDraw(self, player, previousWeaponMapName)
    
    self.primaryAttacking = false
    -- disabling this b/c it should already be false.  By setting it again here, we created a bug
    -- where if you start stab, switch to swipe, switch back to stab, then the stab animation completes,
    -- no damage occurs b/c stabbing is false.
    --self.stabbing = false
    
end

function StabTeleport:GetIsStabbing()
    return self.stabbing == true
end

function StabTeleport:GetIsAffectedByFocus()
    return self.primaryAttacking
end

function StabTeleport:GetMaxFocusBonusDamage()
    return kStabFocusDamageBonusAtMax
end

function StabTeleport:GetAttackAnimationDuration()
    return kAttackDuration * StabTeleport.cooldownInfluence
end

function StabTeleport:DoAttack()
    self:TriggerEffects("stab_hit")
    self.stabbing = false

    local player = self:GetParent()
    if player then

        AttackMeleeCapsule(self, player, kStabDamage, kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
        
        self:OnAttack(player)
    end
end

function StabTeleport:OnTag(tagName)

    PROFILE("SwipeWraithTeleport:OnTag")
    
    if tagName == "stab_start" then
    
        self:TriggerEffects("stab_attack")
        self.stabbing = true
    
    elseif tagName == "hit" and self.stabbing then
    
        self:DoAttack()
        
    end

end

function StabTeleport:OnUpdateAnimationInput(modelMixin)

    PROFILE("StabTeleport:OnUpdateAnimationInput")

    WraithTeleport.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "stab")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("StabTeleport", StabTeleport.kMapName, networkVars)