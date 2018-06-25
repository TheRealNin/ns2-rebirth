Marine.kPickupWeaponTimeLimit = 2 -- was 1
Marine.kUseWeaponPickupTimeLimit = 0.2 -- was 1
Marine.kFindWeaponRange = 1.5 -- was 2
Marine.kPickupWeaponRange = 2.5


-- add last drop and last use to network
local networkVars =
{      
    _lastDropPressed = "private compensated boolean",
    _lastUsedPressed = "private compensated boolean"
}
Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)


local function PickupWeapon(self, weapon, wasAutoPickup)
    
    -- some weapons completely replace other weapons (welder > axe).
    -- find the weapon that is about to be dropped to make room for this one
    local replacedActiveWeapon = false
    local replacement = weapon.GetReplacementWeaponMapName and weapon:GetReplacementWeaponMapName()
    local obsoleteWep = replacement and self:GetWeapon(replacement)
    
    if obsoleteWep then
        -- TODO: Make welders figure out if the axe is actually a welder?
        if obsoleteWep:isa("Axe") and obsoleteWep.hasWelder then
            if not wasAutoPickup then
                obsoleteWep:SwitchToWelder(self)
                self:SetHUDSlotActive(weapon:GetHUDSlot())
            end
            obsoleteWep = nil
            return
        else
            replacedActiveWeapon = (self:GetActiveWeapon() == obsoleteWep)
            self:RemoveWeapon(obsoleteWep)
            DestroyEntity(obsoleteWep)
        end
    end
    
    local slot = weapon:GetHUDSlot()
    local oldWep = self:GetWeaponInHUDSlot(slot)
    
    -- perform the actual weapon pickup (also drops weapon in the slot)
    self:AddWeapon(weapon, false) -- not wasAutoPickup
    StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())
    
    -- switch to the active weapon if the player deliberately (non-automatically) picked up the weapon,
    -- or if the weapon they were picking up automatically replaced the currently held weapon
    -- or if we recently dropped a weapon (maybe to pick up this one?) so you can "juggle" weapons
    if (not wasAutoPickup or replacedActiveWeapon or (Shared.GetTime() < self.timeOfLastPickUpWeapon + Marine.kPickupWeaponTimeLimit)) 
        and weapon:GetHUDSlot() == 1 then
        self:SetHUDSlotActive(weapon:GetHUDSlot())
    end
    
    self.timeOfLastPickUpWeapon = Shared.GetTime()
    self.lastDroppedWeapon = oldWep
    
end

function Marine:HandleButtons(input)

    PROFILE("Marine:HandleButtons")
    
    Player.HandleButtons(self, input)
    
    if self:GetCanControl() then
    
        -- Update sprinting state
        self:UpdateSprintingState(input)
        
        local flashlightPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
        if not self.flashlightLastFrame and flashlightPressed then
        
            self:SetFlashlightOn(not self:GetFlashlightOn())
            StartSoundEffectOnEntity(Marine.kFlashlightSoundName, self, 1, self)
            
        end
        self.flashlightLastFrame = flashlightPressed
        
        if Server then
        
            local dropPressed = bit.band(input.commands, Move.Drop) ~= 0
            local usePressed = bit.band(input.commands, Move.Use) ~= 0
            
            
            if usePressed ~= self._lastUsedPressed and (Shared.GetTime() > self.timeOfLastPickUpWeapon + Marine.kUseWeaponPickupTimeLimit) then
                local weapon = self:GetNearbyPickupableWeapon()
                if weapon then
                    self.timeOfLastPickUpWeapon = Shared.GetTime()
                    PickupWeapon(self, weapon, false)
                end
            elseif dropPressed ~= self._lastDropPressed then
                
                -- drop the active weapon.
                local activeWeapon = self:GetActiveWeapon()
                if self:Drop() then
                    self.lastDroppedWeapon = activeWeapon
                    self.timeOfLastPickUpWeapon = Shared.GetTime()
                end
                
            end
            self._lastDropPressed = dropPressed
            self._lastUsedPressed = usePressed
            
            -- search for weapons to auto-pickup nearby.
            -- this is actually ONLY an NS2+ setting
            local autopickupWeapon = self:FindNearbyAutoPickupWeapon()
            if autopickupWeapon then
                -- yes, it was an autopickup, and we might not want to switch to it
                if (Shared.GetTime() > self.timeOfLastPickUpWeapon + Marine.kPickupWeaponTimeLimit) then
                    PickupWeapon(self, autopickupWeapon, true)
                else
                    PickupWeapon(self, autopickupWeapon, false)
                end
            end
                
            
            
        end
    end
end