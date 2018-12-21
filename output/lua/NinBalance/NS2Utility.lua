
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





--[[
 * Does an attack with a melee capsule.
--]]
function AttackMeleeCleaveCapsule(weapon, player, damage, range, optionalCoords, altMode, filter)

    local targets = {}
    local didHit, target, endPoint, direction, surface, startPoint, trace

    if not filter then
        filter = EntityFilterTwo(player, weapon)
    end

    -- loop upto 20 times just to go through any soft targets.
    -- Stops as soon as nothing is hit or a non-soft target is hit
    for i = 1, 20 do

        local traceFilter = function(test)
            return EntityFilterList(targets)(test) or filter(test)
        end

        -- Enable tracing on this capsule check, last argument.
        didHit, target, endPoint, direction, surface, startPoint, trace = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true, 1, nil, traceFilter)
        local alreadyHitTarget = target ~= nil and table.icontains(targets, target)

        if didHit and not alreadyHitTarget then
            weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
        end

        if target and not alreadyHitTarget then
            table.insert(targets, target)
        end

        -- all targets are soft to a cleave!
        if not target then
            break
        end

    end

    HandleHitregAnalysis(player, startPoint, endPoint, trace)

    return didHit, targets[#targets], endPoint, surface

end



function GetMaxSupplyForTeam(teamNumber)

    local maxSupply = 0

    if Server then
    
        local team = GetGamerules():GetTeam(teamNumber)
        if team and team.GetNumCapturedTechPoints then
            maxSupply = team:GetNumCapturedTechPoints() * kSupplyPerTechpoint
        end
        
    else    
        
        local teamInfoEnt = GetTeamInfoEntity(teamNumber)
        if teamInfoEnt and teamInfoEnt.GetNumCapturedTechPoints then
            maxSupply = teamInfoEnt:GetNumCapturedTechPoints() * kSupplyPerTechpoint
        end

    end   

    return maxSupply 
end
