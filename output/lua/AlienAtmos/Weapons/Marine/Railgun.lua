if Client then

    local kAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_railgun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_railgun_muzzle" }
    local kMuzzleEffectName = PrecacheAsset("cinematics/marine/railgun/muzzle_flash.cinematic")

    function Railgun:OnClientPrimaryAttackEnd()
    
        local parent = self:GetParent()
        
        if parent and not self:GetIsWeakCharge() then
            CreateMuzzleCinematic(self, kMuzzleEffectName, kMuzzleEffectName, kAttachPoints[self:GetExoWeaponSlot()] , parent)
        end
        
    end
end
function Railgun:GetBarrelPoint()

    local player = self:GetParent()
    if player then
    
        if player:GetIsLocalPlayer() then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return self:GetOrigin()
    
end

local kChargeTime = 2
function Railgun:GetIsWeakCharge()
    local chargeAmount = math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime)

    return (chargeAmount < 0.4)
end

function Railgun:GetTracerEffectName()
    if self:GetIsWeakCharge() then
        return kMinigunTracerEffectName
    end
    return kRailgunTracerEffectName
end

function Railgun:GetTracerResidueEffectName()
    if self:GetIsWeakCharge() then
        return kSpikeTracerResidueEffectName
    end
    return kRailgunTracerResidueEffectName
end




local kRailgunSpread = Math.Radians(0)
local kRailgunRange = 400
local kBulletSize = 0.3

local function TriggerSteamEffect(self, player)

    if self:GetIsLeftSlot() then
        player:TriggerEffects("railgun_steam_left")
    elseif self:GetIsRightSlot() then
        player:TriggerEffects("railgun_steam_right")
    end
    
end
local function ExecuteShot(self, startPoint, endPoint, player)

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
    local hitPointOffset = trace.normal * 0.3
    local direction = (endPoint - startPoint):GetUnit()
    local damage = kRailgunDamage + math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime) * kRailgunChargeDamage
    
    local extents = GetDirectedExtentsForDiameter(direction, kBulletSize)
    
    if trace.fraction < 1 then
    
        -- do a max of 10 capsule traces, should be sufficient
        local hitEntities = {}
        for i = 1, 20 do
        
            local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            if capsuleTrace.entity then
            
                if not table.find(hitEntities, capsuleTrace.entity) then
                
                    table.insert(hitEntities, capsuleTrace.entity)
                    self:DoDamage(damage, capsuleTrace.entity, capsuleTrace.endPoint + hitPointOffset, direction, capsuleTrace.surface, false, false)
                
                end
                
            end    
                
            if (capsuleTrace.endPoint - trace.endPoint):GetLength() <= extents.x then
                break
            end
            
            -- use new start point
            startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
        
        end
        
        -- for tracer
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
        self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, showTracer)
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, trace.endPoint)
        end
    
    end
    
end
local function Shoot(self, leftSide)

    local player = self:GetParent()
    
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if player then
        
        if self:GetIsWeakCharge() then
            player:TriggerEffects("railgun_weak_attack")
        else
            player:TriggerEffects("railgun_attack")
        end
        
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, kRailgunSpread, NetworkRandom)
        
        local endPoint = startPoint + spreadDirection * kRailgunRange
        ExecuteShot(self, startPoint, endPoint, player)
        
        if Client then
            TriggerSteamEffect(self, player)
        end
        
        self:LockGun()
        self.lockCharging = true
        
    end
    
end


function Railgun:OnTag(tagName)

    PROFILE("Railgun:OnTag")
    
    if self:GetIsLeftSlot() then
    
        if tagName == "l_shoot" then
            Shoot(self, true)
        elseif tagName == "l_shoot_end" then
            self.lockCharging = false
        end
        
    elseif not self:GetIsLeftSlot() then
    
        if tagName == "r_shoot" then
            Shoot(self, false)
        elseif tagName == "r_shoot_end" then
            self.lockCharging = false
        end
        
    end
    
end
