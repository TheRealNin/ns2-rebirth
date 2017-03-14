

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techDataTable = oldBuildTechData()
    table.insert(techDataTable, 
        { [kTechDataId] = kTechId.HadesDevice,
        [kTechDataBuildRequiresMethod] = GetRoomHasNoHadesDevice,
        [kTechDataBuildMethodFailedMessage] = "Only one Hades Device allowed per room",
        [kTechDataHint] = "Explodes after a short delay",
        [kTechDataGhostModelClass] = "MarineGhostModel",
        [kTechDataMapName] = HadesDevice.kMapName,
        [kTechDataDisplayName] = "Hades Device",
        [kTechDataCostKey] = kHadesDeviceCost,
        [kTechDataPointValue] = kHadesDevicePointValue,
        [kTechDataModel] = HadesDevice.kModelName,
        [kTechDataEngagementDistance] = 2,
        [kTechDataBuildTime] = kHadesDeviceBuildTime,
        [kTechDataMaxHealth] = kHadesDeviceHealth,
        [kTechDataMaxArmor] = kHadesDeviceArmor,
        [kTechDataTooltipInfo] = string.format("After a %s second arming time, the device can be detonated by a marine dealing massive damage to everything nearby.", kHadesDeviceArmTime),
        [kTechDataHotkey] = Move.E,
        [kTechDataAlertText] = "Hades Device taking damage",
        [kTechDataNotOnInfestation] = kPreventMarineStructuresOnInfestation,
        [kVisualRange] = HadesDevice.kRange,
        [kTechDataObstacleRadius] = 0.55,
        [kTechDataOverrideCoordsMethod] = AdjustHadesDevice,
        [kTechDataCooldown] = 3
        }
    )
    return techDataTable
end