
local kSpreadDistance = kShotgunSpreadDistance
local medSpread = 0.707 * 1.1
Shotgun.kSpreadVectors =
{
    GetNormalizedVector(Vector(-0.01, 0.01, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-medSpread, medSpread, kSpreadDistance)),
    GetNormalizedVector(Vector(medSpread, medSpread, kSpreadDistance)),
    GetNormalizedVector(Vector(medSpread, -medSpread, kSpreadDistance)),
    GetNormalizedVector(Vector(-medSpread, -medSpread, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kSpreadDistance))
}
function Shotgun:GetBulletFalloffStart()
    return kShotgunDamageFalloffStart
end

function Shotgun:GetBulletFalloffEnd()
    return kShotgunDamageFalloffEnd
end

function Shotgun:GetBulletFalloffFraction()
    return kShotgunDamageFalloffFraction
end

local oldOnTag = Shotgun.OnTag
function Shotgun:OnTag(tagName)
    oldOnTag(self, tagName)
    
    if tagName == "shoot" then
        local player = self:GetParent()
        player:Reload()
    end
end