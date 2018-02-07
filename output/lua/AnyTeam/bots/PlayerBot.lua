Script.Load("lua/AnyTeam/bots/MinigunBrain.lua")


function PlayerBot:_LazilyInitBrain()

    if self.brain == nil then
        local player = self:GetPlayer()

        if player:isa("Marine") then
            self.brain = MarineBrain()
        elseif player:isa("Skulk") then
            self.brain = SkulkBrain()
        elseif player:isa("Gorge") then
            self.brain = GorgeBrain()
        elseif player:isa("Lerk") then
            self.brain = LerkBrain()
        elseif player:isa("Fade") then
            self.brain = FadeBrain()
        elseif player:isa("Onos") then
            self.brain = OnosBrain()
        elseif player:isa("Exo") then
            self.brain = MinigunBrain()
        end

        if self.brain ~= nil then
            self.brain:Initialize()
            self:GetPlayer().botBrain = self.brain
            self.aim = BotAim()
            self.aim:Initialize(self)
        end

    else

        -- destroy brain if we are ready room
        if self:GetPlayer():isa("ReadyRoomPlayer") then
            self.brain = nil
            self:GetPlayer().botBrain = nil
        end

    end

end

local kSayTeamDelay = 20 -- don't want to make them too chatty
function PlayerBot:SendTeamMessage(message, extraTime)

    if self.brain then
        local brain = self.brain
        if not extraTime then
            extraTime = 0
        end
        if not brain.timeLastSayTeam or brain.timeLastSayTeam + kSayTeamDelay + extraTime < Shared.GetTime() then
            
            local chatMessage = string.UTF8Sub(message, 1, kMaxChatLength)
            
            if string.len(chatMessage) > 0 then
                
                local player = self:GetPlayer()
                local playerName = player:GetName()
                local playerLocationId = player.locationId
                local playerTeamNumber = player:GetTeamNumber()
                local playerTeamType = player:GetTeamType()
                
                local players = GetEntitiesForTeam("Player", playerTeamNumber)
                for _, player in ipairs(players) do
                    Server.SendNetworkMessage(player, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
                end
            end
            
            brain.timeLastSayTeam = Shared.GetTime()
        end
    end
end
