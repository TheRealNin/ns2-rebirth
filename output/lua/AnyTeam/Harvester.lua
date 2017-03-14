
local networkVars = { }

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

local oldOnCreate = Harvester.OnCreate
function Harvester:OnCreate()
    oldOnCreate(self)
    InitMixin(self, ParasiteMixin)
end

Shared.LinkClassToMap("Harvester", Harvester.kMapName, networkVars)