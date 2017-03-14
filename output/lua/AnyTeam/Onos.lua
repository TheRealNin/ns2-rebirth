
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
