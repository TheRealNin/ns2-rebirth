
local kRookieModeDelay = 20
local kPregameLength = 5 -- extra time to select your team, was 3 seconds
local kGameStartMessageInterval = 10

-- How often to send the "No commander" message to players in seconds.
local kSendNoCommanderMessageRate = 10

if Server then

    function NS2Gamerules:BuildTeam(teamType)
        
        if teamType == kAlienTeamType then
            return AlienTeam()
        end
        
        if teamType == kPrecursorTeamType then
            return PrecursorTeam()
        end
        
        return MarineTeam()
        
    end
    
    function NS2Gamerules:SwitchTeamType(teamIndex, newTeamType)
        
        if kForceMvM then
            newTeamType = kMarineTeamType
        end
        if kForceAvA then
            newTeamType = kAlienTeamType
        end
        
        self:SetGameState(kGameState.NotStarted)
        
        local commanderClient = self:GetTeam(teamIndex):GetCommander() and self:GetTeam(teamIndex):GetCommander():GetClient()
        
        --self:GetTeam(teamIndex):GetCommander():Logout()
        for index, entity in ipairs(GetEntitiesForTeam("CommandStructure", teamIndex)) do
            entity:Logout()
        end
        
        
        DestroyLiveMapEntities()
        
        for index, entity in ientitylist(Shared.GetEntitiesWithClassname("Entity")) do
        
            local shieldTypes = { "GameInfo", "MapBlip", "NS2Gamerules", "PlayerInfoEntity", "SiegeDoor", "FrontDoor", "Front Door", "FuncDoor", "LogicBreakable", "SideDoor", "ModPanel"}
            local allowDestruction =  not (entity.GetTeamNumber and entity:GetTeamNumber() ~= teamIndex and
                (entity:isa("CommandStructure") or entity:isa("TeamInfo")))
            for i = 1, #shieldTypes do
                allowDestruction = allowDestruction and not entity:isa(shieldTypes[i])
            end
            
            
            if allowDestruction and entity:GetParent() == nil then
            
                local isMapEntity = entity:GetIsMapEntity()
                local mapName = entity:GetMapName()
                
                -- Reset all map entities and all player's that have a valid Client (not ragdolled players for example).
                local resetEntity = entity:GetIsMapEntity() or (entity:isa("Player") and entity:GetClient() ~= nil)
                if resetEntity then
                
                    if entity.Reset then
                        entity:Reset()
                    end
                    
                else
                    DestroyEntity(entity)
                end
                
            end
        end
        
        -- Clear out obstacles from the navmesh before we start repopualating the scene
        RemoveAllObstacles()
        
        -- Build list of tech points
        local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
        if table.maxn(techPoints) < 2 then
            Print("Warning -- Found only %d %s entities.", table.maxn(techPoints), TechPoint.kMapName)
        end
        
        
        local resourcePoints = Shared.GetEntitiesWithClassname("ResourcePoint")
        if resourcePoints:GetSize() < 2 then
            Print("Warning -- Found only %d %s entities.", resourcePoints:GetSize(), ResourcePoint.kPointMapName)
        end
        
        -- add obstacles for resource points back in
        for index, resourcePoint in ientitylist(resourcePoints) do        
            resourcePoint:AddToMesh()        
        end
        
        local initialTechPointId = self:GetTeam(teamIndex).initialTechPointId
        
        
        local playersOnTeam = {}
        table.copy(self:GetTeam(teamIndex).playerIds, playersOnTeam)
        local players = self:GetTeam(teamIndex):GetPlayers()
        local newPlayers = {}
        for index, player in ipairs(players) do
            --player:ClearConcedeSequence()
            player:SetCameraDistance(0)
            local success, newPlayer = self:JoinTeam(player, kTeamReadyRoom, true)
            if success then
                table.insert(newPlayers, newPlayer)
            end
        end
        
        self.worldTeam:ResetPreservePlayers(nil)
        self.spectatorTeam:ResetPreservePlayers(nil)  
        
        self:GetTeam(teamIndex):Uninitialize()
        
        -- hack to fix up some garbage code
        if teamIndex == kTeam1Index then
            kTeam1Type = newTeamType
            kTeamIndexToType[kTeam1Index] = kTeam1Type
            self.team1 = self:BuildTeam(kTeam1Type)
            self.team1:Initialize(kTeam1Name, kTeam1Index)
        elseif teamIndex == kTeam2Index then
            kTeam2Type = newTeamType
            kTeamIndexToType[kTeam2Index] = kTeam2Type
            self.team2 = self:BuildTeam(kTeam2Type)
            self.team2:Initialize(kTeam2Name, kTeam2Index)
        else
            Print("You tried to change the team that doesn't exist")
        end
        
        teamInfoEntity = Shared.GetEntity(self:GetTeam(teamIndex).teamInfoEntityId)
        
        if teamInfoEntity then
            teamInfoEntity:SetWatchTeam(self:GetTeam(teamIndex))
        end
        --Log("New team type: %s", self:GetTeam(teamIndex):GetTeamType())
        
        self:GetTeam(teamIndex).initialTechPointId = initialTechPointId
        table.copy(playersOnTeam, self:GetTeam(teamIndex).playerIds)  
        
        for index, player in ipairs(newPlayers) do
            self:JoinTeam(player, teamIndex, true)
            player:OnInitialSpawn(Shared.GetEntity(initialTechPointId):GetOrigin())
            player.sendTechTreeBase = true
        end
        
        local commandStructure = self:GetTeam(teamIndex):ResetTeam()
        
        -- login the commanders again
        local function LoginCommander(commandStructure, client)
			local player = client and client:GetControllingPlayer()
            if commandStructure and player then
				-- make up for not manually moving to CS and using it
				commandStructure.occupied = not client:GetIsVirtual()
				player:SetOrigin(commandStructure:GetDefaultEntryOrigin())
				local newPlayer = commandStructure:LoginPlayer(player,true)
                
                if newPlayer then
                    --newPlayer:SetIsReady(true)
                else
                    --Log("Couldn't set the new commander to ready!")
                end
                
            end
        end
		self.clientpres = {}
        
        self:GetTeam(teamIndex):OnInitialized()
        
        LoginCommander(commandStructure, commanderClient)
        
        
        -- Create living map entities fresh
        CreateLiveMapEntities()
        
        self.forceGameStart = false
        self.preventGameEnd = nil
        -- Reset banned players for new game
        self.bannedPlayers = {}
        
        local netmsg = {
            team1Type = kTeam1Type,
            team2Type = kTeam2Type,
            forced = kForcedByConfig
        }
        
        -- Send new team info
        for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            Server.SendNetworkMessage(player, "SwitchTeamTypes", netmsg, true)
            player.sendTechTreeBase = true
        end
        
        self.team1:OnResetComplete()
        self.team2:OnResetComplete()
        
    end
    
    -- HACK: TODO: make this only send the update when the player needs to
    local oldJoinTeam = NS2Gamerules.JoinTeam
    function NS2Gamerules:JoinTeam(player, newTeamNumber, force)
    
        local netmsg = {
            team1Type = kTeam1Type,
            team2Type = kTeam2Type,
            forced = kForcedByConfig
        }
        
        Server.SendNetworkMessage(player, "SwitchTeamTypes", netmsg, true)
        
        return oldJoinTeam(self, player, newTeamNumber, force)
    end
        
    
    function NS2Gamerules:CheckForNoCommander(onTeam, commanderType) -- IGNORE commanderType
        commanderType = ConditionalValue(onTeam:GetTeamType() == kAlienTeamType, "AlienCommander", "MarineCommander")
        self.noCommanderStartTime = self.noCommanderStartTime or { }
        
        if not self:GetGameStarted() then
            self.noCommanderStartTime[commanderType] = nil
        else
        
            local commanderExists = Shared.GetEntitiesWithClassname(commanderType):GetSize() ~= 0
            
            if commanderExists then
                self.noCommanderStartTime[commanderType] = nil
            elseif not self.noCommanderStartTime[commanderType] then
                self.noCommanderStartTime[commanderType] = Shared.GetTime()
            elseif Shared.GetTime() - self.noCommanderStartTime[commanderType] >= kSendNoCommanderMessageRate then
            
                self.noCommanderStartTime[commanderType] = nil
                SendTeamMessage(onTeam, kTeamMessageTypes.NoCommander)
                
            end
            
        end
        
    end
        
    function NS2Gamerules:OnCreate()

        -- Calls SetGamerules()
        Gamerules.OnCreate(self)

        self.sponitor = ServerSponitor()
        self.sponitor:Initialize(self)
        
        self.playerRanking = PlayerRanking()
        
        self.techPointRandomizer = Randomizer()
        self.techPointRandomizer:randomseed(Shared.GetSystemTime())

        self.botTeamController = BotTeamController()
        
        local config = LoadConfigFile("AnyTeam.json")
        local teams
        if config then
            teams = config.teams and config.teams:lower()
        end
        if teams == "mvm" then
            kForceMvM = true
            kForcedByConfig = true
            kTeam1Type = kMarineTeamType
            kTeam2Type = kMarineTeamType
        elseif teams == "avm" or teams == "mva" then
            kForcedByConfig = true
            kTeam1Type = kMarineTeamType
            kTeam2Type = kAlienTeamType
        elseif teams == "ava" then
            kForceAvA = true
            kForcedByConfig = true
            kTeam1Type = kAlienTeamType
            kTeam2Type = kAlienTeamType
        elseif teams then
            Print "WARNING: Invalid team settings. Defaulting teams to random and commander's choice."
        else
            -- leave defaults
        end
        
        -- Create team objects
        self.team1 = self:BuildTeam(kTeam1Type)
        self.team1:Initialize(kTeam1Name, kTeam1Index)
        
        self.team2 = self:BuildTeam(kTeam2Type)
        self.team2:Initialize(kTeam2Name, kTeam2Index)
        
        self.worldTeam = ReadyRoomTeam()
        self.worldTeam:Initialize("World", kNeutralTeamType)
        
        self.spectatorTeam = SpectatingTeam()
        self.spectatorTeam:Initialize("Spectator", kSpectatorIndex)
        
        self.gameInfo = Server.CreateEntity(GameInfo.kMapName)
        
        self:SetGameState(kGameState.NotStarted)
        
        self.allTech = false
        self.orderSelf = false
        self.autobuild = false
        self.teamsReady = false
        self.tournamentMode = false

        if self.gameInfo:GetIsDedicated() then
            --Set rookie mode based on the config values
            self:SetRookieMode(Server.GetConfigSetting("rookie_only"))
            if self.gameInfo:GetRookieMode() then
                self:SetMaxBots(Server.GetConfigSetting("rookie_only_bots"), true)
            else
                self:SetMaxBots(Server.GetConfigSetting("filler_bots"), false)
            end
        end

        self:SetIsVisible(false)
        self:SetPropagate(Entity.Propagate_Never)
        
        -- Track how much pres clients have when they switch a team or disconnect
        self.clientpres = {}
        
        self.justCreated = true
        
    end
    
    function NS2Gamerules:OnCommanderLogout(commandStructure, oldCommander)
        if (self.gameInfo:GetRookieMode() or self.removeCommanderBots)and self:GetGameState() > kGameState.NotStarted and
                self:GetGameState() < kGameState.Team1Won and
                not self.botTeamController:GetCommanderBot(commandStructure:GetTeamNumber()) then
            OnConsoleAddBots(nil, 1, commandStructure:GetTeamNumber(), "com")
        end
    end
    
    local function StartCountdown(self)
    
        self:ResetGame()
        
        self:SetGameState(kGameState.Countdown)
        self.countdownTime = kCountDownLength
        
        self.lastCountdownPlayed = nil
        
    end
    local oldResetGame = NS2Gamerules.ResetGame
    function NS2Gamerules:ResetGame()
        oldResetGame(self)
        
        -- TODO: Fix this hack so it isn't needed
        kTeamIndexToType[kTeam1Index] = kTeam1Type
        kTeamIndexToType[kTeam2Index] = kTeam2Type
        
        local netmsg = {
            team1Type = kTeam1Type,
            team2Type = kTeam2Type,
            forced = kForcedByConfig
        }
        
        -- Send new team info
        for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            Server.SendNetworkMessage(player, "SwitchTeamTypes", netmsg, true)
        end
    end
    
    function NS2Gamerules:CheckGameStart()
    
        if self:GetGameState() <= kGameState.PreGame then
        
            -- Start pre-game when both teams have commanders or when once side does if cheats are enabled
            local team1Commander = self.team1:GetCommander()
            local team2Commander = self.team2:GetCommander()
            
            
            local team1NumPlayer = self.team1:GetNumPlayers()
            local team2NumPlayer = self.team2:GetNumPlayers()
            --firstPregameJoin is used to trigger the vote to start the game with bots
            if team1NumPlayer + team2NumPlayer > 0 then
                if self.firstPregameJoin == nil then
                    self.firstPregameJoin = Shared.GetTime()
                end
            else
                self.firstPregameJoin = nil
            end
            
            if ((team1Commander and team2Commander and team1Commander:GetIsReady() and team2Commander:GetIsReady()) or Shared.GetCheatsEnabled()) and (not self.tournamentMode or self.teamsReady) then
            
                if self:GetGameState() < kGameState.PreGame then
                    --Log("Starting %s second countdown for game start", kPregameLength)
                    --SendGlobalMessage(kTeamMessageTypes.GameStartingSoon)
                    SendTeamMessage(self.team1, kTeamMessageTypes.GameStartingSoon)
                    SendTeamMessage(self.team2, kTeamMessageTypes.GameStartingSoon)
                    self:SetGameState(kGameState.PreGame)
                end
                
            else
            
                if self:GetGameState() == kGameState.PreGame then
                    self:SetGameState(kGameState.NotStarted)
                    SendTeamMessage(self.team1, kTeamMessageTypes.GameStartAborted)
                    SendTeamMessage(self.team2, kTeamMessageTypes.GameStartAborted)
                end
                
                if (not team1Commander or not team2Commander) then
                    if not self.nextGameStartMessageTime or Shared.GetTime() > self.nextGameStartMessageTime then
                        SendTeamMessage(self.team1, kTeamMessageTypes.GameStartCommanders)
                        SendTeamMessage(self.team2, kTeamMessageTypes.GameStartCommanders)
                        self.nextGameStartMessageTime = Shared.GetTime() + kGameStartMessageInterval
                    end
                    
                    local gamestate = self:GetGameState()
                    if gamestate == kGameState.WarmUp and self.nextGameStartMessageTime and
                            self.nextGameStartMessageTime ~= self.lastWarmUpMessageTime and
                            Shared.GetTime() > self.nextGameStartMessageTime - kGameStartMessageInterval / 2 then
                        SendTeamMessage(self.team1, kTeamMessageTypes.WarmUpActive, self:GetWarmUpPlayerLimit())
                        SendTeamMessage(self.team2, kTeamMessageTypes.WarmUpActive, self:GetWarmUpPlayerLimit())
                        self.lastWarmUpMessageTime = self.nextGameStartMessageTime
                    end
                    
                    --check if it's time to start the add commander bots vote
                    local autoVoteAddCommBots = Server.GetConfigSetting("auto_vote_add_commander_bots")
                    if autoVoteAddCommBots and gamestate < kGameState.PreGame and self.firstPregameJoin
                            and self.firstPregameJoin + self.kStartGameVoteDelay < Shared.GetTime() then

                        local votename = "VoteAddCommanderBots"
                        if GetStartVoteAllowed(votename) == kVoteCannotStartReason.VoteAllowedToStart then
                            self.firstPregameJoin = false
                            StartVote(votename, nil, {})
                        end
                    end
                    
                end
            end
            
        end
        
    end
    
    
    function NS2Gamerules:GetPregameLength()
    
        local preGameTime = kPregameLength
        if Shared.GetCheatsEnabled() then
            preGameTime = 0
        end

        if self.gameInfo:GetRookieMode() and #gServerBots >= 2 then
            preGameTime = kRookieModeDelay
        end
        
        return preGameTime
        
    end
    
    --[[
     * Ends the current game (optional boolean parameter specifies if it is due to an auto-concede
    ]]
    function NS2Gamerules:EndGame(winningTeam, autoConceded)
    
        if self:GetGameState() == kGameState.Started then
            
            local winningTeamNumber = winningTeam and winningTeam.GetTeamNumber and winningTeam:GetTeamNumber() or kNeutralTeamType
            
            if winningTeamNumber == kTeam1Index then

                self:SetGameState(kGameState.Team1Won)
                PostGameViz( kTeam1Name .. " Wins!")
                
            elseif winningTeamNumber == kTeam2Index then

                self:SetGameState(kGameState.Team2Won)
                PostGameViz( kTeam2Name .. " Wins!")

            else

                self:SetGameState(kGameState.Draw)
                PostGameViz("Draw Game!")

            end
            
            Server.SendNetworkMessage( "GameEnd", { win = winningTeamNumber }, true)
            
            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()

            -- Clear out Draw Game window handling
            self.team1Lost = nil
            self.team2Lost = nil
            self.timeDrawWindowEnds = nil
            
            --remove commander bots that where added via the comm bot vote
            if self.removeCommanderBots then
                self.botTeamController:RemoveCommanderBots()
                self.removeCommanderBots = false
            end
            
            -- Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")

            if winningTeam then
                self.sponitor:OnEndMatch(winningTeam)
                self.playerRanking:EndGame(winningTeam)
            end
            TournamentModeOnGameEnd()
            
            -- Check if the game ended due to either team conceding.  If so, do the concede
            -- sequence.
            if autoConceded then
                if winningTeam == self:GetTeam(kMarineTeamType) then
                    self:CheckForConcedeSequence(self:GetTeam(kAlienTeamType))
                else
                    self:CheckForConcedeSequence(self:GetTeam(kMarineTeamType))
                end
            else
                self:CheckForConcedeSequence()
            end

        end
        
    end
end

function NS2Gamerules:GetPlayerConnectMapName(client)
    return Gorge.kMapName
end