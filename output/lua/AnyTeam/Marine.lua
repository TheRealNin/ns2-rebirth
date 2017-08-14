
local networkVars =
{      
    flashlightOn = "boolean",
    
    timeOfLastDrop = "private time",
    timeOfLastPickUpWeapon = "private time",
    
    flashlightLastFrame = "private boolean",
    
    timeLastSpitHit = "private time",
    lastSpitDirection = "private vector",
    
    ruptured = "boolean",
    interruptAim = "private boolean",
    poisoned = "boolean",
    catpackboost = "boolean",
    timeCatpackboost = "private time",
    weaponUpgradeLevel = "integer (0 to 3)",
    
    unitStatusPercentage = "private integer (0 to 100)",
    
    strafeJumped = "private compensated boolean",
    
    timeLastBeacon = "private time",
    
    weaponBeforeUseId = "private entityid"
}

AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(SprintMixin, networkVars)
AddMixinNetworkVars(OrderSelfMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(MarineVariantMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(RegenerationMixin, networkVars)

-- new
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)

local oldOnCreate = Marine.OnCreate
function Marine:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
end

local kMarineEngageOffset = Vector(0, 1.5, 0)
function Marine:GetEngagementPointOverride()
    return self:GetOrigin() + kMarineEngageOffset
end
--[[
local MarineModifier = {}
MarineModifier["Railgun"] = kMarineRailgunModifier


function Marine:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
    -- apply "umbra" to marines so that railgun deals less damage
    if attacker:GetTeamType() == kMarineTeamType then
    
        local modifier = 1
        if doer then        
            modifier = MarineModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end
]]--



Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)