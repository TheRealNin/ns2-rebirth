
Player.kDamageIndicatorDrawTime = 2.5

function Player:GetIsLocalPlayer()
    return Client and self == Client.GetLocalPlayer()
end