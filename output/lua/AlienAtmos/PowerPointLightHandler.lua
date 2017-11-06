Script.Load("lua/uniqueAlienAtmos_Elixer/Elixer_Utility.lua")
Elixer.UseVersion(1.8)

local kMinCommanderLightIntensityScalar = 0.3

local kPowerDownTime = 1
local kOffTime = 15
local kLowPowerCycleTime = 1
local kDamagedCycleTime = 0.2
local kDamagedMinIntensity = 0.5
local kAuxPowerMinIntensity = 0
local kAuxPowerMinCommanderIntensity = 3
local kNoPowerIntensity = 0.05 -- 0.02
local kNoPowerMinIntensity = 0.4

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
    return color
    --[[
    if not color then
      return
    end
    
    local r = color.r
    local g = color.g
    local b = color.b
    local h, s, l = rgb_to_hsl(r, g, b)
    
    if s > 1.0 then
      Print("saturation out of range, undefined behaviour: %s", s)
      s = 1.0
    end
    
    -- bring luminosity closer to center, since we can increase intensity. l=0.5 is strongest
    --l = Clamp(0.5 * math.pow(2.0 * l, 3.0) + 0.5, 0, 1)
    --local old_l = l
    l = Clamp(((0.5 * math.pow(2.0 * l - 1, 3.0) + 0.5) + l) / 2.0, 0, 1)
    --Print("%s vs %s", old_l, l)
    -- increase saturation
    if (s > 0) then
        s = Clamp(math.pow(s, 0.1), 0,1)
    end
    -- convert back to rgb
    r, g, b = hsl_to_rgb(h, s, l)
    
    -- lower how green everyhing is now
    g = math.pow(g, 1.1)
    
    
    return Color(r, g, b, color.a)
    --]]
end

-- set the intensity and color for a light. If the renderlight is ambient, we set the color
-- the same in all directions
local function SetLight(renderLight, intensity, color)
    
    
    if intensity then
        --boost intensity if it is below 40ish
        --intensity = 2 * 15 * (math.pow(intensity, 0.3) / 15.0) + intensity * 0.85
        renderLight:SetIntensity(intensity)
    end
    
    if color then
    
        renderLight:SetColor(_col_amp(color))
        
        if renderLight:GetType() == RenderLight.Type_AmbientVolume then
        
            renderLight:SetDirectionalColor(RenderLight.Direction_Right,    _col_amp(color))
            renderLight:SetDirectionalColor(RenderLight.Direction_Left,     _col_amp(color))
            renderLight:SetDirectionalColor(RenderLight.Direction_Up,       _col_amp(color))
            renderLight:SetDirectionalColor(RenderLight.Direction_Down,     _col_amp(color))
            renderLight:SetDirectionalColor(RenderLight.Direction_Forward,  _col_amp(color))
            renderLight:SetDirectionalColor(RenderLight.Direction_Backward, _col_amp(color))
            
        end
        
    end
    
end

ReplaceUpValue(NormalLightWorker.Run, "SetLight", SetLight, { LocateRecurse = true; CopyUpValues = true; } )

function NormalLightWorker:RestoreColor(renderLight)
    
    renderLight:SetColor((renderLight.originalColor))

    if renderLight:GetType() == RenderLight.Type_AmbientVolume then

        renderLight:SetDirectionalColor(RenderLight.Direction_Right,   (renderLight.originalRight   ) )
        renderLight:SetDirectionalColor(RenderLight.Direction_Left,    (renderLight.originalLeft    ) )
        renderLight:SetDirectionalColor(RenderLight.Direction_Up,      (renderLight.originalUp      ) )
        renderLight:SetDirectionalColor(RenderLight.Direction_Down,    (renderLight.originalDown    ) )
        renderLight:SetDirectionalColor(RenderLight.Direction_Forward, (renderLight.originalForward ) )
        renderLight:SetDirectionalColor(RenderLight.Direction_Backward,(renderLight.originalBackward) )
        
    end

end

-- Turning on full power.
-- When turn on full power, the lights are never decreased in intensity.
--
function NormalLightWorker:Run()

    PROFILE("NormalLightWorker:Run")

    local timeOfChange = self.handler.powerPoint:GetTimeOfLightModeChange()
    local time = Shared.GetTime()
    local timePassed = time - timeOfChange    

    if self.activeProbes then
    
        local startFullLightTime = PowerPoint.kMinFullLightDelay
        local fullFullLightTime = startFullLightTime + PowerPoint.kFullPowerOnTime      
        
        local probeTint = nil
        
        if timePassed < startFullLightTime then
            -- we don't change lights or color during this period
            probeTint = nil
        else
            probeTint = Color(1, 1, 1, 1)
            self.activeProbes = false
        end

        if probeTint ~= nil then
            for _,probe in ipairs(self.handler.probeTable) do
                probe:SetTint( Color(1, 1, 1, 1) )
            end
         end
        
    end

    for _,renderLight in ipairs(self.activeLights) do

        local intensity = nil
        local randomValue = renderLight.randomValue
    
        local startFullLightTime = PowerPoint.kMinFullLightDelay + PowerPoint.kMaxFullLightDelay * randomValue
        -- time when full lightning is achieved
        local fullFullLightTime = startFullLightTime + PowerPoint.kFullPowerOnTime  
 
        if timePassed < startFullLightTime then

            -- we don't change lights or color during this period
            intensity = nil
          
        elseif timePassed < fullFullLightTime then
            
            -- the period when lights start to come on, possibly with a little flickering
            local t = timePassed - startFullLightTime
            local scalar = math.sin(( t / PowerPoint.kFullPowerOnTime  ) * math.pi / 2)
            intensity = renderLight.originalIntensity * scalar
            
            if renderLight.flickering == nil and intensity < renderLight:GetIntensity() then
                -- don't change anything until we exceed the origin light intensity.
                intensity = nil
            else
            
                if renderLight.flickering == nil then
                    self:RestoreColor(renderLight)
                end
                intensity = intensity * self:CheckFlicker(renderLight,PowerPoint.kFullFlickerChance, scalar)
                
            end
            
        else
            
            intensity = renderLight.originalIntensity
            
            self:RestoreColor(renderLight)
            
            -- remove this light from processing
            self.activeLights[renderLight] = nil
            
        end
        
        -- color are only changed once during the full-power-on
        SetLight(renderLight, intensity, nil)

    end

end
--
-- handles lights when the powerpoint has no power. This involves a time with no lights,
-- and then a period when lights are coming on line into aux power setting. Once the aux light
-- has stabilized, the lights will stay mostly steady, but will sometimes cycle a bit.
--
-- Performance wise, we shift lights from the activeLights table over to lightgroups. Each group
-- of lights stay fixed for a while, then starts to cycle as one for another span of time. Done
-- this way so that we can avoid running the lights most of the time.
--
function NoPowerLightWorker:Run()

    PROFILE("NoPowerLightWorker:Run")

    local timeOfChange = self.handler.powerPoint:GetTimeOfLightModeChange()
    local time = Shared.GetTime()
    local timePassed = time - timeOfChange    
    
    local startAuxLightTime = kPowerDownTime
    local fullAuxLightTime = startAuxLightTime + PowerPoint.kAuxPowerCycleTime
    local startAuxLightFailTime = fullAuxLightTime + PowerPoint.kAuxLightSafeTime
    local totalAuxLightFailTime = startAuxLightFailTime + PowerPoint.kAuxLightDyingTime
    
    local probeTint
    
    if timePassed < kPowerDownTime then
        local intensity = math.sin(Clamp(timePassed / kPowerDownTime, 0, 1) * math.pi / 2)
        probeTint = Color(intensity, intensity, intensity, 1)
    elseif timePassed < startAuxLightTime then
        probeTint = Color(0, 0, 0, 1)
    elseif timePassed < fullAuxLightTime then
    
        -- Fade red in smoothly. t will stay at zero during the individual delay time
        local t = timePassed - startAuxLightTime
        -- angle goes from zero to 90 degres in one kAuxPowerCycleTime
        local angleRad = (t / PowerPoint.kAuxPowerCycleTime) * math.pi / 2
        -- and scalar goes 0->1
        local scalar = kNoPowerIntensity

        probeTint = Color(PowerPoint.kDisabledProbeColor.r * scalar,
                          PowerPoint.kDisabledProbeColor.g * scalar,
                          PowerPoint.kDisabledProbeColor.b * scalar,
                          1)
 
    else
        self.activeProbes = false
    end

    if self.activeProbes then    
        for _, probe in ipairs(self.handler.probeTable) do
            probe:SetTint( probeTint )
        end
    end

    local removeLights = {}
    
    for _, renderLight in ipairs(self.activeLights) do
        
        local randomValue = renderLight.randomValue
        -- aux light starting to come on
        local startAuxLightTime = kPowerDownTime + kOffTime + randomValue * PowerPoint.kMaxAuxLightDelay 
        -- ... fully on
        local fullAuxLightTime = startAuxLightTime + PowerPoint.kAuxPowerCycleTime
        -- aux lights starts to fade
        local startAuxLightFailTime = fullAuxLightTime + PowerPoint.kAuxLightSafeTime + randomValue * PowerPoint.kAuxLightFailTime
        -- ... and dies completly
        local totalAuxLightFailTime = startAuxLightFailTime + PowerPoint.kAuxLightDyingTime
        
        local intensity = nil
        local color = nil
        
        local showCommanderLight = false
        
        local player = Client.GetLocalPlayer()
        if player and player:isa("Commander") then
            showCommanderLight = true
        end
        
        if timePassed < kPowerDownTime then
        
            local scalar = math.sin(Clamp(timePassed / kPowerDownTime, 0, 1) * math.pi / 2)
            scalar = (1 - scalar)
            if showCommanderLight then
                scalar = math.max(kMinCommanderLightIntensityScalar, scalar)
            end
            intensity = renderLight.originalIntensity * (1 - scalar)

        elseif timePassed < startAuxLightTime then
        
            if showCommanderLight then
                intensity = renderLight.originalIntensity * kMinCommanderLightIntensityScalar
            else
                intensity = 0  
            end     
            
        elseif timePassed < fullAuxLightTime then
        
            -- Fade red in smoothly. t will stay at zero during the individual delay time
            local t = timePassed - startAuxLightTime
            -- angle goes from zero to 90 degres in one kAuxPowerCycleTime
            local angleRad = (t / PowerPoint.kAuxPowerCycleTime) * math.pi / 2
            -- and scalar goes 0->1
            local scalar = kNoPowerIntensity
            
            if showCommanderLight then
                scalar = math.max(kMinCommanderLightIntensityScalar, scalar)
            end
            
            intensity = math.max(scalar * renderLight.originalIntensity, kNoPowerMinIntensity)
            
            if showCommanderLight then
                color = PowerPoint.kDisabledCommanderColor
            else
                color = PowerPoint.kDisabledColor
            end
     
        else
        
            -- Deactivate from initial state
            table.insert(removeLights, renderLight)

            -- in steady state, we shift lights between a constant state and a varying state.
            -- We assign each light to one of several groups, and then randomly start/stop cycling for each group.
            local lightGroupIndex = math.random(1, NoPowerLightWorker.kNumGroups)
            table.insert(self.lightGroups[lightGroupIndex].lights,renderLight)
            
        end
        if intensity then
          SetLight(renderLight, intensity, color)
        end
        
    end
    
    for i = 1, #removeLights do
        table.removevalue(self.activeLights, removeLights[i])
    end

    -- handle the light-cycling groups.
    for _,lightGroup in ipairs(self.lightGroups) do
        lightGroup:Run(timePassed)
    end

end


function LightGroup:RunCycle( time)

    if time > self.cycleEndTime then
    
        -- end varying cycle and fix things for a while. Note that the intensity will
        -- stay a bit random, which is all to the good.
        self.stateFunction = LightGroup.RunFixed
        self.nextThinkTime = time + math.random(10)
        self.cycleUsedTime = self.cycleUsedTime + (time - self.cycleStartTime)
        
    else
    
        -- this is the time used to calc intensity. This is calculated so that when
        -- we restart after a pause, we continue where we left off.
        local t = time - self.cycleStartTime + self.cycleUsedTime 
        
        local showCommanderLight = false
        local player = Client.GetLocalPlayer()
        if player and player:isa("Commander") then
            showCommanderLight = true
        end
        
        for _,renderLight in ipairs(self.lights) do
        
            -- Fade disabled color in and out to make it very clear that the power is out
            local scalar = kNoPowerIntensity
            
            color = PowerPoint.kDisabledColor
            
            if showCommanderLight then
            
                color = PowerPoint.kDisabledCommanderColor
                
            end
            
            intensity = math.max(renderLight.originalIntensity * scalar, kNoPowerMinIntensity)
            
            SetLight(renderLight, intensity, color)
            
        end
        
    end
    
end


function PowerPointLightHandler:Reset()

    self.lightTable = { }
    self.probeTable = { }
    
    -- all lights for this powerPoint, and filter away those that
    -- shouldn't be affected by the power changes
    for _, light in ipairs(GetLightsForLocation(self.powerPoint:GetLocationName())) do
    
        if not light.ignorePowergrid then
            table.insert(self.lightTable, light)
        end
        
    end
    
    self.probeTable = GetReflectionProbesForLocation(self.powerPoint:GetLocationName())

    self.workerTable = {
        [kLightMode.Normal] = NormalLightWorker():Init(self, "normal"),
        [kLightMode.NoPower] = NoPowerLightWorker():Init(self, "nopower"),
        [kLightMode.LowPower] = LowPowerLightWorker():Init(self, "lowpower"),
        [kLightMode.Damaged] = DamagedLightWorker():Init(self, "damaged"),
    }
    
    self:Run(kLightMode.NoPower)

end