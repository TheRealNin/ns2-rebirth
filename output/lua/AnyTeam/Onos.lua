
local kOnosGoreModifier = 2.0

Onos.kBlockDoers =
set {
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

local function GetNearbyStampedeables(onos, origin)
    local marines = GetEntitiesWithinRange("Marine", origin, Onos.kStampedeCheckRadius)
    local exos = GetEntitiesWithinRange("Exo", origin, Onos.kStampedeCheckRadius)
    local aliens = GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(onos:GetTeamNumber()), origin, Onos.kStampedeCheckRadius)
    local all = {}
    for i = 1, #marines do
        if self:CanBeStampeded(marines[i]) then
            table.insert(both, marines[i])
        end
    end

    for i = 1, #exos do
        if self:CanBeStampeded(exos[i]) then
            table.insert(both, exos[i])
        end
    end

    for i = 1, #aliens do
        if self:CanBeStampeded(aliens[i]) then
            table.insert(both, aliens[i])
        end
    end


    return all
end

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