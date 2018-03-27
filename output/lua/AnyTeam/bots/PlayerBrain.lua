
kPlayerBrainTickrate = 6
kPlayerBrainTickFrametime = 1 / kPlayerBrainTickrate

function PlayerBrain:Update(bot, move)
    PROFILE("PlayerBrain:Update")

    if gBotDebug:Get("spam") then
        Log("PlayerBrain:Update")
    end

    if not bot:GetPlayer():isa( self:GetExpectedPlayerClass() )
    or bot:GetPlayer():GetTeamNumber() <= 0 then
        Log("WARNING: Bot isn't on the right team OR the right player class. Deleting brain.")
        bot.brain = nil
        return false
    end

    if not bot:GetPlayer():GetCanControl() then
        -- no point in doing anything if we can't control ourselves
        return false
    end
    
    local time = Shared.GetTime()
    if self.lastAction and self.nextMoveTime and self.nextMoveTime > time and
            self.lastAction.name ~= "attack" and not self.lastAction.fastUpdate then 
        if bot.lastcommands then
            move.commands = bit.bor(move.commands, bot.lastcommands)
        end
        return false
    end

    self.debug = self:GetShouldDebug(bot)

    if self.debug then
        DebugPrint("-- BEGIN BRAIN UPDATE, player name = %s --", bot:GetPlayer():GetName())
    end

    self.teamBrain = GetTeamBrain( bot:GetPlayer():GetTeamNumber() )

    local bestAction = nil

    -- Prepare senses before action-evals use it
    assert( self:GetSenses() ~= nil )
    self:GetSenses():OnBeginFrame(bot)

    for actionNum, actionEval in ipairs( self:GetActions() ) do

        self:GetSenses():ResetDebugTrace()

        local action = actionEval(bot, self)
        assert( action.weight ~= nil )

        if true or self.debug then
            DebugPrint("weight(%s) = %0.2f. trace = %s",
                    action.name, action.weight, self:GetSenses():GetDebugTrace())
        end

        if bestAction == nil or action.weight > bestAction.weight then
            bestAction = action
        end
    end

    if bestAction ~= nil then
        --Log(bestAction.name)
        if self.debug then
            DebugPrint("-- chose action: " .. bestAction.name)
        end

        bestAction.perform(move)
        self.lastAction = bestAction
        self.nextMoveTime = time + 1 / kPlayerBrainTickrate
        
        bot.lastcommands = move.commands

        if self.debug or gBotDebug:Get("debugall") then
            Shared.DebugColor( 0, 1, 0, 1 )
            Shared.DebugText( bestAction.name, bot:GetPlayer():GetEyePos()+Vector(-1,0,0), 0.0 )
        end
    end

end