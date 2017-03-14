
local kRailgunTargetDuration = 0.3
function RailgunTargetMixin:OnUpdate(deltaTime)
    PROFILE("RailgunTargetMixin:OnUpdate")
    local isTarget = self.timeRailgunTargeted + kRailgunTargetDuration > Shared.GetTime()
    local model = self:GetRenderModel()
    
    if self.isRailgunTarget ~= isTarget and model then
    
        if isTarget then
            EquipmentOutline_AddModel(model, kEquipmentOutlineColor.Red)
        else
            EquipmentOutline_RemoveModel(model)
        end
        
        self.isRailgunTarget = isTarget
    
    end

end