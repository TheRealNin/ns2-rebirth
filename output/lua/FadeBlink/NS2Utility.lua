
local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()

    local ClassToGrid = oldBuildClassToGrid()
    
    ClassToGrid["WraithFade"] = { 4, 3 } -- same as fade
    
    return ClassToGrid
    
end

local oldGetTexCoordsForTechId = GetTexCoordsForTechId
function GetTexCoordsForTechId(techId)

	if techId == kTechId.WraithTeleport then
		techId = kTechId.Blink
	end
	if techId == kTechId.SwipeTeleport then
		techId = kTechId.Swipe
	end
	if techId == kTechId.StabTeleport then
		techId = kTechId.Stab
	end
	if techId == kTechId.Backtrack then
		techId = kTechId.MetabolizeEnergy
	end
	return oldGetTexCoordsForTechId(techId)
end