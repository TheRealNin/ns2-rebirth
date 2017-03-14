-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Prowler_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function Prowler:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(BiteHowl.kMapName)
    --self:GiveItem(Parasite.kMapName)
    
    self:SetActiveWeapon(BiteHowl.kMapName)    
    
end

function Prowler:InitWeaponsForReadyRoom()
    
    Alien.InitWeaponsForReadyRoom(self)
    
    self:GiveItem(ReadyRoomLeap.kMapName)
    self:SetActiveWeapon(ReadyRoomLeap.kMapName)
    
end

function Prowler:GetTierTwoTechId()
    return kTechId.Howl
end

function Prowler:GetTierThreeTechId()
    return kTechId.XenocideHowl
end