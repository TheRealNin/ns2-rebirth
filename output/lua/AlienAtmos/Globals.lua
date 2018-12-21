
if AddModPanel then 
    local kAlienAtmosMaterial = PrecacheAsset("materials/AlienAtmos/alienatmos.material")
    AddModPanel(kAlienAtmosMaterial)
end

kTracerSpeed = 230 -- was 115

debug.appendtoenum(kHitEffectSurface, "organicCarapace")