
local oldOnProcessMove = Alien.OnProcessMove
function Alien:OnProcessMove(input)
    oldOnProcessMove(self, input)
    
    if not self:GetIsDestroyed() then 
    
        self:UpdateSilenceLevel()
        
    end
end