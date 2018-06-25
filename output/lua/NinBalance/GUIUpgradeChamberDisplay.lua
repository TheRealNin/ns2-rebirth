-- first entry is tech id to use if the player has none of the upgrades in the list
local kIndexToUpgrades =
{
    { kTechId.Shell, kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration },
    { kTechId.Spur, kTechId.Silence, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
}
debug.setupvaluex( GUIUpgradeChamberDisplay.Update, "kIndexToUpgrades", kIndexToUpgrades, true)