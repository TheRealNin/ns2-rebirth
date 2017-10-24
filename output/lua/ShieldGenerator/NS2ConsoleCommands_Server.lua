
local function OnCommandPersonalShield(client)

    if client ~= nil and Shared.GetCheatsEnabled() then

        local player = client:GetControllingPlayer()
        
        if HasMixin(player, "PersonalShieldAble") then
            player:ActivatePersonalShield()
        end
        
    end
    
end

Event.Hook("Console_shield", OnCommandPersonalShield)