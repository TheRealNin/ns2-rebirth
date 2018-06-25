
local oldAddBuyNode = TechTree.AddBuyNode
local function HackedAddBuyNode(self, techId, prereq1, prereq2, addOnTechId)
    
    if techId == kTechId.Crush then
        techId = kTechId.Silence
    end
    return oldAddBuyNode(self, techId, prereq1, prereq2, addOnTechId)
    
end

local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    TechTree.AddBuyNode = HackedAddBuyNode
    oldInitTechTree(self)
    
    TechTree.AddBuyNode = oldAddBuyNode
    
end



local kUpgradeStructureTable =
{
    {
        name = "Shell",
        techId = kTechId.Shell,
        upgrades = {
            kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration
        }
    },
    {
        name = "Veil",
        techId = kTechId.Veil,
        upgrades = {
            kTechId.Camouflage, kTechId.Aura, kTechId.Focus
        }
    },
    {
        name = "Spur",
        techId = kTechId.Spur,
        upgrades = {
            kTechId.Silence, kTechId.Celerity, kTechId.Adrenaline
        }
    }
}
function AlienTeam.GetUpgradeStructureTable()
    return kUpgradeStructureTable
end