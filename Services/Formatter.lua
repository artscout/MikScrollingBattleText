local Formatter = {
	config = {},
}

local function ColorText(settings, text)
	return string.format(
		"|cFF%02x%02x%02x%s|r",
		settings.colorR * 255,
		settings.colorG * 255,
		settings.colorB * 255,
		text
	)
end

function Formatter:Configure(config)
	self.config = config
end

function Formatter:GetProfile()
	return self.config.getProfile()
end

function Formatter:FormatDisplayAmount(amount, profile)
	profile = profile or self:GetProfile()
	if profile.shortenNumbers then
		return self.config.shortenNumber(
			amount,
			profile.shortenNumberPrecision
		)
	end

	return self.config.formatLargeNumber(amount)
end

function Formatter:AbbreviateSkillName(skillName)
	if string.find(skillName, "[%s%-]") then
		return string.gsub(skillName, "(%a)[%l%p]*[%s%-]*", "%1")
	end

	return skillName
end

local function FormatPartialAmount(self, event, profile)
	local amount = event.amount
	local partialAmount = ""
	local partialValue
	local settings

	if event.overhealAmount and event.overhealAmount > 0
		and not profile.overheal.disabled then
		partialValue = event.overhealAmount
		settings = profile.overheal
	elseif event.overkillAmount and event.overkillAmount > 0
		and not profile.overkill.disabled then
		partialValue = event.overkillAmount
		settings = profile.overkill
	end

	if partialValue then
		amount = amount - partialValue
		partialAmount = string.gsub(
			settings.trailer,
			"%%a",
			self:FormatDisplayAmount(partialValue, profile)
		)
		if not profile.partialColoringDisabled then
			partialAmount = ColorText(settings, partialAmount)
		end
	end

	return amount, partialAmount
end

local function FormatName(self, message, event, profile)
	local name = event.name
	if name and string.find(message, "%n", 1, true) then
		if event.hideNames then
			return string.gsub(message, "%s?%-?%s?%%n", ""), true
		end

		if string.find(name, "-", 1, true) then
			name = string.gsub(name, "(.-)%-.*", "%1")
		end

		local classSettings = event.class and profile[event.class]
		if classSettings and not profile.classColoringDisabled
			and not classSettings.disabled then
			name = ColorText(classSettings, name)
		end

		return string.gsub(message, "%%n", name), false
	end

	return string.gsub(message, "%%n", ""), true
end

local function FormatSkill(self, message, event, profile)
	local effectName = event.effectName
	if not effectName then
		return message
	end

	if string.find(message, "%e", 1, true) then
		message = string.gsub(message, "%%e", effectName)
	end
	if not string.find(message, "%s", 1, true) then
		return message
	end
	if event.hideSkills then
		return string.gsub(message, "%s?%-?%s?%%sl?%s?%-?%s?", ""), true
	end

	local isChanged
	local substitution = profile.abilitySubstitutions[effectName]
	if substitution then
		effectName = substitution
		isChanged = true
	end
	if string.find(message, "%sl", 1, true) then
		message = string.gsub(message, "%%sl", effectName)
	end
	if self.config.isEnglish and not isChanged and profile.abbreviateAbilities then
		effectName = self:AbbreviateSkillName(effectName)
	end

	return string.gsub(message, "%%s", effectName), false
end

function Formatter:FormatEvent(event)
	local profile = self:GetProfile()
	local message = event.message
	local checkParens

	if event.amount and string.find(message, "%a", 1, true) then
		local amount, partialAmount = FormatPartialAmount(self, event, profile)
		local formattedAmount = self:FormatDisplayAmount(amount, profile)
		local colorEntry = event.damageType
			and self.config.damageColorEntries[event.damageType]
		local damageSettings = colorEntry and profile[colorEntry]
		if damageSettings and not event.ignoreDamageColoring
			and not profile.damageColoringDisabled
			and not event.forceEventColoring
			and not damageSettings.disabled then
			formattedAmount = ColorText(damageSettings, formattedAmount)
		end
		message = string.gsub(message, "%%a", formattedAmount .. partialAmount)
	end

	if event.powerType and string.find(message, "%p", 1, true) then
		local token = self.config.powerTokens[event.powerType] or "UNKNOWN"
		message = string.gsub(message, "%%p", _G[token] or self.config.unknown)
	end

	local nameChanged
	message, nameChanged = FormatName(self, message, event, profile)
	checkParens = checkParens or nameChanged

	local skillChanged
	message, skillChanged = FormatSkill(self, message, event, profile)
	checkParens = checkParens or skillChanged

	if checkParens then
		message = string.gsub(message, "%(%)", "")
		message = string.gsub(message, "%[%]", "")
		message = string.gsub(message, "%{%}", "")
		message = string.gsub(message, "%<%>", "")
	end

	if event.damageType and string.find(message, "%t", 1, true) then
		local damageType = self.config.damageTypes[event.damageType]
			or self.config.unknownSchool
		message = string.gsub(message, "%%t", damageType)
	end
	if event.partialEffects then
		message = message .. event.partialEffects
	end
	if event.mergeTrailer then
		message = message .. event.mergeTrailer
	end

	return message
end

function Formatter:FormatLegacyEvent(
	message,
	amount,
	damageType,
	overhealAmount,
	overkillAmount,
	powerType,
	name,
	class,
	effectName,
	partialEffects,
	mergeTrailer,
	ignoreDamageColoring,
	hideSkills,
	hideNames,
	forceEventColoring
)
	return self:FormatEvent({
		message = message,
		amount = amount,
		damageType = damageType,
		overhealAmount = overhealAmount,
		overkillAmount = overkillAmount,
		powerType = powerType,
		name = name,
		class = class,
		effectName = effectName,
		partialEffects = partialEffects,
		mergeTrailer = mergeTrailer,
		ignoreDamageColoring = ignoreDamageColoring,
		hideSkills = hideSkills,
		hideNames = hideNames,
		forceEventColoring = forceEventColoring,
	})
end

MikSBT.Services = MikSBT.Services or {}
MikSBT.Services.Formatter = Formatter

return Formatter
