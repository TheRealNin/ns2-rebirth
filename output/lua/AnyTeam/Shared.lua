
Script.Load("lua/AnyTeam/AnyTeamEffects.lua")


Script.Load("lua/AnyTeam/PrecursorTeamInfo.lua")
Script.Load("lua/AnyTeam/RepairBot.lua")

-- nullify some stuff
Shared.GetDevMode = function(...)

end
HPrint = function(...)

end