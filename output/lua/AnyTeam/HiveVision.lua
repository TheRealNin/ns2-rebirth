
local _renderMask       = 0x2
local _invRenderMask    = bit.bnot(_renderMask)

kHiveVisionOutlineColor = enum { [0]='Blue', 'Green', 'KharaaOrange' }
kHiveVisionOutlineColorCount = #kHiveVisionOutlineColor+1


-- Adds a model to the hive vision
function HiveVision_AddModel(model, color)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask( bit.bor(renderMask, _renderMask) )
    local outlineid = Clamp( color or kHiveVisionOutlineColor.KharaaOrange, 0, kHiveVisionOutlineColorCount )    
    model:SetMaterialParameter("outline", outlineid/kHiveVisionOutlineColorCount + 0.5/kHiveVisionOutlineColorCount )
end

-- Removes a model from the hive vision
function HiveVision_RemoveModel(model)
    if model then
        local renderMask = model:GetRenderMask()
        model:SetRenderMask( bit.band(renderMask, _invRenderMask) )
    end
end
