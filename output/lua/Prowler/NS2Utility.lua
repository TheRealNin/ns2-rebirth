
local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()

    local ClassToGrid = oldBuildClassToGrid()
    
    ClassToGrid["Prowler"] = { 6, 3 }
    
    return ClassToGrid
    
end