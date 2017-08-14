
local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.HealingField then
        techId = kTechId.MedPack
    end
    return origGetMaterialXYOffset(techId)
end