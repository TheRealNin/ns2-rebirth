

local oldInit = GUIAlienBuyMenu.Initialize
function GUIAlienBuyMenu:Initialize()
    oldInit(self)
    GUIAlienBuyMenu.kAlienTypes[1].LocaleName = "Wraith Fade"
end