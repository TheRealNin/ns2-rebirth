
local kOnosGoreModifier = 2.0

local kBlockDoers =
{
    "Minigun",
    "Pistol",
    "Rifle",
    "HeavyRifle",
    "HeavyMachineGun",
    "Shotgun",
    "Axe",
    "Welder",
    "Sentry",
    "Grenade",
    "PulseGrenade",
    "ClusterFragment",
    "Mine",
    "Claw",
    "LerkBite",
    "Parasite",
    "Hydra",
    "AcidRocket",
    "SpitSpray",
    "BiteHowl", -- prowler
    "Whip"
}



local function GetHitsBoneShield(self, doer, hitPoint)

    if table.icontains(kBlockDoers, doer:GetClassName()) then
    
        local viewDirection = GetNormalizedVectorXZ( self:GetViewCoords().zAxis )
        local zPosition = viewDirection:DotProduct( GetNormalizedVector( hitPoint - self:GetOrigin() ) )
        return zPosition >= 0.34 --approx 115 degree cone of Onos facing
    
    end
    
    return false

end

ReplaceUpValue( Onos.ModifyDamageTaken, "GetHitsBoneShield", GetHitsBoneShield, { LocateRecurse = true; CopyUpValues = true; } )



local function CanBeStampeded(onos, ent)
    
    if ent.nextStampede and Shared.GetTime() < ent.nextStampede then
        return false
    end
    
    if not GetAreEnemies(onos, ent) then
        return false
    end
    
    return true
end

local kChargeExtents = Vector(1, 1.2, 1.2)
local kStampedeCheckRadius = kChargeExtents:GetLength() + 1.5
local function GetNearbyStampedeables(onos, origin)
    local marines = GetEntitiesWithinRange("Marine", origin, kStampedeCheckRadius)
    local exos = GetEntitiesWithinRange("Exo", origin, kStampedeCheckRadius)
    local aliens = GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(onos:GetTeamNumber()), origin, kStampedeCheckRadius)
    local all = {}
    for i=1, #marines do
        if CanBeStampeded(onos, marines[i]) then
            table.insert(all, marines[i])
        end
    end
    for i=1, #exos do
        if CanBeStampeded(onos, exos[i]) then
            table.insert(all, exos[i])
        end
    end
    for i=1, #aliens do
        if CanBeStampeded(onos, aliens[i]) then
            table.insert(all, aliens[i])
        end
    end
    return all
end

ReplaceUpValue( Onos.PreUpdateMove, "GetNearbyStampedeables", GetNearbyStampedeables, { LocateRecurse = true; CopyUpValues = true; } )




local kOnosModifier = {}
kOnosModifier["Gore"] = kOnosGoreModifier
kOnosModifier["Smash"] = kOnosGoreModifier
kOnosModifier["Stomp"] = kOnosGoreModifier


local oldModifyDamageTaken = Onos.ModifyDamageTaken
function Onos:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    oldModifyDamageTaken(damageTable, attacker, doer, damageType)
    -- apply "reverse umbra" to onos so that other onos deal more damage
    if attacker:GetTeamType() == kAlienTeamType then
    
        local modifier = 1
        if doer then        
            modifier = kOnosModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end


-- copied from exo
local kSmashEggRange = 1.5
local function SmashNearbyEggs(self)

    assert(Server)
    
    
    local nearbyEggs = GetEntitiesForTeamWithinRange("Egg", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kSmashEggRange)
    for e = 1, #nearbyEggs do
        nearbyEggs[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
    end
    
    local nearbyEmbryos = GetEntitiesForTeamWithinRange("Embryo", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kSmashEggRange)
    for e = 1, #nearbyEmbryos do
        nearbyEmbryos[e]:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
    end
    
    
    -- Keep on killing those nasty eggs forever.
    return true
    
end

local oldCreate = Onos.OnCreate
function Onos:OnCreate()
    oldCreate(self)
    
    if Server then
        self:AddTimedCallback(SmashNearbyEggs, 0.1)
    end
    
end