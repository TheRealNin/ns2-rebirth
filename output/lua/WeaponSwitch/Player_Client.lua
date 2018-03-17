
local oldPlayerUI_GetHasItem = PlayerUI_GetHasItem
function PlayerUI_GetHasItem(techId)
    
    if techId and techId == kTechId.Welder then
    
        local player = Client.GetLocalPlayer()
        if player then
        
            local items = GetChildEntities(player, "ScriptActor")

            for index, item in ipairs(items) do
            
                if item:GetTechId() == kTechId.Axe and item.hasWelder then
                    return true
                end
            end
        end
    end
    return oldPlayerUI_GetHasItem(techId)
end