
local kOnosGoreModifier = 2.0

local kOnosModifier = {}
kOnosModifier["Gore"] = kOnosGoreModifier
kOnosModifier["Smash"] = kOnosGoreModifier
kOnosModifier["Stomp"] = kOnosGoreModifier


function Onos:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
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