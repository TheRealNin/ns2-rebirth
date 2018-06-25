
function WeaponAmmoPack:GetIsValidRecipient(recipient)
    return false
end

RifleAmmo.GetIsValidRecipient =  WeaponAmmoPack.GetIsValidRecipient
ShotgunAmmo.GetIsValidRecipient =  WeaponAmmoPack.GetIsValidRecipient
FlamethrowerAmmo.GetIsValidRecipient =  WeaponAmmoPack.GetIsValidRecipient
GrenadeLauncherAmmo.GetIsValidRecipient =  WeaponAmmoPack.GetIsValidRecipient
HeavyMachineGunAmmo.GetIsValidRecipient =  WeaponAmmoPack.GetIsValidRecipient



function WeaponAmmoPack:GetIsValidForAmmo(recipient)
	local correctWeaponType
    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then
        
            correctWeaponType = child and child:isa(self:GetWeaponClassName())
            if correctWeaponType then
                break
            end
        end
    end
    return self.ammoPackSize ~= nil and correctWeaponType
    
end


RifleAmmo.GetIsValidForAmmo =  WeaponAmmoPack.GetIsValidForAmmo
ShotgunAmmo.GetIsValidForAmmo =  WeaponAmmoPack.GetIsValidForAmmo
FlamethrowerAmmo.GetIsValidForAmmo =  WeaponAmmoPack.GetIsValidForAmmo
GrenadeLauncherAmmo.GetIsValidForAmmo =  WeaponAmmoPack.GetIsValidForAmmo
HeavyMachineGunAmmo.GetIsValidForAmmo =  WeaponAmmoPack.GetIsValidForAmmo



function WeaponAmmoPack:OnGiveAmmo(recipient)
    
    local consumedSome = false
    local consumedAll = false
    
    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa(self:GetWeaponClassName()) and child:GetNeedsAmmo(false) then
        
            local missing = child:GetMaxAmmo() - child:GetAmmo()
            child:GiveReserveAmmo(self.ammoPackSize, false)
            self.ammoPackSize = self.ammoPackSize - missing
            consumedSome = true
            if self.ammoPackSize <= 0 then
                consumedAll = true
                break
            end
        end
        
    end  
    
    if consumedSome then
        StartSoundEffectAtOrigin(AmmoPack.kPickupSound, recipient:GetOrigin())
    end
    
    return consumedAll
end

RifleAmmo.OnGiveAmmo =  WeaponAmmoPack.OnGiveAmmo
ShotgunAmmo.OnGiveAmmo =  WeaponAmmoPack.OnGiveAmmo
FlamethrowerAmmo.OnGiveAmmo =  WeaponAmmoPack.OnGiveAmmo
GrenadeLauncherAmmo.OnGiveAmmo =  WeaponAmmoPack.OnGiveAmmo
HeavyMachineGunAmmo.OnGiveAmmo =  WeaponAmmoPack.OnGiveAmmo

