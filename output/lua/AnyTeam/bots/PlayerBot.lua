Script.Load("lua/AnyTeam/bots/MinigunBrain.lua")


local personalities = {
    {["names"] = {"Shooty", "ShooterMcShooterface", "FPSer", "XxXkillaXxX", "SniperLyfe", "Bulletz4Breakfast", "XenoMorphing", "SeekNDstroy", "supercodplayer1995", "woman_respector69"},
        ["aim"] = 0.9,
        ["help"] = 0.0,
        ["aggro"] = 0.9,
        ["sneaky"] = true
    },
    {["names"] = {"Apache Attack Helicopter", "Poor Life Decisions", "Suspiciously Slow", "Kony Hawk Pro Slaver", "Shaving Ryan's Privates", "Not A Human, Promise", "The Terrible Spicy Tea", "Believe it or not, France", "Nipple of the North", "Hank Hill", "Obesity Related Illness", "Nein Lives", "Gorge of the Jungle", "Sock Full of Shame", "Country-Steak:Sauce", "Only Couches Pull Out", "Stop Dying, you Cowards!", "Stone Cold Steve Autism", "Syndrome of a Down", "I Only Love My Mom", "I Hope Senpai Notices Me", "Harry P. Ness"},
        ["aim"] = 0.5,
        ["help"] = 0.9,
        ["aggro"] = 0.0,
        ["sneaky"] = true
    },
    {["names"] = {"IronHorse", "BeigeAlert", "McGlaspie", "Flayra", "Ghoul", "sclark39", "fsfod", "rantology", "WasabiOne"},
        ["aim"] = 0.0,
        ["help"] = 0.0,
        ["aggro"] = 0.9,
        ["sneaky"] = false
    },
}

function PlayerBot:OnThink()
    PROFILE("PlayerBot:OnThink")

    Bot.OnThink(self)

    self:_LazilyInitBrain()

    if not self.initializedBot then
        local botType = personalities[math.random(#personalities)]
        if not botType.nameNum then
            botType.nameNum =  math.random(#botType.names)
        end
        local botName = botType.names[botType.nameNum]
        botType.nameNum = (botType.nameNum) % #botType.names + 1
        self.botName = botName
        self.aimAbility = botType.aim
        self.helpAbility = botType.help
        self.aggroAbility = botType.aggro
        self.sneakyAbility = botType.sneaky
        self.initializedBot = true
    end
        
    self:UpdateNameAndGender()
end

function PlayerBot:GetNamePrefix()
    return "BOT "
end

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


function PlayerBot:UpdateNameAndGender()
    PROFILE("PlayerBot:UpdateNameAndGender")

    if self.botSetName == nil then

        local player = self:GetPlayer()
        local name = player:GetName()
        
        self.botSetName = true
        
        name = self:GetNamePrefix()..TrimName(self.botName)
        player:SetName(name)

        -- set gender
        self.client.variantData = {
            isMale = math.random() < 0.8,
            marineVariant = kMarineVariant[kMarineVariant[math.random(1, #kMarineVariant)]],
            skulkVariant = kSkulkVariant[kSkulkVariant[math.random(1, #kSkulkVariant)]],
            gorgeVariant = kGorgeVariant[kGorgeVariant[math.random(1, #kGorgeVariant)]],
            lerkVariant = kLerkVariant[kLerkVariant[math.random(1, #kLerkVariant)]],
            fadeVariant = kFadeVariant[kFadeVariant[math.random(1, #kFadeVariant)]],
            onosVariant = kOnosVariant[kOnosVariant[math.random(1, #kOnosVariant)]],
            rifleVariant = kRifleVariant[kRifleVariant[math.random(1, #kRifleVariant)]],
            pistolVariant = kPistolVariant[kPistolVariant[math.random(1, #kPistolVariant)]],
            axeVariant = kAxeVariant[kAxeVariant[math.random(1, #kAxeVariant)]],
            shotgunVariant = kShotgunVariant[kShotgunVariant[math.random(1, #kShotgunVariant)]],
            exoVariant = kExoVariant[kExoVariant[math.random(1, #kExoVariant)]],
            shoulderPadIndex = 0
        }
        self.client:GetControllingPlayer():OnClientUpdated(self.client)
        
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
