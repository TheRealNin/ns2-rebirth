local kGrenadeVelocity = 18
local kGrenadeBounce = 0.35
local kGrenadeFriction = 0.15
local kLauncherBarrelDist = 1.5

local function ThrowGrenade(self, player)

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()
        
        local floorAim = 1 - math.min(viewCoords.zAxis.y,0) -- this will be a number 1-2

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis * floorAim * kLauncherBarrelDist, ClusterGrenade.kRadius, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis

        local grenadeClassName = self:GetGrenadeClassName()
        player:CreatePredictedProjectile(grenadeClassName, startPoint, direction * kGrenadeVelocity, kGrenadeBounce, kGrenadeFriction)

    end

end

debug.replaceupvalue( GrenadeThrower.OnTag, "ThrowGrenade", ThrowGrenade, true)
