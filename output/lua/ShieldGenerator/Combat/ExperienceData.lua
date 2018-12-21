
local function GiveShield(player)
	player.combatTable.hasShield = true
	player.personalShielded = true
	if player.ActivatePersonalShieldDelayed then
		player:ActivatePersonalShieldDelayed()
	end
	player:UpdateArmorAmount()
end

local upgrade = CombatMarineUpgrade()

upgrade:Initialize(kCombatUpgrades.ShieldGenerator, "shieldgenerator", "Shield Generator", kTechId.ShieldGenerator, GiveShield, kCombatUpgrades.Armor3, 2, kCombatUpgradeTypes.Class, false, 0, { kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.DualMinigunExosuit })

table.insert(UpsList, upgrade)