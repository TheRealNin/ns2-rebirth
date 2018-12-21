
if Client then

    function GasGrenade:OnUpdateRender()
    
        --PredictedProjectile.OnUpdateRender(self)
    
        if self.releaseGas and not self.clientGasReleased then

            self:TriggerEffects("release_nervegas", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )        
            self.clientGasReleased = true
        
        end
    
    end

end