

local oldMarineBuy_GetWeaponDescription = MarineBuy_GetWeaponDescription
function MarineBuy_GetWeaponDescription(techId)
    if techId ~= kTechId.ShieldGenerator then
        return oldMarineBuy_GetWeaponDescription(techId)
    end
    
    local description = "Replace your armor with an auto-recharging, 95% effective energy shield, giving you extra armor. Additionally, it has 30% resistance against Railgun, Minigun, and Grenade Launcher damage."

    local techTree = GetTechTree()
        
    if techTree then

        local level3Node = techTree:GetTechNode(kTechId.ShieldGeneratorTech3)
        local level2Node = techTree:GetTechNode(kTechId.ShieldGeneratorTech2)
        local level1Node = techTree:GetTechNode(kTechId.ShieldGeneratorTech)

        if level3Node and level3Node:GetResearched() then
            description =  "(level 3) " .. description
        elseif level2Node and level2Node:GetResearched() then
            description =  "(level 2) " .. description
        elseif level1Node and level1Node:GetResearched() then
            description =  "(level 1) " .. description
        end
        
    end
    
    local requieres = techTree:GetRequiresText(techId)

    if requieres ~= "" then
        description = string.format(Locale.ResolveString("WEAPON_DESC_REQUIREMENTS"), requieres:lower(), description)
    end

    
    return description
    
end


local oldMarineBuy_GetEquipment = MarineBuy_GetEquipment
function MarineBuy_GetEquipment()
    
    local inventory = oldMarineBuy_GetEquipment()
    
    local player = Client.GetLocalPlayer()
    if player and player.GetIsPersonalShielded and player:GetIsPersonalShielded() then
        inventory[kTechId.ShieldGenerator] = true
    end
    
    return inventory
    
end

local oldMarineBuy_GetEquipped = MarineBuy_GetEquipped
function MarineBuy_GetEquipped()

    local equipped = oldMarineBuy_GetEquipped()
    
    local player = Client.GetLocalPlayer()

    
    if player.GetIsPersonalShielded and player:GetIsPersonalShielded() then
        table.insertunique(equipped, kTechId.ShieldGenerator)
    end    
    
    return equipped

end