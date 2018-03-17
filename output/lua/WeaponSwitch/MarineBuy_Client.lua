
local oldMarineBuy_GetEquipped = MarineBuy_GetEquipped
function MarineBuy_GetEquipped()

    local equipped = oldMarineBuy_GetEquipped()
    
    local player = Client.GetLocalPlayer()
    local items = GetChildEntities(player, "ScriptActor")

    for _, item in ipairs(items) do
    
        local techId = item:GetTechId()
        
        if techId == kTechId.Axe and item.hasWelder then
            table.insertunique(equipped, kTechId.Welder)
        end
        
    end
    
    return equipped

end

local oldMarineBuy_GetEquipment = MarineBuy_GetEquipment
function MarineBuy_GetEquipment()
    
    local inventory = oldMarineBuy_GetEquipment()
    local player = Client.GetLocalPlayer()
    local items = GetChildEntities( player, "ScriptActor" )
    
    for _, item in ipairs(items) do
    
        local techId = item:GetTechId()
        
        if techId == kTechId.Axe and item.hasWelder then
           inventory[kTechId.Welder] = true
        end

    end
    
    return inventory
    
end

-- this isn't called from anywhere...
--[[
local oldMarineBuy_GetEquippedWeapons = MarineBuy_GetEquippedWeapons
function MarineBuy_GetEquippedWeapons()

    local t = oldMarineBuy_GetEquippedWeapons()
    
    local player = Client.GetLocalPlayer()
    local items = GetChildEntities(player, "ScriptActor")

    for _, item in ipairs(items) do
    
        local techId = item:GetTechId()
        
        if techId == kTechId.Axe and item.hasWelder then
        
            local itemName = GetDisplayNameForTechId(kTechId.Welder)
            table.insert(t, itemName)    
            
            local index = TechIdToWeaponIndex(kTechId.Welder)
            table.insert(t, 0)
            table.insert(t, index - 1)
            
        end

    end
    
    return t
    
end
]]--