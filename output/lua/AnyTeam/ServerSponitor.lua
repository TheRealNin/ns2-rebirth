local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

if not file_exists("lua/entry/nosponitor.entry") then
    local kSponitor2Url = "http://sponitor2.herokuapp.com/api/send/"
    local gDebugAlwaysPost = false

    local function ResetTeamStats(stats, team)

        stats.pvpKills = 0
        stats.team = team
        stats.minNumPlayers = team:GetNumPlayers()
        stats.maxNumPlayers = stats.minNumPlayers
        stats.avgNumPlayersSum = 0
        stats.avgNumRookiesSum = 0
        stats.numPlayerCountSamples = 0
        stats.currNumPlayers = 0

    end
    local function TechIdToString(techId)

        return LookupTechData( techId, kTechDataDisplayName, string.format("techId=%d", techId) )

    end
    function ServerSponitor:ListenToTeam(team)

        team:AddListener("OnResearchComplete",
                function(structure, researchId)

                    local node = team:GetTechTree():GetTechNode(researchId)

                    if node:GetIsResearch() or node:GetIsUpgrade() then
                        self:OnTechEvent("DONE "..TechIdToString(researchId))
                    end

                end )

        team:AddListener("OnCommanderAction",
                function(techId)
                    self:OnTechEvent("CMDR "..TechIdToString(techId))
                end )

        team:AddListener("OnConstructionComplete",
                function(structure)
                    self:OnTechEvent("BUILT "..TechIdToString(structure:GetTechId()))
                end )

        team:AddListener("OnEvolved",
                function(techId)
                    self:OnTechEvent("EVOL "..TechIdToString(techId))
                end )
        
        team:AddListener("OnBought",
                function(techId)
                    self:OnTechEvent("BUY "..TechIdToString(techId))
                end )

        self.teamStats[team:GetTeamNumber()] = {}
        ResetTeamStats( self.teamStats[ team:GetTeamNumber() ], team )

    end

    function ServerSponitor:OnEndMatch(winningTeam)

        if self.matchId or gDebugAlwaysPost then
        
            local startHiveTech = "None"
            
            if self.game.initialHiveTechId then
                startHiveTech = EnumToString(kTechId, self.game.initialHiveTechId)
            end
            
            local stats1 = self.teamStats[kTeam1Index]
            local stats2 = self.teamStats[kTeam2Index]
            
            local jsonData = json.encode(
            {
                matchId = self.matchId,
                endTime = Shared.GetGMTString(false),
                winner = winningTeam:GetTeamType(),
                start_location1 = self.game.startingLocationNameTeam1,
                start_location2 = self.game.startingLocationNameTeam2,
                start_path_distance = self.game.startingLocationsPathDistance,
                start_hive_tech = startHiveTech,
                
                pvpKills1 = stats1.pvpKills,
                pvpKills2 = stats2.pvpKills,
                minPlayers1 = stats1.minNumPlayers,
                minPlayers2 = stats2.minNumPlayers,
                maxPlayers1 = stats1.maxNumPlayers,
                maxPlayers2 = stats2.maxNumPlayers,
                avgPlayers1 = stats1.avgNumPlayersSum / stats1.numPlayerCountSamples,
                avgPlayers2 = stats2.avgNumPlayersSum / stats2.numPlayerCountSamples,
                avgRookies1 = stats1.avgNumRookiesSum / stats1.numPlayerCountSamples,
                avgRookies2 = stats2.avgNumRookiesSum / stats2.numPlayerCountSamples,
                totalTResMined1 = stats1.team:GetTotalTeamResources(),
                totalTResMined2 = stats2.team:GetTotalTeamResources(),
                averageSkill = GetGameInfoEntity():GetAveragePlayerSkill()
            })
            
            SendSponitorRequest(kSponitor2Url .. "matchEnd", "POST", { data = jsonData })
            
            self.matchId = nil
            
        end
        
        -- Reset team stats here instead of OnStartMatch. This is because there is data we want to track
        -- before the match actually starts, such as players joining the team.
        for teamType, stats in pairs(self.teamStats) do
            ResetTeamStats(stats, stats.team)
        end
        
    end
end