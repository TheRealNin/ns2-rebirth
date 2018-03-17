
local origDropAllWeapons = Marine.DropAllWeapons
function Marine:DropAllWeapons()

    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
    
        local weapon = weaponList[w]
        if weapon:isa("Axe") and weapon.hasWelder then
        
            local newWelder = CreateEntity(Welder.kMapName, self:GetEyePos(), self:GetTeamNumber(), nil, true)
            
            -- need to pretend that the weapon was on someone first
            newWelder.weaponWorldState = false
            newWelder:Dropped(self)
            
        end
        
    end
    
    origDropAllWeapons(self)
    
end