
local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.ShieldGeneratorTech then
        techId = kTechId.NanoShieldTech
    end
    return origGetMaterialXYOffset(techId)
end