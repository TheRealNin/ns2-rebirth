

local oldGetItemList = Armory.GetItemList
function Armory:GetItemList(forPlayer)
    
    local itemList = oldGetItemList(self, forPlayer)
    table.insert(itemList, kTechId.ShieldGenerator)
    return itemList
    
end


local oldAdvancedArmoryGetItemList = AdvancedArmory.GetItemList
function AdvancedArmory:GetItemList(forPlayer)
    
    local itemList = oldAdvancedArmoryGetItemList(self, forPlayer)
    table.insert(itemList, kTechId.ShieldGenerator)
    return itemList
    
end

local shieldGeneratorPos = 4
local oldGetTechButtons = Armory.GetTechButtons
function Armory:GetTechButtons(techId)
    
    local techButtons = oldGetTechButtons(self, techId)

   -- techButtons = { kTechId.ShotgunTech, kTechId.MinesTech, kTechId.GrenadeTech, kTechId.None,
   --                 kTechId.None, kTechId.None, kTechId.None, kTechId.None }
   
    if techButtons[shieldGeneratorPos] == kTechId.None then
        if GetHasTech(self, kTechId.ShieldGeneratorTech2, true) then
            techButtons[shieldGeneratorPos] = kTechId.ShieldGeneratorTech3
        elseif GetHasTech(self, kTechId.ShieldGeneratorTech, true) then
            techButtons[shieldGeneratorPos] = kTechId.ShieldGeneratorTech2
        else
            techButtons[shieldGeneratorPos] = kTechId.ShieldGeneratorTech
        end
    end
    --techButtons[6] = kTechId.ShieldGeneratorTech
    --techButtons[7] = kTechId.AdvancedShieldGeneratorTech
    
    return techButtons
    
end

local oldAdvancedArmoryGetTechButtons = AdvancedArmory.GetTechButtons
function AdvancedArmory:GetTechButtons(techId)
    
    local techButtons = oldAdvancedArmoryGetTechButtons(self, techId)

   -- techButtons = { kTechId.ShotgunTech, kTechId.MinesTech, kTechId.GrenadeTech, kTechId.None,
   --                 kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    if techButtons[shieldGeneratorPos] == kTechId.None then
        if GetHasTech(self, kTechId.ShieldGeneratorTech2, true) then
            techButtons[shieldGeneratorPos] = kTechId.ShieldGeneratorTech3
        elseif GetHasTech(self, kTechId.ShieldGeneratorTech, true) then
            techButtons[shieldGeneratorPos] = kTechId.ShieldGeneratorTech2
        else
            techButtons[shieldGeneratorPos] = kTechId.ShieldGeneratorTech
        end
    end
    --techButtons[6] = kTechId.ShieldGeneratorTech
    --techButtons[7] = kTechId.AdvancedShieldGeneratorTech
    
    return techButtons
    
end