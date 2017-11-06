-- ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GeneralEffects.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kAnyTeamEffectData = 
{
    bloodmist =
    {
    
        bloodmistEffects =
        {
            {cinematic = "cinematics/marine/bloodmist.cinematic", done = true}
        }   
    }
            
}

GetEffectManager():AddEffectData("AnyTeamEffectData", kAnyTeamEffectData)

-- hack because the effect manager suuuucks
GetEffectManager():PrecacheEffects()
