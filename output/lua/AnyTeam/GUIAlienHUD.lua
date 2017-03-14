
-- force our darkvision to take priority
local oldInitialize = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()
    oldInitialize(self)
    
		Client.DestroyScreenEffect(Player.screenEffects.darkVision)
    Player.screenEffects.darkVision = Client.CreateScreenEffect("shaders/AnyTeamVision.screenfx")
end