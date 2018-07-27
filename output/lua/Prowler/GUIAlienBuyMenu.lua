

local oldFunc = GUIAlienBuyMenu._InitializeBackground
function GUIAlienBuyMenu:_InitializeBackground()
	oldFunc(self)
	local xpos = 3
    for k, alienType in ipairs(GUIAlienBuyMenu.kAlienTypes) do
		if alienType.XPos >= xpos then
			alienType.XPos = alienType.XPos + 1
		end
	end
    table.insert(GUIAlienBuyMenu.kAlienTypes, { LocaleName = "Prowler", Name = "Prowler", Width = GUIScale(240), Height = GUIScale(170), XPos = xpos, Index = kProwlerTechIdIndex })
end