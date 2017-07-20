
Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Weapons/DotMarker.lua")
Script.Load("lua/DamageMixin.lua")

class 'AcidRocket' (PredictedProjectile)

AcidRocket.kMapName            = "acidrocket"
AcidRocket.kProjectileCinematic = PrecacheAsset("cinematics/acidrocket_projectile.cinematic")

AcidRocket.kRadius             = 0.05
AcidRocket.kDetonateRadius     = 0.65
AcidRocket.kClearOnImpact      = true
AcidRocket.kClearOnEnemyImpact = true

AcidRocket.kLifetime = 6

local networkVars = { }

AddMixinNetworkVars(TeamMixin, networkVars)

function AcidRocket:OnCreate()
    
    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
        self:AddTimedCallback(AcidRocket.TimeUp, AcidRocket.kLifetime)
    end

end

function AcidRocket:GetDamageType()
    return kAcidRocketDamageType
end
function AcidRocket:GetDeathIconIndex()
    return kDeathMessageIcon.BileBomb
end

function AcidRocket:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:ProcessHit( targetHit )
        end
        return true
    end
end

if Server then

    local function SineFalloff(distanceFraction)
        local piFraction = Clamp(distanceFraction, 0, 1) * math.pi / 2
        return math.cos(piFraction + math.pi) + 1 
    end

    function AcidRocket:ProcessHit(targetHit, surface, normal)        
    
         -- Do damage to nearby targets.
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kAcidRocketSplashRadius)
        
        -- Remove rocket and firing player.
        local player = self:GetParent()
        if player then
          table.removevalue(hitEntities, player)
        end
        table.removevalue(hitEntities, self)
        
        -- full damage on direct impact
        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(kAcidRocketDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end
        --          (entities,    centerOrigin,     radius,                  fullDamage,        doer, ignoreLOS, fallOffFunc)
        RadiusDamage(hitEntities, self:GetOrigin(), kAcidRocketSplashRadius, kAcidRocketDamage, self, false, function() return 0 end )

        self:TriggerEffects("acidrocket_hit")
        DestroyEntity(self)
       

    end
    
    function AcidRocket:TimeUp(currentRate)

        DestroyEntity(self)
        return false
    
    end

end

function AcidRocket:GetNotifiyTarget()
    return true
end


Shared.LinkClassToMap("AcidRocket", AcidRocket.kMapName, networkVars)