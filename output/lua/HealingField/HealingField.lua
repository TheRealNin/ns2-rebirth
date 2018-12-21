
class 'HealingField' (CommanderAbility)

HealingField.kMapName = "healingfield"

HealingField.kFieldEffect = PrecacheAsset("cinematics/healing_field/healing_field.cinematic")
HealingField.kFieldEffectEnemy = PrecacheAsset("cinematics/healing_field/healing_field_enemy.cinematic")
HealingField.kSound = PrecacheAsset("sound/NS2.fev/marine/structures/generic_spawn")
HealingField.kHealthSound = PrecacheAsset("sound/NS2.fev/marine/common/health")

HealingField.kType = CommanderAbility.kType.Repeat
local kHealingInterval = 0.2
HealingField.kRadius = kHealingFieldRadius
kMedpackSoundInterval = 1.0


local networkVars = { }

function HealingField:OnCreate()

    CommanderAbility.OnCreate(self)
    
    if Server then
        StartSoundEffectOnEntity(HealingField.kSound, self)
    end
    
end

function HealingField:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    if Server then
        local function EntityFilterOneOrNotTeamNumberFunction(entity, teamNumber)
            return function (test) return test == entity or test ~= nil and HasMixin(test, "Team") and test:GetTeamNumber() ~= teamNumber end
        end
        local teamNumber = self:GetTeamNumber()
        DestroyEntitiesWithinRange("HealingField", self:GetOrigin(), HealingField.kRadius*1.9, EntityFilterOneOrNotTeamNumberFunction(self, teamNumber)) 
    
    end
    
end

function HealingField:GetRepeatCinematic()
    if kAnyTeamEnabled and Client.GetLocalPlayer() and GetAreEnemies(self, Client.GetLocalPlayer()) then
        return HealingField.kFieldEffectEnemy
    end
    return HealingField.kFieldEffect
end

function HealingField:GetType()
    return HealingField.kType
end

function HealingField:GetUpdateTime()
    return kHealingInterval
end

function HealingField:GetLifeSpan()
    return kHealingFieldDuration
end

function HealingField:GetIntervalHealingAmount()
    return kHealingFieldAmount / self:GetLifeSpan() * self:GetUpdateTime()
end

if Server then

    function HealingField:Perform(deltaTime)
        
        local friendlyMarines = GetEntitiesForTeamWithinXZRange("Marine", self:GetTeamNumber(), self:GetOrigin(), HealingField.kRadius)
        
        for _, recipient in ipairs(friendlyMarines) do
        
            local healed = recipient:Heal(self:GetIntervalHealingAmount())
            -- recipient:AddRegeneration()
            if healed and (not recipient.timeLastMedpack or recipient.timeLastMedpack + kMedpackSoundInterval <= Shared.GetTime()) then 
                StartSoundEffectAtOrigin(HealingField.kHealthSound, self:GetOrigin())
                recipient.timeLastMedpack = Shared.GetTime()
            end

        end
        
        
    end
    
end

Shared.LinkClassToMap("HealingField", HealingField.kMapName, networkVars)