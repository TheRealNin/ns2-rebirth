
Script.Load("lua/ShieldGenerator/PersonalShieldMixin.lua")

local networkVars =
{      
}

AddMixinNetworkVars(PersonalShieldMixin, networkVars)

local oldOnInitialized = Marine.OnInitialized
function Marine:OnInitialized()
    oldOnInitialized(self)
    
    InitMixin(self, PersonalShieldMixin)
end

local oldGetArmorAmount = Marine.GetArmorAmount
function Marine:GetArmorAmount(armorLevels)
    local armorBonus = 0
    if self.personalShielded then
        if GetHasTech(self, kTechId.ShieldGeneratorTech3, true) then
            armorBonus = kPersonalShield3ArmorBonus
        elseif GetHasTech(self, kTechId.ShieldGeneratorTech2, true) then
            armorBonus = kPersonalShield2ArmorBonus
        else
            armorBonus = kPersonalShieldArmorBonus
        end
    end
    return oldGetArmorAmount(self, armorLevels) + armorBonus
end

--[[
local oldGetCanBeWeldedOverride = Marine.GetCanBeWeldedOverride
function Marine:GetCanBeWeldedOverride()
    if self:GetIsPersonalShielded() then
        return false
    end
    return oldGetCanBeWeldedOverride(self)
end
]]--

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)