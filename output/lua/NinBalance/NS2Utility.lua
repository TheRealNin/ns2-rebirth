
function SetPlayerPoseParameters(player, viewModel, headAngles)

    local coords = player:GetCoords()

    local pitch = -Math.Wrap(Math.Degrees(headAngles.pitch), -180, 180)

    local landIntensity = player.landIntensity or 0

    local bodyYaw = 0
    if player.bodyYaw then
        bodyYaw = Math.Wrap(Math.Degrees(player.bodyYaw), -180, 180)
    end

    local bodyYawRun = 0
    if player.bodyYawRun then
        bodyYawRun = Math.Wrap(Math.Degrees(player.bodyYawRun), -180, 180)
    end

    local headCoords = headAngles:GetCoords()

    local velocity = player:GetVelocityFromPolar()
    -- Not all players will contrain their movement to the X/Z plane only.
    if player.GetMoveSpeedIs2D and player:GetMoveSpeedIs2D() then
        velocity.y = 0
    end

    local x = Math.DotProduct(headCoords.xAxis, velocity)
    local z = Math.DotProduct(headCoords.zAxis, velocity)
    local moveYaw = Math.Wrap(Math.Degrees( math.atan2(z,x) ), -180, 180)

    local moveSpeed = player.velocityLengthSmoothed / player:GetMaxSpeed(true)

    local crouchAmount = HasMixin(player, "CrouchMove") and player:GetCrouchAmount() or 0
    if player.ModifyCrouchAnimation then
        crouchAmount = player:ModifyCrouchAnimation(crouchAmount)
    end

    player:SetPoseParam("move_yaw", moveYaw)
    player:SetPoseParam("move_speed", moveSpeed)
    player:SetPoseParam("body_pitch", pitch)
    player:SetPoseParam("body_yaw", bodyYaw)
    player:SetPoseParam("body_yaw_run", bodyYawRun)
    player:SetPoseParam("crouch", crouchAmount)
    player:SetPoseParam("land_intensity", landIntensity)

    if viewModel then

        viewModel:SetPoseParam("move_yaw", moveYaw)
        viewModel:SetPoseParam("move_speed", moveSpeed)
        viewModel:SetPoseParam("body_pitch", pitch)
        viewModel:SetPoseParam("body_yaw", bodyYaw)
        viewModel:SetPoseParam("body_yaw_run", bodyYawRun)
        viewModel:SetPoseParam("crouch", crouchAmount)
        viewModel:SetPoseParam("land_intensity", landIntensity)

    end

end
