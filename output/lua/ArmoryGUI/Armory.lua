

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
    return {
        Locale.ResolveString("BINDINGS_WEAPON_#1"),
        Locale.ResolveString("BINDINGS_WEAPON_#2"),
        Locale.ResolveString("BINDINGS_WEAPON_#3"),
        Locale.ResolveString("BINDINGS_WEAPON_#4"),
        Locale.ResolveString("BINDINGS_WEAPON_#5")
    }
end

-- hack because both classes are defined in the same bloody file
AdvancedArmory.GetItemList = Armory.GetItemList
AdvancedArmory.GetItemSlotNames = Armory.GetItemSlotNames