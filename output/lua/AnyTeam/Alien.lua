
local networkVars = 
{
}

AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)

local oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
    oldOnCreate(self)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, WebableMixin)
end

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)