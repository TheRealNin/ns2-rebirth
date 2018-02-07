

-- slerping between two vectors is moving one to the other along the shortest path along a sphere by rate <rate>
-- You can't slerp between two vectors by a third vector. This function is performing a Lerp on the components of
-- all three arguments if you 
function SlerpVector(current, target, rate)

    local result

    if type(rate) == "number" then
    
        local dot = current:DotProduct(target)
        
        -- close enough
        if dot > 0.99999 or dot < -0.99999 then
          result = rate <= 0.5 and current or target
        else
          result = math.acos(dot)
          result = (current*math.sin((1 - rate)*result) + target*math.sin(rate*result)) / math.sin(result)
        end
        
    elseif rate:isa("Vector") then
        result = Vector()
        result.x = Slerp(current.x, target.x, rate.x)
        result.y = Slerp(current.y, target.y, rate.y)
        result.z = Slerp(current.z, target.z, rate.z)
    
    end
    
    return result

end


function SlerpRadians(current, target, rate)
    -- normalize the current and target angles to between -pi to pi
    current = math.atan2(math.sin(current), math.cos(current))
    target = math.atan2(math.sin(target), math.cos(target))
    
    -- Interpoloate the short way around
    if(target - current > math.pi) then
        target = target - 2*math.pi
    elseif(current - target > math.pi) then
        target = target + 2*math.pi
    end
   
    return Slerp(current, target, rate)

end


-- Returns radians in [-pi,pi)
function RadiansTo2PiRange(rads)

    return math.atan2(math.sin(rads), math.cos(rads))

end

-- this is actually a lerp
function SlerpAngles(current, target, rate)

    -- local result = Angles()
    
    -- result.pitch = SlerpRadians(current.pitch, target.pitch, rate)
    -- result.yaw = SlerpRadians(current.yaw, target.yaw, rate)
    -- result.roll = SlerpRadians(current.roll, target.roll, rate)
    
    return Angles.Lerp(current, target, rate)

end
