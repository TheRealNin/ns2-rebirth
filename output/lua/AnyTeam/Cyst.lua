
local kBestLength = 20
local kPointOffset = Vector(0, 0.1, 0)
local kParentSearchRange = 400


local networkVars = {}
AddMixinNetworkVars(ParasiteMixin, networkVars)
local oldOnCreate = Cyst.OnCreate
function Cyst:OnCreate()
    oldOnCreate(self)
    InitMixin(self, ParasiteMixin)
end

Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)

--
-- To avoid problems with minicysts on walls connection to each other through solid rock,
-- we need to move the start/end points a little bit along the start/end normals
--
local function CreateBetween(trackStart, startNormal, trackEnd, endNormal, startOffset, endOffset)

    trackStart = trackStart + startNormal * 0.01
    trackEnd = trackEnd + endNormal * 0.01
    
    local pathDirection = trackEnd - trackStart
    pathDirection:Normalize()
    
    if startOffset == nil then
        startOffset = 0.1
    end
    
    if endOffset == nil then
        endOffset = 0.1
    end
    
    -- DL: Offset the points a little towards the center point so that we start with a polygon on a nav mesh
    -- that is closest to the start. This is a workaround for edge case where a start polygon is picked on
    -- a tiny island blocked off by an obstacle.
    trackStart = trackStart + pathDirection * startOffset
    trackEnd = trackEnd - pathDirection * endOffset
    
    local points = PointArray()
    Pathing.GetPathPoints(trackEnd, trackStart, points)
    return points
    
end

function Cyst:SetIncludeRelevancyMask(includeMask)
    
    if self:GetTeamNumber() == kTeam1Index then
        --Print("Relevant to team 1")
        includeMask = bit.bor(includeMask, kRelevantToTeam1Commander)
    elseif self:GetTeamNumber() == kTeam2Index then
        --Print("Relevant to team 2")
        includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
    else
        includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
        includeMask = bit.bor(includeMask, kRelevantToTeam1Commander)
    end
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)    

end


--
-- Return true if a connected cyst parent is availble at the given origin normal, and no destroyed cysts present
--
function GetIsDeadCystNearby(origin, teamNumber) 

    if not teamNumber then
        Print("No teamNumber for GetIsDeadCystNearby")
        return false
    end
    
    local deadCyst = false
    for _, cyst in ipairs(GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, kInfestationRadius)) do
        
        if not cyst:GetIsAlive() then
            deadCyst = true
            break
        end
        
    end
    
    return deadCyst

end

function GetSortedListOfPotentialParents(origin, teamNumber)
    if not teamNumber then
        Print("No teamNumber for GetSortedListOfPotentialParents")
        return {}
    end
    
    function sortByDistance(ent1, ent2)
        return (ent1:GetOrigin() - origin):GetLength() < (ent2:GetOrigin() - origin):GetLength()
    end
    
    -- first, check for hives
    local hives = GetEntitiesForTeamWithinRange("Hive", teamNumber, origin, kHiveCystParentRange)
    table.sort(hives, sortByDistance)
    
    -- add in the cysts. We get all cysts here, but mini-cysts have a shorter parenting range (bug, should be filtered out)
    local cysts = GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, kCystMaxParentRange)
    table.sort(cysts, sortByDistance)
    
    local parents = {}
    table.copy(hives, parents)
    table.copy(cysts, parents, true)
    
    return parents
    
end


-- Takes a position (vector), and returns the path from the given position to the closest connected
-- parent (connected cyst or hive).
-- returns: PointArray path
--          Entity parent
function FindPathToClosestParent(origin, teamNumber)

    PROFILE("Cyst:FindPathToClosestParent")
    
    if not teamNumber then
        Print("no teamNumber set for FindPathToClosestParent")
        return PointArray(), nil
    end

    local parents = GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, kParentSearchRange)
    table.copy(GetEntitiesForTeamWithinRange("Hive", teamNumber, origin, kParentSearchRange), parents, true)
    
    Shared.SortEntitiesByDistance(origin, parents)
    
    local currentPathLength = 100000
    local closestConnectedPathLength = 100000
    
    local currentPath = PointArray()

    local closestParent = nil
    local closestConnectedParent = nil
    
    for i = 1, #parents do
    
        local parent = parents[i]
        
        if parent:GetIsAlive() and ((parent:isa("Cyst") and parent:GetIsConnected()) or (parent:isa("Hive") and parent:GetIsBuilt())) then
        
            local path = PointArray()
            Pathing.GetPathPoints(parent:GetOrigin() + kPointOffset, origin + kPointOffset, path)
            local pathLength = GetPointDistance(path)

            -- it can happen on some maps, just break here when path length or number of points higher than 500
            if pathLength > 500 or #path > 500 then
                --DebugPrint("path length %s, points %s", ToString(pathLength), ToString(#path))
                break
            end
            
            if currentPathLength > pathLength then
            
                currentPath = path
                currentPathLength = pathLength
                closestParent = parent
                
            elseif currentPathLength + 30 < pathLength then                
                break
            end            
        
        end
    
    end
    
    return currentPath, closestParent

end


-- Takes a position (vector) and gives us where cysts should go between this position and
-- the closest connected cyst or hive. (first position is the parent's position!!!)
-- Returns: splitPoints -- a list of positions for the new cysts
--          parent -- the parent cyst it is connecting to
--          normals -- the normal vectors of the cysts (ie on flat ground == straight-up)
function GetCystPoints(origin, teamNumber)
    
    PROFILE("Cyst:GetCystPoints")
    
    if not teamNumber then
        Print("no teamNumber set for GetCystPoints")
    end

    local path, parent = FindPathToClosestParent(origin, teamNumber)

    local splitPoints = {}
    local normals = {}
    
    local maxDistance = kCystMaxParentRange - 1.5
    local minDistance = kCystRedeployRange - 1
    
    local pathLength = GetPointDistance(path)
    
    -- number of cysts needed for the new path, including the new child (at cursor) cyst, but not
    -- including the already existing parent cyst.
    local requiredCystCount = math.ceil(pathLength / maxDistance)
    
    -- a nice, even distance to spread the cysts out.  This is more desirable as opposed to having
    -- every cyst its maximum distance from its parent until the very end of the chain.
    local evenDistance = pathLength / requiredCystCount
    
    if parent then

        table.insert(splitPoints, parent:GetOrigin())
        
        local fromPoint = Vector(parent:GetOrigin())
        local currentDistance = 0
        
        local currentCystIndex = 1 -- first cyst to be placed.

        for i = 1, #path do
        
            if #splitPoints > 20 then
                DebugPrint("split points exceeded 20")
                return {}, nil
            end
        
            local point = path[i]
            currentDistance = currentDistance + (point - fromPoint):GetLength()       
            
            if currentCystIndex == requiredCystCount then
                
                local groundTrace = Shared.TraceRay(origin + Vector(0, 0.25, 0), origin + Vector(0, -5, 0), CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))
                if groundTrace.fraction == 1 then                        
                    return {}, nil                        
                end
                
                table.insert(splitPoints, groundTrace.endPoint)
                table.insert(normals, groundTrace.normal)
                
                break
                
            elseif currentDistance > evenDistance then
            
                local groundTrace = Shared.TraceRay(path[i] + Vector(0, 0.25, 0), path[i] + Vector(0, -5, 0), CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))
                if groundTrace.fraction == 1 then                        
                    return {}, nil                        
                end
                
                table.insert(splitPoints, groundTrace.endPoint)
                table.insert(normals, groundTrace.normal)
                
                currentDistance = (path[i] - point):GetLength()
                
                currentCystIndex = currentCystIndex + 1
                
            end
            
            fromPoint = point
        
        end
    
    end
    
    return splitPoints, parent, normals
    
end


function GetCystParentFromPoint(origin, normal, connectionMethodName, optionalIgnoreEnt, teamNumber)

    PROFILE("Cyst:GetCystParentFromPoint")
    if not teamNumber then
        Print("no teamNumber set for GetCystParentFromPoint")
        return nil, nil
    end
    
    local ents = GetSortedListOfPotentialParents(origin, teamNumber)
    
    if Client then
        MarkPotentialDeployedCysts(ents, origin)
    end
    
    for i = 1, #ents do
    
        local ent = ents[i]
        
        -- must be either a built hive or an cyst with a connected infestation
        if optionalIgnoreEnt ~= ent and
           ((ent:isa("Hive") and ent:GetIsBuilt()) or (ent:isa("Cyst") and ent[connectionMethodName](ent))) then
            
            local range = (origin - ent:GetOrigin()):GetLength()
            if range <= ent:GetCystParentRange() then
            
                -- check if we have a track from the entity to origin
                local endOffset = 0.1
                if ent:isa("Hive") then
                    endOffset = 3
                end
                
                local path = CreateBetween(origin, normal, ent:GetOrigin(), ent:GetCoords().yAxis, 0.1, endOffset)
                if path then
                
                    -- Check that the total path length is within the range.
                    local pathLength = GetPointDistance(path)
                    if pathLength <= ent:GetCystParentRange() then
                        return ent, path
                    end
                    
                end
                
            end
            
        end
        
    end
    
    return nil, nil
    
end

function GetCystParentAvailable(techId, origin, normal, commander)

    PROFILE("Cyst:GetCystParentAvailable")

    local points, parent = GetCystPoints(origin, commander:GetTeamNumber())
    return parent ~= nil
    
end