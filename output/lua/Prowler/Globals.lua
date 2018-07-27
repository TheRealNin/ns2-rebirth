

if AddModPanel then 
    local kProwlerMaterial = PrecacheAsset("materials/prowler/prowler.material")
    AddModPanel(kProwlerMaterial)
end

debug.appendtoenum(kPlayerStatus, "Prowler")
debug.appendtoenum(kPlayerStatus, "ProwlerEgg")

debug.appendtoenum(kMinimapBlipType, "Prowler")

