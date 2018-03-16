
-- force shadows, atmospherics, and bloom to be on
local oldRender_SyncRenderOptions = Render_SyncRenderOptions
function Disabled_Render_SyncRenderOptions()
    oldRender_SyncRenderOptions()
    local shadows           = true
    Client.SetRenderSetting("shadows", ToString(shadows))
    local atmospherics      = true
    Client.SetRenderSetting("atmospherics", ToString(atmospherics))
    local bloom             = true
    Client.SetRenderSetting("bloom"  , ToString(bloom))

end
function Render_SyncRenderOptions()
    oldRender_SyncRenderOptions()
    local ambient_occlusion = false
    Client.SetRenderSetting("ambient_occlusion", ToString(ambient_occlusion))
    local bloom             = true
    Client.SetRenderSetting("bloom"  , ToString(bloom))
    Client.SetRenderSetting("particles", "high")
end