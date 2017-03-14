function Skulk:GetHeartOffset()
    return Vector(0, 0.6, 0)
end

local kSkulkBiteModifier = 0.70

local kSkulkModifier = {}
kSkulkModifier["BiteLeap"] = kSkulkBiteModifier
kSkulkModifier["BiteHowl"] = kSkulkBiteModifier
kSkulkModifier["LerkBite"] = kSkulkBiteModifier
kSkulkModifier["SwipeBlink"] = kSkulkBiteModifier
kSkulkModifier["Gore"] = kSkulkBiteModifier


function Skulk:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
    -- apply "umbra" to exos so that bullets deal less damage
    if attacker:GetTeamType() == kAlienTeamType then
    
        local modifier = 1
        if doer then        
            modifier = kSkulkModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end
