
function CreateStructureInfestation(parent, coords, teamNumber, infestationRadius, blobMultiplier)

    local infestation = Infestation()
    infestation:Initialize()
    infestation:SetCoords(coords)    
    infestation:SetMaxRadius(infestationRadius)
    infestation:SetBlobMultiplier(blobMultiplier)
    infestation:SetTeamNumber(teamNumber)
    
    return infestation
    
end

function Infestation:SetTeamNumber(teamNumber)
    self.teamNumber = teamNumber
end

function Infestation:GetTeamNumber()
    return self.teamNumber
end
-- only called when the infestation actually changed
function Infestation:UpdateInfestables()

    PROFILE("Infestation:UpdateInfestables")

    local smallestRadius = self.radius
    local biggestRadius = self.lastRadius
    -- point is guaranteed on infestation when growing, only shrinking requires another check
    local onInfestation = self.radius > self.lastRadius

    if smallestRadius > biggestRadius then
        smallestRadius, biggestRadius = biggestRadius, smallestRadius
    end
    
    local origin = self.coords.origin
    -- don't specify team number here since marine buildings take damage from infestation
    for _, entity in ipairs(GetEntitiesWithMixinWithinRange("InfestationTracker",  self.coords.origin, biggestRadius)) do
    
        local range = (origin - entity:GetOrigin()):GetLength()
        if range >= smallestRadius and range <= biggestRadius then
            entity:UpdateInfestedState(onInfestation)
        end
        
    end

end


-- only called when the infestation actually changed
local oldRenderInfestation = Infestation.RenderInfestation
function Infestation:RenderInfestation(generateBlobs)
    oldRenderInfestation(self, generateBlobs)
    local localPlayer = Client.GetLocalPlayer()
    local showHighlight = localPlayer ~= nil and localPlayer.GetTeamNumber and ((localPlayer:GetTeamNumber() == self:GetTeamNumber() or localPlayer:GetTeamNumber() == kNeutralTeamNumber))
    if localPlayer ~= nil and HasMixin(localPlayer, "Team") and HasMixin(self, "Team") and (localPlayer:GetTeamNumber() == kTeamReadyRoom or localPlayer:GetTeamNumber() == kSpectatorIndex) then
        showHighlight = self:GetTeamNumber() == kTeam2Index
    end
    
    if self.infestationModelArray then
        --Log("Setting infestationModelArray")
        if showHighlight then
            self.infestationModelArray:SetMaterialParameter("tint", 1)
        else
            self.infestationModelArray:SetMaterialParameter("tint", 0)
        end
    end
    
    if self.infestationShellModelArray then
        --Log("Setting infestationShellModelArray")
        if showHighlight then
            self.infestationShellModelArray:SetMaterialParameter("tint", 1)
        else
            self.infestationShellModelArray:SetMaterialParameter("tint", 0)
        end
    end
    if self.infestationDecals then
        --Log("Setting infestation decals")
        if showHighlight then
            self.infestationMaterial:SetParameter("tint", 1)
        else
            self.infestationMaterial:SetParameter("tint", 0)
        end
        
    end
end