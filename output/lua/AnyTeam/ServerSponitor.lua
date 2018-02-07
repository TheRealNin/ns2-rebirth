-- have to disable it. It was causing too many errors.

local void = function() end
function ServerSponitor()
	return {
		Initialize = void,
		ListenToTeam = void,
		OnEntityKilled = void,
		Update = void,
		OnEndMatch = void,
		OnJoinTeam = void,
		OnStartMatch = void
	}
end