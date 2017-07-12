
function MapBlip:GetMapBlipTeam() -- minimap isn't used
  
    local playerTeam = PlayerUI_GetTeamNumber()
    local blipTeam = kMinimapBlipTeam.Neutral

    local blipTeamNumber = self:GetTeamNumber()
    local isSteamFriend = false
    
    local playerTeamNumber = playerTeam
    local enemyTeamNumber = GetEnemyTeamNumber(playerTeam)
    
    if self.clientIndex and self.clientIndex > 0 and blipTeamNumber ~= enemyTeamNumber then

        local steamId = GetSteamIdForClientIndex(self.clientIndex)
        if steamId then
            isSteamFriend = Client.GetIsSteamFriend(steamId)
        end

    end
    
    if not self:GetIsActive() then

        if blipTeamNumber == playerTeamNumber then
            blipTeam = kMinimapBlipTeam.InactiveFriendly
        else
            blipTeam = kMinimapBlipTeam.InactiveEnemy
        end

    elseif isSteamFriend then
    
        if blipTeamNumber == playerTeamNumber then
            blipTeam = kMinimapBlipTeam.FriendFriendly
        else
            blipTeam = kMinimapBlipTeam.FriendEnemy
        end
    
    else

        if blipTeamNumber == playerTeamNumber then
            blipTeam = kMinimapBlipTeam.Friendly
        elseif blipTeamNumber == kNeutralTeamNumber then
            blipTeam = kMinimapBlipTeam.Neutral
        else
            blipTeam = kMinimapBlipTeam.Enemy
        end
        
    end  
    

    return blipTeam
end
local actualGetMapBlipTeam = MapBlip.GetMapBlipTeam


if Client then

    local kFriendly = {}
    kFriendly[kMinimapBlipTeam.Friendly] = true
    kFriendly[kMinimapBlipTeam.FriendFriendly] = true
    kFriendly[kMinimapBlipTeam.InactiveFriendly] = true
    kFriendly[kMinimapBlipTeam.Neutral] = true

    local function IsFriendly(blipTeam)
        return kFriendly[blipTeam] == true
    end

    local blipRotation = Vector(0,0,0)
    function MapBlip:UpdateMinimapItemHook(minimap, item)

        PROFILE("MapBlip:UpdateMinimapItemHook")

        local rotation = self:GetRotation()
        if rotation ~= item.prevRotation then
            item.prevRotation = rotation
            blipRotation.z = rotation
            item:SetRotation(blipRotation)
        end
        local blipTeam = actualGetMapBlipTeam(self, minimap)
        local blipColor = item.blipColor
        
        if IsFriendly(blipTeam) then

            self:UpdateHook(minimap, item)
            
            if self.isHallucination then
                blipColor = kHallucinationColor
            elseif self.isInCombat then
                if self.MinimapBlipTeamIsActive(blipTeam) then
                    blipColor = self.PulseRed(1.0)
                else
                    blipColor = self.PulseDarkRed(blipColor)
                end
            end  
        end
        self.currentMapBlipColor = blipColor

    end
    PlayerMapBlip.UpdateMinimapItemHook = MapBlip.UpdateMinimapItemHook
    
    -- override NS2+ function
    function MapBlip:GetMapBlipColor(minimap, item)
        --Log("MapBlip:GetMapBlipColor")
        return self.currentMapBlipColor or Color()
    end
    function PlayerMapBlip:GetMapBlipColor(minimap, item)
        --Log("PlayerMapBlip:GetMapBlipColor")
        return self.currentMapBlipColor or Color()
    end
    
    
    -- players can show their names on the minimap
    function PlayerMapBlip:UpdateHook(minimap, item)
        minimap:DrawMinimapName(item, actualGetMapBlipTeam(self, minimap), self.clientIndex, self.isParasited)
    end
end


local oldUpdateRelevancy = MapBlip.UpdateRelevancy
function MapBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    local mask = 0

    if self.mapBlipType == kMinimapBlipType.PowerPoint and GetGamerules():GetTeam(1):GetTeamType() == kMarineTeamType then
        mask = bit.bor(mask, kRelevantToTeam1)
    end
    if self.mapBlipType == kMinimapBlipType.PowerPoint and GetGamerules():GetTeam(2):GetTeamType() == kMarineTeamType then
        mask = bit.bor(mask, kRelevantToTeam2)
    end
    if self.mapBlipTeam == kTeam1Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
        mask = bit.bor(mask, kRelevantToTeam1)
    end
    if self.mapBlipTeam == kTeam2Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
        mask = bit.bor(mask, kRelevantToTeam2)
    end
    
    self:SetExcludeRelevancyMask( mask )

end