function PlayerUI_NeedsCrosshair()    local player = Client.GetLocalPlayer()    return (not player:GetIsThirdPerson() or player:NeedsCrosshairOverride())end function PlayerUI_GetCrosshairY()    local player = Client.GetLocalPlayer()    if player and PlayerUI_NeedsCrosshair() then                local weapon = player:GetActiveWeapon()        if(weapon ~= nil) then                    -- Get class name and use to return index            local index             local mapname = weapon:GetMapName()                        if mapname == Rifle.kMapName or mapname == HeavyMachineGun.kMapName then                index = 0            elseif mapname == Pistol.kMapName then                index = 1            elseif mapname == Shotgun.kMapName then                index = 3            elseif mapname == Minigun.kMapName then                index = 4            elseif mapname == Flamethrower.kMapName or mapname == GrenadeLauncher.kMapName then                index = 5            -- All alien crosshairs are the same for now            elseif mapname == LerkBite.kMapName or mapname == Spores.kMapName or mapname == LerkUmbra.kMapName or mapname == Parasite.kMapName or mapname == BileBomb.kMapName then                index = 6            elseif mapname == SpitSpray.kMapName or mapname == BabblerAbility.kMapName then                index = 7            -- Blanks (with default damage indicator)            else                index = 8            end                    return index * 64                    end            endend--[[ * Get the width of the crosshair image in the atlas, return 0 to hide]]function PlayerUI_GetCrosshairWidth()    local player = Client.GetLocalPlayer()    if player and player:GetActiveWeapon() and PlayerUI_NeedsCrosshair() then        return 64    end        return 0    end--[[ * Get the height of the crosshair image in the atlas, return 0 to hide]]function PlayerUI_GetCrosshairHeight()    local player = Client.GetLocalPlayer()    if player and player:GetActiveWeapon() and PlayerUI_NeedsCrosshair() then        return 64    end        return 0end