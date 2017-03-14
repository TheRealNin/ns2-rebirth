local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()
    -- sentry battery is 
    -- ClassToGrid["SentryBattery"] = { 8, 4 }
    ClassToGrid["HadesDevice"] = { 8, 4 }
    return ClassToGrid
end



-- All damage is routed through here.
local oldCanEntityDoDamageTo = CanEntityDoDamageTo
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
    if not GetGameInfoEntity():GetGameStarted() and not GetGameInfoEntity():GetWarmUpActive() then
        return false
    end
    if not target:GetCanTakeDamage() then
        return false
    end
   -- Hades device cares not for your friends
    if attacker ~= nil and attacker:isa("HadesDevice") then
        return true
    end
    return oldCanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
end