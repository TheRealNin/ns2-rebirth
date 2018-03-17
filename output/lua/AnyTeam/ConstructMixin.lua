
-- constants from original file 
local kBuildEffectsInterval = 1
local kDrifterBuildRate = 1


function ConstructMixin:OnConstructionComplete(builder)

    local team = HasMixin(self, "Team") and self:GetTeam()
    
    if team and team.OnConstructionComplete then

        if self.GetCompleteAlertId then
            team:TriggerAlert(self:GetCompleteAlertId(), self)
            
        elseif GetIsMarineUnit(self) then

            if builder and builder:isa("MAC") then    
                team:TriggerAlert(kTechId.MACAlertConstructionComplete, self)
            else            
                team:TriggerAlert(kTechId.MarineAlertConstructionComplete, self)
            end
            
        end

        team:OnConstructionComplete(self)

    end     

    self:TriggerEffects("construction_complete")
    
end    

--
-- Add health to structure as it builds.
--
local function AddBuildHealth(self, scalar)

    -- Add health according to build time.
    if scalar > 0 then
    
        local maxHealth = self:GetMaxHealth()
        self:AddHealth(scalar * (1 - kStartHealthScalar) * maxHealth, false, false, true)
        
    end
    
end

--
-- Add health to structure as it builds.
--
local function AddBuildArmor(self, scalar)

    -- Add health according to build time.
    if scalar > 0 then
    
        local maxArmor = self:GetMaxArmor()
        self:SetArmor(self:GetArmor() + scalar * (1 - kStartHealthScalar) * maxArmor, true)
        
    end
    
end

function ConstructMixin:GetCanConstruct(constructor)

    if self.GetCanConstructOverride then
        return self:GetCanConstructOverride(constructor)
    end
    
    -- Check if we're on infestation
    -- Doing the origin-based check may be expensive, but this is only done sparsely. And better than tracking infestation all the time.
    if LookupTechData(self:GetTechId(), kTechDataNotOnInfestation) and GetIsPointOnInfestation(self:GetOrigin(), self:GetTeamNumber()) then
        return false
    end
    
    return not self:GetIsBuilt() and GetAreFriends(self, constructor) and self:GetIsAlive() and
           (not constructor or constructor:isa("Marine") or constructor:isa("Gorge") or constructor:isa("MAC"))
    
end

function ConstructMixin:Construct(elapsedTime, builder)

    local success = false
    local playAV = false
    
    if not self.constructionComplete and (not HasMixin(self, "Live") or self:GetIsAlive()) then
        
        if builder and builder.OnConstructTarget then
            builder:OnConstructTarget(self)
        end
        
        if Server then

            if not self.lastBuildFractionTechUpdate then
                self.lastBuildFractionTechUpdate = self.buildFraction
            end
            
            local techTeam = self:GetTeam()
            local techTree = techTeam and techTeam.GetTechTree and techTeam:GetTechTree()

            local modifier = (self:GetTeamType() == kMarineTeamType and GetIsPointOnInfestation(self:GetOrigin(), self:GetTeamNumber())) and kInfestationBuildModifier or 1
            local startBuildFraction = self.buildFraction
            local newBuildTime = self.buildTime + elapsedTime * modifier
            local timeToComplete = self:GetTotalConstructionTime()           
            
            if newBuildTime >= timeToComplete then

                if not self.AllowConstructionComplete or self:AllowConstructionComplete(builder) then
                    
                    self:SetConstructionComplete(builder)

                    if techTree then
                        local techNode = techTree:GetTechNode(self:GetTechId())
                        if techNode then
                            techNode:SetResearchProgress(1.0)
                            techTree:SetTechNodeChanged(techNode, "researchProgress = 1.0f")
                        end
                    end
                    
                else
                    
                    self.buildTime = timeToComplete
                    self.oldBuildFraction = self.buildFraction
                    self.buildFraction = 1

                    if not self.GetAddConstructHealth or self:GetAddConstructHealth() then
                        local scalar = self.buildFraction - startBuildFraction
                        AddBuildHealth(self, scalar)
                        AddBuildArmor(self, scalar)
                    end

                    if self.oldBuildFraction ~= self.buildFraction then

                        if self.OnConstruct then
                            self:OnConstruct(builder, self.buildFraction, self.oldBuildFraction)
                        end

                    end
                    
                end
            else
            
                if self.buildTime <= self.timeOfNextBuildWeldEffects and newBuildTime >= self.timeOfNextBuildWeldEffects then
                
                    playAV = true
                    self.timeOfNextBuildWeldEffects = newBuildTime + kBuildEffectsInterval
                    
                end
                
                self.timeLastConstruct = Shared.GetTime()
                self.underConstruction = true
                
                self.buildTime = newBuildTime
                self.oldBuildFraction = self.buildFraction
                self.buildFraction = math.max(math.min((self.buildTime / timeToComplete), 1), 0)
                
                if techTree then
                    local techNode = techTree:GetTechNode(self:GetTechId())
                    if techNode and (self.buildFraction - self.lastBuildFractionTechUpdate) >= 0.05 then
                    
                        techNode:SetResearchProgress(self.buildFraction)
                        techTree:SetTechNodeChanged(techNode, string.format("researchProgress = %.2f", self.buildFraction))
                        self.lastBuildFractionTechUpdate = self.buildFraction
                        
                    end
                end
                
                if not self.GetAddConstructHealth or self:GetAddConstructHealth() then
                
                    local scalar = self.buildFraction - startBuildFraction
                    AddBuildHealth(self, scalar)
                    AddBuildArmor(self, scalar)
                
                end
                
                if self.oldBuildFraction ~= self.buildFraction then
                
                    if self.OnConstruct then
                        self:OnConstruct(builder, self.buildFraction, self.oldBuildFraction)
                    end
                    
                end
                
            end
        end
        
        success = true
        
    end
    
    if playAV then

        local builderClassName = builder and builder:GetClassName()    
        self:TriggerEffects("construct", {classname = self:GetClassName(), doer = builderClassName, isalien = GetIsAlienUnit(self)})
        
    end 
    
    return success, playAV
    
end