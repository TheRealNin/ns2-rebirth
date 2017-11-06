
local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.ShieldGeneratorTech or techId == kTechId.ShieldGeneratorTech2 or techId == kTechId.ShieldGeneratorTech3 then
        techId = kTechId.NanoShieldTech
    end
    return origGetMaterialXYOffset(techId)
end