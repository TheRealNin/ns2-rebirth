
local kLowHealthUrgencyTime = 25

function MarineBrain:Update( bot, move )

    if gBotDebug:Get("spam") then
        Print("MarineBrain:Update")
    end

    if PlayerBrain.Update( self, bot, move ) == false then
        return false
    end

    local marine = bot:GetPlayer()

    if marine ~= nil and marine:GetIsAlive() then
        
        -- handle firing pistol
        local weapon = marine:GetActiveWeapon()
        if weapon and weapon:isa("Pistol") and bit.band(move.commands, Move.PrimaryAttack) ~= 0 and marine.primaryAttackLastFrame then
            move.commands = bit.bxor(move.commands, Move.PrimaryAttack)
        end
        
        -- Send ammo request
        if self.hadAmmo then
            if self.senses:Get("ammoFraction") <= 0.0 then
                CreateVoiceMessage( marine, kVoiceId.MarineRequestAmmo )
                self.hadAmmo = false
            end
        else
            if self.senses:Get("ammoFraction") > 0.0 then
                self.hadAmmo = true
            end
        end

        -- Med kit request
        if self.hadGoodHealth then
            if self.senses:Get("healthFraction") <= 0.5 then
                if math.random() < 0.2 then
                    CreateVoiceMessage( marine, kVoiceId.MarineRequestMedpack )
                end
                self.hadGoodHealth = false
            end
        else
            if self.senses:Get("healthFraction") > 0.5 then
                self.hadGoodHealth = true
            end
        end
        
        if self.hadGoodHealth then
            self.medPackTimer = nil
        end
        
        -- persistent med kit request
        if self.senses:Get("healthFraction") <= 0.5 then
            if not self.medPackTimer then
                self.medPackTimer = Shared.GetTime()
            end
            local fractionTime = kLowHealthUrgencyTime * self.senses:Get("healthFraction") + 3
            if self.medPackTimer < Shared.GetTime() - fractionTime then
                self.medPackTimer = Shared.GetTime()
                CreateVoiceMessage( marine, kVoiceId.MarineRequestMedpack )
            end
        end
        
        
        local lightMode
        local powerPoint = GetPowerPointForLocation(marine:GetLocationName())
        if powerPoint then
            lightMode = powerPoint:GetLightMode()
        end
        if not lightMode or lightMode == kLightMode.NoPower and not marine:GetCrouching() then
            if not marine:GetFlashlightOn() then
                marine:SetFlashlightOn(true)
            end
        else
            if marine:GetFlashlightOn() then
                marine:SetFlashlightOn(false)
            end
        end
    else
        self.hadAmmo = false
        self.hadGoodHealth = false
    end

end
