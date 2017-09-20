

function Armory:GetItemList(forPlayer)

    local itemList = {
        kTechId.Rifle,
        kTechId.Pistol,
        kTechId.Welder,
        kTechId.LayMines, 
        kTechId.Shotgun,
        kTechId.ClusterGrenade,
        kTechId.GasGrenade,
        kTechId.PulseGrenade
    }
    
    if self:GetTechId() == kTechId.AdvancedArmory then
    
        itemList = {
            kTechId.Rifle,
            kTechId.Pistol,
            kTechId.Welder,
            kTechId.LayMines,
            kTechId.Shotgun,
            kTechId.GrenadeLauncher,
            kTechId.Flamethrower,
            kTechId.HeavyMachineGun,
            kTechId.ClusterGrenade,
            kTechId.GasGrenade,
            kTechId.PulseGrenade,
        }
        
    end
    
    return itemList
    
end

function Armory:GetItemSlotNames()
    return {"Weapon slot 1", "Weapon slot 2", "Weapon slot 3", "Weapon slot 4", "Weapon slot 5"}
end

-- hack because both classes are defined in the same bloody file
AdvancedArmory.GetItemList = Armory.GetItemList
AdvancedArmory.GetItemSlotNames = Armory.GetItemSlotNames