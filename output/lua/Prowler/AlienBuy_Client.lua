--=============================================================================
--
-- lua/AlienBuy_Client.lua
--
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2011, Unknown Worlds Entertainment
-- Modified by Adam
-- need to do almost a complete copy+paste because locals need to be modified
--
--=============================================================================
Script.Load("lua/InterfaceSounds_Client.lua")
Script.Load("lua/AlienUpgrades_Client.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/Gorge.lua")
Script.Load("lua/Lerk.lua")
Script.Load("lua/Fade.lua")
Script.Load("lua/Onos.lua")

-- Indices passed in from flash
local indexToAlienTechIdTable = {kTechId.Fade, kTechId.Gorge, kTechId.Lerk, kTechId.Onos, kTechId.Skulk, kTechId.Prowler}

local kAlienBuyMenuSounds = { Open = "sound/NS2.fev/alien/common/alien_menu/open_menu",
                              Close = "sound/NS2.fev/alien/common/alien_menu/close_menu",
                              Evolve = "sound/NS2.fev/alien/common/alien_menu/evolve",
                              BuyUpgrade = "sound/NS2.fev/alien/common/alien_menu/buy_upgrade",
                              SellUpgrade = "sound/NS2.fev/alien/common/alien_menu/sell_upgrade",
                              Hover = "sound/NS2.fev/alien/common/alien_menu/hover",
                              SelectSkulk = "sound/NS2.fev/alien/common/alien_menu/skulk_select",
                              SelectProwler = "sound/NS2.fev/alien/common/alien_menu/skulk_select",
                              SelectFade = "sound/NS2.fev/alien/common/alien_menu/fade_select",
                              SelectGorge = "sound/NS2.fev/alien/common/alien_menu/gorge_select",
                              SelectOnos = "sound/NS2.fev/alien/common/alien_menu/onos_select",
                              SelectLerk = "sound/NS2.fev/alien/common/alien_menu/lerk_select" }

for i, soundAsset in pairs(kAlienBuyMenuSounds) do
    Client.PrecacheLocalSound(soundAsset)
end

function IndexToAlienTechId(index)

    if index >= 1 and index <= table.count(indexToAlienTechIdTable) then
        return indexToAlienTechIdTable[index]
    else    
        Print("IndexToAlienTechId(%d) - invalid id passed", index)
        return kTechId.None
    end
    
end

function AlienTechIdToIndex(techId)
    for index, alienTechId in ipairs(indexToAlienTechIdTable) do
        if techId == alienTechId then
            return index
        end
    end
    
    ASSERT(false, "AlienTechIdToIndex(" .. ToString(techId) .. ") - invalid tech id passed")
    return 0
    
end

--
-- Return 1-d array of name, hp, ap, and cost for this class index
--
function AlienBuy_GetClassStats(idx)

    if idx == nil then
        Print("AlienBuy_GetClassStats(nil) called")
    end
    
    -- name, hp, ap, cost
    local techId = IndexToAlienTechId(idx)
    
    if techId == kTechId.Fade then
        return {"Fade", Fade.kHealth, Fade.kArmor, kFadeCost}
    elseif techId == kTechId.Gorge then
        return {"Gorge", kGorgeHealth, kGorgeArmor, kGorgeCost}
    elseif techId == kTechId.Lerk then
        return {"Lerk", kLerkHealth, kLerkArmor, kLerkCost}
    elseif techId == kTechId.Onos then
        return {"Onos", Onos.kHealth, Onos.kArmor, kOnosCost}
    elseif techId == kTechId.Prowler then
        return {"Prowler", Prowler.kHealth, Prowler.kArmor, kProwlerCost}
    else
        return {"Skulk", Skulk.kHealth, Skulk.kArmor, kSkulkCost}
    end   
    
end

function AlienBuy_OnSelectAlien(type)

        -- just in case
    local assetName = kAlienBuyMenuSounds.SelectSkulk
    if type == "Skulk" then
        assetName = kAlienBuyMenuSounds.SelectSkulk
    elseif type == "Gorge" then
        assetName = kAlienBuyMenuSounds.SelectGorge
    elseif type == "Lerk" then
        assetName = kAlienBuyMenuSounds.SelectLerk
    elseif type == "Onos" then
        assetName = kAlienBuyMenuSounds.SelectOnos
    elseif type == "Prowler" then
        assetName = kAlienBuyMenuSounds.SelectSkulk
    elseif type == "Fade" then
        assetName = kAlienBuyMenuSounds.SelectFade
    end
    StartSoundEffect(assetName)

end


-- use those function also in Alien.lua
local gTierTwoTech = nil
function GetAlienTierTwoFor(techId)

    if not gTierTwoTech then
    
        gTierTwoTech = {}
        
        gTierTwoTech[kTechId.Skulk] = kTechId.Leap
        gTierTwoTech[kTechId.Prowler] = kTechId.Leap
        gTierTwoTech[kTechId.Gorge] = kTechId.BileBomb
        gTierTwoTech[kTechId.Lerk] = kTechId.Spores
        gTierTwoTech[kTechId.Fade] = kTechId.MetabolizeHealth
        gTierTwoTech[kTechId.Onos] = kTechId.BoneShield
        
    end
    
    return gTierTwoTech[techId]

end

local gTierThreeTech = nil
function GetAlienTierThreeFor(techId)

    if not gTierThreeTech then
    
        gTierThreeTech = {}
        
        gTierThreeTech[kTechId.Skulk] = kTechId.Xenocide
        gTierThreeTech[kTechId.Prowler] = kTechId.Xenocide
        gTierThreeTech[kTechId.Gorge] = kTechId.WebTech
        gTierThreeTech[kTechId.Lerk] = kTechId.Umbra
        gTierThreeTech[kTechId.Fade] = kTechId.Stab
        gTierThreeTech[kTechId.Onos] = kTechId.Stomp
        
    end
    
    return gTierThreeTech[techId]

end
