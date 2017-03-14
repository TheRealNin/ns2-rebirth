 
-- yup it says playerui but it's in alien_client...
function PlayerUI_GetNumHives()

    for _, ent in GetEntitiesForTeam("AlienTeamInfo", Client.GetLocalPlayer():GetTeamNumber()) do
        return ent:GetNumHives()
    end
    
    return 0

end


function AlienUI_GetEggCount()

    local eggCount = 0
    
    local player = Client.GetLocalPlayer()
    local teamInfo = GetTeamInfoEntity(player:GetTeamNumber())
    if teamInfo and teamInfo:GetTeamType() == kAlienTeamType and teamInfo.GetEggCount then
        eggCount = teamInfo:GetEggCount()
    end
    
    return eggCount
    
end

local alienVisionEnabled = true
local function ToggleAlienVision(enabled)
    alienVisionEnabled = enabled ~= "false"
end
Event.Hook("Console_alienvision", ToggleAlienVision)

function Alien:UpdateClientEffects(deltaTime, isLocal)

    Player.UpdateClientEffects(self, deltaTime, isLocal)
    
    -- If we are dead, close the evolve menu.
    if isLocal and not self:GetIsAlive() and self:GetBuyMenuIsDisplaying() then
        self:CloseMenu()
    end
    
    self:UpdateEnzymeEffect(isLocal)
    self:UpdateElectrified(isLocal)
    self:UpdateMucousEffects(isLocal)
    
    if isLocal and self:GetIsAlive() then
    
        local darkVisionFadeAmount = 1
        local darkVisionFadeTime = 0.2
        local darkVisionPulseTime = 4
        local darkVisionState = self:GetDarkVisionEnabled()

        if self.lastDarkVisionState ~= darkVisionState then

            if darkVisionState then
            
                self.darkVisionTime = Shared.GetTime()
                self:TriggerEffects("alien_vision_on") 
                
            else
            
                self.darkVisionEndTime = Shared.GetTime()
                self:TriggerEffects("alien_vision_off")
                
            end
            
            self.lastDarkVisionState = darkVisionState
        
        end
        
        if not darkVisionState then
            darkVisionFadeAmount = Clamp(1 - (Shared.GetTime() - self.darkVisionEndTime) / darkVisionFadeTime, 0, 1)
        end
        
        local useShader = Player.screenEffects.darkVision 
        
        if useShader then
            useShader:SetActive(alienVisionEnabled)            
            useShader:SetParameter("startTime", self.darkVisionTime)
            useShader:SetParameter("time", Shared.GetTime())
            useShader:SetParameter("amount", darkVisionFadeAmount)
            useShader:SetParameter("teamNumber", self:GetTeamNumber())
            
        end
        
        self:UpdateRegenerationEffect()
        
    end
    
end