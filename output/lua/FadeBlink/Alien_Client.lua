function AlienUI_GetHasShadowDance()

    local player = Client.GetLocalPlayer()
    if player and player:isa("WraithFade") and player.GetCanMetabolizeHealth then
        return player:GetCanMetabolizeHealth()
    end
    
    return false
end

function AlienUI_GetTimeOfLastShadowDanceRegen()
    local player = Client.GetLocalPlayer()
    if player and player.timeOfLastPhase then
        return player.timeOfLastPhase
    end
    return 0
end

function AlienUI_GetIsSighted()
    local player = Client.GetLocalPlayer()
    if player and player.GetIsSighted then
        return player:GetIsSighted()
    end
    return false
end