
-- doesn't work
--[[
function GUIVoiceChat:SendKeyEvent(key, down, amount)

    local player = Client.GetLocalPlayer()
    
    if down then
        if not ChatUI_EnteringChatMessage() then
            if not player:isa("Commander") then
                if GetIsBinding(key, "VoiceChat") then
                    self.recordBind = "VoiceChat"
                    self.recordEndTime = nil
					Client.ConfigureVoice(1.0, 0, -10000)
                    Client.VoiceRecordStartGlobal()
                end
            else
                if GetIsBinding(key, "VoiceChatCom") then
                    self.recordBind = "VoiceChatCom"
                    self.recordEndTime = nil
					Client.ConfigureVoice(2.0, 0, -5)
                    Client.VoiceRecordStartGlobal()
                end
            end
        end
    else
        if self.recordBind and GetIsBinding( key, self.recordBind ) then
            self.recordBind = nil
            self.recordEndTime = Shared.GetTime() + Client.GetOptionFloat("recordingReleaseDelay", 0.15)
        end
    end
    
end
]]--