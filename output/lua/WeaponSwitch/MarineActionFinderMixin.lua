-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MarineActionFinderMixin.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kIconUpdateRate = 0.25
local kConeTolerance = math.cos(22.5 * (math.pi / 180.0))

MarineActionFinderMixin = CreateMixin( MarineActionFinderMixin )
MarineActionFinderMixin.type = "MarineActionFinder"

MarineActionFinderMixin.expectedCallbacks = 
{
    GetOrigin = "Returns the position of the Entity in world space"
}

-- Returns an unsorted table of all the nearby weapons that can be picked up.
local function GetAllNearbyPickupableWeapons(self, usePickupRange, canPickupLastDropped)
    
    local pos = self:GetOrigin()
    local range = usePickupRange and Marine.kPickupWeaponRange or Marine.kFindWeaponRange
    
    -- add a little bit to the range so we can check against a slightly offset origin that's more representative of the
    -- model's center.
    local pickupables = GetEntitiesWithMixinWithinRange("Pickupable", pos, range + 1.0)
    local filtered = {}
    local rangeSq = (range * range)
    
    for i=1, #pickupables do
        local wep = pickupables[i]
        local wepOrigin = pickupables[i].GetPickupOrigin and pickupables[i]:GetPickupOrigin() or pickupables[i]:GetOrigin()
        local distSq = (wepOrigin - self:GetOrigin()):GetLengthSquared()
        if wep and wep:isa("Weapon") and not wep:GetIsDestroyed() and wep:GetIsValidRecipient(self)
            and (canPickupLastDropped or (self.lastDroppedWeapon ~= pickupables[i] or (self.lastDroppedWeapon == pickupables[i] and Shared.GetTime() > self.timeOfLastPickUpWeapon + Marine.kPickupWeaponTimeLimit))) and distSq <= rangeSq then
            filtered[#filtered+1] = wep
        end
    end
    
    return filtered
    
end

-- Out of all the weapons in the weaponTable passed to it, pick the one closest to the middle of
-- the viewer's screen, but restricting ourselves to a kConeTolerance radians cone, from the
-- player's eye.
local function GetWeaponClosestToViewCenter(self, weaponTable)
    
    local coords = self:GetViewAngles():GetCoords()
    local closest
    local closestDot = 0
    
    for i=1, #weaponTable do
        local toWeaponVec = (weaponTable[i]:GetOrigin() - self:GetEyePos()):GetUnit()
        local dot = coords.zAxis:DotProduct(toWeaponVec)
        if dot >= kConeTolerance then
            if not closest then
                closest = weaponTable[i]
                closestDot = dot
            else
                if closestDot < dot then
                    closest = weaponTable[i]
                    closestDot = dot
                end
            end
        end
    end
    
    return closest
    
end

-- Returns nil if table is empty, otherwise returns the closest weapon to the player.
local function GetWeaponClosestToPlayer(self, weaponTable)
    
    local closest, closestDist
    
    for i = 1, #weaponTable do
        local distSq = (self:GetOrigin() - weaponTable[i]:GetOrigin()):GetLengthSquared()
        if not closest or distSq < closestDist then
            closest = weaponTable[i]
            closestDist = distSq
        end
    end
    
    return closest
    
end

local function GetWeaponPriority(weapon)
    
    if not weapon then
        return 0
    end
    
    return Marine.kPickupPriority[weapon:GetTechId()] or 0
    
end

local function GetPrimaryWeaponPriority(self)
    
    local primary = self:GetWeaponInHUDSlot(1)
    return GetWeaponPriority(primary)
    
end

-- Returns a copy of the weaponTable with only weapons that can be auto picked up.
local function GetAutoPickupables(self, weaponTable)
    
    local filtered = {}
    for i=1, #weaponTable do
        local wep = weaponTable[i]
        local slot = wep:GetHUDSlot()
        local weaponInSlot = self:GetWeaponInHUDSlot(slot)
        if (not weaponInSlot) or (weaponInSlot:isa("Axe") and not weaponInSlot.hasWelder) then
            filtered[#filtered+1] = wep
        end
    end
    
    return filtered
    
end

-- Gets the highest priority pickupable in the table.  If there is a priority tie, the closest
-- weapon takes precedence (and the active weapon is given 0 distance, so it will never be dropped
-- in favor of an equal-priority weapon).
local function GetHighestPriorityPickupable(self, weaponTable)
    
    local currentBestPriority = GetPrimaryWeaponPriority(self)
    local best
    local bestDistSq = 0
    for i = 1, #weaponTable do
        local weaponPriority = GetWeaponPriority(weaponTable[i])
        local distSq = (self:GetOrigin() - weaponTable[i]:GetOrigin()):GetLengthSquared()
        if weaponPriority > currentBestPriority then
            currentBestPriority = weaponPriority
            best = weaponTable[i]
            bestDistSq = distSq
        elseif weaponPriority == currentBestPriority and distSq < bestDistSq then
            bestDistSq = distSq
            best = weaponTable[i]
        end
    end
    
    return best
    
end

function MarineActionFinderMixin:__initmixin()
    
    if Client and Client.GetLocalPlayer() == self then
        
        self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
        self.actionIconGUI:SetColor(kMarineFontColor)
        self.lastMarineActionFindTime = 0
        
    end
    
end

function MarineActionFinderMixin:OnDestroy()
    
    if Client and self.actionIconGUI then
        
        GetGUIManager():DestroyGUIScript(self.actionIconGUI)
        self.actionIconGUI = nil
        
    end
    
end

-- Searches near the player for weapons that it can automatically pick up.  Returns the closest
-- weapon entity if found, otherwise nil.
function MarineActionFinderMixin:FindNearbyAutoPickupWeapon()
    
    local autoPickupBetter = self.ShouldAutopickupBetterWeapons and self:ShouldAutopickupBetterWeapons()
    
    -- attempt to pickup higher-priority primary weapons (eg slot-1 weapons).
    if autoPickupBetter then
        local bestNearby = GetHighestPriorityPickupable(self, GetAllNearbyPickupableWeapons(self))
        if bestNearby then
            return bestNearby
        end
    end
    
    -- either we do not desire to auto-pickup better, or we were unable to find one better.
    -- Do regular autopickup now.
    return GetWeaponClosestToPlayer(self, GetAutoPickupables(self, GetAllNearbyPickupableWeapons(self)))
    
end

-- Searches for pickupable weapons near the player.  Returns the closest one, or nil if none
-- are found.
function MarineActionFinderMixin:GetNearbyPickupableWeapon()
    
    local weapons = GetAllNearbyPickupableWeapons(self, true, true)
    local bestWeapon = GetWeaponClosestToViewCenter(self, weapons)
    return bestWeapon
    
end

if Client then
    
    function MarineActionFinderMixin:OnProcessMove()
        
        PROFILE("MarineActionFinderMixin:OnProcessMove")
        
        local prediction = Shared.GetIsRunningPrediction()
        if prediction then
            return
        end
        
        local now = Shared.GetTime()
        local enoughTimePassed = (now - self.lastMarineActionFindTime) >= kIconUpdateRate
        if not enoughTimePassed then
            return
        end
        
        self.lastMarineActionFindTime = now
        
        local success = false
        
        local gameStarted = self:GetGameStarted()
        
        if self:GetIsAlive() then
            local manualPickupWeapon = self:GetNearbyPickupableWeapon()
            if gameStarted and manualPickupWeapon then
                self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), manualPickupWeapon:GetClassName(), nil)
                success = true
            else
                
                local ent = self:PerformUseTrace()
                if ent and (gameStarted or (ent.GetUseAllowedBeforeGameStart and ent:GetUseAllowedBeforeGameStart())) then
                    
                    if GetPlayerCanUseEntity(self, ent) and not self:GetIsUsing() then
                        
                        local hintText
                        if ent:isa("CommandStation") and ent:GetIsBuilt() then
                            hintText = gameStarted and "START_COMMANDING" or "START_GAME"
                        end
                        
                        self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, hintText, nil)
                        success = true
                        
                    end
                    
                end
                
            end
        end
        
        if not success then
            self.actionIconGUI:Hide()
        end
        
    end
    
end


