


local oldFunc = GUIAlienBuyMenu._InitializeBackground
function GUIAlienBuyMenu:_InitializeBackground()
	oldFunc(self)
	local wraithPosition = 5
    for k, alienType in ipairs(GUIAlienBuyMenu.kAlienTypes) do
		if alienType.XPos >= wraithPosition then
			alienType.XPos = alienType.XPos + 1
		end
	end
    table.insert(GUIAlienBuyMenu.kAlienTypes, { LocaleName = "Wraith Fade", Name = "WraithFade", Width = GUIScale(188), Height = GUIScale(220), XPos = wraithPosition, Index = kWraithFadeIndex })
end