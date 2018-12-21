
local oldCombatMarineBuy_GUISortUps = CombatMarineBuy_GUISortUps
function CombatMarineBuy_GUISortUps(upgradeList)

	local shieldUpgrade
	for _, upgrade in ipairs(upgradeList) do
		if upgrade:GetTechId() == kTechId.ShieldGenerator then
			shieldUpgrade = upgrade
			break
		end
	end

	local oldList = oldCombatMarineBuy_GUISortUps(upgradeList)
	
	if shieldUpgrade then
		for index, entry in ipairs(oldList) do
			if entry.GetTechId and entry:GetTechId() == kTechId.Armor3 then
				table.insert(oldList, index+1, shieldUpgrade)
				break
			end
		end
	end
	
	return oldList
	
end

local oldDescFunc = CombatMarineBuy_GetWeaponDescription
function CombatMarineBuy_GetWeaponDescription(techId)
	if techId == kTechId.ShieldGenerator then
		return "Provides extra armor, decreases damage you take from exos and explosives, and also auto-repairs when out of combat. Requires Armor 3."
	end
	return oldDescFunc(techId)
end