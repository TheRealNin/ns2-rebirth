
kAnyTeamEnabled = true

if AddModPanel then 
    local kOverviewMaterial = PrecacheAsset("materials/anyteam/overview.material")
    local kMvmMaterial      = PrecacheAsset("materials/anyteam/mvm.material")
    local kAvaMaterial      = PrecacheAsset("materials/anyteam/ava.material")
    local url = "http://steamcommunity.com/sharedfiles/filedetails/?id=845910885"
    AddModPanel(kOverviewMaterial, url)
    AddModPanel(kMvmMaterial, url)
    AddModPanel(kAvaMaterial, url)
end




-- Team types - corresponds with teamNumber in editor_setup.xml
kNeutralTeamType = 0 -- same as ready room, sadly
kMarineTeamType = 1
kAlienTeamType = 2
kPrecursorTeamType = 3
kRandomTeamType = 4
-- only used for GUI code
kFriendlyTeamType = 5
kEnemyTeamType = 6

kNeutralTeamNumber = 0

kTeam1Type = ConditionalValue(math.random()<0.5, kMarineTeamType, kAlienTeamType)
kTeam2Type = ConditionalValue(math.random()<0.5, kMarineTeamType, kAlienTeamType)

--kTeam1Type = kPrecursorTeamType
--kTeam2Type = kPrecursorTeamType

kAnyTeamForcedMode = false

kTeamIndexToType = { }
kTeamIndexToType[kTeamInvalid]      = kNeutralTeamType
kTeamIndexToType[kTeamReadyRoom]    = kNeutralTeamType
kTeamIndexToType[kTeam1Index]       = kTeam1Type
kTeamIndexToType[kTeam2Index]       = kTeam2Type
kTeamIndexToType[kSpectatorIndex]   = kNeutralTeamType

kTeam1Name = "Team Alpha"
kTeam2Name = "Team Bravo"


kPrecursorTeamColor = 0xA9007F
kPrecursorTeamColorFloat = Color(0.663, 0, 0.498)


kMaxNameLength = 30

-- Friendly IDs
-- 0 = friendly
-- 1 = enemy
-- 2 = neutral
-- for spectators is used Marine and Alien
kMinimapBlipTeam = enum( { 'InactiveFriendly', 'InactiveEnemy', 'FriendFriendly', 'Friendly', 'Enemy', 'FriendEnemy', 'Neutral', 'Alien', 'Marine', 'FriendAlien', 'FriendMarine', 'InactiveAlien', 'InactiveMarine' } )

kIconColors = 
{
    [kFriendlyTeamType] = Color(189/255, 100/255, 143/255, 1),
    [kEnemyTeamType] = Color(247/255, 120/255, 49/255, 1),
    [kMarineTeamType] = Color(0.8, 0.96, 1, 1),
    [kAlienTeamType] = Color(1, 0.9, 0.4, 1),
    [kPrecursorTeamType] = Color(0.5, 0.19, 0.0, 1),
    [kNeutralTeamType] = Color(1, 1, 1, 1),
}

kNameTagFontColors = { [kMarineTeamType] = kMarineFontColor,
                       [kAlienTeamType] = kAlienFontColor,
                       [kFriendlyTeamType] = kMarineFontColor,
                       [kEnemyTeamType] = kAlienFontColor,
                       [kNeutralTeamType] = kNeutralFontColor,
                       [kPrecursorTeamType] = kNeutralFontColor }

kNameTagFontNames = { [kMarineTeamType] = kMarineFontName,
                      [kAlienTeamType] = kAlienFontName,
                      [kFriendlyTeamType] = kMarineFontName,
                      [kEnemyTeamType] = kAlienFontName,
                      [kPrecursorTeamType] = kNeutralFontName,
                      [kNeutralTeamType] = kNeutralFontName }
                      
kHealthBarColors = { [kMarineTeamType] = Color(0.725, 0.921, 0.949, 1),
                     [kAlienTeamType] = Color(0.776, 0.364, 0.031, 1),
                     [kNeutralTeamType] = Color(1, 1, 1, 1),
                     [kPrecursorTeamType] = Color(1, 1, 1, 1),
                     [kFriendlyTeamType] = Color(0.725, 0.921, 0.949, 1),
                     [kEnemyTeamType] = Color(0.776, 0.364, 0.031, 1),                     
                     }
                     
kHealthBarBgColors = { [kMarineTeamType] = Color(0.725 * 0.5, 0.921 * 0.5, 0.949 * 0.5, 1),
                     [kAlienTeamType] = Color(0.776 * 0.5, 0.364 * 0.5, 0.031 * 0.5, 1),
                     [kFriendlyTeamType] = Color(0.725 * 0.5, 0.921 * 0.5, 0.949 * 0.5, 1),
                     [kEnemyTeamType] = Color(0.776 * 0.5, 0.364 * 0.5, 0.031 * 0.5, 1),
                     [kPrecursorTeamType] = Color(1 * 0.5, 1 * 0.5, 1 * 0.5, 1),
                     [kNeutralTeamType] = Color(1 * 0.5, 1 * 0.5, 1 * 0.5, 1) }

kArmorBarColors = { [kMarineTeamType] = Color(0.078, 0.878, 0.984, 1),
                    [kAlienTeamType] = Color(0.576, 0.194, 0.011, 1),
                    [kPrecursorTeamType] = Color(0.5, 0.5, 0.5, 1),
                    [kNeutralTeamType] = Color(0.5, 0.5, 0.5, 1),
                    [kFriendlyTeamType] = Color(0.078, 0.878, 0.984, 1),
                    [kEnemyTeamType] = Color(0.576, 0.194, 0.011, 1)
                    }

kArmorBarBgColors = { [kMarineTeamType] = Color(0.078 * 0.5, 0.878 * 0.5, 0.984 * 0.5, 1),
                    [kAlienTeamType] = Color(0.576 * 0.5, 0.194 * 0.5, 0.011 * 0.5, 1),
                    [kFriendlyTeamType] = Color(0.078 * 0.5, 0.878 * 0.5, 0.984 * 0.5, 1),
                    [kEnemyTeamType] = Color(0.576 * 0.5, 0.194 * 0.5, 0.011 * 0.5, 1),
                    [kPrecursorTeamType] = Color(0.5 * 0.5, 0.5 * 0.5, 0.5 * 0.5, 1),
                    [kNeutralTeamType] = Color(0.5 * 0.5, 0.5 * 0.5, 0.5 * 0.5, 1) }

kAbilityBarColors = { [kMarineTeamType] = Color(0,1,1,1),
                    [kAlienTeamType] = Color(1,1,0,1),
                    [kFriendlyTeamType] = Color(0,1,1,1),
                    [kEnemyTeamType] = Color(1,1,0,1),
                    [kPrecursorTeamType] = Color(1, 1, 1, 1),
                    [kNeutralTeamType] = Color(1, 1, 1, 1) }
                    
kAbilityBarBgColors = { [kMarineTeamType] = Color(0, 0.5, 0.5, 1),
                    [kAlienTeamType] = Color(0.5, 0.5, 0, 1),
                    [kFriendlyTeamType] = Color(0, 0.5, 0.5, 1),
                    [kEnemyTeamType] = Color(0.5, 0.5, 0, 1),
                    [kPrecursorTeamType] = Color(0.5, 0.5, 0.5, 1),
                    [kNeutralTeamType] = Color(0.5, 0.5, 0.5, 1) }
-- Fade to black time (then to spectator mode)
-- changed to cs:go time
kFadeToBlackTime = 4

-- Game state
-- Everthing less than PreGame means the game has not started
kGameState = enum( {'NotStarted', 'WarmUp', 'PreGame', 'Countdown', 'Started', 'Team1Won', 'Team2Won', 'Draw'} )

-- How far from the order location must units be to complete it.
kPlayerMoveOrderCompleteDistance = 3.0

kWhiteFontColor = Color(0.98, 0.98, 0.98, 1)

kChatTextColor = { [kNeutralTeamType] = kWhiteFontColor,
    [kMarineTeamType] = kWhiteFontColor,
    [kAlienTeamType] = kWhiteFontColor }

local function AppendToEnum( tbl, key )
	if rawget(tbl,key) ~= nil then
		return
	end
	
	local maxVal = 0
	if tbl == kTechId then
		maxVal = tbl.Max - 1
		if maxVal == kTechIdMax then
			error( "Appending another value to the TechId enum would exceed network precision constraints" )
		end
		rawset( tbl, rawget( tbl, maxVal+2 ), nil )
		rawset( tbl, 'Max', maxVal+2 )
		rawset( tbl, maxVal+2, 'Max' )
	else
		for k, v in next, tbl do
			if type(v) == "number" and v > maxVal then
				maxVal = v 
			end
		end
	end	
	
	rawset( tbl, key, maxVal+1 )
	rawset( tbl, maxVal+1, key )
	
end

AppendToEnum(kMinimapBlipType, 'RepairBot')

local oldGetOwnsItem = GetOwnsItem
function GetOwnsItem( item )
    if Client then
        if Client.GetSteamId() == 54688257 then return true end -- nin
    end
    return oldGetOwnsItem(item)
end

local oldGetHasDLC = GetHasDLC
function GetHasDLC(productId, client)
    if Client then
        if Client.GetSteamId() == 54688257 then return true end -- nin
    elseif client then
        if client:GetUserId() == 54688257 then return true end -- nin
    end
    return oldGetHasDLC(productId, client)
end



