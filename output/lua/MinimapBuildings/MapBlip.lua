
local spottedColor = Color(250/255, 250/255, 250/255, 1)

local networkVars =
{
    spotted = "boolean"
}
function MapBlip:GetIsSighted()

    local owner = Shared.GetEntity(self.ownerEntityId)
    
    if owner then
    
        if owner.GetTeamNumber and owner:GetTeamNumber() == kTeamReadyRoom and owner:GetAttached() then
            owner = owner:GetAttached()
        end
        
        return HasMixin(owner, "LOS") and owner:GetIsSpotted() or false
        
    end
    
    return false
    
end


-- Called (server side) when a mapblips owner has changed its map-blip dependent state
local oldUpdate = MapBlip.Update
function MapBlip:Update()
    oldUpdate(self)
    

    if self.ownerEntityId and Shared.GetEntity(self.ownerEntityId) then
        local owner = Shared.GetEntity(self.ownerEntityId)
        
        self.spotted = (HasMixin(owner, "LOS") and owner:GetIsSpotted() and not owner:GetIsSighted())
    end
end

if Client then

    if kAnyTeamEnabled then
        local kFriendly = {}
        kFriendly[kMinimapBlipTeam.Friendly] = true
        kFriendly[kMinimapBlipTeam.FriendFriendly] = true
        kFriendly[kMinimapBlipTeam.InactiveFriendly] = true
        kFriendly[kMinimapBlipTeam.Neutral] = true

        function IsAnyTeamFriendly(blipTeam)
            return kFriendly[blipTeam] == true
        end
    end
    
    local oldUpdateMinimapItemHook = MapBlip.UpdateMinimapItemHook
    function MapBlip:UpdateMinimapItemHook(minimap, item)
        oldUpdateMinimapItemHook(self, minimap, item)
        
        local blipTeam = self:GetMapBlipTeam(minimap)
        
        if self.spotted and not minimap.spectating and 
           ((not kAnyTeamEnabled and not self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam)) or
            (kAnyTeamEnabled and not IsAnyTeamFriendly(blipTeam))) then
            self.currentMapBlipColor =  Color(spottedColor.r, spottedColor.g, spottedColor.b, self.currentMapBlipColor.a)
        end

    end
end

Shared.LinkClassToMap("MapBlip", MapBlip.kMapName, networkVars)