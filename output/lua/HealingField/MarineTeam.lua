

-- this is pretty tricky
local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    
    -- super tricksy
    local medpack = kTechId.MedPack
    kTechId.MedPack = kTechId.HealingField
    oldInitTechTree(self)
    kTechId.MedPack = medpack
    
end