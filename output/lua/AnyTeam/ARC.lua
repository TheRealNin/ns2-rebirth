
local networkVars =
{
}

AddMixinNetworkVars(DetectableMixin, networkVars)


local oldOnCreate = ARC.OnCreate
function ARC:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
end


local oldGetCanFireAtTargetActual = ARC.GetCanFireAtTargetActual
function ARC:GetCanFireAtTargetActual(target, targetPoint)    
    if target:isa("ARC") or target:isa("MAC") then
        return false
    end
    return oldGetCanFireAtTargetActual(self, target, targetPoint)
end

Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)