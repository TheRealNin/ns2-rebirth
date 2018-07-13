local largestSizeSquared = 5*5
local oldOnUpdateRender = BaseModelMixin.OnUpdateRender
function BaseModelMixin:OnUpdateRender()
    local player = Client.GetLocalPlayer()
    if player and player:isa("Commander") and GetAreEnemies(player, self) and self.spotted and not self.sighted then
        -- TODO: set the model to the "default" pose param
    else
        oldOnUpdateRender(self)
    end

end
