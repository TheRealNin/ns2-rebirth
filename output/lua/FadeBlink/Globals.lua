
if AddModPanel then 
    local kFadeBlinkMaterial = PrecacheAsset("materials/FadeBlink/fadeblink.material")
    AddModPanel(kFadeBlinkMaterial)
end

debug.appendtoenum(kPlayerStatus, "WraithFade")
debug.appendtoenum(kPlayerStatus, "WraithFadeEgg")


-- This then gets corrected to fade
debug.appendtoenum(kMinimapBlipType, "WraithFade")