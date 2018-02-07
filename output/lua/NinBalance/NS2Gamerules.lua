

function NS2Gamerules:DestroyActuallyUnusedPowerNodes()

    local powerConsumers = GetEntitiesWithMixinForTeam("PowerConsumer", kTeam1Index)
    local roomsNeedingPower = {}
    for i=1, #powerConsumers do
        if powerConsumers[i] then
            roomsNeedingPower[powerConsumers[i]:GetLocationId()] = true
        end
    end
    powerConsumers = GetEntitiesWithMixinForTeam("PowerConsumer", kTeam2Index)
    for i=1, #powerConsumers do
        if powerConsumers[i] then
            roomsNeedingPower[powerConsumers[i]:GetLocationId()] = true
        end
    end
    local powerNodes = EntityListToTable(Shared.GetEntitiesWithClassname("PowerPoint"))
    for i=1, #powerNodes do
        if powerNodes[i] then
            if not powerNodes[i]:GetIsSocketed() then
                powerNodes[i]:SocketPowerNode()
            end
            if not powerNodes[i]:GetIsBuilt() then
                powerNodes[i]:SetConstructionComplete()
            end
            if not roomsNeedingPower[powerNodes[i]:GetLocationId()] then
                -- power is permanently destroyed in all other rooms
                powerNodes[i]:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
                powerNodes[i]:SetLightMode(kLightMode.NoPower)
                
                -- Fake kill it
                powerNodes[i].health = 0
                powerNodes[i].armor = 0
                powerNodes[i].alive = false
                powerNodes[i]:OnKill()
            end
        end
    end
end

local oldResetGame = NS2Gamerules.ResetGame
function NS2Gamerules:ResetGame()
    oldResetGame(self)
    self:DestroyActuallyUnusedPowerNodes()
end