-- Removed, basically, because it's fucked.

FlinchMixin = CreateMixin(FlinchMixin)
FlinchMixin.type = "Flinch"

FlinchMixin.networkVars =
{
}

function FlinchMixin:GetFlinchIntensity()
    return 0
end