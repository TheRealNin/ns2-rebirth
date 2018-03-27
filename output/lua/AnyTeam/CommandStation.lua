
local networkVars =
{
}

AddMixinNetworkVars(DetectableMixin, networkVars)


local oldOnCreate = CommandStation.OnCreate
function CommandStation:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
end


Shared.LinkClassToMap("CommandStation", CommandStation.kMapName, networkVars)