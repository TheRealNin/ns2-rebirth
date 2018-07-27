
class 'SwipeTeleport' (WraithTeleport)


SwipeTeleport.kMapName = "swipe_teleport"

SwipeTeleport.kSwipeEnergyCost = kSwipeEnergyCost * 0.5
SwipeTeleport.kDamage = kSwipeDamage
SwipeTeleport.kRange = 1.8

local networkVars =
{
}

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
local kAttackDuration = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "swipe_attack")

function SwipeTeleport:OnCreate()

    WraithTeleport.OnCreate(self)
    
    self.lastSwipedEntityId = Entity.invalidId
    self.primaryAttacking = false

end

function SwipeTeleport:GetAnimationGraphName()
    return kAnimationGraph
end

function SwipeTeleport:GetEnergyCost()
    return SwipeTeleport.kSwipeEnergyCost
end

function SwipeTeleport:GetHUDSlot()
    return 1
end

function SwipeTeleport:GetPrimaryAttackRequiresPress()
    return false
end

function SwipeTeleport:GetMeleeBase()
    -- Width of box, height of box
    return 1.6, 1.6 -- was .7, 1.2
    
end


function SwipeTeleport:GetDeathIconIndex()
    return kDeathMessageIcon.Swipe
end

function SwipeTeleport:GetVampiricLeechScalar()
    return kSwipeVampirismScalar
end

function SwipeTeleport:GetSecondaryTechId()
    return kTechId.WraithTeleport
end

function SwipeTeleport:GetBlinkAllowed()
    return true
end

function SwipeTeleport:OnPrimaryAttack(player)
    local notBlinking = not self:GetIsBlinking()
    local hasEnergy = player:GetEnergy() >= self:GetEnergyCost()
    local cooledDown = (not self.nextAttackTime) or (Shared.GetTime() >= self.nextAttackTime)
    if notBlinking and hasEnergy and cooledDown then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function SwipeTeleport:OnPrimaryAttackEnd()
    
    WraithTeleport.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function SwipeTeleport:OnHolster(player)

    WraithTeleport.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

function SwipeTeleport:GetIsAffectedByFocus()
    return self.primaryAttacking
end

function SwipeTeleport:GetAttackAnimationDuration()
    return kAttackDuration
end

function SwipeTeleport:OnTag(tagName)

    PROFILE("SwipeTeleport:OnTag")
    
    if tagName == "hit" then
    
        local stabWep = self:GetParent():GetWeapon(StabTeleport.kMapName)
        if stabWep and stabWep.stabbing then
            -- player is using stab and has switched to swipe really fast, but the attack the "hit"
            -- tag is from is still a stab, and thus should do stab damage.
            stabWep:DoAttack()
        else
            self:TriggerEffects("swipe_attack")    
            self:PerformMeleeAttack()
        
            local player = self:GetParent()
            if player then
            
                self:OnAttack(player)
            
            end
        end
    
    end

end

function SwipeTeleport:PerformMeleeAttack()

    local player = self:GetParent()
    if player then    
        AttackMeleeCapsule(self, player, SwipeTeleport.kDamage, SwipeTeleport.kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
    end
    
end

function SwipeTeleport:OnUpdateAnimationInput(modelMixin)

    PROFILE("SwipeTeleport:OnUpdateAnimationInput")

    WraithTeleport.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "swipe")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("SwipeTeleport", SwipeTeleport.kMapName, networkVars)