
local networkVars = 
{
    -- The alien energy used for all alien weapons and abilities (instead of ammo) are calculated
    -- from when it last changed with a constant regen added
    timeAbilityEnergyChanged = "time",
    abilityEnergyOnChange = "float (0 to " .. math.ceil(kAdrenalineAbilityMaxEnergy) .. " by 0.05 [] )",
    
    movementModiferState = "boolean",
    
    oneHive = "private boolean",
    twoHives = "private boolean",
    threeHives = "private boolean",
    
    hasAdrenalineUpgrade = "boolean",
    
    enzymed = "boolean",
    
    infestationSpeedScalar = "private float",
    infestationSpeedUpgrade = "private boolean",
    
    storedHyperMutationTime = "private float",
    storedHyperMutationCost = "private float",
    
    silenceLevel = "integer (0 to 3)",
    
    electrified = "boolean",
    
    hatched = "private boolean",
    
    darkVisionSpectatorOn = "private boolean",
    
    isHallucination = "boolean",
    hallucinatedClientIndex = "integer",
    
    creationTime = "time"

}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(EnergizeMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(StormCloudMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(MucousableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)

local oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
    oldOnCreate(self)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, WebableMixin)
end

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)