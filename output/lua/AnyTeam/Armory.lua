
local networkVars =
{
}

AddMixinNetworkVars(DetectableMixin, networkVars)


local oldOnCreate = Armory.OnCreate
function Armory:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
end


Shared.LinkClassToMap("Armory", Armory.kMapName, networkVars)