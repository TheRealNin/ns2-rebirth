
local kAttackRange = 1.7
local kFloorAttackRage = 0.9


function Gore:GetMeleeBase()
    -- Width of box, height of box
    -- was 1, 1.4
    return 1.4, 1.4
end

local function GetGoreAttackRange(viewCoords)
    return kAttackRange + math.max(0, -viewCoords.zAxis.y) * kFloorAttackRage
end

function Gore:Attack(player)
    
    local now = Shared.GetTime()
    local didHit = false
    local impactPoint
    local target
    local attackType = self.attackType
    
    if Server then
        attackType = self.lastAttackType
    end
    
    local range = GetGoreAttackRange(player:GetViewCoords())
    didHit, target, impactPoint = AttackMeleeCleaveCapsule(self, player, kGoreDamage, range)

    player:DeductAbilityEnergy(self:GetEnergyCost(player))
    
    self:DoAbilityFocusCooldown(player, self:GetAttackAnimationDuration(attackType))
    
    return didHit, impactPoint, target
    
end

function Gore:IsAffectedBySilence()
    return false
end