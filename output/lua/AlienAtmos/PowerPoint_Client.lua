

local kPrimedSound = PrecacheAsset("sound/NS2.fev/common/door_lock")
local kBuildMeSound = PrecacheAsset("sound/NS2.fev/common/door_unlock")
Client.PrecacheLocalSound(kPrimedSound)
Client.PrecacheLocalSound(kBuildMeSound)

PowerPoint.kDisabledColor = Color(0.02, 0.18, 0.75)
PowerPoint.kDisabledSpotlight = Color(0.02, 0.18, 1.0)
PowerPoint.kDisabledProbeColor = Color(0.48, 0.000, 1.0)

PowerPoint.kDisabledCommanderColor = Color(0.02, 0.18, 1.0)
PowerPoint.kAuxPowerCycleTime = 20
-- chance of a aux light flickering when powering up
PowerPoint.kAuxFlickerChance = 0
-- chance of a full light flickering when powering up
PowerPoint.kFullFlickerChance = 0.30

-- determines if aux lights will randomly fail after they have come on for a certain amount of time
PowerPoint.kAuxLightsFail = false

-- max varying delay to turn on full lights
PowerPoint.kMaxFullLightDelay = 4
-- min 2 seconds from repairing the node till the light goes on
PowerPoint.kMinFullLightDelay = 0
-- how long time for the light to reach full power (PowerOnTime was a bit brutal and give no chance for the flicker to work)
PowerPoint.kFullPowerOnTime = 4

-- max varying delay to turn on aux lights
PowerPoint.kMaxAuxLightDelay = 4

-- minimum time that aux lights are on before they start going out
PowerPoint.kAuxLightSafeTime = 2 -- short for testing, should be like 300 (5 minutes)
-- maximum time for a power point to stay on after the safe time
PowerPoint.kAuxLightFailTime = 2 -- short .. should be like 600 (10 minues)
-- how long time a light takes to go from full aux power to dead (last 1/3 of that time is spent flickering)
PowerPoint.kAuxLightDyingTime = 2
