
if Client then

local kFriendly = {}
kFriendly[kMinimapBlipTeam.Neutral] = true
kFriendly[kMinimapBlipTeam.Friendly] = true
kFriendly[kMinimapBlipTeam.FriendFriendly] = true
kFriendly[kMinimapBlipTeam.InactiveFriendly] = true

function MinimapMappableMixin.OnSameMinimapBlipTeam(blipTeam)
    return kFriendly[blipTeam]
end

function MinimapMappableMixin.MinimapBlipTeamIsActive(blipTeam)
    return (blipTeam == kMinimapBlipTeam.FriendFriendly or blipTeam == kMinimapBlipTeam.Friendly)
end

function MinimapMappableMixin:GetMapBlipTeamFixed() 
  
    local playerTeam = PlayerUI_GetTeamNumber()
    local blipTeam = kMinimapBlipTeam.Neutral

    local blipTeamNumber = self.GetTeamNumber and self:GetTeamNumber() or kNeutralTeamNumber
    local isSteamFriend = false
    
    local playerTeamNumber = playerTeam
    if (Client.GetLocalClientTeamNumber() == kSpectatorIndex) then
        playerTeamNumber = kTeam1Index
    end
    local enemyTeamNumber = GetEnemyTeamNumber(playerTeam)
    
    if self.clientIndex and self.clientIndex > 0 and blipTeamNumber ~= enemyTeamNumber then

        local steamId = GetSteamIdForClientIndex(self.clientIndex)
        if steamId then
            isSteamFriend = Client.GetIsSteamFriend(steamId)
        end

    end
    
    if self.GetIsActive and not self:GetIsActive() then

        if blipTeamNumber == playerTeamNumber or (Client.GetLocalClientTeamNumber() == kSpectatorIndex and blipTeamNumber == kTeam1Index) then
            blipTeam = kMinimapBlipTeam.InactiveFriendly
        else
            blipTeam = kMinimapBlipTeam.InactiveEnemy
        end

    elseif isSteamFriend then
    
        if blipTeamNumber == playerTeamNumber or (Client.GetLocalClientTeamNumber() == kSpectatorIndex and blipTeamNumber == kTeam1Index) then
            blipTeam = kMinimapBlipTeam.FriendFriendly
        else
            blipTeam = kMinimapBlipTeam.FriendEnemy
        end
    
    else

        if blipTeamNumber == playerTeamNumber or (Client.GetLocalClientTeamNumber() == kSpectatorIndex and blipTeamNumber == kTeam1Index) then
            blipTeam = kMinimapBlipTeam.Friendly
        elseif blipTeamNumber == kNeutralTeamNumber then
            blipTeam = kMinimapBlipTeam.Neutral
        else
            blipTeam = kMinimapBlipTeam.Enemy
        end
        
    end  
    

    return blipTeam
end

-- convinience function to extract info from the data tables
function MinimapMappableMixin:InitMinimapItem(minimap, item)
    minimap:InitMinimapIcon(item, self:GetMapBlipType(), self:GetMapBlipTeamFixed())
    
    item.prevBlipOrigin = nil
    item.prevBlipColor = nil
    
    if self.InitMinimapItemHook then
        self:InitMinimapItemHook(minimap, item)
    end
end

end

