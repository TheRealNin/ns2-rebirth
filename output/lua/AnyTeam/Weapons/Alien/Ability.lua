
function Ability:DoAbilityFocusCooldown(player, animationDuration)
    local veilLevel = 0
    if player:GetHasUpgrade( kTechId.Focus ) then
        veilLevel = GetVeilLevel( player:GetTeamNumber() )
        local cooldown = animationDuration * (1 + kFocusAttackSlowAtMax * (veilLevel / 3))
        
        -- factor in effects like enzyme and pulse grenade hits
        local attackPeriodFactor = 1.0
        -- general attack speed modifications by self
        if player.ModifyAttackSpeed then
            local attackSpeedTable = { attackSpeed = attackPeriodFactor }
            player:ModifyAttackSpeed(attackSpeedTable)
            attackPeriodFactor = attackSpeedTable.attackSpeed
        end
        
        -- pulse grenades/overcharge
        if player.electrified then
            attackPeriodFactor = attackPeriodFactor * kElectrifiedAttackSpeed
        end
        
        -- enzyme
        if player:GetIsEnzymed() then
            attackPeriodFactor = attackPeriodFactor * kEnzymeAttackSpeed
        end
        
        self.nextAttackTime = Shared.GetTime() + (cooldown / attackPeriodFactor)
    end
end