-- Returns the name of the player's lifeform
local oldGetPlayerStatusDesc = Alien.GetPlayerStatusDesc
function Alien:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void
    
    if self:GetIsAlive() and self:isa("Embryo") and self.gestationTypeTechId == kTechId.WraithFade then
        return kPlayerStatus.FadeEgg
    end
    
    return oldGetPlayerStatusDesc(self)

end
