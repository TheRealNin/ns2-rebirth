
function Armory:ResupplyPlayerDisabled(player)
    
    local resuppliedPlayer = false
    
    -- Heal player first
    if (player:GetHealth() < player:GetMaxHealth()) then

        -- third param true = ignore armor
        player:AddHealth(Armory.kHealAmount, false, true)

        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        
        resuppliedPlayer = true
        --[[
        if HasMixin(player, "ParasiteAble") and player:GetIsParasited() then
        
            player:RemoveParasite()
            
        end
        --]]
        
        if player:isa("Marine") and player.poisoned then
        
            player.poisoned = false
            
        end
        
    elseif (player:GetArmor() < player:GetMaxArmor()) then

        -- third param true = ignore armor
        player:AddArmor(Armory.kHealAmount / 4, true, false)

        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        
        resuppliedPlayer = true
        
    end

    -- Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    
    for index, weapon in ipairs(weapons) do
    
        if weapon:isa("ClipWeapon") then
        
            if weapon:GiveAmmo(1, false) then
            
                self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                resuppliedPlayer = true
                
                break
                
            end 
                   
        end
        
    end
        
    if resuppliedPlayer then
    
        -- Insert/update entry in table
        self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
        
        -- Play effect
        --self:PlayArmoryScan(player:GetId())

    end

end


function Armory:GetShouldResupplyPlayer(player)

    if not player:GetIsAlive() then
        return false
    end
    
    local stunned = HasMixin(player, "Stun") and player:GetIsStunned()
    
    if stunned then
        return false
    end
    
    local inNeed = false
    
    -- Don't resupply when already full
    if (player:GetHealth() < player:GetMaxHealth()) then
        inNeed = true
    elseif (player:GetArmor() < player:GetMaxArmor()) then
        inNeed = true
    else

        -- Do any weapons need ammo?
        for i, child in ientitychildren(player, "ClipWeapon") do
        
            if child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
            
        end
        
    end
    
    if inNeed then
    
        -- Check player facing so players can't fight while getting benefits of armory
        local viewVec = player:GetViewAngles():GetCoords().zAxis

        local toArmoryVec = self:GetOrigin() - player:GetOrigin()
        
        if(GetNormalizedVector(viewVec):DotProduct(GetNormalizedVector(toArmoryVec)) > .75) then
        
            if self:GetTimeToResupplyPlayer(player) then
        
                return true
                
            end
            
        end
        
    end
    
    return false
    
end