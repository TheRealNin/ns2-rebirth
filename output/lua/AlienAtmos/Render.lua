
-- force shadows, atmospherics, and bloom to be on
local oldRender_SyncRenderOptions = Render_SyncRenderOptions

function Render_SyncRenderOptions()
    oldRender_SyncRenderOptions()
    local ambient_occlusion = false
    Client.SetRenderSetting("ambient_occlusion", ToString(ambient_occlusion))
    
    -- force bloom to be off
	local bloom             = false
	Client.SetRenderSetting("bloom"  , ToString(bloom))
	
    Client.SetRenderSetting("particles", "high")
end