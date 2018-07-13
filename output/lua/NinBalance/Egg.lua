-- shamelessly stolen from Ghoul's balance mod
-- Copyright Ghoul
-- Licensed under the MIT License


--Todo: Receive this via a alienteam method
local kUpgrades = {
	[kTechId.Shell] = { kTechId.Carapace, },
	[kTechId.Carapace] = kTechId.Shell,
	[kTechId.Regeneration] = kTechId.Shell,
	[kTechId.Camouflage] = kTechId.Shell,
	[kTechId.Crush] = kTechId.Shell,
	[kTechId.Veil] = { kTechId.Aura, },
	[kTechId.Vampirism] = kTechId.Veil,
	[kTechId.Aura] = kTechId.Veil,
	[kTechId.Focus] = kTechId.Veil,
	[kTechId.Spur] = { kTechId.Silence, kTechId.Celerity},
	[kTechId.Silence] = kTechId.Spur,
	[kTechId.Celerity] = kTechId.Spur,
	[kTechId.Adrenaline] = kTechId.Spur,
}

local kStructures = {
	kTechId.Shell,
	kTechId.Veil,
	kTechId.Spur
}

function Egg:PickUpgrades(newPlayer)
	local lastUpgradeList = newPlayer.lastUpgradeList or {}
	local teamNumber = self:GetTeamNumber()

	local picked = {}
	for i = 1, #lastUpgradeList do
		local techId = lastUpgradeList[i]
		if techId then
			picked[kUpgrades[techId]] = true

			if GetIsTechUseable(techId, teamNumber) then
				newPlayer:GiveUpgrade(techId)
			end
		end
	end

	for i = 1, #kStructures do
		local techId = kStructures[i]
		if not picked[techId] then
			local upgrade = table.random(kUpgrades[techId])
			if GetIsTechUseable(upgrade, teamNumber) then
				newPlayer:GiveUpgrade(upgrade)
			end
            
            if newPlayer:isa("Skulk") then
                newPlayer.lastUpgradeList = newPlayer.lastUpgradeList or {}
                table.insert(newPlayer.lastUpgradeList, upgrade)
            end
		end
	end
end

function Egg:SpawnPlayer(player)

	PROFILE("Egg:SpawnPlayer")

	local queuedPlayer = player

	if not queuedPlayer or self.queuedPlayerId ~= nil then
		queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
	end

	if queuedPlayer ~= nil then

		local queuedPlayer = player
		if not queuedPlayer then
			queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
		end

		-- Spawn player on top of egg
		local spawnOrigin = Vector(self:GetOrigin())
		-- Move down to the ground.
		local _, normal = GetSurfaceAndNormalUnderEntity(self)
		if normal.y < 1 then
			spawnOrigin.y = spawnOrigin.y - (self:GetExtents().y / 2) + 1
		else
			spawnOrigin.y = spawnOrigin.y - (self:GetExtents().y / 2)
		end

		local gestationClass = self:GetClassToGestate()

		-- We must clear out queuedPlayerId BEFORE calling ReplaceRespawnPlayer
		-- as this will trigger OnEntityChange() which would requeue this player.
		self.queuedPlayerId = nil

		local team = queuedPlayer:GetTeam()
		local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles(), gestationClass)
		player:SetCameraDistance(0)
		player:SetHatched()
		-- It is important that the player was spawned at the spot we specified.
		assert(player:GetOrigin() == spawnOrigin)

		if success then

			self:PickUpgrades(player)

			self:TriggerEffects("egg_death")
			DestroyEntity(self)

			return true, player

		end

	end

	return false, nil

end


if Server then
    --
    -- Takes the queued player from this Egg and placed them back in the
    -- respawn queue to be spawned elsewhere.
    --
    -- This modification reduces the respawn time for players when killed as an egg
    --
    local function RequeuePlayer(self)

        if self.queuedPlayerId then
        
            local player = Shared.GetEntity(self.queuedPlayerId)
            local team = self:GetTeam()
            -- There are cases when the player or team is no longer valid such as
            -- when Egg:OnDestroy() is called during server shutdown.
            if player and team then
            
                if not player:isa("AlienSpectator") then
                    error("AlienSpectator expected, instead " .. player:GetClassName() .. " was in queue")
                end
                
                player:SetEggId(Entity.invalidId)
                player:SetIsRespawning(false)
                player.spawnReductionTime = 7
                team:PutPlayerInRespawnQueue(player)
                
            end
            
        end
        
        -- Don't spawn player
        self:SetEggFree()
        
    end

    debug.replaceupvalue( Egg.OnKill, "RequeuePlayer", RequeuePlayer, true)

end