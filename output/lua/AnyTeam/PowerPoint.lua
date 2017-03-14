
local kDamagedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/damaged")
local kTakeDamageSound = PrecacheAsset("sound/NS2.fev/marine/power_node/take_damage")
local kDestroyedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed")
local kDestroyedPowerDownSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed_powerdown")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local kDamagedPercentage = 0.4

-- The amount of time that must pass since the last time a PP was attacked until
-- the team will be notified. This makes sure the team isn't spammed.
local kUnderAttackTeamMessageLimit = 5

local kDefaultUpdateRange = 100

local oldOnInitialized = PowerPoint.OnInitialized

function PowerPoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    if Server then
    
        -- PowerPoints now belong to any team
        self:SetTeamNumber(kNeutralTeamNumber)
        
        -- extend relevancy range as the powerpoint plays with lights around itself, so
        -- the effects of a powerpoint are visible far beyond the normal relevancy range
        self:SetRelevancyDistance(kDefaultUpdateRange + 20)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    
end


local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")



function PowerPoint:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
    -- anti-troll tech: don't allow marines to destroy a powernode if they have a building that is using it
    if attacker:GetTeamType() == kMarineTeamType and attacker:isa("Player") then
        for _, powerUser in ipairs(GetEntitiesWithMixinForTeam("PowerConsumer", attacker:GetTeamNumber())) do
            if powerUser.GetIsAlive and powerUser:GetIsAlive() and powerUser.GetLocationId and powerUser:GetLocationId() == self:GetLocationId() then
                damageTable.damage = 0
                break
            end
        end
    end
end

function PowerPoint:GetCanBeUsed(player, useSuccessTable)

    if player:isa("Exo") then
        useSuccessTable.useSuccess = false
        return
    end

    useSuccessTable.useSuccess = not GetPowerPointRecentlyDestroyed(self) and (not self:GetIsBuilt() or (self:GetIsBuilt() and self:GetHealthScalar() < 1))
end

function PowerPoint:OnUse(player, elapsedTime, useSuccessTable)

    local success = false
    if player:isa("Marine") then
        if self:GetPowerState() == PowerPoint.kPowerState.unsocketed and Server then
            self:SocketPowerNode()
            success = true
        elseif self:GetIsBuilt() and self:GetHealthScalar() < 1 then
    
            if Server then
                -- exclude the welder, as the welding is performed elsewhere.
                -- Doing it here will double up the effect.
                local activeWeapon = player:GetActiveWeapon()
                if activeWeapon:GetMapName() ~= Welder.kMapName then
                    self:OnWeld(player, elapsedTime)
                end
            end
            success = true
            
            if player.OnConstructTarget then
                player:OnConstructTarget(self)
            end
        
        elseif self.buildFraction == 1 and not self:CanBeCompletedByScriptActor( player ) then
            local time = Shared.GetTime()
            if Client and self.timeLastConstruct + 1 < time then
                if not self.timeLastPowerLockedMessage or self.timeLastPowerLockedMessage + 1 < time then
                    if self:HasUnbuiltConsumerRequiringPower() then                        
                        player:SetTeamMessage( Locale.ResolveString( "POWERPOINT_FINISHBUILD_TOOLTIP" ) )
                    else
                        player:SetTeamMessage( Locale.ResolveString( "POWERPOINT_NOSTRUCTURES_TOOLTIP" ) )
                    end
                    self.timeLastPowerLockedMessage = time
                end
                player:TriggerInvalidSound()
            end
            useSuccessTable.useSuccess = false
            return
        end
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess or success
    
end

if Server then

    local function PowerUp(self)
    
        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetLightMode(kLightMode.Normal)
        self:StopSound(kAuxPowerBackupSound)
        self:TriggerEffects("fixed_power_up")
        self:SetPoweringState(true)
        
    end
    
    local function PlayAuxSound(self)
    
        if not self:GetIsDisabled() then
            self:PlaySound(kAuxPowerBackupSound)
        end
        
    end
    
    function PowerPoint:OnKill(attacker, doer, point, direction)
    
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        
        self:StopDamagedSound()
        
        self:MarkBlipDirty()
        
        self:PlaySound(kDestroyedSound)
        self:PlaySound(kDestroyedPowerDownSound)
        
        self:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
        
        self:SetLightMode(kLightMode.NoPower)
        
        -- Remove effects such as parasite when destroyed.
        self:ClearGameEffects()
        
        -- only give score to non-marines for destroying powernodes
        if attacker and attacker:isa("Player") and attacker:GetTeamType() ~= kMarineTeamType  then
            attacker:AddScore(self:GetPointValue())
        end
        
        -- Let the teams know the power is down.
        if GetGamerules():GetTeam1():GetTeamType() == kMarineTeamType then
            SendTeamMessage(GetGamerules():GetTeam1(), kTeamMessageTypes.PowerLost, self:GetLocationId())
        end
        if GetGamerules():GetTeam2():GetTeamType() == kMarineTeamType then
            SendTeamMessage(GetGamerules():GetTeam2(), kTeamMessageTypes.PowerLost, self:GetLocationId())
        end
        
        
        -- A few seconds later, switch on aux power.
        self:AddTimedCallback(PlayAuxSound, 4)
        self.timeOfDestruction = Shared.GetTime()
        
    end
    
    function PowerPoint:OnWeldOverride(entity, elapsedTime)
    
        local welded = false
        
        -- Marines can repair power points
        if entity:isa("Welder") then

            local amount = kWelderPowerRepairRate * elapsedTime
            welded = (self:AddHealth(amount) > 0)            
            
        elseif entity:isa("MAC") then
        
            welded = self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime) > 0 
            
        else
        
            local amount = kBuilderPowerRepairRate * elapsedTime
            welded = (self:AddHealth(amount) > 0)
        
        end
        
        if self:GetHealthScalar() > kDamagedPercentage then
        
            self:StopDamagedSound()
            
            if self:GetLightMode() == kLightMode.LowPower and self:GetIsPowering() then
                self:SetLightMode(kLightMode.Normal)
            end
            
        end
        
        if self:GetHealthScalar() == 1 and self:GetPowerState() == PowerPoint.kPowerState.destroyed then
        
            -- PowerPoints now belong to any team
            self:SetTeamNumber(kNeutralTeamNumber)
            self:StopDamagedSound()
            
            self.health = kPowerPointHealth
            self.armor = kPowerPointArmor
            
            self:SetMaxHealth(kPowerPointHealth)
            self:SetMaxArmor(kPowerPointArmor)
            
            self.alive = true
            
            PowerUp(self)
            
            self:UpdateInfestedState()
            
        end
        
        if welded then
            self:AddAttackTime(-0.1)
        end
        
    end
    
    -- send a message every kUnderAttackTeamMessageLimit seconds when a base power node is under attack
    local function CheckSendDamageTeamMessage(self)

        if not self.timePowerNodeAttackAlertSent or self.timePowerNodeAttackAlertSent + kUnderAttackTeamMessageLimit < Shared.GetTime() then
            
            for teamNumber = 1, 2 do 
                -- Check if there is anything using power near this powerPoint
                local foundStation = false
                local stations = GetEntitiesWithMixinForTeam("PowerConsumer", teamNumber)
                for s = 1, #stations do
                
                    local station = stations[s]
                    if station.GetLocationId and station:GetIsBuilt() and station:GetLocationName() == self:GetLocationName() then
                        foundStation = true
                    end
                    
                end
                
                -- Only send the message if there was a CommandStation found at this same location.
                if foundStation then
                    local team = GetGamerules():GetTeam(teamNumber)
                    SendTeamMessage(team, kTeamMessageTypes.PowerPointUnderAttack, self:GetLocationId())
                    team:TriggerAlert(kTechId.MarineAlertStructureUnderAttack, self, true)
                end
                
                self.timePowerNodeAttackAlertSent = Shared.GetTime()
            end
        end
        
    end
    function PowerPoint:OnTakeDamage(damage, attacker, doer, direction, damageType, preventAlert)

        if not self:GetIsBuilt() then
            return
        end
        
        self:DoDamageLighting()
        
        if self.powerState == PowerPoint.kPowerState.socketed and damage > 0 then

            self:PlaySound(kTakeDamageSound)
            
            local healthScalar = self:GetHealthScalar()
            
            if healthScalar < kDamagedPercentage then
                
                if not self.playingLoopedDamaged then
                
                    self:PlaySound(kDamagedSound)
                    self.playingLoopedDamaged = true
                    
                end
                
            end
            -- why would you ever want to prevent the alert?
            --if not preventAlert then
                CheckSendDamageTeamMessage(self)
            --end
            
        end
        
    end
end