-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\HowlMixin.lua
--
--    Created by:   Adam
--

HowlMixin = CreateMixin( HowlMixin )
HowlMixin.type = "Leap"

-- GetHasSecondary and GetSecondaryEnergyCost should completely override any existing
-- same named function defined in the object.
HowlMixin.overrideFunctions =
{
    "GetHasSecondary",
    "GetSecondaryEnergyCost",
    "PerformSecondaryAttack"
}

function HowlMixin:GetHasSecondary(player)
    
    return GetHasTech(player, kTechId.ShiftHive, true) or GetHasTech(player, kTechId.ShadeHive, true) or GetHasTech(player, kTechId.CragHive, true)
end

function HowlMixin:GetSecondaryEnergyCost(player)
    return kHowlEnergyCost
end

function HowlMixin:PerformSecondaryAttack(player)

    local parent = self:GetParent()
    
    if parent and self:GetHasSecondary(player) and not player:GetSecondaryAttackLastFrame() and player.OnHowl then
    
    --if self.timeOfLastHowl + Prowler.kHowlCooldown < Shared.GetTime() and not self:GetSecondaryAttackLastFrame() then
        --self.timeOfLastHowl = Shared.GetTime()
    
        player:OnHowl()
        player:TriggerEffects("howl")
        return true
        
    end
    
    return false
    
end