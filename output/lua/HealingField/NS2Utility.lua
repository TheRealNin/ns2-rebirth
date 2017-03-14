local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()
    -- sentry battery is 
    -- ClassToGrid["SentryBattery"] = { 8, 4 }
    ClassToGrid["HealingField"] = { 8, 4 }
    return ClassToGrid
end

