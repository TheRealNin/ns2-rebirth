
local lookup = 
{ 
    "Shotgun", --kEquipmentOutlineColor.Green
    "GrenadeLauncher", --kEquipmentOutlineColor.Fuchsia
    "Flamethrower", --kEquipmentOutlineColor.Yellow
    "HeavyMachineGun", --kEquipmentOutlineColor.Red

}
function EquipmentOutline_UpdateModel(forEntity)

    local player = Client.GetLocalPlayer()

    -- Check if player can pickup this item or if player is a spectator
    local highlightDroppedWeapon = player ~= nil and ((player:GetTeamNumber() == kSpectatorIndex and Client.GetOutlinePlayers()) or (player:isa("MarineCommander")) and forEntity:isa("Weapon") and forEntity.weaponWorldState == true and not GetAreEnemies(forEntity, player))
    
    local visible = (player ~= nil and forEntity:GetIsValidRecipient(player) and not GetAreEnemies(forEntity, player)) or highlightDroppedWeapon
    local model = HasMixin(forEntity, "Model") and forEntity:GetRenderModel() or nil

    if forEntity:isa("WeaponAmmoPack") then
        model = forEntity:GetRenderModel() or nil
        visible = player ~= nil and player:GetActiveWeapon() and player:GetActiveWeapon():isa(forEntity:GetWeaponClassName()) and not GetAreEnemies(forEntity, player)
    end

    local weaponclass = 0
    for i=1,#lookup do
        if forEntity:isa( lookup[i] ) then
            weaponclass = i
            break
        end
    end
    
    -- Update the visibility status.
    if model and visible ~= model.equipmentVisible then    
    
        if visible then
            EquipmentOutline_AddModel(model,weaponclass)
        else
            EquipmentOutline_RemoveModel(model)
        end
        model.equipmentVisible = visible

    end

end