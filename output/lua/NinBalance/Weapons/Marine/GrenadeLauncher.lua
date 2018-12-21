local kGrenadeSpeed = 25
local kGrenadeBounce = 0.15
local kGrenadeFriction = 0.35
local kLauncherBarrelDist = 1.5

local function ShootGrenade(self, player)

    PROFILE("ShootGrenade")
    
    self:TriggerEffects("grenadelauncher_attack")

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()
        
        local floorAim = 1 - math.min(viewCoords.zAxis.y,0) -- this will be a number 1-2

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis * floorAim * kLauncherBarrelDist, Grenade.kRadius+0.0001, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis

        local grenade = player:CreatePredictedProjectile("Grenade", startPoint, direction * kGrenadeSpeed, kGrenadeBounce, kGrenadeFriction)
    
    end

end

debug.replaceupvalue( GrenadeLauncher.FirePrimary, "ShootGrenade", ShootGrenade, true)

-- for fast reloading
function GrenadeLauncher:GetCatalystSpeedBase()
	local base = ClipWeapon.GetCatalystSpeedBase and ClipWeapon.GetCatalystSpeedBase(self) or 1
    if self:GetIsReloading() or not self.primaryAttacking then
        return kGrenadeLauncherReload * base
    end
    return base
end
