

-- Set light shake amount due to nearby roaming Onos
-- disable for perf
function Player:SetLightShakeAmount(amount, duration, scalar)
    --[[
    if scalar == nil then
        scalar = 1
    end

    -- So lights start moving in time with footsteps
    self:ResetShakingLights()

    self.lightShakeAmount = Clamp(amount, 0, 1)

    -- Save off original amount so we can have it fall off nicely
    self.savedLightShakeAmount = self.lightShakeAmount

    self.lightShakeEndTime = Shared.GetTime() + duration

    self.lightShakeScalar = scalar
    ]]--
end

local originalUpdateClientEffects = Player.UpdateClientEffects
-- Disabled because perf
function Player:UpdateClientEffects(deltaTime, isLocal)

    if isLocal then
        self:UpdateCommanderPingSound()
    end

    -- Rumbling effects due to Onos
    --self:UpdateShakingLights(deltaTime)
    --self:UpdateDirtFalling(deltaTime)
    --self:UpdateOnosRumble(deltaTime)

end


-- from https://gamedev.stackexchange.com/questions/126267/my-perlin-noise-height-map-doesnt-have-smooth-transitions-and-goes-directly-fro
local function f(t)
    return t * t * t * (t * (6 * t - 15) + 10)
end

local function l(t, a, b)
    return a + t * (b - a)
end

local function g(h, x, y, z)
    local h, u, v, r = h % 16
    if h < 8 then u = x else u = y end
    if h < 4 then v = y elseif h == (12 or 14) then v = x else v = z end
    if h % 2 == 0 then r = u else r = -u end
    if h % 4 == 0 then r = r + v else r = r - v end
    return r
end

local m = math.modf
local function noise(o, x, y, z)
    y, z = y or 1 / 3, z or 2 / 3
    local f, l, g, m = f, l, g, m
    local X, x = m(x % 256)
    local Y, y = m(y % 256)
    local Z, z = m(z % 256)
    local u, v, w = f(x), f(y), f(z)
    local A = o[X] + Y
    local AA = o[A] + Z
    local AB = o[A + 1] + Z
    local B = o[X + 1] + Y
    local BA = o[B] + Z
    local BB = o[B + 1] + Z
    return l(w, l(v, l(u, g(o[AA], x, y, z), 
            g(o[BA], x - 1, y, z)), 
            l(u, g(o[AB], x, y - 1, z), 
            g(o[BB], x - 1, y - 1, z))),
            l(v, l(u, g(o[AA + 1], x, y, z - 1),  
            g(o[BA + 1], x - 1, y, z - 1)),
            l(u, g(o[AB + 1], x, y - 1, z - 1),
            g(o[BB + 1], x - 1, y - 1, z - 1))))
end

local m = {
 __index = function(t, i)
        return type(i) == "number" and t[i % 256] or noise
 end}

function Perlin(s)
    local o = {}
    local rand = math.random
    local _ = s and math.randomseed(tonumber(s) or os.time())
    for n = 0, 255 do
     local t = rand(0, 255)
      while o[t] do
           t = rand(0, 255)
     end
      o[t] = n
    end
    return setmetatable(o, m)
end

local cameraShakeFalloff = 0.15

function Player:SetCameraShake(amount, speed, time)

    local currentTime = Shared.GetTime()
    local delta = currentTime - self.cameraShakeLastTime

    self.cameraShakeAmount = math.max((self.cameraShakeAmount - cameraShakeFalloff * delta), 0) + amount

    -- "bumps" per second
    self.cameraShakeSpeed = 10

    self.cameraShakeLastTime = currentTime

    return true

end

local perlin_pitch = Perlin(Shared.GetTime()+1)
local perlin_yaw = Perlin(Shared.GetTime()+2)
function Player:GetCameraViewCoordsOverride(cameraCoords)

    local initialAngles = Angles()
    initialAngles:BuildFromCoords(cameraCoords)

    local continue = true

    if not self:GetIsAlive() and self:GetAnimateDeathCamera() and self:GetRenderModel() then

        local attachCoords = self:GetAttachPointCoords(self:GetHeadAttachpointName())

        local animationIntensity = 0.2
        local movementIntensity = 0.5

        cameraCoords.yAxis = GetNormalizedVector(cameraCoords.yAxis + attachCoords.yAxis * animationIntensity)
        cameraCoords.xAxis = cameraCoords.yAxis:CrossProduct(cameraCoords.zAxis)
        cameraCoords.zAxis = cameraCoords.xAxis:CrossProduct(cameraCoords.yAxis)

        cameraCoords.origin.x = cameraCoords.origin.x + (attachCoords.origin.x - cameraCoords.origin.x) * movementIntensity
        cameraCoords.origin.y = attachCoords.origin.y
        cameraCoords.origin.z = cameraCoords.origin.z + (attachCoords.origin.z - cameraCoords.origin.z) * movementIntensity

        return cameraCoords

    end

    if self:GetCountdownActive() and not Shared.GetCheatsEnabled() then

        if HasMixin(self, "Team") and (self:GetTeamNumber() == kMarineTeamType or self:GetTeamNumber() == kAlienTeamType) then
            cameraCoords = self:GetCameraViewCoordsCountdown(cameraCoords)
            Client.SetYaw(self.viewYaw)
            Client.SetPitch(self.viewPitch)
            continue = false
        end

        if not self.clientCountingDown then

            self.clientCountingDown = true
            if self.OnCountDown then
                self:OnCountDown()
            end

        end

    end

    if continue then

        if self.clientCountingDown then
            self.clientCountingDown = false

            if self.OnCountDownEnd then
                self:OnCountDownEnd()
            end
        end

        local activeWeapon = self:GetActiveWeapon()
        local animateCamera = activeWeapon and (not activeWeapon.GetPreventCameraAnimation or not activeWeapon:GetPreventCameraAnimation(self))

        -- clamp the yaw value to prevent sudden camera flip
        local cameraAngles = Angles()
        cameraAngles:BuildFromCoords(cameraCoords)
        cameraAngles.pitch = Clamp(cameraAngles.pitch, -kMaxPitch, kMaxPitch)

        cameraCoords = cameraAngles:GetCoords(cameraCoords.origin)

        -- Add in camera movement from view model animation
        if self:GetCameraDistance() == 0 then

            local viewModel = self:GetViewModelEntity()
            if viewModel and animateCamera then

                local success, viewModelCameraCoords = viewModel:GetCameraCoords()
                if success then

                    -- If the view model coords has scaling in it that can affect
                    -- our later calculations, so remove it.
                    viewModelCameraCoords.xAxis:Normalize()
                    viewModelCameraCoords.yAxis:Normalize()
                    viewModelCameraCoords.zAxis:Normalize()

                    cameraCoords = cameraCoords * viewModelCameraCoords

                end

            end

        end

        -- Allow weapon or ability to override camera (needed for Blink)
        if activeWeapon then

            local override, newCoords = activeWeapon:GetCameraCoords()

            if override then
                cameraCoords = newCoords
            end

        end

        -- Add in camera shake effect if any

        -- Camera shake knocks view up and down a bit
        local currentTime = Shared.GetTime()
        local delta = currentTime - self.cameraShakeLastTime
        local shakeAmount = math.pow(math.max((self.cameraShakeAmount - cameraShakeFalloff * delta), 0) * 10, 0.1) * 0.05
        local shakeSpeed = currentTime * self.cameraShakeSpeed * 2
        local origin = Vector(cameraCoords.origin)

        --cameraCoords.origin = cameraCoords.origin + self.shakeVec*shakeAmount
        local yaw = GetYawFromVector(cameraCoords.zAxis)-- + perlin_yaw:noise(shakeSpeed) * shakeAmount
        local pitch = GetPitchFromVector(cameraCoords.zAxis) + perlin_pitch:noise(shakeSpeed) * shakeAmount

        local angles = Angles(Clamp(pitch, -kMaxPitch, kMaxPitch), yaw, 0)
        cameraCoords = angles:GetCoords(origin)


        cameraCoords = self:PlayerCameraCoordsAdjustment(cameraCoords)

    end

    local resultingAngles = Angles()
    resultingAngles:BuildFromCoords(cameraCoords)
    --[[
    local fovScale = 1

    if self:GetNumModelCameras() > 0 then
        local camera = self:GetModelCamera(0)
        fovScale = camera:GetFov() / math.rad(self:GetFov())
    else
        fovScale = 65 / self:GetFov()
    end

    self.pitchDiff = GetAnglesDifference(resultingAngles.pitch, initialAngles.pitch) * fovScale
    ]]

    return cameraCoords

end