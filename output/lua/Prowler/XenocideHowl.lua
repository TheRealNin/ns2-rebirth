
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Prowler/HowlMixin.lua")


class 'XenocideHowl' (XenocideLeap)
XenocideHowl.kMapName = "xenocidehowl"


local networkVars =
{
}

function XenocideHowl:OnCreate()

    Ability.OnCreate(self)
    InitMixin(self, HowlMixin)
    
    self.primaryAttacking = false

end

function XenocideHowl:GetHUDSlot()
    return 2
end

Shared.LinkClassToMap("XenocideHowl", XenocideHowl.kMapName, networkVars)