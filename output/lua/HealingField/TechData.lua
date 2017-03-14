

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techDataTable = oldBuildTechData()
    table.insert(techDataTable, 
        { [kTechDataId] = kTechId.HealingField,
        [kTechDataMapName] = HealingField.kMapName,
        [kTechDataDisplayName] = "Healing Field",
        [kTechDataCostKey] = kHealingFieldCost,
        [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight,
        [kTechDataTooltipInfo] = string.format("Heals marines in radius for %s health over %s seconds. Does not stack.", kHealingFieldAmount, kHealingFieldDuration),
        [kVisualRange] = kHealingFieldRadius,
        [kTechDataAllowStacking] = true,
        [kTechDataCollideWithWorldOnly] = true,
        [kTechDataIgnorePathingMesh] = true,
        --[kTechDataModel] = SentryBattery.kModelName,
        [kTechDataCooldown] = kHealingFieldCooldown,
        [kTechDataModel] = MedPack.kModelName,
        [kTechDataOverrideCoordsMethod] = AlignDroppack
        }
    )
    return techDataTable
end
