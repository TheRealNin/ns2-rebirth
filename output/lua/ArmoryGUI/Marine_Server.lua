
function Marine:DropAllWeapons()

    --local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
    
        local weapon = weaponList[w]
        
        if weapon:isa("GrenadeThrower") then
            weapon:DropItLikeItsHot( self )
			if weapon.grenadesLeft > 0 then
				self.grenadesLeft = weapon.grenadesLeft
				self.grenadeType = weapon.kMapName
			end			
        elseif weapon:GetIsDroppable() and 
            LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 and
            not weapon:isa("Rifle") and
            not weapon:isa("Axe") and
            not weapon:isa("Pistol") then
            self:Drop(weapon, true, true)
        end
        
    end
    
end