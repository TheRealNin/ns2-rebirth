-- shamelessly stolen from Ghoul's balance mod


--Todo: Receive this via a alienteam method
local kUpgrades = {
	[kTechId.Shell] = { kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration },
	[kTechId.Vampirism] = kTechId.Shell,
	[kTechId.Carapace] = kTechId.Shell,
	[kTechId.Regeneration] = kTechId.Shell,
	[kTechId.Veil] = { kTechId.Silence, kTechId.Aura }, --ignore Focus for autoselect
	[kTechId.Silence] = kTechId.Veil,
	[kTechId.Aura] = kTechId.Veil,
	[kTechId.Focus] = kTechId.Veil,
	[kTechId.Spur] = { kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
	[kTechId.Crush] = kTechId.Spur,
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

			newPlayer.lastUpgradeList = newPlayer.lastUpgradeList or {}
			table.insert(newPlayer.lastUpgradeList, upgrade)
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