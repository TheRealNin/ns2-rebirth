
Scan.kEnemyScanEffect = PrecacheAsset("cinematics/marine/observatory/scan_enemy.cinematic")


function Scan:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    if Server then
    
        DestroyEntitiesForTeamWithinRange("Scan", self:GetTeamNumber(), self:GetOrigin(), Scan.kScanDistance * 0.5, EntityFilterOne(self)) 
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    end
    
end

function Scan:GetRepeatCinematic()
    if Client.GetLocalPlayer() and not GetAreFriends(self, Client.GetLocalPlayer()) then
        return Scan.kEnemyScanEffect
    end
    return Scan.kScanEffect
end
