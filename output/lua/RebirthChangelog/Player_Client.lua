
local kLastRebirthUpdate = 1521923199  

local menu_was_opened = false
local function GetShouldOpenChangelog()
    if menu_was_opened then
        return false
    end
    menu_was_opened = true
    
    local last =  Client.GetOptionInteger( "lastRebirthModUpdate", 0)
    Log("Last viewed rebirth changlog: " .. last)
    if last < kLastRebirthUpdate then
        last = os.time(os.date("!*t"))
        Client.SetOptionInteger("lastRebirthModUpdate", last)
        return true
    end
    
    return false
end

local oldSendKeyEvent = Player.SendKeyEvent
function Player:SendKeyEvent(key, down)
    oldSendKeyEvent(self, key, down)
    
    if GetShouldOpenChangelog() then
        MainMenu_Open()
        menu_was_opened = true
    end
end