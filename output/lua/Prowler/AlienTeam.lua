
local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)
    
    
    self.techTree:AddMenu(kTechId.ProwlerMenu)
    self.techTree:AddAction(kTechId.Prowler,                   kTechId.None,                kTechId.None)
    -- prowler researches
    self.techTree:AddResearchNode(kTechId.Howl,              kTechId.BioMassTwo,  kTechId.None, kTechId.AllAliens) 
    
    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end
