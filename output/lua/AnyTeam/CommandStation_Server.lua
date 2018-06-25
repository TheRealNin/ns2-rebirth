
local function KillPlayersInside(self)

    for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
    
        if not player:isa("Commander") and not player:isa("Spectator") then
        
            if self:GetIsPlayerInside(player) and player:GetId() ~= self.playerIdStartedLogin then
            
                player:Kill(self, self, self:GetOrigin())
                
            end
            
        end
    
    end

end

function CommandStation:LoginPlayer(player, forced )

    if player:GetTeam() == nil then
        return player
    end
    
    local newPlayer = CommandStructure.LoginPlayer(self, player, forced )
    
    if GetTeamHasCommander(self:GetTeamNumber()) then
        KillPlayersInside(self)
    end
    
    return newPlayer
end
