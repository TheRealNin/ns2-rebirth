
-- TODO: code assumes that babbler alway belong to team 2 (aliens), need to be fixed when more dynamic teams are done (alien vs. alien?)
local function UpdateRelevancy(self)

    local owner = self:GetOwner()
    local sighted = owner ~= nil and (owner:GetOrigin() - self:GetOrigin()):GetLengthSquared() < 16 and (HasMixin(owner, "LOS") and owner:GetIsSighted())

    local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom, kRelevantToTeam2Commander)    
    if sighted then
        mask = bit.bor(mask, kRelevantToTeam1Commander)
    end
    
    self:SetExcludeRelevancyMask( mask )

end

local function UpdateBabbler(self, deltaTime)

    if Server then

        self:UpdateJumpPhysicsBody()    
        self:UpdateJumpPhysics(deltaTime)
        self:UpdateMove(deltaTime)
        self.attacking = self.timeLastAttack + 0.2 > Shared.GetTime()
        self.wagging = self.moveType == kBabblerMoveType.Wag
        
        UpdateRelevancy(self)

    elseif Client then
    
        self:UpdateMoveDirection(deltaTime)
        if Client.GetLocalPlayer() then
            local model = self:GetRenderModel()
            if model ~= nil and not self.addedToHiveVision and self:GetTeamNumber() == Client.GetLocalPlayer():GetTeamNumber() then
                HiveVision_AddModel(model, kHiveVisionOutlineColor.Blue)
                self.addedToHiveVision = true
            end
        end
    end
    
    self.lastVelocity = self:GetVelocity()
    self.lastOrigin = self:GetOrigin()

end

function Babbler:OnUpdate(deltaTime)

    PROFILE("Babbler:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    
    UpdateBabbler(self, deltaTime)

end