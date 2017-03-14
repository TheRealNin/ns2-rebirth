
local networkVars =
{
}

AddMixinNetworkVars(DetectableMixin, networkVars)


local oldOnCreate = Observatory.OnCreate
function Observatory:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
end


Shared.LinkClassToMap("Observatory", Observatory.kMapName, networkVars)