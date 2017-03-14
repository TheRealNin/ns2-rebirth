
-- caches damage dropoff and target ids so it does not need to be recomputed every time
local function ConstructCachedTargetList(origin, forTeam, damage, radius, fallOffFunc)

    local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", forTeam, origin, radius)
    local targetList = {}
    local targetIds = {}
    
    for index, hitEntity in ipairs(hitEntities) do
        local entry = ConstructTargetEntry(origin, hitEntity, damage, radius, false, nil, fallOffFunc)
        
        if entry then
            table.insert(targetList, entry)
            targetIds[hitEntity:GetId()] = true
        end
    end
    
    return targetList, targetIds
    
end

            Log("LOADING DOTMARKER CODE in  dotmarker")

function DotMarker:OnUpdate(deltaTime)

    if Server then

        if self.timeLastUpdate + self.damageIntervall < Shared.GetTime() then
            -- we are attached to a target, update position
            if self.targetId ~= Entity.invalidId then        
                local target = Shared.GetEntity(self.targetId)
                if target then
                    self:SetOrigin(target:GetOrigin())  
                end
            end

            local targetList = self.targetList
            
            if self.dotMarkerType == DotMarker.kType.SingleTarget then
            Log("singletarget dotmarker")

                -- single target will deal damage only to the attached target (used for poison dart)
                if not targetList and self.targetId ~= Entity.invalidId then
                    
                    local target = Shared.GetEntity(self.targetId)

                    if target then

                        self.targetList = {}
                        table.insert(self.targetList, ConstructTargetEntry(self:GetOrigin(), target, self.damage, self.radius, true, self.impactPoint, self.fallOffFunc) )
                        targetList = self.targetList
                        
                    end
                    
                end

            elseif self.dotMarkerType == DotMarker.kType.Dynamic then
            Log("dynamic dotmarker")
            
                -- in case for dynamic dot marker recalculate the target list each damage tick (used for burning)
                targetList = ConstructCachedTargetList(self:GetOrigin(), GetEnemyTeamNumber(self:GetTeamNumber()), self.damage, self.radius, self.fallOffFunc)
                
            elseif self.dotMarkerType == DotMarker.kType.Static then
            Log("Static dotmarker")
                -- calculate the target list once and reuse it later (used for bilebomb)
                if not targetList then
            Log("creating dotmarker targets")
                    self.targetList, self.targetIds = ConstructCachedTargetList(self:GetOrigin(), GetEnemyTeamNumber(self:GetTeamNumber()), self.damage, self.radius, self.fallOffFunc)
                    local powerNodeList
                    local powerNodeIdList
                    powerNodeList, powerNodeIdList = ConstructCachedTargetList(self:GetOrigin(), kNeutralTeamNumber, self.damage, self.radius, self.fallOffFunc)
                    self.targetList = ConcatTable(self.targetList, powerNodeList)
                    self.targetIds = ConcatTable(self.targetIds, powerNodeIdList)
                    targetList = self.targetList
                end
            
            end
            
            if targetList then
                ApplyDamage(self, targetList)
            end
                
            self.timeLastUpdate = Shared.GetTime()
            
        end
    
    elseif Client then
    
    
    end

end