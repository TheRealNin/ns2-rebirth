

local kStatusTranslationStringMap = debug.getupvaluex(Scoreboard_ReloadPlayerData, "kStatusTranslationStringMap")

kStatusTranslationStringMap[kPlayerStatus.WraithFade]="Wraith"

debug.setupvaluex( Scoreboard_ReloadPlayerData, "kStatusTranslationStringMap", kStatusTranslationStringMap)