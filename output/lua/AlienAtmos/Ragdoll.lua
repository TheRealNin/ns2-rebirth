

local kRagdollTime = 9.5

function Ragdoll:OnCreate()

    Entity.OnCreate(self)
    
    local now = Shared.GetTime()
    self.dissolveStart = now
    self.dissolveAmount = 0
    
    if Server then
        self:AddTimedCallback(Ragdoll.TimeUp, kRagdollTime)
    end
    
    self:SetUpdates(true)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)  
    
    self:SetRelevancyDistance(kMaxRelevancyDistance)
end

function CreateRagdoll(fromEntity)

    local useModelName = fromEntity:GetModelName()
    local useGraphName = fromEntity:GetGraphName()
    
    if useModelName and string.len(useModelName) > 0 and useGraphName and string.len(useGraphName) > 0 then

        local ragdoll = CreateEntity(Ragdoll.kMapName, fromEntity:GetOrigin())
        ragdoll:SetCoords(fromEntity:GetCoords())
        ragdoll:SetModel(useModelName, useGraphName)
        
        --if fromEntity.GetPlayInstantRagdoll and fromEntity:GetPlayInstantRagdoll() then
            ragdoll:SetPhysicsType(PhysicsType.Dynamic)
            ragdoll:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
        -- else    
        --    ragdoll:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)    
        --end
        
        ragdoll:SetPhysicsGroupFilterMask(PhysicsMask.DroppedWeaponFilter)
        
        ragdoll:CopyAnimationState(fromEntity)
    end
    
end



function Ragdoll:OnUpdateRender()

    PROFILE("Ragdoll:OnUpdateRender")
    
    local now = Shared.GetTime()
    if self.dissolveStart < now then
        
        if self.dissolveAmount < 1 then
            local t = (now - self.dissolveStart) / kRagdollTime
            self.dissolveAmount = Math.Clamp( t * 0.5 + 0.5, 0.0, 1.0 )
        end
        
        self:SetOpacity(1-self.dissolveAmount, "dissolveAmount")
        
    end
    
end