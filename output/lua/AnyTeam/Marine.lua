
local networkVars =
{
}

-- new
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)

local oldOnCreate = Marine.OnCreate
function Marine:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
end

local kMarineEngageOffset = Vector(0, 1.5, 0)
function Marine:GetEngagementPointOverride()
    return self:GetOrigin() + kMarineEngageOffset
end

local MarineModifier = {}
MarineModifier["Railgun"] = kMarineRailgunModifier


function Marine:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
    -- apply "umbra" to marines so that railgun deals less damage
    if attacker:GetTeamType() == kMarineTeamType then
    
        local modifier = 1
        if doer then        
            modifier = MarineModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end



Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)