
local oldOnInitialized = Whip.OnInitialized
function Whip:OnInitialized()
    oldOnInitialized(self)
    self.nextSlapStartTime    = 0
    self.nextBombardStartTime = 0
end
