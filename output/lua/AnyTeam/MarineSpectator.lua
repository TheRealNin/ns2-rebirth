
function MarineSpectator:OnCreate()

    TeamSpectator.OnCreate(self)

    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
    end
    
end

function MarineSpectator:OnInitialized()

    TeamSpectator.OnInitialized(self)
    
    
end