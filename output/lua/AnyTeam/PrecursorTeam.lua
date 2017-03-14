Script.Load("lua/AnyTeam/RepairBot.lua")

class 'PrecursorTeam' (PlayingTeam)


function PrecursorTeam:GetTeamType()
    return kPrecursorTeamType
end

function PrecursorTeam:GetIsAlienTeam()
    return false
end

function MarineTeam:GetIsMarineTeam()
    return false 
end

function PrecursorTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = RepairBot.kMapName

    -- List stores all the structures owned by builder player types such as the Gorge.
    -- This list stores them based on the player platform ID in order to maintain structure
    -- counts even if a player leaves and rejoins a server.
    self.clientOwnedStructures = { }
end


function PrecursorTeam:OnInitialized()

    PlayingTeam.OnInitialized(self)
    
    self.clientOwnedStructures = { }
    
end
