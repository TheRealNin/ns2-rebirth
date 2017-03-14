

local networkVars =
{
    extendAmount = "float (0 to 1 by 0.01)",
    bioMassLevel = "integer (0 to 6)",
    evochamberid = "entityid"
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

local oldOnCreate = Hive.OnCreate
function Hive:OnCreate()
    oldOnCreate(self)
    InitMixin(self, ParasiteMixin)
end


function Hive:SetIncludeRelevancyMask(includeMask)

    if self:GetTeamNumber() == kTeam1Index then
        includeMask = bit.bor(includeMask, kRelevantToTeam1Commander)
    elseif self:GetTeamNumber() == kTeam2Index then
        includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
    end
    CommandStructure.SetIncludeRelevancyMask(self, includeMask)    

end


function Hive:GetIsWallWalkingAllowed(entity)
    return entity and GetAreFriends(entity, self)
end

Shared.LinkClassToMap("Hive", Hive.kMapName, networkVars)