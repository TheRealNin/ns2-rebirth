
local networkVars =
{
}

AddMixinNetworkVars(DetectableMixin, networkVars)


local oldOnCreate = Extractor.OnCreate
function Extractor:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
end


Shared.LinkClassToMap("Extractor", Extractor.kMapName, networkVars)