-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PersonalShieldMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

PersonalShieldMixin = CreateMixin( PersonalShieldMixin )
PersonalShieldMixin.type = "PersonalShieldAble"

--PrecacheAsset("cinematics/vfx_materials/personalshield.surface_shader")
--PrecacheAsset("cinematics/vfx_materials/personalshield_view.surface_shader")

PrecacheAsset("cinematics/vfx_materials/personalshield.surface_shader")
PrecacheAsset("cinematics/vfx_materials/personalshield_view.surface_shader")
--PrecacheAsset("cinematics/vfx_materials/personalshield_exoview.surface_shader")

local kNanoShieldStartSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_shield_3D")
local kNanoLoopSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_loop")
local kNanoDamageSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_damage")

local kpersonalShieldMaterial = PrecacheAsset("cinematics/vfx_materials/personalshield.material")
local kNanoshieldViewMaterial = PrecacheAsset("cinematics/vfx_materials/personalshield_view.material")
local kNanoshieldExoViewMaterial = PrecacheAsset("cinematics/vfx_materials/personalshield_view.material")

PersonalShieldMixin.expectedMixins =
{
    Live = "PersonalShieldMixin makes only sense if this entity can take damage (has LiveMixin).",
}

PersonalShieldMixin.optionalCallbacks =
{
    GetCanBePersonalShieldedOverride = "Return true or false if the entity has some specific conditions under which nano shield is allowed.",
    GetPersonalShieldOffset = "Return a vector defining an offset for the nano shield effect"
}

PersonalShieldMixin.networkVars =
{
    personalShielded = "boolean"
}

function PersonalShieldMixin:__initmixin()

    if Server then
        
        self.timePersonalShieldInit = 0
        self.personalShielded = false
        self.timeOfLastRepair = 0
        
    end
    
end

local function ClearPersonalShield(self, destroySound)

    self.personalShielded = false
    self.timePersonalShieldInit = 0    
    
    if Client then
        self:_RemoveShieldEffect()
    end
    
end

function PersonalShieldMixin:OnDestroy()

    if self:GetIsPersonalShielded() then
        ClearPersonalShield(self, false)
    end
    
end

function PersonalShieldMixin:OnTakeDamage(damage, attacker, doer, point)

    if self:GetIsPersonalShielded() and 
        (damageType == kDamageType.Structural or damageType == kDamageType.GrenadeLauncher ) then
        StartSoundEffectAtOrigin(kNanoDamageSound, self:GetOrigin())
    end
    
end

function PersonalShieldMixin:ActivatePersonalShield()

    if self:GetCanBePersonalShielded() then
    
        self.timePersonalShieldInit = Shared.GetTime()
        self.personalShielded = true
        
        if Server then
        
            
        end
        
    end
    
end
local function ActivatePersonalShieldOn(self)
    self:ActivatePersonalShield()
    return false
end

function PersonalShieldMixin:ActivatePersonalShieldDelayed()

    self:AddTimedCallback(ActivatePersonalShieldOn, 1)
    
end

function PersonalShieldMixin:GetIsPersonalShielded()
    return self.personalShielded
end

if Server then


    function PersonalShieldMixin:OnEntityChange(oldEntityId, newEntityId)
        if not oldEntityId or not newEntityId then
            return
        end
        local oldEnt = Shared.GetEntity(oldEntityId)
        if oldEnt and oldEnt.GetIsPersonalShielded and oldEnt:GetIsPersonalShielded() then
            local newEnt = Shared.GetEntity(newEntityId)
            if newEnt and newEnt.ActivatePersonalShield then
            
                -- this is a hack to prevent marines keeping the shield gen when round starts
                if newEnt:isa("JetpackMarine") then 
                    newEnt:ActivatePersonalShieldDelayed()
                end
            end
        end
    end
    
end

function PersonalShieldMixin:GetCanBePersonalShielded()

    local resultTable = { shieldedAllowed = true }
    
    if self.GetCanBePersonalShieldedOverride then
        self:GetCanBePersonalShieldedOverride(resultTable)
    end
    
    return resultTable.shieldedAllowed
    
end

local function UpdateClientPersonalShieldEffects(self)

    assert(Client)
    
    if self:GetIsPersonalShielded() and self:GetIsAlive() then
        self:_CreateShieldEffect()
    else
        self:_RemoveShieldEffect() 
    end
    
end

local function SharedUpdate(self)

    if Server then
    
        if not self:GetIsPersonalShielded() then
            return
        end
        
        -- See if personal shield time is over
        --if self.timePersonalShieldInit + kPersonalShieldDuration < Shared.GetTime() then
        --    ClearPersonalShield(self, true)
        --end
        if self.timeLastCombatAction < Shared.GetTime() - kPersonalShieldRepairDelay then
            if (self:GetArmor() < self:GetMaxArmor()) then
                if (self.timeOfLastRepair < Shared.GetTime() - kPersonalShieldRepairInterval) then
                    
                    self.timeOfLastRepair = Shared.GetTime()
                    
                    -- third param true = hideEffect
                    self:AddArmor(kPersonalShieldRepairPerSecond * kPersonalShieldRepairInterval, true, false)
                    
                end
            end
        end
       
    elseif Client and not Shared.GetIsRunningPrediction() then
        UpdateClientPersonalShieldEffects(self)
    end
    
end

function PersonalShieldMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    
    if self:GetIsPersonalShielded() then
        if (doer and doer:isa("Railgun")) or damageType == kDamageType.GrenadeLauncher then
            damageTable.damage = damageTable.damage * kPersonalShieldDamageSpecialReductionDamage
        --else
        --    damageTable.damage = damageTable.damage * kPersonalShieldDamageReductionDamage
        end
        damageTable.armorFractionUsed = kPersonalShieldArmorFraction
    end
end

function PersonalShieldMixin:OnUpdate(deltaTime)   
    SharedUpdate(self)
end

function PersonalShieldMixin:OnProcessMove(input)   
    SharedUpdate(self)
end

if Client then

    -- Adds the material effect to the entity and all child entities (hat have a Model mixin)
    local function AddEffect(entity, material, viewMaterial, entities)
    
        local numChildren = entity:GetNumChildren()
        
        if HasMixin(entity, "Model") then
            local model = entity._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:AddMaterial(viewMaterial)
                else
                    model:AddMaterial(material)
                end
                table.insert(entities, entity:GetId())
            end
        end
        
        for i = 1, entity:GetNumChildren() do
            local child = entity:GetChildAtIndex(i - 1)
            AddEffect(child, material, viewMaterial, entities)
        end
    
    end
    
    local function RemoveEffect(entities, material, viewMaterial)
    
        for i =1, #entities do
            local entity = Shared.GetEntity( entities[i] )
            if entity ~= nil and HasMixin(entity, "Model") then
                local model = entity._renderModel
                if model ~= nil then
                    if model:GetZone() == RenderScene.Zone_ViewModel then
                        model:RemoveMaterial(viewMaterial)
                    else
                        model:RemoveMaterial(material)
                    end
                end                    
            end
        end
        
    end

    function PersonalShieldMixin:_CreateShieldEffect()
   
        if not self.personalShieldMaterial then
        
            local material = Client.CreateRenderMaterial()
            material:SetMaterial(kpersonalShieldMaterial)

            local viewMaterial = Client.CreateRenderMaterial()
            
            if self:isa("Exo") then
                viewMaterial:SetMaterial(kNanoshieldExoViewMaterial)
            else
                viewMaterial:SetMaterial(kNanoshieldViewMaterial)
            end    
            
            self.personalShieldEntities = {}
            self.personalShieldMaterial = material
            self.personalShieldViewMaterial = viewMaterial
            AddEffect(self, material, viewMaterial, self.personalShieldEntities)
            
        end    
        
    end

    function PersonalShieldMixin:_RemoveShieldEffect()

        if self.personalShieldMaterial then
            RemoveEffect(self.personalShieldEntities, self.personalShieldMaterial, self.personalShieldViewMaterial)
            Client.DestroyRenderMaterial(self.personalShieldMaterial)
            Client.DestroyRenderMaterial(self.personalShieldViewMaterial)
            self.personalShieldMaterial = nil
            self.personalShieldViewMaterial = nil
            self.personalShieldEntities = nil
        end            

    end
    
end