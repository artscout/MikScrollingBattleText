local RestrictedValue = MikSBT.API.RestrictedValue
local Spells = MikSBT.API.Spells
local Units = MikSBT.API.Units
local Cooldowns = MikSBT.API.Cooldowns

MikSBT.GetSpellInfo = function(...)
	return Spells:GetLegacyInfo(...)
end

MikSBT.GetSpellTexture = function(...)
	return Spells:GetTexture(...)
end

MikSBT.GetSpellCooldown = function(...)
	return Cooldowns:GetLegacySpell(...)
end

MikSBT.HasAura = function(...)
	return Units:HasAura(...)
end

MikSBT.GetSkillName = function(skillID)
	local safeID = RestrictedValue:Number(skillID)
		or RestrictedValue:String(skillID)
	if not safeID then
		return UNKNOWN
	end

	local skillName = Spells:GetLegacyInfo(safeID)
	if not skillName then
		MikSBT.Print("Skill ID " .. safeID .. " has been removed by Blizzard.")
	end

	return skillName or UNKNOWN
end
