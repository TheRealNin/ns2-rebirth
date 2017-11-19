
if Server then

    function EMPBlast:Perform()

        StartSoundEffectAtOrigin(self.kBlastSound, self:GetOrigin())

        for _, player in ipairs(GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kPowerSurgeDamageRadius)) do
            self:DoDamage(kPowerSurgeDamage, player, player:GetOrigin(), GetNormalizedVector(player:GetOrigin() - self:GetOrigin()), "none")
            if GetAreEnemies(player, self) and player.SetElectrified then
                player:SetElectrified(kPowerSurgeElectrifiedDuration)
            end
            player:TriggerEffects("emp_blasted")
        end

    end

end