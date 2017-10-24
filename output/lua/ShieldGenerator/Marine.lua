
Script.Load("lua/ShieldGenerator/PersonalShieldMixin.lua")

local networkVars =
{      
}

AddMixinNetworkVars(PersonalShieldMixin, networkVars)

local oldOnInitialized = Marine.OnInitialized
function Marine:OnInitialized()
    oldOnInitialized(self)
    
    InitMixin(self, PersonalShieldMixin)
end


Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)