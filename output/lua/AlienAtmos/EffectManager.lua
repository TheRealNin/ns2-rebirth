
local origAddEffectData = EffectManager.AddEffectData
function EffectManager:AddEffectData(name, data)
    
    -- fix railgun decal
    if name and name == "DamageEffects" then
    
        for index,record in ipairs(data["damage_decal"]["damageDecals"]) do 
            
            local decalName = record["decal"]
            if decalName == "cinematics/vfx_materials/decals/railgun_hole_02.material" then
                record["scale"] = 0.8
            end
        end
    end
    return origAddEffectData(self, name, data)
end