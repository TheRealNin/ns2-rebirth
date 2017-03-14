
function PlayerUI_GetStatusInfoForUnit(player, unit)
        
    local crossHairTarget = PlayerUI_ShowsUnitStatusInfo(player, unit)
    
    -- checks here if the model was rendered previous frame as well
    local status = unit:GetUnitStatus(player)
    if unit:GetShowUnitStatusFor(player) then

        -- Get direction to blip. If off-screen, don't render. Bad values are generated if
        -- Client.WorldToScreen is called on a point behind the camera.
        local dotProduct, origin, worldOrigin, distance, healthBarOrigin = PlayerUI_GetPositionalInfo(player, unit) 
        
        if dotProduct > 0 then

            local statusFraction = unit:GetUnitStatusFraction(player)
            local description = unit:GetUnitName(player)
            local action = unit:GetActionName(player)
            local hint = unit:GetUnitHint(player)
           
            local health = 0
            local armor = 0
            local regen = 0

            local visibleToPlayer = true                        
            if HasMixin(unit, "Cloakable") and GetAreEnemies(player, unit) then
            
                if unit:GetIsCloaked() or (unit:isa("Player") and unit:GetCloakFraction() > 0.2) then
                    visibleToPlayer = false
                end
                
            end
            
            if player:GetHasMarkedTarget(unit) and unit ~= player:GetCrossHairTarget() then
                description = ""
                action = ""
                hint = ""
            end
            
            -- Don't show tech points or nozzles if they are attached
            if (unit:GetMapName() == TechPoint.kMapName or unit:GetMapName() == ResourcePoint.kPointMapName) and unit.GetAttached and (unit:GetAttached() ~= nil) then
                visibleToPlayer = false
            end
            
            if HasMixin(unit, "Live") and (not unit.GetShowHealthFor or unit:GetShowHealthFor(player)) then
            
                health = unit:GetHealthFraction()
                if unit:GetArmor() == 0 then
                    armor = 0
                else 
                    armor = unit:GetArmorScalar()
                end
               
                if HasMixin(unit, "Regeneration") then
                    regen = unit:GetRegenerationFraction()
                end
                
            end
            
            local badgeTextures = ""
            
            if HasMixin(unit, "Player") then
                if unit.GetShowBadgeOverride and not unit:GetShowBadgeOverride() then
                    badgeTextures = {}
                else
                    badgeTextures = Badges_GetBadgeTextures(unit:GetClientIndex(), "unitstatus") or {}
                end
            end
            
            local hasWelder = false 
            if distance < 10 then    
                hasWelder = unit:GetHasWelder(player)
            end
            
            local abilityFraction = 0
            if player:isa("Commander") then
                abilityFraction = unit:GetAbilityFraction(player)
            end
            
            local unitState = {
                UnitId = unit:GetId(),
                Position = origin,
                WorldOrigin = worldOrigin,
                HealthBarPosition = healthBarOrigin,
                Status = status,
                Name = description,
                Action = action,
                Hint = hint,
                StatusFraction = statusFraction,
                HealthFraction = health,
                RegenFraction = regen,
                ArmorFraction = armor,
                IsCrossHairTarget = crossHairTarget and visibleToPlayer,
                TeamType = kNeutralTeamType,
                TeamNumber = kTeamInvalid,
                ForceName = unit:isa("Player") and not GetAreEnemies(player, unit),
                BadgeTextures = badgeTextures,
                HasWelder = hasWelder,
                IsPlayer = unit:isa("Player"),
                IsSteamFriend = unit:isa("Player") and unit:GetIsSteamFriend() or false,
                AbilityFraction = abilityFraction,
                IsParasited = HasMixin(unit, "ParasiteAble") and unit:GetIsParasited()
            }

            
            if unit.GetTeamNumber then
                unitState.IsFriend = (unit:GetTeamNumber() == player:GetTeamNumber())
            end
            
            if unit.GetTeamType then
                unitState.TeamType = unit:GetTeamType()
            end
            
            if unit.GetTeamNumber then
                unitState.TeamNumber = unit:GetTeamNumber()
            end

            if unit:isa("Player") and unit:isa("Marine") and HasMixin(unit, "WeaponOwner") and not GetAreEnemies(player, unit) then
                local primaryWeapon = unit:GetWeaponInHUDSlot(1)
                if primaryWeapon and primaryWeapon:isa("ClipWeapon") then
                    unitState.PrimaryWeapon = primaryWeapon:GetTechId()
                end
            end
            
            if unit:isa("InfantryPortal") and unit.timeSpinStarted then
                if unit.queuedPlayerId ~= Entity.invalidId then
                    local playerName = ""
                    for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
                        if playerInfo.playerId == unit.queuedPlayerId then
                            playerName = playerInfo.playerName
                            break
                        end
                    end

                    unitState.SpawnerName = playerName
                    unitState.SpawnFraction = Clamp((Shared.GetTime() - unit.timeSpinStarted) / kMarineRespawnTime, 0, 1)
                end
            elseif unit:isa("Embryo") then
                unitState.EvolvePercentage = unit.evolvePercentage / 100
                unitState.EvolveClass = unit:GetEggTypeDisplayName()
            elseif unit:isa("Egg") and unit.researchProgress > 0 and unit.researchProgress < 1 then
                unitState.EvolvePercentage = unit.researchProgress
            elseif unit.GetDestinationLocationName then
                unitState.Destination = unit:GetDestinationLocationName()
            elseif unit:isa("Weapon") then
                -- Make super sure that we're hiding this
                unitState.IsCrossHairTarget = false
                unitState.Name = ""
                unitState.HealthFraction = 0
                unitState.ArmorFraction = 0
                unitState.Hint = ""
                -- Only show the AbilityFraction for Marine Commanders
                if player:isa("MarineCommander") and unit.weaponWorldState == true and unit.GetExpireTimeFraction and not unit:isa("Rifle") and not unit:isa("Pistol") then
                    unitState.IsCrossHairTarget = true
                    unitState.AbilityFraction = unit:GetExpireTimeFraction()
                    unitState.IsWorldWeapon = true
                end
            end
            
            return unitState
        end
    end
    return nil
end


function Player:GetShowCrossHairText()
    return self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index
end

function Player:UpdateCrossHairText(entity)

    if self.buyMenu ~= nil then
        self.crossHairText = nil
        self.crossHairHealth = 0
        self.crossHairMaturity = 0
        self.crossHairBuildStatus = 0
        return
    end

    if not entity or ( entity.GetShowCrossHairText and not entity:GetShowCrossHairText(self) ) then
        self.crossHairText = nil
        return
    end    
    
    if HasMixin(entity, "Cloakable") and GetAreEnemies(self, entity) and entity:GetIsCloaked() then
        self.crossHairText = nil
        return
    end
    
    if entity:isa("Player") and GetAreEnemies(self, entity) then
        self.crossHairText = nil
        return
    end    
    
    if HasMixin(entity, "Tech") and HasMixin(entity, "Live") and (entity:GetIsAlive() or (entity.GetShowHealthFor and entity:GetShowHealthFor(self))) then
    
        if self:isa("Marine") and entity:isa("Marine") and self:GetActiveWeapon() and self:GetActiveWeapon():isa("Welder") then
            self.crossHairHealth = math.ceil(math.max(0.00, entity:GetArmor() / entity:GetMaxArmor() ) * 100)
        else
            self.crossHairHealth = math.ceil(math.max(0.00, entity:GetHealthScalar()) * 100)
        end
        
        if entity:isa("Player") then        
            self.crossHairText = entity:GetName()    
        else 
            self.crossHairText = Locale.ResolveString(LookupTechData(entity:GetTechId(), kTechDataDisplayName, ""))
            
            if entity:isa("CommandStructure") then
              self.crossHairText = entity:GetLocationName() .. " " .. self.crossHairText          
            end
            
        end
        
        --add build %
        if HasMixin(entity, "Construct") then
        
            if entity:GetIsBuilt() then
                self.crossHairBuildStatus = 100
            else
                self.crossHairBuildStatus = math.floor(entity:GetBuiltFraction() * 100)
            end
        
        else
            self.crossHairBuildStatus = 0
        end
        
        if HasMixin(entity, "Team") then
            self.crossHairTeamType = entity:GetTeamType()        
        end
        
    else
    
        self.crossHairText = nil
        self.crossHairHealth = 0
        
        if entity:isa("Player") then
            self.crossHairText = entity:GetName()
        end
        
    end
        
    if not GetAreFriends(self, entity) then
        self.crossHairTextColor = kEnemyColor
    elseif HasMixin(entity, "GameEffects") and entity:GetGameEffectMask(kGameEffect.Parasite) then
        self.crossHairTextColor = kParasitedTextColor
    elseif HasMixin(entity, "Team") and self:GetTeamNumber() == entity:GetTeamNumber() then
        self.crossHairTextColor = kFriendlyColor
    else
        self.crossHairTextColor = kNeutralColor
    end

end