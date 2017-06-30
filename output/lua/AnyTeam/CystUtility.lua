
if Server then
local function GetClosestCyst(player)
    local origin = player:GetOrigin()
    local teamNumber = player:GetTeamNumber()
    
    -- get closest cyst inside 5m
    local targets = GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, 5)
    local target, range
    for _,t in ipairs(targets) do
        local r = (t:GetOrigin() - origin):GetLength() 
        if target == nil or range > r then
            target, range = t, r
        end
    end
    return target
end

function OnCommandCyst(client, cmd)
    if client ~= nil and (Shared.GetCheatsEnabled() or Shared.GetDevMode()) then
        local cyst = GetClosestCyst(client:GetControllingPlayer())
        if cyst == nil then
            Print("Have to be within 5m of a Cyst for the command to work")
        else
            if cmd == "track" then
                if cyst.track == nil then
                    Log("%s has no track", cyst)
                else
                    Log("track %s", cyst)
                    cyst.track:Debug()
                end
            elseif cmd == "reconnect" then
                TrackYZ.kTrace,TrackYZ.kTraceTrack,TrackYZ.logTable["log"] = true,true,true
                Log("Try reconnect %s", cyst)
                cyst:TryToFindABetterParent()
                TrackYZ.kTrace,TrackYZ.kTraceTrack,TrackYZ.logTable["log"] = false,false,false
            else
                Print("Usage: cyst track - show track to parent") 
            end
        end
    end
end

Event.Hook("Console_cyst", OnCommandCyst)
end