 
function GUIHiveStatus:Reset()
    
    self.statusSlots = {}
    self.statusSlots[1] = { _isEmpty = true, _locationId = 0 }
    self.statusSlots[2] = { _isEmpty = true, _locationId = 0 }
    self.statusSlots[3] = { _isEmpty = true, _locationId = 0 }
    self.statusSlots[4] = { _isEmpty = true, _locationId = 0 }
    self.statusSlots[5] = { _isEmpty = true, _locationId = 0 }
    
    self.nextUpdateTime = 0
    self.nextDataUpdateTime = 0
    
    self.teamInfoEnt = nil --ensure valid per-round ent ref
    self.validLocations = {}
    
    local techPoints = GetEntitiesMatchAnyTypes( { "TechPoint" } )
    if techPoints then
        for _, techPoint in ipairs(techPoints) do
            table.insert( self.validLocations, techPoint.locationId )
        end
    end
    
    local localPlayer = Client.GetLocalPlayer()
    self.teamInfoEnt = GetTeamInfoEntity( localPlayer:GetTeamNumber() ) --Data Source
    
end


function GUIHiveStatus:Update( deltaTime ) 
    PROFILE("GUIHiveStatus:Update")
    
    local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    self.background:SetIsVisible( fullMode )
    if not fullMode then
        return
    end
    
    local player = Client.GetLocalPlayer()
    if player then --TODO Spectator, dead checks, etc
        if player:GetBuyMenuIsDisplaying() or player:GetIsMinimapVisible() or PlayerUI_GetIsTechMapVisible() then
            self.background:SetIsVisible( false )
            return
        else
            self.background:SetIsVisible( true ) --faster to just set true, than check
        end
    end
    
    --TODO examine .updateInterval as its used in other elements instead of below
    local time = Shared.GetTime()
    if ( self.nextUpdateTime > 0 and time < self.nextUpdateTime ) or time < 2 then  --skip until update window and ignore first 2 seconds of gametime
        return
    end
    
    --TODO Examine slot-data for InCombat flags, set to "max-interval" while in combat? Or on state changes?
    self.nextUpdateTime = time + GUIHiveStatus.kUpdateRate
    
    --temp-cache locationIds, denotes if slot was created
    local slotLocations = 
    {
        self.statusSlots[1]._locationId,
        self.statusSlots[2]._locationId,
        self.statusSlots[3]._locationId,
        self.statusSlots[4]._locationId,
        self.statusSlots[5]._locationId
    }
    
    for locIdx = 1, #self.validLocations do
        
        local locationId = self.validLocations[locIdx]
        
        if locationId then
            local teamInfoEnt = GetTeamInfoEntity(player:GetTeamNumber())
            if teamInfoEnt then
                local slotData = self.teamInfoEnt:GetLocationSlotData( locationId )
                
                if slotData then
                    
                    local emptySlotData = slotData.hiveFlag == 0 and slotData.eggCount == 0
                    
                    for idx, slotTbl in ipairs(self.statusSlots) do --Top-Down slot update order
                        
                        if not emptySlotData and self.statusSlots[idx]._isEmpty and not table.find( slotLocations, locationId ) then
                            self:CreateStatusContainer( idx, locationId )
                            slotLocations[idx] = locationId
                        end
                        
                        if not self.statusSlots[idx]._isEmpty and self.statusSlots[idx]._locationId == locationId then
                            self:UpdateStatusSlot( idx, slotData )
                        end
                        
                    end
                    
                end
            end
        end
        
    end
    
end