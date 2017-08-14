
local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.HadesDevice then
        techId = kTechId.Construct
    end
    return origGetMaterialXYOffset(techId)
end