
class 'PrecursorTeamInfo' (TeamInfo)

PrecursorTeamInfo.kMapName = "PrecursorTeamInfo"


PrecursorTeamInfo.kLocationEntityTypes = { "Hive"}


local networkVars =
{
    numCubes = "integer (0 to 10)",
    commanderLocationId = "entityid",
    
}
function PrecursorTeamInfo:OnCreate()

    TeamInfo.OnCreate(self)
    
    self.numCubes = 0
    self.commanderLocationId = Entity.invalidId
    
end


if Server then

    
    function PrecursorTeamInfo:Reset()
    
        TeamInfo.Reset( self ) 
		
        self.numCubes = 0
        self:ResetAllLocationSlotsData()
        
    end
    function PrecursorTeamInfo:ResetAllLocationSlotsData()
        
        self.commanderLocationId = Entity.invalidId
        
    end
    
end

Shared.LinkClassToMap("PrecursorTeamInfo", PrecursorTeamInfo.kMapName, networkVars, true)