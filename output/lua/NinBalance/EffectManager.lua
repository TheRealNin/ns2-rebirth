
-- disable silence for weapon effects
--[[
local oldAddEffectData = EffectManager.AddEffectData
function EffectManager:AddEffectData(name, data)
    if name == "AlienWeaponEffects" then
    
        for effectName, effect in pairs(data) do
            
            for _, effectGrouping in pairs(effect) do
                
                for i=1, #effectGrouping do
                    local component = effectGrouping[i]
                    if component[kEffectFilterSilenceUpgrade] then
                        data[effectName][_][i][kEffectFilterSilenceUpgrade] = false
                        Log("%s", component)
                    end
                end
                
            end
            
        end
        
    end
    
    return oldAddEffectData(self, name, data)
end
]]--