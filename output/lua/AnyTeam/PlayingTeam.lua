 
function PlayingTeam:Initialize(teamName, teamNumber)

    InitMixin(self, TeamDeathMessageMixin)
    
    Team.Initialize(self, teamName, teamNumber)

    self.respawnEntity = nil
    
    self:OnCreate()
        
    self.timeSinceLastLOSUpdate = Shared.GetTime()
    self.timeSinceLastRTUpdate = Shared.GetTime()
    
    self.ejectCommVoteManager = VoteManager()
    self.ejectCommVoteManager:Initialize()
    
    self.concedeVoteManager = VoteManager()
    self.concedeVoteManager:Initialize()
    self.concedeVoteManager:SetTeamPercentNeeded(kPercentNeededForVoteConcede)

    -- child classes can specify a custom team info class
    local teamInfoMapName = TeamInfo.kMapName
    if self.GetTeamInfoMapName then
        teamInfoMapName = self:GetTeamInfoMapName()
    end
    
    self.supplyUsed = 0
    
    local teamInfoEntity = Server.CreateEntity(teamInfoMapName)

    self.teamInfoEntityId = teamInfoEntity:GetId()
    teamInfoEntity:SetWatchTeam(self)
    
    self.lastCommPingTime = 0
    self.lastCommPingPosition = Vector(0,0,0)
    
    self.entityTechIds = {}
    self.techIdCount = {}

    self.eventListeners = {}

end


function PlayingTeam:ResetTeam()

    local initialTechPoint = self:GetInitialTechPoint()
    
    local tower, commandStructure = self:SpawnInitialStructures(initialTechPoint)
    
    self.conceded = false
    
    if commandStructure and commandStructure:isa("Hive") then
        commandStructure:SetHotGroupNumber(1)
    end 
    
    local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
    for p = 1, #players do
    
        local player = players[p]
        player:OnInitialSpawn(initialTechPoint:GetOrigin())
        player:SetResources(ConditionalValue(self:GetTeamType() == kMarineTeamType, kMarineInitialIndivRes, kAlienInitialIndivRes))
        
    end
    
    return commandStructure
    
end