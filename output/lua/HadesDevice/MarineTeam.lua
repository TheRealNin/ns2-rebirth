

-- this is pretty tricky
local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()

    PlayingTeam.InitTechTree(self)
    self.techTree:AddBuildNode(kTechId.HadesDevice , kTechId.None,      kTechId.None)    
    
    -- temporarily disable initializing the tech tree
    local oldPlayingInit = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    oldInitTechTree(self)  
    -- re-enable it now
    PlayingTeam.InitTechTree = oldPlayingInit
end