local RestrictedValue = MikSBT.API.RestrictedValue
local Cooldowns = {}

local function NormalizeEnabled(value)
	local booleanValue = RestrictedValue:Boolean(value)
	if booleanValue ~= nil then
		return booleanValue
	end

	local numberValue = RestrictedValue:Number(value)
	if numberValue ~= nil then
		return numberValue ~= 0
	end
end

local function NormalizeCooldown(startTime, duration, isEnabled, modRate)
	startTime = RestrictedValue:Number(startTime)
	duration = RestrictedValue:Number(duration)
	if startTime == nil or duration == nil then
		return nil
	end

	return {
		startTime = startTime,
		duration = duration,
		isEnabled = NormalizeEnabled(isEnabled),
		modRate = RestrictedValue:Number(modRate),
	}
end

function Cooldowns:GetSpell(spellID)
	if RestrictedValue:Number(spellID) == nil then
		return nil
	end

	if C_Spell and type(C_Spell.GetSpellCooldown) == "function" then
		local success, rawCooldown = pcall(C_Spell.GetSpellCooldown, spellID)
		local cooldown = success and RestrictedValue:Table(rawCooldown) or nil
		if not cooldown then
			return nil
		end

		return NormalizeCooldown(
			cooldown.startTime,
			cooldown.duration,
			cooldown.isEnabled,
			cooldown.modRate
		)
	end

	if type(GetSpellCooldown) ~= "function" then
		return nil
	end

	local success, startTime, duration, isEnabled, modRate =
		pcall(GetSpellCooldown, spellID)
	if not success then
		return nil
	end

	return NormalizeCooldown(startTime, duration, isEnabled, modRate)
end

function Cooldowns:GetLegacySpell(spellID)
	local cooldown = self:GetSpell(spellID)
	if not cooldown then
		return nil
	end

	return cooldown.startTime, cooldown.duration, cooldown.isEnabled,
		cooldown.modRate
end

function Cooldowns:GetItem(itemID)
	if RestrictedValue:Number(itemID) == nil
		or not C_Container
		or type(C_Container.GetItemCooldown) ~= "function" then
		return nil
	end

	local success, startTime, duration, isEnabled =
		pcall(C_Container.GetItemCooldown, itemID)
	if not success then
		return nil
	end

	return NormalizeCooldown(startTime, duration, isEnabled)
end

MikSBT.API.Cooldowns = Cooldowns

return Cooldowns
