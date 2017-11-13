
-- for performance, cache the lights for each locationName
local propLightLocationCache = {}

function GetPropLightsForLocation(locationName)

    if locationName == nil or locationName == "" or not Client.lightPropList then
        return {}
    end

    if propLightLocationCache[locationName] then
        return propLightLocationCache[locationName]
    end

    local lightList = {}

    local locations = GetLocationEntitiesNamed(locationName)

    if table.icount(locations) > 0 then

        for _, location in ipairs(locations) do

            for _, propLight in ipairs(Client.lightPropList) do

                if propLight then

                    local lightOrigin = propLight:GetCoords().origin

                    if location:GetIsPointInside(lightOrigin) then

                        table.insert(lightList, propLight)

                    end

                end

            end

        end

    end

    -- Log("Total prop lights %s, lights in %s = %s", #Client.lightPropList, locationName, #lightList)
    propLightLocationCache[locationName] = lightList

    return lightList

end