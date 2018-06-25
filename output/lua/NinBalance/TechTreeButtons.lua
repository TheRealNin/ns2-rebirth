
local oldGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.Silence then
        techId = kTechId.Sneak
    end
    return oldGetMaterialXYOffset(techId)
end