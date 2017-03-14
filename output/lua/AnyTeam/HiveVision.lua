
local _renderMask       = 0x2

kHiveVisionOutlineColor = enum { [0]='Blue', 'Green', 'KharaaOrange' }
kHiveVisionOutlineColorCount = #kHiveVisionOutlineColor+1


-- Adds a model to the hive vision
function HiveVision_AddModel(model, color)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask( bit.bor(renderMask, _renderMask) )
    
    local outlineid = Clamp( color or kHiveVisionOutlineColor.Blue, 0, kHiveVisionOutlineColorCount )    
    model:SetMaterialParameter("outline", outlineid/kHiveVisionOutlineColorCount + 0.5/kHiveVisionOutlineColorCount )
end
