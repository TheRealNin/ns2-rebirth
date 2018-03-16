
local kExecuteVoteDelay = 5

RegisterVoteType("VoteBotStomp", { })

if Client then

    local function SetupBotStompVote(voteMenu)

        local function StartBotStompVote(data)
            AttemptToStartVote("VoteBotStomp", { })
        end

        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_ADD_COMMANDER_BOTS"), nil, StartBotStompVote)

        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteBotStompQuery(data)
            local gameStarted = GetGameInfoEntity():GetGameStarted()
            if gameStarted then
                return Locale.ResolveString("VOTE_ADD_COMMANDER_BOTS_QUERY")
            else
                return Locale.ResolveString("VOTE_START_COMMANDER_BOTS_QUERY")
            end
        end
        AddVoteStartListener("VoteBotStomp", GetVoteBotStompQuery)

    end
    AddVoteSetupCallback(SetupBotStompVote)

end

if Server then

    function VotingBotStompAllowed()
        return true
    end

    local function OnBotStompVoteSuccessful(data)
        local gamerules = GetGamerules()
        if not gamerules:GetTeam1():GetHasCommander() then
            OnConsoleAddBots(nil, 1, 1, "com")
        end

        if not gamerules:GetTeam2():GetHasCommander() then
            OnConsoleAddBots(nil, 1, 2, "com")
        end

        gamerules.removeCommanderBots = true
    end
    SetVoteSuccessfulCallback("VoteBotStomp", kExecuteVoteDelay, OnBotStompVoteSuccessful)

end