
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

function ReplaceUpValue( func, localname, newval, options )
	local val,i;

	func, val, i = LocateUpValue( func, localname, options );

	if options and options.CopyUpValues then
		CopyUpValues( newval, val )
	end

	debug.setupvalue( func, i, newval )
end

-- Pass in a function and a table of local variables (Lua "upvalues") used in that
-- function and these variables will be replaced.
-- Example: ReplaceLocals(Player.GetJumpHeight, { kMaxHeight = 10 })
-- This example assumed a local variable with the name kMaxHeight is referenced
-- from inside the Player:GetJumpHeight() function.
function ReplaceLocals(originalFunction, replacedLocals)

    local numReplaced = 0
    for name, value in pairs(replacedLocals) do
    
        local index = 1
        local foundIndex = nil
        while true do
        
            local n, v = debug.getupvalue(originalFunction, index)
            if not n then
                break
            end
            
            -- Find the highest index matching the name.
            if n == name then
                foundIndex = index
            end
            
            index = index + 1
            
        end
        
        if foundIndex then
        
            debug.setupvalue(originalFunction, foundIndex, value)
            numReplaced = numReplaced + 1
            
        end
        
    end
    
    return numReplaced
    
end

