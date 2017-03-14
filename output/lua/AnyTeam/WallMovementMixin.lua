

function WallMovementMixin:TraceWallNormal(startPoint, endPoint, result, feelerSize)
    
    local theTrace = Shared.TraceCapsule(startPoint, endPoint, feelerSize, 0, CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOneAndIsaActual(self, "Babbler"))
    
    --[[ double-comment to see wall-walk traces
    if Client then
        DebugLine(startPoint, theTrace.endPoint, 5, 0,1,0,1)
    end --]]
    
    if self:ValidWallTrace(theTrace) then 
   
        table.insert(result, theTrace.normal)
        return true
        
    end
    
    return false
    
end
