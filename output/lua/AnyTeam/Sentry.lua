
local kAnimationGraph = PrecacheAsset("models/marine/sentry/sentry.animation_graph")

function Sentry:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    
    --InitMixin(self, LaserMixin)
    
    self:SetModel(Sentry.kModelName, kAnimationGraph)
    
    self:SetUpdates(true)
    
    if Server then 
    
        InitMixin(self, SleeperMixin)
        
        self.timeLastTargetChange = Shared.GetTime()
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        -- TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        InitMixin(self, SupplyUserMixin)
        
        -- configure how targets are selected and validated
        self.targetSelector = TargetSelector():Init(
            self,
            Sentry.kRange, 
            true,
            { kMarineStaticTargets, kMarineMobileTargets },
            { PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), CloakTargetFilter() },
            { function(target) return target:isa("Player") end } )

        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)   
        InitMixin(self, HiveVisionMixin)
 
    end
    
end

function GetCheckSentryLimit(techId, origin, normal, commander)

    -- Prevent the case where a Sentry in one room is being placed next to a
    -- SentryBattery in another room.
    local battery = GetSentryBatteryInRoom(origin, commander)
    if battery then
    
        if (battery:GetOrigin() - origin):GetLength() > SentryBattery.kRange then
            return false
        end
        
    else
        return false
    end
    
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    local teamNum = commander:GetTeamNumber()
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ipairs(GetEntitiesForTeam("Sentry", teamNum)) do
        
            if sentry:GetLocationName() == locationName then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kSentriesPerBattery
    
end
