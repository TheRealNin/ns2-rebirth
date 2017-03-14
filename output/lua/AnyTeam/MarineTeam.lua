
function MarineTeam:SpawnWarmUpStructures()
    local techPoint = self.startTechPoint
    if not (Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode) then
        MakeTechEnt(techPoint, AdvancedArmory.kMapName, 3.5, -2, self:GetTeamNumber())
        MakeTechEnt(techPoint, PrototypeLab.kMapName, -3.5, 2, self:GetTeamNumber())
    end
end