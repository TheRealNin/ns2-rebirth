
local networkVars =
{
    entId       = "entityid"
}


AddMixinNetworkVars(TeamMixin, networkVars)

function SensorBlip:OnCreate()

    Entity.OnCreate(self)
    
    self.entId    = Entity.invalidId
    InitMixin(self, TeamMixin)
    
    if Client then
        InitMixin(self, MinimapMappableMixin)
    end
end


function SensorBlip:OnInitialized()
    self:UpdateRelevancy()
end

function SensorBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    -- relevancy is for the other team
    local relevancyMask = (self:GetTeamNumber() == kTeam1Index) and kRelevantToTeam2 or kRelevantToTeam1
    self:SetExcludeRelevancyMask(relevancyMask)
    
end

Shared.LinkClassToMap("SensorBlip", SensorBlip.kMapName, networkVars)