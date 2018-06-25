

local kStatusTranslationStringMap = debug.getupvaluex(Scoreboard_ReloadPlayerData, "kStatusTranslationStringMap")

kStatusTranslationStringMap[kPlayerStatus.Prowler]="Prowler"
kStatusTranslationStringMap[kPlayerStatus.ProwlerEgg]="Prowler Egg"


debug.setupvaluex( Scoreboard_ReloadPlayerData, "kStatusTranslationStringMap", kStatusTranslationStringMap)