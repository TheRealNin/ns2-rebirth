 
 -- THIS IS A HACK - it just so happens that everywhere that tests this is for "Babbler" only actually just means to filter out the current team
function EntityFilterOneAndIsa(entity, classname)
    if classname == "Babbler" then
      return function (test) return test == entity or (test:isa(classname) and test.GetTeamNumber and entity.GetTeamNumber and test:GetTeamNumber() == entity:GetTeamNumber())  end
    else
      return function (test) return test == entity or test:isa(classname) end
    end
end
function EntityFilterOneAndIsaEnemyBabbler(entity)
    return function (test) return test == entity or (test:isa("Babbler") and test.GetTeamNumber and entity.GetTeamNumber and test:GetTeamNumber() ~= entity:GetTeamNumber())  end
end

function EntityFilterOneAndIsaActual(entity, classname)
    return function (test) return test == entity or test:isa(classname) end
end

function GetColorForPlayer(player)

    if(player ~= nil) then
        if player:GetTeamType() == kMarineTeamType then
            return kMarineTeamColor
        elseif player:GetTeamType() == kAlienTeamType then
            return kAlienTeamColor
        end
    end
    
    return kNeutralTeamColor   
    
end

-- This assumes marines vs. aliens
function GetColorForTeamNumber(teamNumber)
    --[[
    if kTeamIndexToType[teamNumber] == kMarineTeamType then
        return kMarineTeamColor
    elseif kTeamIndexToType[teamNumber] == kAlienTeamType then
        return kAlienTeamColor
    end
    ]]--
    local localTeamNumber = Client.GetLocalPlayer():GetTeamNumber() or -1
    if localTeamNumber == teamNumber and (localTeamNumber == 1 or localTeamNumber == 2) then
        return kMarineTeamColor
    elseif localTeamNumber == GetEnemyTeamNumber(teamNumber) then
        return kAlienTeamColor
    end
    
    return kNeutralTeamColor   
    
end

function GetColorCustomColorForTeamNumber(teamNumber, MarineTeamColor, AlienTeamColor, NeutralTeamColor)

    local localTeamNumber = Client.GetLocalPlayer():GetTeamNumber() or -1
    if (localTeamNumber == 1 or localTeamNumber == 2) then
        if localTeamNumber == teamNumber then
            return MarineTeamColor
        elseif localTeamNumber == GetEnemyTeamNumber(teamNumber) then
            return AlienTeamColor
        end
    else
        if teamNumber == kTeam1Index then
            return MarineTeamColor
        elseif teamNumber == kTeam2Index  then
            return AlienTeamColor
        end
    end
    
    return NeutralTeamColor   
    
end

function ConcatTable(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end


