
local function TimeUp(self)
    DestroyEntity(self)
end


function DropPack:SetExpireTime(func, time)
    -- func is ignored because we want to reset stuff
    -- self:AddTimedCallback(func, time)
    self.expireTime = Shared.GetTime() + time
end

if Server then

    local oldOnUpdate = DropPack.OnUpdate
    function DropPack:OnUpdate(deltaTime)
    
        oldOnUpdate(self, deltaTime)
        
        if self.GetIsValidForAmmo then
            local playersNearby = GetEntitiesForTeamTypeWithinXZRange( "Player", self:GetTeamType(), self:GetOrigin(), self.pickupRange )
            Shared.SortEntitiesByDistance(self:GetOrigin(), playersNearby)

            for _, player in ipairs(playersNearby) do
            
                if not player:isa("Commander") and self:GetIsValidForAmmo(player) then
                
                    self:SetExpireTime(TimeUp, kItemStayTime)
                    
                    if self:OnGiveAmmo(player) then
                        DestroyEntity(self)
                        break
                    end
                    
                end
            
            end
        end
        
        if self.expireTime < Shared.GetTime() then
            DestroyEntity(self)
        end
            
    end
end