
local origInclude = Script.Load
function Script.Load(script, reload)
    if script == "lua/shine/lib/game.lua" then
        script = "lua/SgShine/game.lua"
    end
    return origInclude(script, reload)
end