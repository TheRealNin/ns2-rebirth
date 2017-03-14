-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MapEntityLoader.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================


local function hue2rgb(p, q, t)
  if t < 0   then t = t + 1 end
  if t > 1   then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

local function rgb_to_hsl(r, g, b)
   --r, g, b = r/255, g/255, b/255
   local min = math.min(r, g, b)
   local max = math.max(r, g, b)
   local delta = max - min

   local h, s, l = 0, 0, ((min+max)/2)

   if l > 0 and l < 0.5 then s = delta/(max+min) end
   if l >= 0.5 and l < 1 then s = delta/(2-max-min) end

   if delta > 0 then
      if max == r and max ~= g then h = h + (g-b)/delta end
      if max == g and max ~= b then h = h + 2 + (b-r)/delta end
      if max == b and max ~= r then h = h + 4 + (r-g)/delta end
      h = h / 6;
   end

   if h < 0 then h = h + 1 end
   if h > 1 then h = h - 1 end

   return h * 360, s, l
end

local function _h2rgb(m1, m2, h)
  if h<0 then h = h+1 end
  if h>1 then h = h-1 end
  if h*6<1 then 
     return m1+(m2-m1)*h*6
  elseif h*2<1 then 
     return m2 
  elseif h*3<2 then 
     return m1+(m2-m1)*(2/3-h)*6
  else
     return m1
  end
end

local function hsl_to_rgb(h, s, L)
   h = h/360
   local m1, m2
   if L<=0.5 then 
      m2 = L*(s+1)
   else 
      m2 = L+s-L*s
   end
   m1 = L*2-m2


   return _h2rgb(m1, m2, h+1/3), _h2rgb(m1, m2, h), _h2rgb(m1, m2, h-1/3)
end


local function _col_amp(color)
    if not color then
      return
    end
    
    local r = color.r
    local g = color.g
    local b = color.b
    
    -- lower how green everyhing will be
    g = math.pow(g , 1.05)
    
    
    local h, s, l = rgb_to_hsl(r, g, b)
    
    if s > 1.0 then
      Print("saturation out of range, undefined behaviour: %s", s)
      s = 1.0
    end
    
    -- bring luminosity closer to center, since we can increase intensity. l=0.5 is strongest
    --local old_l = l
    --l = Clamp(0.5 * math.pow(2.0 * l, 3.0) + 0.5, 0, 1)
    --l = Clamp(((0.5 * math.pow(2.0 * l - 1, 3.0) + 0.4) + l) / 2.0, 0, 1)
    --Print("%s vs %s", old_l, l)
    -- increase saturation
    if (s > 0) then
        s = Clamp(math.pow(s, 0.95), 0,1.1)
    end
    -- convert back to rgb
    r, g, b = hsl_to_rgb(h, s, l)
    
    
    return Color(r, g, b, color.a)
end


local function ClientOnly()
    return Client ~= nil
end

local function ServerOnly()
    return Server ~= nil
end

local function ClientAndServerAndPredict()
    return Client or Server or Predict
end

function LoadEntityFromValues(entity, values, initOnly)

    entity:SetOrigin(values.origin)
    entity:SetAngles(values.angles)

    -- Copy all of the key values as fields on the entity.
    for key, value in pairs(values) do 
    
        if key ~= "origin" and key ~= "angles" then
            entity[key] = value
        end
        
    end
    
    if not initOnly then
    
        if entity.OnLoad then
            entity:OnLoad()
        end
        
    end
    
    if entity.OnInitialized then
        entity:OnInitialized()
    end
    
end

local function LoadLight(className, groupName, values)

    if not values.modified then
    
        values.modified = true
        --[[
        -- boost the saturation
        if values.color_dir_right then
            values.color_dir_right    = _col_amp(values.color_dir_right   )
            values.color_dir_left     = _col_amp(values.color_dir_left    )
            values.color_dir_up       = _col_amp(values.color_dir_up      )
            values.color_dir_down     = _col_amp(values.color_dir_down    )
            values.color_dir_forward  = _col_amp(values.color_dir_forward )
            values.color_dir_backward = _col_amp(values.color_dir_backward)
        end
        if values.color then
            values.color              = _col_amp(values.color             )
        end
        --]]
        -- boost ambient light intensity if low
        if not values.color_dir_right and values.intensity and values.intensity > 0 then
            local i = values.intensity
            local ideal = 10.0
            i = i / ideal
            if i > 1.0 then
              i = i + 1 / i
            else
              i = 2 * - math.pow(i - 1, 2) + 2
            end
            values.intensity = i * ideal
            if values.color then
                values.color              = _col_amp(values.color             )
            end
        end
        
        -- widen all the lights if we can, since they are all so bloody narrow
        -- nevermind, maps suck and have no light bleed protection
        if values.outerAngle then
            --values.outerAngle = values.outerAngle * 1.2
        end
    end
    
    if Client.lightList == nil then
        Client.lightList = { }
    end
    
    if Client.lowLightList == nil then
        Client.lowLightList = { }
    end
    
    if Client.originalLights == nil then
        Client.originalLights = { }
    end

    if Client.fullyLoaded == nil then --Game hasnt loaded yet, so build light data tables.
    
        if groupName == "Low Lights" then
            table.insert(Client.lowLightList, {className = className, groupName = groupName, values = values})
        else
            table.insert(Client.originalLights, {className = className, groupName = groupName, values = values})
        end
        
    else
    
        local renderLight = Client.CreateRenderLight()
        local coords = values.angles:GetCoords(values.origin)
        
        if values.specular == nil then
            values.specular = true
        end        
        
        if className == "light_spot" then
        
            renderLight:SetType(RenderLight.Type_Spot)
            renderLight:SetOuterCone(values.outerAngle)
            renderLight:SetInnerCone(values.innerAngle)
            renderLight:SetCastsShadows(values.casts_shadows)
            renderLight:SetSpecular(values.specular)
            
            if values.gobo_texture ~= nil then
                renderLight:SetGoboTexture(values.gobo_texture)
            end
            
            if values.shadow_fade_rate ~= nil then
                renderLight:SetShadowFadeRate(values.shadow_fade_rate)
            end
        
        elseif className == "light_point" then
        
            renderLight:SetType(RenderLight.Type_Point)
            renderLight:SetCastsShadows(values.casts_shadows)
            renderLight:SetSpecular(values.specular)

            if values.shadow_fade_rate ~= nil then
                renderLight:SetShadowFadeRate(values.shadow_fade_rate)
            end
            
        elseif className == "light_ambient" then
            
            renderLight:SetType(RenderLight.Type_AmbientVolume)
            
            renderLight:SetDirectionalColor(RenderLight.Direction_Right,    (values.color_dir_right))
            renderLight:SetDirectionalColor(RenderLight.Direction_Left,     (values.color_dir_left))
            renderLight:SetDirectionalColor(RenderLight.Direction_Up,       (values.color_dir_up))
            renderLight:SetDirectionalColor(RenderLight.Direction_Down,     (values.color_dir_down))
            renderLight:SetDirectionalColor(RenderLight.Direction_Forward,  (values.color_dir_forward))
            renderLight:SetDirectionalColor(RenderLight.Direction_Backward, (values.color_dir_backward))
            
        end

        renderLight:SetCoords(coords)
        renderLight:SetRadius(values.distance)
        renderLight:SetIntensity(values.intensity)
        renderLight:SetColor(values.color)
        renderLight:SetGroup(groupName)
        renderLight.ignorePowergrid = values.ignorePowergrid
        
        local atmosphericDensity = tonumber(values.atmospheric_density)
        
        -- Backwards compatibility
        if values.atmospheric then
            atmosphericDensity = 1.0
        end
        
        if atmosphericDensity ~= nil then
            local atmoModifier = Client.GetOptionFloat("graphics/atmospheric-density", 1.0)
            renderLight:SetAtmosphericDensity( atmosphericDensity * atmoModifier )
        end
        
        -- Save original values so we can alter and restore lights
        renderLight.originalIntensity = values.intensity
        renderLight.originalColor = values.color
        renderLight.originalCoords = Coords(coords)
        renderLight.originalAtmosphericDensity = atmosphericDensity
        
        if (className == "light_ambient") then
        
            renderLight.originalRight =     values.color_dir_right   
            renderLight.originalLeft =      values.color_dir_left    
            renderLight.originalUp =        values.color_dir_up      
            renderLight.originalDown =      values.color_dir_down    
            renderLight.originalForward =   values.color_dir_forward 
            renderLight.originalBackward =  values.color_dir_backward
            
        end
        
        renderLight.className = className
        renderLight.groupName = groupName
        renderLight.values = values
        
        table.insert(Client.lightList, renderLight)

        return true
    
    end
        
end

local function LoadBillboard(className, groupName, values)

    local renderBillboard = Client.CreateRenderBillboard()

    renderBillboard:SetOrigin(values.origin)
    renderBillboard:SetGroup(groupName)
    renderBillboard:SetMaterial(values.material)
    renderBillboard:SetSize(values.size)
    
    if Client.billboardList == nil then
        Client.billboardList = { }
    end
    table.insert(Client.billboardList, renderBillboard)
    
    return true
        
end

local function LoadDecal(className, groupName, values)

    local renderDecal = Client.CreateRenderDecal()

    if values.material == "" then
        Shared.Message(string.format("Warning: Missing or invalid decal at: %s!", ToString(values.origin)))
        return
    end
        
    local coords = values.angles:GetCoords(values.origin)
    renderDecal:SetCoords(coords)
    --renderDecal:SetGroup(groupName)
    renderDecal:SetMaterial(values.material)
    renderDecal:SetExtents(values.extents)
    
    if Client.decalList == nil then
        Client.decalList = { }
    end
    table.insert(Client.decalList, renderDecal)
    
    return true
        
end

local function LoadStaticProp(className, groupName, values)

    if values.model == "" or values.model == nil then
        Shared.Message(string.format("Warning: Missing or invalid prop at: %s!", ToString(values.origin)))
        return
    end

    local physicsModel

    local coords = values.angles:GetCoords(values.origin)
    
    coords.xAxis = coords.xAxis * values.scale.x
    coords.yAxis = coords.yAxis * values.scale.y
    coords.zAxis = coords.zAxis * values.scale.z
    
    local renderModelCommAlpha = GetAndCheckValue(values.commAlpha, 0, 1, "commAlpha", 1, true)
    local blocksPlacement = groupName == kCommanderInvisibleGroupName or
                            groupName == kCommanderInvisibleVentsGroupName or
                            groupName == kCommanderNoBuildGroupName or
                            ( gSeasonalCommanderInvisibleGroupName and groupName == gSeasonalCommanderInvisibleGroupName )

    -- Test against false so that the default is true
    if values.collidable ~= false then
    
        -- Create the physical representation of the prop.
        physicsModel = Shared.CreatePhysicsModel(values.model, false, coords, nil) 
        physicsModel:SetPhysicsType(CollisionObject.Static)
    
        -- Make it not block selection and structure placement (GetCommanderPickTarget)
        if renderModelCommAlpha < 1 or blocksPlacement then
            physicsModel:SetGroup(PhysicsGroup.CommanderPropsGroup)
        end

    end
    
    -- Only create Pathing objects if we are told too
    if values.pathInclude and not Pathing.GetLevelHasPathingMesh() then
        Pathing.CreatePathingObject(values.model, coords, values.pathWalkable or false)
    end
    
    if Client then
    
        -- Create the visual representation of the prop.
        -- All static props can be instanced.
        local renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)       
        renderModel:SetModel(values.model)
        
        if values.castsShadows ~= nil then
            renderModel:SetCastsShadows(values.castsShadows)
        end
        renderModel:SetCoords(coords)
        renderModel:SetIsStatic(true)
        renderModel:SetIsInstanced(true)
        renderModel:SetGroup(groupName)
        
        renderModel.commAlpha = renderModelCommAlpha
        renderModel.model = values.model
        
        table.insert(Client.propList, {renderModel, physicsModel})
        
    end
    
    return true

end

local function LoadSoundEffect(className, groupName, values)

    local soundEffect = Server.CreateEntity(className)
    if soundEffect then
    
        soundEffect:SetMapEntity()
        
        soundEffect:SetOrigin(values.origin)
        soundEffect:SetAngles(values.angles)
        
        Shared.PrecacheSound(values.eventName)
        soundEffect:SetAsset(values.eventName)
        
        if values.listenChannel then
            soundEffect:SetListenChannel(values.listenChannel)
        end
        
        if values.startsOnMessage and string.len(values.startsOnMessage) > 0 then
            soundEffect:RegisterSignalListener(function() soundEffect:Start() end, values.startsOnMessage)
        end

        return true
        
    end
    
    return false
    
end

local function LoadReflectionProbe(className, groupName, values)

    local renderReflectionProbe = Client.CreateRenderReflectionProbe()
    
    if values.strength == nil then
        values.strength = 1
    end

    renderReflectionProbe:SetOrigin(values.origin)
    renderReflectionProbe:SetGroup(groupName)
    renderReflectionProbe:SetRadius(values.distance)
    renderReflectionProbe:SetStrength(values.strength)
    
    if Client.reflectionProbeList == nil then
        Client.reflectionProbeList = { }
    end
    renderReflectionProbe.className = className
    renderReflectionProbe.groupName = groupName
    renderReflectionProbe.values = values

    table.insert(Client.reflectionProbeList, renderReflectionProbe)
    
    if values.__editorData ~= nil then
        cubemap = values.__editorData.reflection_probe_cubemap
    end

    if cubemap ~= nil and cubemap:GetSize() > 0 then
        renderReflectionProbe:SetCubeMapRaw( values.__editorData.reflection_probe_cubemap )
    end
    
    return true
        
end

local loadTypes = { }
loadTypes["light_spot"] = { LoadAllowed = ClientOnly, LoadFunction = LoadLight }
loadTypes["light_point"] = { LoadAllowed = ClientOnly, LoadFunction = LoadLight }
loadTypes["light_ambient"] = { LoadAllowed = ClientOnly, LoadFunction = LoadLight }
loadTypes["prop_static"] = { LoadAllowed = ClientAndServerAndPredict, LoadFunction = LoadStaticProp }
loadTypes["sound_effect"] = { LoadAllowed = ServerOnly, LoadFunction = LoadSoundEffect }
loadTypes["billboard"] = { LoadAllowed = ClientOnly, LoadFunction = LoadBillboard }
loadTypes["decal"] = { LoadAllowed = ClientOnly, LoadFunction = LoadDecal }
loadTypes["reflection_probe"] = { LoadAllowed = ClientOnly, LoadFunction = LoadReflectionProbe }

--
-- This will load common map entities for the Client, Server, or both.
-- Call LoadMapEntity() with the map name of the entity and the map values
-- and it will be loaded. Returns true on success.
--
function LoadMapEntity(className, groupName, values)
    local loadData = loadTypes[className]
    if loadData and loadData.LoadAllowed() and IsGroupActiveInSeason(groupName, GetSeason()) then
        return loadData.LoadFunction(className, groupName, values)
    end
    return false

end