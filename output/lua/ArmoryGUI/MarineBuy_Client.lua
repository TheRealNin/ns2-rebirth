
function MarineBuy_GetEquipment()
    
    local inventory = {}
    local player = Client.GetLocalPlayer()
    local items = GetChildEntities( player, "ScriptActor" )
    
    for index, item in ipairs(items) do
    
        local techId = item:GetTechId()
        
        --if techId ~= kTechId.Pistol and techId ~= kTechId.Axe and techId ~= kTechId.Rifle then
        --can't buy above, so skip
            
            local itemName = GetDisplayNameForTechId(techId)    --simple validity check
            if itemName then
                inventory[techId] = true
            end
            
            if MarineBuy_GetHasGrenades( techId ) then
                inventory[kTechId.ClusterGrenade] = true
                inventory[kTechId.GasGrenade] = true
                inventory[kTechId.PulseGrenade] = true
            end
            
        --end

    end
    
    if player:isa("JetpackMarine") then
        inventory[kTechId.Jetpack] = true
    --elseif player:isa("Exo") then
        --Exo's are inheriently handled by how the BuyMenus are organized
    end
    
    return inventory
    
end


function MarineBuy_GetEquippedWeapons()

    local t = {}
    
    local player = Client.GetLocalPlayer()
    local items = GetChildEntities(player, "ScriptActor")

    for index, item in ipairs(items) do
    
        local techId = item:GetTechId()
        
        --if techId ~= kTechId.Pistol and techId ~= kTechId.Axe then
        
            local itemName = GetDisplayNameForTechId(techId)
            table.insert(t, itemName)    
            
            local index = TechIdToWeaponIndex(techId)
            table.insert(t, 0)
            table.insert(t, index - 1)
            
        --end

    end
    
    return t
    
end


-- called by GUIMarineBuyMenu
function MarineBuy_IsResearching(techId)

    local progress = GetTechTree():GetResearchProgressForNode(techId)
    
    if progress > 0 and progress < 1 then
        return true
    end
    
    return false
end
