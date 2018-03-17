

local function AppendToEnum( tbl, key )
	if rawget(tbl,key) ~= nil then
		return
	end
	
	local maxVal = 0
    for k, v in next, tbl do
        if type(v) == "number" and v > maxVal then
            maxVal = v 
        end
    end
	
	rawset( tbl, key, maxVal+1 )
	rawset( tbl, maxVal+1, key )
  
  -- incrase max each time...
  kTechIdMax = kTechIdMax + 1
	
end



AppendToEnum(kTechId, "Prowler")
AppendToEnum(kTechId, "ProwlerMenu")
AppendToEnum(kTechId, "ProwlerEgg")
AppendToEnum(kTechId, "HallucinateProwler")
AppendToEnum(kTechId, "UpgradeProwler")
AppendToEnum(kTechId, "Howl")
AppendToEnum(kTechId, "XenocideHowl")