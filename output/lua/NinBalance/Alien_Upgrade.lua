
--local HasUpgrade = debug.getupvaluex(GetHasSilenceUpgrade, "HasUpgrade")

local function HasUpgrade(callingEntity, techId)

    if not callingEntity then
        return false
    end

    local techtree = GetTechTree(callingEntity:GetTeamNumber())

    if techtree then
        return callingEntity:GetHasUpgrade(techId) -- and techtree:GetIsTechAvailable(techId)
    else
        return false
    end

end

function GetHasSilenceUpgrade(callingEntity)
    return HasUpgrade(callingEntity, kTechId.Silence)
end