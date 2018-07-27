
local indexToAlienTechIdTable = debug.getupvaluex(IndexToAlienTechId, "indexToAlienTechIdTable")

table.insert(indexToAlienTechIdTable, kTechId.WraithFade)

kWraithFadeIndex = #indexToAlienTechIdTable


local oldAlienBuy_GetClassStats = AlienBuy_GetClassStats
function AlienBuy_GetClassStats(idx)
    local techId = IndexToAlienTechId(idx)

    if techId == kTechId.WraithFade then
        return {"WraithFade", kWraithFadeHealth, kWraithFadeArmor, kFadeCost}
	else
		return oldAlienBuy_GetClassStats(idx)
	end
end


local oldAlienBuy_OnSelectAlien = AlienBuy_OnSelectAlien
function AlienBuy_OnSelectAlien(type)
	if type == "WraithFade" then
        type = "Fade"
    end
    oldAlienBuy_OnSelectAlien(type)

end

