
local oldAddResearchNode = TechTree.AddResearchNode
function TechTree:AddResearchNode(techId, prereq1, prereq2, addOnTechId)

    if techId == kTechId.Stab then
        -- was kTechId.BioMassSeven
        prereq1 = kTechId.BioMassSix
    end
    oldAddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
end