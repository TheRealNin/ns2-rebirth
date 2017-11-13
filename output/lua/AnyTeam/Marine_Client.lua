
local kHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/marine_enemy_highlight.material")

function Marine:GetHealthbarOffset()
    return 0.8 -- uses GetEngagementPointOverride as the base, was 1.2
end


        --[[
local origOnUpdateRender = Marine.OnUpdateRender
function Marine:OnUpdateRender()
    origOnUpdateRender(self)
    
    
    local localPlayer = Client.GetLocalPlayer()
    local showHighlight = localPlayer ~= nil and GetAreEnemies(localPlayer, self) and self:GetIsAlive()
    
    local model = self:GetRenderModel()

    if model then
        if showHighlight then
            model:SetMaterialParameter("tint", 1)
        else
            model:SetMaterialParameter("tint", 0)
        end
    end
end
]]--