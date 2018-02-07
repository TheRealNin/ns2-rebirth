
local kExoModifier = {}
kExoModifier["Shotgun"] = kExoBulletModifier
kExoModifier["Rifle"] = kExoBulletModifier
kExoModifier["HeavyMachineGun"] = kExoBulletModifier
kExoModifier["Pistol"] = kExoBulletModifier
kExoModifier["Sentry"] = kExoBulletModifier
kExoModifier["Minigun"] = kExoBulletModifier
kExoModifier["Railgun"] = kExoBulletModifier
kExoModifier["ClusterGrenade"] = kExoBulletModifier
kExoModifier["ClusterFragment"] = kExoBulletModifier

local networkVars = 
{
    electrified = "boolean"
}
AddMixinNetworkVars(DetectableMixin, networkVars)

local oldOnCreate = Exo.OnCreate
function Exo:OnCreate()
    oldOnCreate(self)
    InitMixin(self, DetectableMixin)
    if Server then
        self.timeElectrifyEnds = 0
        self.electrified = false
    end
end

Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars, true)


function Exo:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
    -- apply "umbra" to exos so that bullets deal less damage
    if attacker:GetTeamType() == kMarineTeamType then
    
        local modifier = 1
        if doer then        
            modifier = kExoModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier * kExoAllMarineDmagmageModifier
        
    end
    

end



function Exo:SetElectrified(time)

    time = time * kExoElectrifiedMult
    
    if self.timeElectrifyEnds - Shared.GetTime() < time then
    
        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true
        
    end
    self:SetFuel( 0 )
    
end

local oldGetMaxSpeed = Exo.GetMaxSpeed
function Exo:GetMaxSpeed(possible)
    local maxSpeed = oldGetMaxSpeed(self, possible)
    
    if self.electrified then
        maxSpeed = kElectrifiedSpeedScalar * maxSpeed
    end
    
    return maxSpeed
    
end


local oldOnProcessMove = Exo.OnProcessMove
function Exo:OnProcessMove(input)
    oldOnProcessMove(self, input)
    if Server and not self:GetIsDestroyed() then
        self.electrified = self.timeElectrifyEnds > Shared.GetTime()
    end
end

if Client then

    local oldUpdateClientEffects = Exo.UpdateClientEffects
    function Exo:UpdateClientEffects(deltaTime, isLocal)
        oldUpdateClientEffects(self, deltaTime, isLocal)
        
        if self.electrifiedClient ~= self.electrified then
            if isLocal then
            
                local viewModel= nil        
                if self:GetViewModelEntity() then
                    viewModel = self:GetViewModelEntity():GetRenderModel()  
                end
                    
                if viewModel then
       
                    if self.electrified then
                        self.electrifiedViewMaterial = AddMaterial(viewModel, Alien.kElectrifiedViewMaterialName)
                    else
                    
                        if RemoveMaterial(viewModel, self.electrifiedViewMaterial) then
                            self.electrifiedViewMaterial = nil
                        end
      
                    end
                
                end
            
            end
            
            
            local thirdpersonModel = self:GetRenderModel()
            if thirdpersonModel then
            
                if self.electrified then
                    self.electrifiedMaterial = AddMaterial(thirdpersonModel, Alien.kElectrifiedThirdpersonMaterialName)
                else
                
                    if RemoveMaterial(thirdpersonModel, self.electrifiedMaterial) then
                        self.electrifiedMaterial = nil
                    end

                end
            
            end
            
            self.electrifiedClient = self.electrified
        end
    end
end