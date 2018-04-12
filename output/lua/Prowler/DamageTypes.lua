
local oldInitializeFocusAbilities = InitializeFocusAbilities
function InitializeFocusAbilities()
    oldInitializeFocusAbilities()
    kFocusAbilities[kTechId.Howl] = true
end