
local kHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/marine_enemy_highlight.material")

local origOnUpdateRender = Marine.OnUpdateRender
function Marine:OnUpdateRender()
    origOnUpdateRender(self)
    
    
    local localPlayer = Client.GetLocalPlayer()
    local showHighlight = localPlayer ~= nil and GetAreEnemies(localPlayer, self) and self:GetIsAlive()
    
    local model = self:GetRenderModel()

    if model then
    
        if showHighlight and not self.marineHighlightMaterial then
            
            self.marineHighlightMaterial = AddMaterial(model, kHighlightMaterial)
            
        elseif not showHighlight and self.marineHighlightMaterial then
        
            RemoveMaterial(model, self.marineHighlightMaterial)
            self.marineHighlightMaterial = nil
        
        end
        
        if self.marineHighlightMaterial then
            self.marineHighlightMaterial:SetParameter("distance", (localPlayer:GetEyePos() - self:GetOrigin()):GetLength())
        end
    
    end
end