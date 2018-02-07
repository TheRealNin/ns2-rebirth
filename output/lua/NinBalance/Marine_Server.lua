
local oldDropAllWeapons = Marine.DropAllWeapons
function Marine:DropAllWeapons()
    oldDropAllWeapons(self) -- this will drop everything that can be dropped
    
    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
        local weapon = weaponList[w]
        if weapon:GetIsDroppable() and weapon:isa("Rifle") then
        
            local ammopackMapName = weapon:GetAmmoPackMapName()
            
            if ammopackMapName and weapon.ammo ~= 0 then
            
                local ammoPack = CreateEntity(ammopackMapName, weapon:GetOrigin(), weapon:GetTeamNumber())
                ammoPack:SetAmmoPackSize(weapon.ammo)
                weapon.ammo = 0
                
            end
        end
    end
    
end