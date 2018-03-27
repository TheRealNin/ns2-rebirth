 
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



local function upvalues( func )
	local i = 0;
	if not func then
		return function() end
	else
		return function()
			i = i + 1
			local name, val = debug.getupvalue (func, i)
			if name then
				return i,name,val
			end -- if
		end
	end
end

local function GetUpValues( func )

	local data = {}

	for _,name,val in upvalues( func ) do
		data[name] = val;
	end

	return data

end

local function LocateUpValue( func, upname, options )
	for i,name,val in upvalues( func ) do
		if name == upname then
			return func,val,i
		end
	end

	if options and options.LocateRecurse then
		for i,name,innerfunc in upvalues( func ) do
			if type( innerfunc ) == "function" then
				local r = { LocateUpValue( innerfunc, upname, options ) }
				if #r > 0 then
					return unpack( r )
				end
			end
		end
	end
end

local function SetUpValues( func, source )

	for i,name,val in upvalues( func ) do
		if source[name] then
			if val == nil then
				assert( val == nil )
				debug.setupvalue( func, i, source[name] )
			else
			end
			source[name] = nil
		end
	end

end

local function CopyUpValues( dst, src )
	SetUpValues( dst, GetUpValues( src ) )
end

-- ReplaceUpValue( Babbler.OnProcessMove, "UpdateBabbler", UpdateBabbler, { LocateRecurse = true; CopyUpValues = true; } )
function ReplaceUpValue( func, localname, newval, options )
	local val,i;

	func, val, i = LocateUpValue( func, localname, options );

	if options and options.CopyUpValues then
		CopyUpValues( newval, val )
	end

	debug.setupvalue( func, i, newval )
end

