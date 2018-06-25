
--Insight upgrades bitmask table
local techUpgradesTable =
{
    kTechId.Jetpack,
    kTechId.Welder,
    kTechId.ClusterGrenade,
    kTechId.PulseGrenade,
    kTechId.GasGrenade,
    kTechId.Mine,

    kTechId.Vampirism,
    kTechId.Carapace,
    kTechId.Regeneration,

    kTechId.Aura,
    kTechId.Focus,
    kTechId.Camouflage,

    kTechId.Celerity,
    kTechId.Adrenaline,
    kTechId.Silence,

    kTechId.Parasite
}
local techUpgradesBitmask = CreateBitMask(techUpgradesTable)

function GetTechIdsFromBitMask(techTable)

    local techIds = { }

    if techTable and techTable > 0 then
        for _, techId in ipairs(techUpgradesTable) do
            local bitmask = techUpgradesBitmask[techId]
            if bit.band(techTable, bitmask) > 0 then
                table.insert(techIds, techId)
            end
        end
    end

    --Sort the table by bitmask value so it keeps the order established in the original table
    table.sort(techIds, function(a, b) return techUpgradesBitmask[a] < techUpgradesBitmask[b] end)

    return techIds
end
--debug.replaceupvalue( PlayerInfoEntity.UpdateScore, "techUpgradesTable", techUpgradesTable, true)
debug.setupvaluex( PlayerInfoEntity.UpdateScore, "techUpgradesBitmask", techUpgradesBitmask, true)