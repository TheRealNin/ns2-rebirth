
local flying2DSound = PrecacheAsset("sound/NS2.fev/alien/lerk/flying")
local flying3DSound = PrecacheAsset("sound/NS2.fev/alien/lerk/flying_3D")

function Lerk:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Lerk.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kLerkFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, LerkVariantMixin)
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, BabblerClingMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
    
    self.gliding = false
    self.lastTimeFlapped = 0
    
    self.wallGripTime = 0
    
    if Client then   
    
        self.flySound = CreateLoopingSoundForEntity(self, flying2DSound, flying3DSound)
        
        if self.flySound then
        
            self.flySound:Start()
            self.flySound:SetParameter("speed", 0, 10)
            
        end
        
    end
    
    if Server then
        self.playIdleStartTime = 0
    end
end
