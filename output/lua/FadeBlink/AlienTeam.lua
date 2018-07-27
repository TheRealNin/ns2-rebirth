
local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)
    
    
    self.techTree:AddAction(kTechId.WraithFade, kTechId.None, kTechId.None)
    
    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end
