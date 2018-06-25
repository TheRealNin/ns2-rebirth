
local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.ShieldGeneratorTech or techId == kTechId.ShieldGeneratorTech2 or techId == kTechId.ShieldGeneratorTech3 then
        return 10, 11
    end
    return origGetMaterialXYOffset(techId)
end