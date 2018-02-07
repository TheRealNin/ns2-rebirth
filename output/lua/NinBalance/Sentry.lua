Sentry.kTargetScanDelay = 1.5

local kAttackSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_fire_loop")
local kSentryScanSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_scan")

function Sentry:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, StunMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, ParasiteMixin)    
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self.desiredYawDegrees = 0
    self.desiredPitchDegrees = 0
    self.barrelYawDegrees = 0
    self.barrelPitchDegrees = 0

    self.confused = false
    self.attachedToBattery = false
    
    if Server then

        self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
        self.attackSound:SetParent(self)
        self.attackSound:SetAsset(kAttackSoundName)
        
    elseif Client then
    
        self.timeLastAttackEffect = Shared.GetTime()
        
        -- Play a "ping" sound effect every Sentry.kPingInterval while scanning.
        local function PlayScanPing(sentry)
        
            local intervall = Sentry.kTargetScanDelay + Sentry.kPingInterval
            if GetIsUnitActive(self) and not self.attacking and self.attachedToBattery and (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
                local player = Client.GetLocalPlayer()
                Shared.PlayPrivateSound(player, kSentryScanSoundName, nil, 1, sentry:GetModelOrigin())
            end
            return true
            
        end
        
        self:AddTimedCallback(PlayScanPing, Sentry.kPingInterval)
        
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end




function GetCheckSentryLimit(techId, origin, normal, commander)

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

if Server then

    -- check for spores in our way every 0.3 seconds
    local function UpdateConfusedState(self, target)

        if not self.confused and target then
            
            if not self.timeCheckedForSpores then
                self.timeCheckedForSpores = Shared.GetTime() - 0.3
            end
            
            if self.timeCheckedForSpores + 0.3 < Shared.GetTime() then
            
                self.timeCheckedForSpores = Shared.GetTime()
            
                local eyePos = self:GetEyePos()
                local toTarget = target:GetOrigin() - eyePos
                local distanceToTarget = toTarget:GetLength()
                toTarget:Normalize()
                
                local stepLength = 3
                local numChecks = math.ceil(Sentry.kRange/stepLength)
                
                -- check every few meters for a spore in the way, min distance 3 meters, max 12 meters (but also check sentry eyepos)
                for i = 0, numChecks do
                
                    -- stop when target has reached, any spores would be behind
                    if distanceToTarget < (i * stepLength) then
                        break
                    end
                
                    local checkAtPoint = eyePos + toTarget * i * stepLength
                    if self:GetFindsSporesAt(checkAtPoint) then
                        self:Confuse(Sentry.kConfuseDuration)
                        break
                    end
                
                end
            
            end
            
        elseif self.confused then
        
            if self.timeConfused < Shared.GetTime() then
                self.confused = false
            end
        
        end

    end
    
    function Sentry:FireBullets()

        local fireCoords = Coords.GetLookIn(Vector(0,0,0), self.targetDirection)     
        local startPoint = self:GetBarrelPoint()

        for bullet = 1, Sentry.kBulletsPerSalvo do
        
            local spreadDirection = CalculateSpread(fireCoords, Sentry.kSpread, math.random)
            
            local endPoint = startPoint + spreadDirection * Sentry.kRange
            
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(self, "Babbler"))
            
            if trace.fraction < 1 then
            
                local damage = kSentryDamage
                local surface = trace.surface
                
                -- Disable friendly fire.
                trace.entity = (not trace.entity or GetAreEnemies(trace.entity, self)) and trace.entity or nil
                
                if trace.entity and trace.entity.SetIsSighted then 
                    trace.entity:SetIsSighted(true)
                end
                
                local blockedByUmbra = trace.entity and GetBlockedByUmbra(trace.entity) or false
                
                if blockedByUmbra then
                    surface = "umbra"
                end
                
                local direction = (trace.endPoint - startPoint):GetUnit()
                --Print("Sentry %d doing %.2f damage to %s (ramp up %.2f)", self:GetId(), damage, SafeClassName(trace.entity), rampUpFraction)
                self:DoDamage(damage, trace.entity, trace.endPoint, direction, surface, false, true) -- show the tracer
                                
            end
            
        end
        
    end
    
    
    function Sentry:OnUpdate(deltaTime)
    
        PROFILE("Sentry:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)  
        
        --UpdateBatteryState(self)
        self.attachedToBattery = true
        
        if self.timeNextAttack == nil or (Shared.GetTime() > self.timeNextAttack) then
        
            local preventShooting = self.target == nil
            
            local prevTarget
            if self.target then
                prevTarget = self.target
            end
            
            self.target = nil
            
            if GetIsUnitActive(self) and self.attachedToBattery and self.deployed then
                self.target = self.targetSelector:AcquireTarget()
            end
            
            if self.target then
            
                local previousTargetDirection = self.targetDirection
                local targetPos = (self.target:isa("Player") and self.target.GetEyePos) and self.target:GetEyePos() or self.target:GetEngagementPoint() 
                self.targetDirection = GetNormalizedVector(targetPos - self:GetAttachPointOrigin(Sentry.kMuzzleNode))
                
                -- Reset damage ramp up if we moved barrel at all
                if previousTargetDirection then
                    local dotProduct = previousTargetDirection:DotProduct(self.targetDirection)
                    
                    if dotProduct < .99 then
                    
                        self.timeLastTargetChange = Shared.GetTime()
                        
                    end    
                end

                -- Or if target changed, reset it even if we're still firing in the exact same direction
                if self.target ~= prevTarget then
                    self.timeLastTargetChange = Shared.GetTime()
                end            
                
                -- don't shoot immediately
                if not preventShooting then
                
                    self.attacking = true
                    self:FireBullets()
                    
                end    
                
            else
            
                self.attacking = false
                self.timeLastTargetChange = Shared.GetTime()

            end
            
            UpdateConfusedState(self, self.target)
            -- slower fire rate when confused
            local confusedTime = ConditionalValue(self.confused, kConfusedSentryBaseROF, 0)
            
            -- Random rate of fire so it can't be gamed

            if preventShooting and self.target then
                self.timeNextAttack = Shared.GetTime() + Sentry.kTargetAcquireTime
            else
                self.timeNextAttack = confusedTime + Shared.GetTime() + Sentry.kBaseROF + math.random() * Sentry.kRandROF
            end    
            
            if not GetIsUnitActive() or self.confused or not self.attacking or not self.attachedToBattery then
            
                if self.attackSound and self.attackSound:GetIsPlaying() then
                    self.attackSound:Stop()
                end
                
            elseif self.attacking then
            
                if self.attackSound and not self.attackSound:GetIsPlaying() then
                    self.attackSound:Start()
                end

            end 
        
        end
    
    end
    
    -- NOTE: this is modifying the function directly above since it's a different balance change
    --[[
    local oldOnUpdate = Sentry.OnUpdate
    function Sentry:OnUpdate(deltaTime)
        oldOnUpdate(self, deltaTime)
        self.attachedToBattery = true
    end
    ]]--
end

if Client then

    local function UpdateAttackEffects(self, deltaTime)
    
        local intervall = ConditionalValue(self.confused, Sentry.kConfusedAttackEffectInterval, Sentry.kAttackEffectIntervall)
        if self.attacking and (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
        
            if self.confused then
                self:TriggerEffects("sentry_single_attack")
            end
            
            -- plays muzzle flash and smoke
            self:TriggerEffects("sentry_attack")

            self.timeLastAttackEffect = Shared.GetTime()
            
        end
        
    end

    function Sentry:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if GetIsUnitActive(self) and self.deployed and self.attachedToBattery then
            
            local swingMult = 1.0
            
            -- Swing barrel yaw towards target
            if self.attacking then
            
                if self.targetDirection then
                
                    local invSentryCoords = self:GetAngles():GetCoords():GetInverse()
                    self.relativeTargetDirection = GetNormalizedVector( invSentryCoords:TransformVector( self.targetDirection ) )
                    self.desiredYawDegrees = Clamp(math.asin(-self.relativeTargetDirection.x) * 180 / math.pi, -Sentry.kMaxYaw, Sentry.kMaxYaw)            
                    self.desiredPitchDegrees = Clamp(math.asin(self.relativeTargetDirection.y) * 180 / math.pi, -Sentry.kMaxPitch, Sentry.kMaxPitch)       
                    
                    swingMult = 4.0
                    
                end
                
                UpdateAttackEffects(self, deltaTime)
                
            -- Else when we have no target, swing it back and forth looking for targets
            else
            
                local intervall = Sentry.kTargetScanDelay
                if (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
                    
                    local sin = math.sin(math.rad((Shared.GetTime() + self:GetId() * .3) * Sentry.kBarrelScanRate))
                    self.desiredYawDegrees = sin * self:GetFov() / 2
                    
                    -- Swing barrel pitch back to flat
                    self.desiredPitchDegrees = 0
                end 
                
            end
            
            -- swing towards desired direction
            self.barrelPitchDegrees = Slerp(self.barrelPitchDegrees, self.desiredPitchDegrees, Sentry.kBarrelMoveRate * deltaTime * swingMult)    
            self.barrelYawDegrees = Slerp(self.barrelYawDegrees , self.desiredYawDegrees, Sentry.kBarrelMoveRate * deltaTime * swingMult)
        
        end
    
    end

end