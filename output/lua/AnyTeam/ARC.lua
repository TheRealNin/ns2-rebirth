
local networkVars =
{
}

AddMixinNetworkVars(DetectableMixin, networkVars)


local oldOnCreate = ARC.OnCreate
function ARC:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
end

--
-- Do a complete check if the target can be fired on.
--
function ARC:GetCanFireAtTarget(target, targetPoint)    

    if target == nil then        
        return false
    end
    
    if not HasMixin(target, "Live") or not target:GetIsAlive() then
        return false
    end
    
    if not GetAreEnemies(self, target) then     
        if target:isa("PowerPoint") then
            if target:IsPoweringFriendlyTo(self) then
                return false
            end
        else
            return false
        end
    end
    
    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    -- don't target eggs (they take only splash damage)
    if target:isa("Egg") or target:isa("Cyst") or target:isa("MAC") or target:isa("ARC") then
        return false
    end
    
    return self:GetCanFireAtTargetActual(target, targetPoint)
    
end


function ARC:OnOrderGiven(order)
    if order ~= nil and (order:GetType() == kTechId.Attack or order:GetType() == kTechId.SetTarget) then
        local target = Shared.GetEntity(order:GetParam())
        if target then
            local dist = (self:GetOrigin() - target:GetOrigin()):GetLength()
            local valid = true
            if not HasMixin(target, "Live") or not target:GetIsAlive() then
                valid = false
            end
            if not GetAreEnemies(self, target) then        
                if target:isa("PowerPoint") then
                    if target:IsPoweringFriendlyTo(self) then
                        valid = false
                    end
                else
                    valid = false
                end
            end
            if target:isa("ARC") or target:isa("MAC") then
                valid = false
            end
            if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
                valid = false
            end
            if dist and valid and dist >= ARC.kMinFireRange and dist <= ARC.kFireRange then
                self.targetedEntity = order:GetParam()
                self.orderedEntity = order:GetParam()
            end
        end
    end
end


local oldGetCanFireAtTargetActual = ARC.GetCanFireAtTargetActual
function ARC:GetCanFireAtTargetActual(target, targetPoint)    
    return oldGetCanFireAtTargetActual(self, target, targetPoint)
end

Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)