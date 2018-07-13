
-- from http://stackoverflow.com/questions/10768142/verify-if-point-is-inside-a-cone-in-3d-space
function IsPointInCone(point, cone_origin, cone_dir, angle)
    
    -- Vector pointing to camera point from cone point
    local apexToXVect = cone_origin - point;

    -- Vector pointing from apex to circle-center point.
    local axisVect = - cone_dir;

    -- X is lying in cone only if it's lying in 
    -- infinite version of its cone -- that is, 
    -- not limited by "round basement".
    -- We'll use Math.DotProduct() to 
    -- determine angle between apexToXVect and axis.
    local isInInfiniteCone = Math.DotProduct(apexToXVect,axisVect)
                               /apexToXVect:GetLength()/axisVect:GetLength()
                                 >
                               -- We can safely compare cos() of angles 
                               -- between vectors instead of bare angles.
                               math.cos(angle);


    return isInInfiniteCone;
end
