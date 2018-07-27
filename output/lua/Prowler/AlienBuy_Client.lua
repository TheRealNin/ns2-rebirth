
local indexToAlienTechIdTable = debug.getupvaluex(IndexToAlienTechId, "indexToAlienTechIdTable")

table.insert(indexToAlienTechIdTable, kTechId.Prowler)

kProwlerTechIdIndex = #indexToAlienTechIdTable

local oldAlienBuy_GetClassStats = AlienBuy_GetClassStats
function AlienBuy_GetClassStats(idx)
    local techId = IndexToAlienTechId(idx)

    if techId == kTechId.Prowler then
        return {"Prowler", Prowler.kHealth, Prowler.kArmor, kProwlerCost}
	else
		return oldAlienBuy_GetClassStats(idx)
	end
end


local oldAlienBuy_OnSelectAlien = AlienBuy_OnSelectAlien
function AlienBuy_OnSelectAlien(type)
	if type == "Prowler" then
        type = "Skulk"
    end
    oldAlienBuy_OnSelectAlien(type)

end

