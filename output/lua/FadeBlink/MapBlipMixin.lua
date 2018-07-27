 
local oldGetMapBlipInfo = MapBlipMixin.GetMapBlipInfo
function MapBlipMixin:GetMapBlipInfo()
	local success, blipType, blipTeam, isAttacked, isParasited = oldGetMapBlipInfo(self)
	
	if blipType == kMinimapBlipType.WraithFade then
		blipType = kMinimapBlipType.Fade
	end
	return success, blipType, blipTeam, isAttacked, isParasited
end