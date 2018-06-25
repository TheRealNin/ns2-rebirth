
local oldDropAllWeapons = Marine.DropAllWeapons
function Marine:DropAllWeapons()
    
    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
        local weapon = weaponList[w]
        if weapon:GetIsDroppable() and weapon:isa("Rifle") then
        
            local ammopackMapName = weapon:GetAmmoPackMapName()
            
            if ammopackMapName and weapon.ammo ~= 0 then
            
                local ammoPack = CreateEntity(ammopackMapName, self:GetOrigin()+Vector(0,0.5,0), weapon:GetTeamNumber())
                ammoPack:SetAmmoPackSize(weapon.ammo)
                weapon.ammo = 0
                
            end
        end
    end
    
    oldDropAllWeapons(self) -- this will drop everything that can be dropped
end

-- cat packs now act as health packs
local oldApplyCatPack = Marine.ApplyCatPack
function Marine:ApplyCatPack()
    oldApplyCatPack(self)
    
    self:AddHealth(MedPack.kHealth, false, true)
    self:AddRegeneration()
    self.timeLastMedpack = Shared.GetTime()
    StartSoundEffectAtOrigin(MedPack.kHealthSound, self:GetOrigin())

end