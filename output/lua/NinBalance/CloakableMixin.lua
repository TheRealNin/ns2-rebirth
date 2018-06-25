
CloakableMixin.kCloakRate = 1

-- no need for this because players now cloak 100%
--local kPlayerMaxCloak = 0.88
local kCloakedMaterial = PrecacheAsset("cinematics/vfx_materials/cloaked.material")
local kDistortMaterial = PrecacheAsset("cinematics/vfx_materials/distort.material")

local kPlayerNearMaxCloakReduction = 0.8
local kPlayerFarCloakDist = 7.0
local kPlayerNearCloakDist = 4.0

local kMaxSpeedScalar = 0.9


local function UpdateDesiredCloakFraction(self, deltaTime)

    if Server then
    
        self.cloakingDesired = false
    
        -- Animate towards uncloaked if triggered
        if Shared.GetTime() > self.timeUncloaked and (not HasMixin(self, "Detectable") or not self:GetIsDetected()) and ( not GetConcedeSequenceActive() ) then
            
            -- Uncloaking takes precedence over cloaking
            if Shared.GetTime() < self.timeCloaked then        
                self.cloakingDesired = true
                self.cloakRate = 3
            elseif self.GetIsCamouflaged and self:GetIsCamouflaged() then
                
                self.cloakingDesired = true
                
                if self:isa("Player") then
                    self.cloakRate = GetVeilLevel(self:GetTeamNumber())
                elseif self:isa("Babbler") then
                    local babblerParent = self:GetParent()
                    if babblerParent and HasMixin(babblerParent, "Cloakable") then
                        self.cloakRate = babblerParent.cloakRate
                    end
                else
                    self.cloakRate = 3
                end
                
            end
            
        end
    
    end
    
    local newDesiredCloakFraction = self.cloakingDesired and 1 or 0
    
    -- Update cloaked fraction according to our speed and max speed
    if newDesiredCloakFraction == 1 and self.GetSpeedScalar and self:GetSpeedScalar() > kMaxSpeedScalar then
        newDesiredCloakFraction = 1 - self:GetSpeedScalar()
    end
    
    if newDesiredCloakFraction ~= nil then
        -- was this
        -- self.desiredCloakFraction = Clamp(newDesiredCloakFraction, 0, (self:isa("Player") or self:isa("Drifter") or self:isa("Babbler")) and kPlayerMaxCloak or 1)
        self.desiredCloakFraction = Clamp(newDesiredCloakFraction, 0, 1)
    end
    
end

debug.replaceupvalue( CloakableMixin.OnUpdate, "UpdateDesiredCloakFraction", UpdateDesiredCloakFraction, true)


if Client then

    function CloakableMixin:_UpdatePlayerModelRender(model)

        local player = Client.GetLocalPlayer()
        local hideFromEnemy = GetAreEnemies(self, player)
        local dist = (player:GetOrigin() - self:GetOrigin()):GetLength()
        
        
        if HasMixin(self, "Extents") then
            dist = dist - self:GetExtents():GetLengthXZ()
        end
        
        local nearFraction = 1 - Clamp((dist - kPlayerNearCloakDist) / (kPlayerFarCloakDist - kPlayerNearCloakDist), 0, 1)
        local modifiedCloak = Clamp(self.cloakFraction - nearFraction * kPlayerNearMaxCloakReduction, 0, self.cloakFraction)
        
        local useMaterial = (self.cloakingDesired or self:GetCloakFraction() ~= 0) and not hideFromEnemy

        if not self.cloakedMaterial and useMaterial then
            self.cloakedMaterial = AddMaterial(model, kCloakedMaterial)
        elseif self.cloakedMaterial and not useMaterial then
        
            RemoveMaterial(model, self.cloakedMaterial)
            self.cloakedMaterial = nil
            
        end

        if self.cloakedMaterial then

            
            -- this code is new to the mod
            -- we figure out the fraction of how close we are
            -- Main material parameter that affects our appearance
            self.cloakedMaterial:SetParameter("cloakAmount", modifiedCloak)          

            -- show it animated for the alien commander. the albedo texture needs to remain visible for outline so we show cloaked in a different way here
            local distortAmount = modifiedCloak
            if player and player:isa("AlienCommander") then            
                distortAmount = distortAmount * 0.5 + math.sin(Shared.GetTime() * 0.05) * 0.05            
            end
        end

        local showDistort = modifiedCloak ~= 0 and modifiedCloak ~= 1

        if showDistort and not self.distortMaterial then

            self.distortMaterial = AddMaterial(model, kDistortMaterial )

        elseif not showDistort and self.distortMaterial then
        
            RemoveMaterial(model, self.distortMaterial)
            self.distortMaterial = nil
        
        end
        
        if self.distortMaterial then        
            self.distortMaterial:SetParameter("distortAmount", modifiedCloak)        
        end

    end
end

if Client then
    
    function CloakableMixin:_UpdateViewModelRender()
    
        -- always show view model distort effect
        local viewModelEnt = self:GetViewModelEntity()
        if viewModelEnt and viewModelEnt:GetRenderModel() then
        
            -- Show view model as enemies see us, so we know how cloaked we are
            if not self.distortViewMaterial then
                self.distortViewMaterial = AddMaterial(viewModelEnt:GetRenderModel(), kDistortMaterial)
            end
            
            local cloakFraction = self.cloakFraction
            
            if not self.fullyCloaked then
                cloakFraction = cloakFraction * 0.5
            end
            
            self.distortViewMaterial:SetParameter("distortAmount", cloakFraction)
            
        end
        
    end
    
end


if Server then

    local function UpdateFullyCloaked(self, deltaTime)
        if self.fullyCloaked then
            for _, player in ipairs(GetEntitiesForTeamWithinRange( "Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kPlayerFarCloakDist-0.5)) do
                if player:GetIsAlive() then
                    self.fullyCloaked = false
                    return
                end
            end
        end
    end
    
    local oldUpdate = CloakableMixin.OnUpdate
    function CloakableMixin:OnUpdate(deltaTime)
        oldUpdate(self, deltaTime)
        UpdateFullyCloaked(self, deltaTime)
    end

    local oldOnProcessMove = CloakableMixin.OnProcessMove
    function CloakableMixin:OnProcessMove(input)
        oldOnProcessMove(self, input)
        UpdateFullyCloaked(self, input.time)
    end
    
    
end