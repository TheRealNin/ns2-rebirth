
local oldInitialize = ReadyRoomTeam.Initialize
function ReadyRoomTeam:Initialize(teamName, teamNumber)

    oldInitialize(self, teamName, teamNumber)
    self.respawnEntity = Gorge.kMapName
end

function ReadyRoomTeam:GetRespawnMapName(player)

    return Gorge.kMapName
    
end