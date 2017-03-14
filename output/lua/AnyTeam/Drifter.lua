
function Drifter:SetIncludeRelevancyMask(includeMask)

    if self:GetTeamNumber() == kTeam1Index then
        includeMask = bit.bor(includeMask, kRelevantToTeam1Commander)
    elseif self:GetTeamNumber() == kTeam2Index then
        includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
    end
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)    

end