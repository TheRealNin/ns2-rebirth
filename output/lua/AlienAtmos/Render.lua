
-- force shadows to be on
local oldRender_SyncRenderOptions = Render_SyncRenderOptions
function Render_SyncRenderOptions()
    oldRender_SyncRenderOptions()
    local shadows           = true
    Client.SetRenderSetting("shadows", ToString(shadows))

end