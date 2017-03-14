
Scan.kEnemyScanEffect = PrecacheAsset("cinematics/marine/observatory/scan_enemy.cinematic")


function Scan:GetRepeatCinematic()
    if Client.GetLocalPlayer() and not GetAreFriends(self, Client.GetLocalPlayer()) then
        return Scan.kEnemyScanEffect
    end
    return Scan.kScanEffect
end
