 
local oldOnCommanderLogin = CommandStructure.OnCommanderLogin
function CommandStructure:OnCommanderLogin(commanderPlayer,forced)
    oldOnCommanderLogin(self, commanderPlayer, forced)
    if forced then
        commanderPlayer:SetIsReady(true)
    end
end