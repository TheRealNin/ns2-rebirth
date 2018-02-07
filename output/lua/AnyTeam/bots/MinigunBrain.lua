
Script.Load("lua/AnyTeam/bots/MinigunBrain_Data.lua")

gMinigunBrains = {}

------------------------------------------
--
------------------------------------------
class 'MinigunBrain' (PlayerBrain)

function MinigunBrain:Initialize()

    PlayerBrain.Initialize(self)
    self.senses = CreateMinigunBrainsSenses()
    table.insert(gMinigunBrains, self)

    self.hadGoodHealth = false

end

function MinigunBrain:Update( bot, move )
    
    if gBotDebug:Get("spam") then
        Print("MinigunBrain:Update")
    end

    if PlayerBrain.Update( self, bot, move ) == false then
        return false
    end

    
    local marine = bot:GetPlayer()
    if marine ~= nil and marine:GetIsAlive() then
        
        -- Med kit request
        if self.hadGoodHealth then
            if self.senses:Get("healthFraction") <= 0.5 then
                if math.random() < 0.5 then
                    CreateVoiceMessage( marine, kVoiceId.RequestWeld )
                end
                self.hadGoodHealth = false
            end
        else
            if self.senses:Get("healthFraction") > 0.5 then
                self.hadGoodHealth = true
            end
        end
        
        local lightMode
        local powerPoint = GetPowerPointForLocation(marine:GetLocationName())
        if powerPoint then
            lightMode = powerPoint:GetLightMode()
        end
        if not lightMode or lightMode == kLightMode.NoPower then
            if not marine:GetFlashlightOn() then
                marine:SetFlashlightOn(true)
            end
        else
            if marine:GetFlashlightOn() then
                marine:SetFlashlightOn(false)
            end
        end
    end
end


function MinigunBrain:GetExpectedPlayerClass()
    return "Exo"
end

function MinigunBrain:GetExpectedTeamNumber()
    return kMarineTeamType
end

function MinigunBrain:GetActions()
    return kMinigunBrainActions
end

function MinigunBrain:GetSenses()
    return self.senses
end
