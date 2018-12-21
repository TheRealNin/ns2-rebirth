
class 'HadesDevice' (ScriptActor)
HadesDevice.kMapName = "hadesdevice"
HadesDevice.kRange = 12.0
local kHadesDeviceScale = 0.75
local kHadesDeviceOffsetX = -0.65
local kHadesDeviceOffsetZ =  0.65

local kSirenInterval = 3.0
local kAlarmInterval = 3.0
local kDetonateInterval = 0.10

HadesDevice.kModelName = PrecacheAsset("models/props/biodome/biobome_Atmosphere_Exchange_cylinder.model")
HadesDevice.kExplosionCinematic = PrecacheAsset("cinematics/hades_explosion.cinematic")
HadesDevice.kSirenSound     = PrecacheAsset("sound/hades_sounds.fev/hades/siren")
HadesDevice.kSirenArmedSound= PrecacheAsset("sound/hades_sounds.fev/hades/siren_armed")
HadesDevice.kExplosionSound = PrecacheAsset("sound/hades_sounds.fev/hades/explosion")
HadesDevice.kDetectedSound = PrecacheAsset("sound/hades_sounds.fev/hades/device_detected")
local kHadesExplosionTime = 6.5 -- used so the sound continues to play

local kHadesCameraShakeDistance = 25
local kHadesMinShakeIntensity = 0.02
local kHadesMaxShakeIntensity = 0.25

local networkVars =
{
    creationTime = "time",
    detonateTime = "time"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)

AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function HadesDevice:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, DamageMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
        self.lastSirenTime = Shared.GetTime()
    end
    if Server then
    
        self.hadesDetectedSound = Server.CreateEntity(SoundEffect.kMapName)
        self.hadesDetectedSound:SetAsset(HadesDevice.kDetectedSound)
        self.hadesDetectedSound:SetRelevancyDistance(Math.infinity)
        
    end
    self.creationTime = Shared.GetTime()
    self.detonateTime = 0
    self.hasDetonated = false
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
end

function HadesDevice:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        -- This field IS synchronized over the network.
        self.creationTime = Shared.GetTime()
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    self:SetModel(HadesDevice.kModelName)

end

-- fix the broken model being used
function HadesDevice:OnAdjustModelCoords(modelCoords)
    modelCoords.xAxis = modelCoords.xAxis * kHadesDeviceScale
    modelCoords.yAxis = modelCoords.yAxis * kHadesDeviceScale
    modelCoords.zAxis = modelCoords.zAxis * kHadesDeviceScale
    modelCoords.origin = modelCoords.origin + modelCoords.xAxis * kHadesDeviceOffsetX + modelCoords.zAxis * kHadesDeviceOffsetZ
    return modelCoords
end

-- fix the broken model being used
function AdjustHadesDevice(modelCoords)
    modelCoords.xAxis = modelCoords.xAxis * kHadesDeviceScale
    modelCoords.yAxis = modelCoords.yAxis * kHadesDeviceScale
    modelCoords.zAxis = modelCoords.zAxis * kHadesDeviceScale
    return modelCoords
end

function HadesDevice:GetReceivesStructuralDamage()
    return true
end

function HadesDevice:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function HadesDevice:GetRequiresPower()
    return false
end
function HadesDevice:GetHealthbarOffset()
    return 0.85
end 
function HadesDevice:GetDamageType()
    return kHadesDeviceDamageType
end

function HadesDevice:GetDetonateRatio()
    return Clamp((Shared.GetTime() - self.detonateTime) / math.max(1, kHadesDeviceDetonateTime), 0, 1)
end
function HadesDevice:ShouldHaveDetonated()
    return self:GetIsDetonating() and Shared.GetTime() > self.detonateTime + kHadesDeviceDetonateTime
end

function HadesDevice:GetTMinusTime()
    return  string.format("%.1f", - (Shared.GetTime() - self.detonateTime - kHadesDeviceDetonateTime))
end

function HadesDevice:GetIsDetonating()
    return self:GetIsBuilt() and not (self.detonateTime <= 0)
end

function HadesDevice:SetIsDetonating()
    self.detonateTime = Shared.GetTime()
    if Server then
        
        self.hadesDetectedSound:Start()

    end
end

function HadesDevice:GetIsArmed()
    return self:GetIsBuilt() and Shared.GetTime() > self.creationTime + kHadesDeviceArmTime and not self:GetIsDetonating()
end 

function HadesDevice:GetUsablePoints()
    return { self:GetOrigin() + Vector(0,1,0) }
end

function HadesDevice:GetCanBeUsedConstructed(byPlayer)
    return self:GetIsArmed() and not byPlayer:isa("Exo")
end    

function HadesDevice:AllowConstructionComplete( player )
    return player:isa("Player") -- prevent macs from being mad bombers
end
function PowerPoint:GetCanConstructOverride( player )
    local isBuildable = not self:GetIsBuilt() and GetAreFriends(player,self)
    return isBuildable and ( self.buildFraction < 1 or self:AllowConstructionComplete(player) )
end

function HadesDevice:GetCanAlwaysBeUsed()
    return self:GetIsArmed()
end    

function HadesDevice:OnUse(player, elapsedTime, useSuccessTable)
    if player:isa("Parine") and self:GetIsArmed() then
        self:SetIsDetonating()
    end
    if not player:isa("Player") then
        useSuccessTable.useSuccess = false
    end
end


function HadesDevice:GetCanBeUsed(player, useSuccessTable)

    if player:isa("Exo") then
        useSuccessTable.useSuccess = false
    end
    
end

function HadesDevice:OnArmed()
end


function HadesDevice:OnConstructionComplete()
    if Server then
        self:SetIsDetonating()
        --self:AddTimedCallback(HadesDevice.OnArmed, kHadesDeviceArmTime)
    end
    self.creationTime = Shared.GetTime()
end

function HadesDevice:GetIsResearching()
    return not self:GetIsArmed() and not self:GetIsDetonating()
end

function HadesDevice:GetResearchProgressOverride()
    return Clamp((self.creationTime - Shared.GetTime()) / kHadesDeviceArmTime, 0,1)
end

function HadesDevice:GetIsUpgrading()

    if self:GetIsResearching() then
        return true
    end
    
    return false
    
end

function GetRoomIsValidForHadesDevice(techId, origin, normal, commander)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local validRoom = false
    local teamNum = commander:GetTeamNumber()
    
    if locationName then
    
        validRoom = true
    
        for index, HadesDevice in ipairs(GetEntitiesForTeam("HadesDevice", teamNum)) do
            
            if HadesDevice:GetLocationName() == locationName then
                validRoom = false
                break
            end
            
        end
        
        for index, CommandStation in ipairs(GetEntitiesForTeam("CommandStation", teamNum)) do
            
            if CommandStation:GetLocationName() == locationName then
                validRoom = false
                break
            end
            
        end
    
    end
    
    return validRoom

end

if Client then
    function HadesDevice:GetDetonateInterval()
        local detonateRatio = self:GetDetonateRatio()
        return (kSirenInterval * (1-detonateRatio) + kDetonateInterval * detonateRatio)
    end
    
    function HadesDevice:OnUpdate()
        self:UpdateStrobe()
        if self:GetIsBuilt() then
            if self:ShouldHaveDetonated() then
                if not self.hasDetonated then
                    self.hasDetonated = true
                    self:StopSound(HadesDevice.kSirenArmedSound)
                end
            elseif self:GetIsDetonating() then
                if self.lastSirenTime + self:GetDetonateInterval() < Shared.GetTime() then
                    self:StopSound(HadesDevice.kSirenSound)
                    self:PlaySound(HadesDevice.kSirenArmedSound)
                    self.lastSirenTime = Shared.GetTime()
                end
            elseif self:GetIsArmed() then
                if  self.lastSirenTime + kAlarmInterval < Shared.GetTime() then
                    --self:StopSound(HadesDevice.kSirenSound)
                    self:PlaySound(HadesDevice.kSirenSound)
                    self.lastSirenTime = Shared.GetTime()
                end
            else
                if  self.lastSirenTime + kSirenInterval < Shared.GetTime() then
                    self:PlaySound(HadesDevice.kSirenSound)
                    self.lastSirenTime = Shared.GetTime()
                end
            end
        end
    end
	
	function HadesDevice:GetStrobeIntensity()
		local sirenRatio = Clamp((Shared.GetTime() - self.detonateTime) / kHadesDeviceDetonateTime, 0, 1)
		
		return math.cos(200 * math.pow(sirenRatio, 3)) * 0.5 + 0.5
	end

    function HadesDevice:UpdateStrobe()
        
        if self:GetIsBuilt() and not self:ShouldHaveDetonated() then
            if not self.strobeLight then
            
                self.strobeLight = Client.CreateRenderLight()
                self.strobeLight:SetType( RenderLight.Type_Point )
                self.strobeLight:SetCastsShadows(false)
                self.strobeLight:SetRadius( HadesDevice.kRange * 0.5 )
                self.strobeLight:SetIsVisible(true)

            end
            local coords = self:GetCoords()
            coords.origin.y = coords.origin.y + coords.yAxis.y * 1.5
            self.strobeLight:SetCoords(coords)
            
            -- if you get math.cos of sirenTime, it will hit 1 ever 1 second. Adjust to fit interval
            local sirenTime = (Shared.GetTime() - self.detonateTime) * math.pi
            
            if self:GetIsDetonating() then
                if (self:GetDetonateRatio() > 0.90) then
                    self.strobeLight:SetColor( Color(1.0, 0.1, 0.0) )
                    self.strobeLight:SetIntensity(45.0 * self:GetDetonateRatio())
                else
                    self.strobeLight:SetColor( Color(0.5 * self:GetDetonateRatio() + 0.5, 0.1, 0.0) )
                    self.strobeLight:SetIntensity(self:GetStrobeIntensity() * 45.0)
                end
            elseif self:GetIsArmed() then
                self.strobeLight:SetColor( Color(0.1, 0.9, 0.0) )
                self.strobeLight:SetIntensity(Clamp(math.cos(sirenTime / kAlarmInterval), 0, 1) * 25.0)
            else
                self.strobeLight:SetColor( Color(0.5, 0.2, 0.0) )
                self.strobeLight:SetIntensity(Clamp(math.cos(sirenTime / kSirenInterval), 0, 1) * 25.0)
                
            end
        elseif self.strobeLight then
            self.strobeLight:SetIsVisible(false)
        end
        
    end
    
    function HadesDevice:OnKill()
        if self.strobeLight then
            Client.DestroyRenderLight(self.strobeLight)
        end
    end
    function HadesDevice:OnDestroy()
        if self.strobeLight then
            Client.DestroyRenderLight(self.strobeLight)
        end
    end
end

if Server then
    local function SineFalloff(distanceFraction)
        local piFraction = Clamp(distanceFraction, 0, 1) * math.pi / 2
        return math.cos(piFraction + math.pi) + 1
    end
    local function NoFalloff(distanceFraction)
        return 0
    end

    function HadesDevice:OnUpdate()
        if self:GetIsBuilt() then
            if self:ShouldHaveDetonated() and not self.hasDetonated then
                self.hasDetonated = true
                self:TriggerEffects("hades_explosion")
                Shared.PlaySound(self, HadesDevice.kExplosionSound)
                
                local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin() + Vector(0,1,0), HadesDevice.kRange)
                table.removevalue(hitEntities, self)
                
                -- SUPER HACKY but required if we want to deal damage to friendlies
                local oldFriendlyFire = kFriendlyFireScalar
                kFriendlyFireScalar = 0.5
                local oldFriendlyFireFunc = GetFriendlyFire
                GetFriendlyFire = function() return true end
                RadiusDamage(hitEntities, self:GetOrigin() + Vector(0,1,0), HadesDevice.kRange, kHadesDeviceDamage, self, false, NoFalloff)
                kFriendlyFireScalar = oldFriendlyFire
                GetFriendlyFire = oldFriendlyFireFunc
                
                CreateExplosionDecals(self)
                TriggerCameraShake(self, kHadesMinShakeIntensity, kHadesMaxShakeIntensity, kHadesCameraShakeDistance)
                
                -- hide the model because sounds stop playing once an entity is dead
                self:SetModel(nil)
                --DestroyEntity(self)
            end
            if self:ShouldHaveDetonated() and Shared.GetTime() > self.detonateTime + kHadesDeviceDetonateTime + kHadesExplosionTime then
                DestroyEntity(self)
            end
        end
    end
    function HadesDevice:OnKill(killer, doer, point, direction)
        self:TriggerEffects("death")
        DestroyEntity(self)
        ScriptActor.OnKill(self, killer, doer, point, direction)

    end
    
    function HadesDevice:OnDestroy()
    
        ScriptActor.OnDestroy(self)
        
        
    end

end

Shared.LinkClassToMap("HadesDevice", HadesDevice.kMapName, networkVars)