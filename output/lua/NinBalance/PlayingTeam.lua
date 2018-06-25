
--[[
local oldUpdateMinResTick = PlayingTeam.UpdateMinResTick
function PlayingTeam:UpdateMinResTick()
    oldUpdateMinResTick(self)
    
    if not self.timeLastFlatResUpdate or self.timeLastFlatResUpdate + kResourceTowerResourceInterval <= Shared.GetTime() then
    
        self:AddTeamResources(kTeamResourceFlatRate)
        
        self.timeLastFlatResUpdate = Shared.GetTime()
    end
end
]]--