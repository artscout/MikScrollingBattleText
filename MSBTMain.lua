
local module = {}
local moduleName = "Main"
MikSBT[moduleName] = module

local MSBTAnimations = MikSBT.Animations
local MSBTMedia = MikSBT.Media
local MSBTParser = MikSBT.Parser
local MSBTTriggers = MikSBT.Triggers
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations
local Formatter = MikSBT.Services.Formatter
local EventRouter = MikSBT.Services.EventRouter
local CombatRoutes = MikSBT.Services.CombatRoutes
local Trace = MikSBT.Trace
local IncomingCombat = MikSBT.Components.IncomingCombat
local OutgoingBatcher = MikSBT.Components.OutgoingBatcher
local DamageMeterSource = MikSBT.Components.DamageMeterSource
local OutgoingCombat = MikSBT.Components.OutgoingCombat
local CombatTextSource = MikSBT.Components.CombatTextSource
local CombatLogMessageSource = MikSBT.Components.CombatLogMessageSource
local ParserNotifications = MikSBT.Components.ParserNotifications
local UtilityNotifications = MikSBT.Components.UtilityNotifications
local Client = MikSBT.Compatibility.Client

local string_find = string.find
local string_gsub = string.gsub
local table_remove = table.remove
local FormatLargeNumber = FormatLargeNumber
local GetTime = GetTime

local GetSpellInfo = MikSBT.GetSpellInfo
local ShortenNumber = MikSBT.ShortenNumber
local DisplayEvent = MSBTAnimations.DisplayEvent
local IsScrollAreaActive = MSBTAnimations.IsScrollAreaActive
local IsScrollAreaIconShown = MSBTAnimations.IsScrollAreaIconShown

local powerTypes = MSBTTriggers.powerTypes

local HasModernAPI = Client.hasModernAPI



local EMOTE_HOLD_TIME = 1

local DAMAGETYPE_PHYSICAL = 0x1
local DAMAGETYPE_HOLY = 0x2
local DAMAGETYPE_FIRE = 0x4
local DAMAGETYPE_NATURE = 0x8
local DAMAGETYPE_FROST = 0x10
local DAMAGETYPE_SHADOW = 0x20
local DAMAGETYPE_ARCANE = 0x40

local DAMAGETYPE_SPELLSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_ARCANE
local DAMAGETYPE_FLAMESTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FIRE
local DAMAGETYPE_FROSTSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FROST
local DAMAGETYPE_STORMSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_NATURE
local DAMAGETYPE_SHADOWSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_SHADOW
local DAMAGETYPE_HOLYSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY

local DAMAGETYPE_SPELLFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLFROST = DAMAGETYPE_FROST + DAMAGETYPE_ARCANE
local DAMAGETYPE_DIVINE = DAMAGETYPE_HOLY + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSHADOW = DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_HOLYFIRE = DAMAGETYPE_HOLY + DAMAGETYPE_FIRE
local DAMAGETYPE_HOLYSTORM = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE
local DAMAGETYPE_HOLYFROST = DAMAGETYPE_HOLY + DAMAGETYPE_FROST
local DAMAGETYPE_FIRESTORM = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE
local DAMAGETYPE_SHADOWFLAME = DAMAGETYPE_FIRE + DAMAGETYPE_SHADOW
local DAMAGETYPE_FROSTFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_FROST
local DAMAGETYPE_FROSTSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWFROST = DAMAGETYPE_FROST + DAMAGETYPE_SHADOW
local DAMAGETYPE_SHADOWHOLY = DAMAGETYPE_HOLY + DAMAGETYPE_SHADOW
local DAMAGETYPE_SHADOWSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW

local DAMAGETYPE_ELEMENTAL = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_COSMIC = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_CHROMATIC = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_MAGIC = DAMAGETYPE_ARCANE + DAMAGETYPE_FIRE + DAMAGETYPE_FROST + DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW + DAMAGETYPE_HOLY
local DAMAGETYPE_CHAOS = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY + DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE





local _

local eventFrame = CreateFrame("Frame")

local playerClass

local eventRouter = EventRouter:New()
local damageTypeMap = {}
local damageColorProfileEntries = {}
local powerTokens = {}


local isEnglish
local playerGUID
local AUTOSHOT_SPELL_ID = 6603
local OUTGOING_GROUP_DELAY = 0.2
local INCOMING_GROUP_DELAY = 0.12
local OUTGOING_FALLBACK_ATTRIBUTION_WINDOW = 0.9
local OUTGOING_DELAYED_SPELL_ATTRIBUTION_WINDOW = 3.0
local OUTGOING_SIGNAL_CONFIDENCE_WINDOW = 1.25
local INCOMING_SELF_HEAL_ICON_ATTRIBUTION_WINDOW = 12.0
local DAMAGE_METER_FALLBACK_STALE_TIME = 0.35
local DAMAGE_METER_POLL_INTERVAL = 0.5
local USE_DAMAGE_METER_OUTGOING = true
local DOT_FALLBACK_DURATION = 18
local incomingCombat
local outgoingCombat
local dispelMeterSource, interruptMeterSource
local SafeUnitBoolean, NoteParserDamage
local parserNotifications
local utilityNotifications
local DOT_FALLBACK_SPELLS = {
	[8921] = {8921},
	[93402] = {93402},
	[106830] = {106830, 405233},
	[77758] = {77758, 405233},
}
local REPEAT_SHOT_SPELLS = {
	[75] = true, -- Auto Shot
	[2764] = true, -- Throw
	[3018] = true, -- Shoot (bow/gun/crossbow)
	[5019] = true, -- Shoot (wand)
}
-- Classic periodic spells, matched by name so every rank is covered. Physical
-- ones are left out: they would swallow melee swings.
local NAMED_DOT_SPELLS = {
	[589] = { duration = 18, school = 32, interval = 3 }, -- Shadow Word: Pain
	[2944] = { duration = 24, school = 32, interval = 3 }, -- Devouring Plague
	[172] = { duration = 18, school = 32, interval = 3 }, -- Corruption
	[980] = { duration = 24, school = 32, interval = 2 }, -- Curse of Agony
	[18265] = { duration = 30, school = 32, interval = 3 }, -- Siphon Life
	[348] = { duration = 15, school = 4, interval = 3 }, -- Immolate
	[8921] = { duration = 12, school = 64, interval = 3 }, -- Moonfire
	[5570] = { duration = 12, school = 8, interval = 2 }, -- Insect Swarm
	[1978] = { duration = 15, school = 8, interval = 3 }, -- Serpent Sting
	[8050] = { duration = 12, school = 4, interval = 3 }, -- Flame Shock
}
local DISPEL_SPELLS = {
	[527] = true, -- Dispel Magic
	[528] = true, -- Cure Disease (priest)
	[552] = true, -- Abolish Disease
	[1152] = true, -- Purify
	[4987] = true, -- Cleanse
	[475] = true, -- Remove Lesser Curse
	[2782] = true, -- Remove Curse
	[8946] = true, -- Cure Poison (druid)
	[2893] = true, -- Abolish Poison
	[526] = true, -- Cure Poison (shaman)
	[2870] = true, -- Cure Disease (shaman)
	[370] = true, -- Purge
	[19505] = true, -- Devour Magic
}
local INTERRUPT_SPELLS = {
	[1766] = true, -- Kick
	[6552] = true, -- Pummel
	[72] = true, -- Shield Bash
	[2139] = true, -- Counterspell
	[8042] = true, -- Earth Shock
	[15487] = true, -- Silence
	[19244] = true, -- Spell Lock
}
local INTERRUPT_MATCH_WINDOW = 0.6
local CLIENT_TOC_VERSION = tonumber((select(4, GetBuildInfo()))) or 0
local IS_FOREVER_CLIENT = CLIENT_TOC_VERSION >= 16000 and CLIENT_TOC_VERSION < 20000
local NAMED_HOT_SPELLS = {
	[139] = { duration = 15 }, -- Renew
	[774] = { duration = 12 }, -- Rejuvenation
	[8936] = { duration = 21 }, -- Regrowth
}
local namedDotsByName
local namedHotsByName

local function BuildSpellNameMap(spellTable)
	local byName, complete = {}, true
	for spellID, info in pairs(spellTable) do
		local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID)
		if type(name) == "string" and name ~= "" then
			byName[name] = info
		else
			complete = false
		end
	end
	return byName, complete
end

local function GetNamedHots()
	if namedHotsByName then
		return namedHotsByName
	end
	local byName, complete = BuildSpellNameMap(NAMED_HOT_SPELLS)
	if complete then
		namedHotsByName = byName
	end
	return byName
end

local function GetNamedDots()
	if namedDotsByName then
		return namedDotsByName
	end
	local byName, complete = BuildSpellNameMap(NAMED_DOT_SPELLS)
	if complete then
		namedDotsByName = byName
	end
	return byName
end

local DOT_FALLBACK_TIMED_SPELLS = {
	[202770] = 8,
}


local function CreateDamageMaps()

	damageTypeMap[DAMAGETYPE_PHYSICAL] = STRING_SCHOOL_PHYSICAL
	damageTypeMap[DAMAGETYPE_HOLY] = STRING_SCHOOL_HOLY
	damageTypeMap[DAMAGETYPE_FIRE] = STRING_SCHOOL_FIRE
	damageTypeMap[DAMAGETYPE_NATURE] = STRING_SCHOOL_NATURE
	damageTypeMap[DAMAGETYPE_FROST] = STRING_SCHOOL_FROST
	damageTypeMap[DAMAGETYPE_SHADOW] = STRING_SCHOOL_SHADOW
	damageTypeMap[DAMAGETYPE_ARCANE] = STRING_SCHOOL_ARCANE
	damageTypeMap[DAMAGETYPE_HOLYSTRIKE] = STRING_SCHOOL_HOLYSTRIKE
	damageTypeMap[DAMAGETYPE_FLAMESTRIKE] = STRING_SCHOOL_FLAMESTRIKE
	damageTypeMap[DAMAGETYPE_STORMSTRIKE] = STRING_SCHOOL_STORMSTRIKE
	damageTypeMap[DAMAGETYPE_SHADOWSTRIKE] = STRING_SCHOOL_SHADOWSTRIKE
	damageTypeMap[DAMAGETYPE_FROSTSTRIKE] = STRING_SCHOOL_FROSTSTRIKE
	damageTypeMap[DAMAGETYPE_SPELLSTRIKE] = STRING_SCHOOL_SPELLSTRIKE
	damageTypeMap[DAMAGETYPE_HOLYFIRE] = STRING_SCHOOL_HOLYFIRE
	damageTypeMap[DAMAGETYPE_SHADOWHOLY] = STRING_SCHOOL_SHADOWHOLY
	damageTypeMap[DAMAGETYPE_DIVINE] = STRING_SCHOOL_DIVINE
	damageTypeMap[DAMAGETYPE_HOLYSTORM] = STRING_SCHOOL_HOLYSTORM
	damageTypeMap[DAMAGETYPE_HOLYFROST] = STRING_SCHOOL_HOLYFROST
	damageTypeMap[DAMAGETYPE_FIRESTORM] = STRING_SCHOOL_FIRESTORM
	damageTypeMap[DAMAGETYPE_FROSTFIRE] = STRING_SCHOOL_FROSTFIRE
	damageTypeMap[DAMAGETYPE_SHADOWFLAME] = STRING_SCHOOL_SHADOWFLAME
	damageTypeMap[DAMAGETYPE_SPELLFIRE] = STRING_SCHOOL_SPELLFIRE
	damageTypeMap[DAMAGETYPE_FROSTSTORM] = STRING_SCHOOL_FROSTSTORM
	damageTypeMap[DAMAGETYPE_SHADOWSTORM] = STRING_SCHOOL_SHADOWSTORM
	damageTypeMap[DAMAGETYPE_SPELLSTORM] = STRING_SCHOOL_SPELLSTORM
	damageTypeMap[DAMAGETYPE_SHADOWFROST] = STRING_SCHOOL_SHADOWFROST
	damageTypeMap[DAMAGETYPE_SPELLFROST] = STRING_SCHOOL_SPELLFROST
	damageTypeMap[DAMAGETYPE_SPELLSHADOW] = STRING_SCHOOL_SPELLSHADOW
	damageTypeMap[DAMAGETYPE_ELEMENTAL] = STRING_SCHOOL_ELEMENTAL
	damageTypeMap[DAMAGETYPE_COSMIC] = STRING_SCHOOL_COSMIC or L.COSMIC
	damageTypeMap[DAMAGETYPE_CHROMATIC] = STRING_SCHOOL_CHROMATIC
	damageTypeMap[DAMAGETYPE_MAGIC] = STRING_SCHOOL_MAGIC
	damageTypeMap[DAMAGETYPE_CHAOS] = STRING_SCHOOL_CHAOS

	damageColorProfileEntries[DAMAGETYPE_PHYSICAL] = "physical"
	damageColorProfileEntries[DAMAGETYPE_HOLY] = "holy"
	damageColorProfileEntries[DAMAGETYPE_FIRE] = "fire"
	damageColorProfileEntries[DAMAGETYPE_NATURE] = "nature"
	damageColorProfileEntries[DAMAGETYPE_FROST] = "frost"
	damageColorProfileEntries[DAMAGETYPE_SHADOW] = "shadow"
	damageColorProfileEntries[DAMAGETYPE_ARCANE] = "arcane"
	damageColorProfileEntries[DAMAGETYPE_HOLYSTRIKE] = "holystrike"
	damageColorProfileEntries[DAMAGETYPE_FLAMESTRIKE] = "flamestrike"
	damageColorProfileEntries[DAMAGETYPE_STORMSTRIKE] = "stormstrike"
	damageColorProfileEntries[DAMAGETYPE_FROSTSTRIKE] = "froststrike"
	damageColorProfileEntries[DAMAGETYPE_SHADOWSTRIKE] = "shadowstrike"
	damageColorProfileEntries[DAMAGETYPE_SPELLSTRIKE] = "spellstrike"
	damageColorProfileEntries[DAMAGETYPE_HOLYFIRE] = "radiant"
	damageColorProfileEntries[DAMAGETYPE_SHADOWHOLY] = "twilight"
	damageColorProfileEntries[DAMAGETYPE_DIVINE] = "divine"
	damageColorProfileEntries[DAMAGETYPE_HOLYSTORM] = "holystorm"
	damageColorProfileEntries[DAMAGETYPE_HOLYFROST] = "holyfrost"
	damageColorProfileEntries[DAMAGETYPE_FIRESTORM] = "volcanic"
	damageColorProfileEntries[DAMAGETYPE_FROSTFIRE] = "frostfire"
	damageColorProfileEntries[DAMAGETYPE_SHADOWFLAME] = "shadowflame"
	damageColorProfileEntries[DAMAGETYPE_SPELLFIRE] = "spellfire"
	damageColorProfileEntries[DAMAGETYPE_FROSTSTORM] = "froststorm"
	damageColorProfileEntries[DAMAGETYPE_SHADOWSTORM] = "plague"
	damageColorProfileEntries[DAMAGETYPE_SPELLSTORM] = "astral"
	damageColorProfileEntries[DAMAGETYPE_SHADOWFROST] = "shadowfrost"
	damageColorProfileEntries[DAMAGETYPE_SPELLFROST] = "spellfrost"
	damageColorProfileEntries[DAMAGETYPE_SPELLSHADOW] = "spellshadow"
	damageColorProfileEntries[DAMAGETYPE_ELEMENTAL] = "elemental"
	damageColorProfileEntries[DAMAGETYPE_COSMIC] = "cosmic"
	damageColorProfileEntries[DAMAGETYPE_CHROMATIC] = "chromatic"
	damageColorProfileEntries[DAMAGETYPE_MAGIC] = "magic"
	damageColorProfileEntries[DAMAGETYPE_CHAOS] = "chaos"
end

local function IsPlainValue(value)
	if issecretvalue and issecretvalue(value) then
		return false
	end
	return value ~= nil
end

local function ParserEventsHandler(parserEvent)
	local currentProfile = MSBTProfiles.currentProfile
	Trace:Inc("emit:" .. tostring(parserEvent.eventType))
	local eventTypeString, effectName, affectedUnitName, affectedUnitClass =
		eventRouter:Resolve(parserEvent, currentProfile)
	if not eventTypeString then
		Trace:Inc("route:none")
		return
	end
	if IsPlainValue(effectName) and currentProfile.abilitySuppressions[effectName] then
		Trace:Inc("route:suppressed")
		return
	end
	local eventSettings
	if parserEvent.isCrit then
		eventSettings = currentProfile.events[eventTypeString .. "_CRIT"]
		if eventSettings and eventSettings.disabled then
			eventSettings = nil
		end
	end
	eventSettings = eventSettings or currentProfile.events[eventTypeString]
	if not eventSettings or eventSettings.disabled
		or not IsScrollAreaActive(eventSettings.scrollArea) then
		Trace:Inc("route:off " .. eventTypeString)
		return
	end
	Trace:Inc("route:ok")
	local effectTexture
	if not currentProfile.skillIconsDisabled and IsScrollAreaIconShown(eventSettings.scrollArea) then
		effectTexture = parserEvent.effectTexture
		local iconID = parserEvent.extraSkillID or parserEvent.skillID
		if not effectTexture and IsPlainValue(iconID) and iconID ~= AUTOSHOT_SPELL_ID then
			_, _, effectTexture = GetSpellInfo(iconID)
		end
		if not effectTexture and IsPlainValue(effectName) then
			_, _, effectTexture = GetSpellInfo(effectName)
		end
	end
	if parserEvent.skillID == AUTOSHOT_SPELL_ID then
		effectName = nil
	end
	local damageType = IsPlainValue(parserEvent.damageType) and parserEvent.damageType or nil
	local outputMessage = Formatter:FormatLegacyEvent(
		eventSettings.message, parserEvent.amount, damageType,
		parserEvent.overhealAmount, nil, parserEvent.powerType,
		affectedUnitName, affectedUnitClass, effectName,
		nil, nil, nil,
		effectTexture and not currentProfile.exclusiveSkillsDisabled or currentProfile.hideSkills,
		currentProfile.hideNames, true
	)
	DisplayEvent(eventSettings, outputMessage, effectTexture)
end

function eventFrame:UNIT_POWER_UPDATE(unitID, powerToken)
	utilityNotifications:HandlePowerUpdate(unitID, powerToken)
end

function eventFrame:PLAYER_REGEN_ENABLED()
	incomingCombat:Reset()
	outgoingCombat:ResetCombatState(false)
	dispelMeterSource:Poll()
	interruptMeterSource:Poll()
	dispelMeterSource:Reset(false)
	interruptMeterSource:Reset(false)
	utilityNotifications:HandleCombatLeave()
end
function eventFrame:PLAYER_REGEN_DISABLED()
	incomingCombat:Reset()
	outgoingCombat:ResetCombatState(true)
	dispelMeterSource:Reset(true)
	interruptMeterSource:Reset(true)
	utilityNotifications:HandleCombatEnter()
end
function eventFrame:CHAT_MSG_MONSTER_EMOTE(message, sourceName)
	utilityNotifications:HandleMonsterEmote(message, sourceName)
end
local function NormalizeNumber(value)
	local ok, result = pcall(function()
		return value + 0
	end)
	if ok and type(result) == "number" then
		return result
	end
	return nil
end

SafeUnitBoolean = function(func, ...)
	if type(func) ~= "function" then
		return false
	end

	local ok, value = pcall(func, ...)
	if not ok then
		return false
	end

	local okNormalize, normalized = pcall(function()
		return value and true or false
	end)
	if okNormalize then
		return normalized
	end

	return false
end

local function IsLikelySpellSchool(schoolMask)
	local maskType = type(schoolMask)
	if maskType == "number" then
		return schoolMask ~= 0 and schoolMask ~= 1
	elseif maskType == "string" then
		if schoolMask == "" then
			return false
		end
		local lowerMask = string.lower(schoolMask)
		local physicalName = STRING_SCHOOL_PHYSICAL and string.lower(STRING_SCHOOL_PHYSICAL) or "physical"
		return lowerMask ~= physicalName and lowerMask ~= "physical"
	end
	return false
end

local function IsAutoAttackSpellID(spellID)
	if not spellID then
		return true
	end
	if C_Spell and C_Spell.IsAutoAttackSpell and C_Spell.IsAutoAttackSpell(spellID) then
		return true
	end
	if C_Spell and C_Spell.IsRangedAutoAttackSpell and C_Spell.IsRangedAutoAttackSpell(spellID) then
		return true
	end
	return spellID == AUTOSHOT_SPELL_ID
end

local function CanUseAutoAttackFallback(now, lastAutoAttackTime)
	local autoActive = false

	if type(IsCurrentSpell) == "function" then
		local ok, result = pcall(IsCurrentSpell, AUTOSHOT_SPELL_ID)
		if ok and result then
			autoActive = true
		end
	end
	if (not autoActive) and type(IsAutoRepeatSpell) == "function" then
		local ok, result = pcall(IsAutoRepeatSpell)
		if ok and result then
			autoActive = true
		end
	end
	if (not autoActive) and C_Spell and type(C_Spell.IsAutoAttackSpell) == "function" then
		local ok, result = pcall(C_Spell.IsAutoAttackSpell, AUTOSHOT_SPELL_ID)
		if ok and result then
			autoActive = true
		end
	end
	if not autoActive then
		return false
	end

	local okSpeed, mainSpeedRaw, offSpeedRaw = pcall(UnitAttackSpeed, "player")
	local mainSpeed = okSpeed and NormalizeNumber(mainSpeedRaw) or nil
	local offSpeed = okSpeed and NormalizeNumber(offSpeedRaw) or nil
	local swingSpeed = mainSpeed or offSpeed or 2
	if offSpeed and offSpeed < swingSpeed then
		swingSpeed = offSpeed
	end

	local minGap = math.max(0.25, swingSpeed * 0.45)
	return (now - (lastAutoAttackTime or 0)) >= minGap
end

local function IsOutgoingTargetContextValid()
	if not SafeUnitBoolean(UnitExists, "target") then
		return false
	end
	if not SafeUnitBoolean(UnitCanAttack, "player", "target") then
		return false
	end
	return true
end

local function HasPlayerDebuffOnTarget(spellID)
	if not spellID or not SafeUnitBoolean(UnitExists, "target") then
		return false
	end

	if AuraUtil and AuraUtil.FindAuraBySpellID then
		local ok, auraData = pcall(AuraUtil.FindAuraBySpellID, spellID, "target", "HARMFUL|PLAYER")
		if ok and auraData then
			return true
		end
	end

	if C_UnitAuras and type(C_UnitAuras.GetAuraDataByIndex) == "function" then
		for i = 1, 40 do
			local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, "HARMFUL")
			if not ok or not aura then
				break
			end
			local auraSpellID = aura.spellId or aura.spellID
			local sourceUnit = aura.sourceUnit or aura.unitCaster
			local okMatch, isMatch = pcall(function()
				return auraSpellID == spellID
			end)
			local okSource, isOwned = pcall(function()
				return sourceUnit == "player" or sourceUnit == "pet" or sourceUnit == "vehicle"
			end)
			if okMatch and isMatch and okSource and isOwned then
				return true
			end
		end
	end

	if type(UnitAura) == "function" then
		for i = 1, 40 do
			local _, _, _, _, _, _, _, unitCaster, _, _, auraSpellID = UnitAura("target", i, "HARMFUL")
			if not auraSpellID then
				break
			end
			local okMatch, isMatch = pcall(function()
				return auraSpellID == spellID
			end)
			local okSource, isOwned = pcall(function()
				return unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"
			end)
			if okMatch and isMatch and okSource and isOwned then
				return true
			end
		end
	end
	return false
end

local function HasPlayerAnyDebuffOnTarget(spellIDs)
	if not spellIDs then
		return false
	end
	for i = 1, #spellIDs do
		if HasPlayerDebuffOnTarget(spellIDs[i]) then
			return true
		end
	end
	return false
end

local function ShouldSplitCritBatch(eventSettings, critSettings, critCount)
	local normalScrollArea = eventSettings and eventSettings.scrollArea
	local critScrollArea = critSettings and critSettings.scrollArea

	return critCount and critCount > 0
		and critSettings and not critSettings.disabled
		and normalScrollArea and critScrollArea
		and normalScrollArea ~= critScrollArea
end

local function ResolveBatchDisplaySettings(eventSettings, critSettings, hitCount, critCount)
	if hitCount and hitCount > 0 and hitCount == critCount
		and critSettings and not critSettings.disabled then
		return critSettings
	end

	return eventSettings
end

local function BuildActionMessage(eventSettings, amount)
	local function CleanupActionMessage(message)
		if not message then
			return message
		end
		message = string_gsub(message, "%%n", "")
		message = string_gsub(message, "%%sl", "")
		message = string_gsub(message, "%%s", "")
		message = string_gsub(message, "%%e", "")
		message = string_gsub(message, "%(%s*%-?%s*%)", "")
		message = string_gsub(message, "%[%s*%-?%s*%]", "")
		message = string_gsub(message, "%{%s*%-?%s*%}", "")
		message = string_gsub(message, "%<%s*%-?%s*%>", "")
		message = string_gsub(message, "^%s*%-%s*", "")
		message = string_gsub(message, "%s*%-%s*$", "")
		message = string_gsub(message, "%s%s+", " ")
		message = string_gsub(message, "^%s+", "")
		message = string_gsub(message, "%s+$", "")
		return message
	end

	if not eventSettings or not eventSettings.message then
		return nil
	end
	local message = string_gsub(eventSettings.message, "%s?%-?%s?%%sl?%s?%-?%s?", "")
	if amount and amount > 0 then
		message = Formatter:FormatLegacyEvent(message, amount)
		message = string_gsub(message, "<%%sl>%s*", "")
		message = string_gsub(message, "<%%s>%s*", "")
		message = string_gsub(message, "<%%e>%s*", "")
		message = string_gsub(message, "%%sl", "")
		message = string_gsub(message, "%%s", "")
		message = string_gsub(message, "%%e", "")
		return CleanupActionMessage(message)
	end

	message = string_gsub(message, "<%%a>%s*", "")
	message = string_gsub(message, "%%a", "")
	message = string_gsub(message, "<%%sl>%s*", "")
	message = string_gsub(message, "<%%s>%s*", "")
	message = string_gsub(message, "<%%e>%s*", "")
	message = string_gsub(message, "%%sl", "")
	message = string_gsub(message, "%%s", "")
	message = string_gsub(message, "%%e", "")
	return CleanupActionMessage(message)
end

local outgoingBatcher = OutgoingBatcher:New({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	formatAmount = function(amount, profile)
		return Formatter:FormatDisplayAmount(amount, profile)
	end,
	display = DisplayEvent,
	after = C_Timer.After,
	getSpellTexture = function(spellID)
		local _, _, texture = GetSpellInfo(spellID)
		return texture
	end,
	isAutoAttack = IsAutoAttackSpellID,
	autoAttackSpellID = AUTOSHOT_SPELL_ID,
	delay = OUTGOING_GROUP_DELAY,
	shouldSplitCritBatch = ShouldSplitCritBatch,
	resolveBatchDisplaySettings = ResolveBatchDisplaySettings,
})

local function IsDamageMeterUsable()
	-- WoW Forever hands addons the session data only once combat ends, so as a
	-- live source it turns a whole fight into one late burst.
	if IS_FOREVER_CLIENT then
		return false
	end
	if not USE_DAMAGE_METER_OUTGOING or not HasModernAPI then
		return false
	end
	if not C_DamageMeter or not C_DamageMeter.GetCombatSessionSourceFromType then
		return false
	end
	if not Enum or not Enum.DamageMeterType or not Enum.DamageMeterSessionType then
		return false
	end
	if C_DamageMeter.IsDamageMeterAvailable then
		local ok, isAvailable = pcall(C_DamageMeter.IsDamageMeterAvailable)
		if ok and isAvailable == false then
			return false
		end
	end
	return true
end

-- A source owns the damage stream only while it is demonstrably producing.
-- Hard-switching on "the combat log is registered" went silent whenever the
-- client accepted the registration but never delivered an event.
local SOURCE_OWNERSHIP_WINDOW = 5
local lastParserDamage = 0
local lastMeterDamage = 0

NoteParserDamage = function()
	lastParserDamage = GetTime()
end

local function NoteMeterDamage()
	lastMeterDamage = GetTime()
end

local function IsParserOwningDamage()
	return lastParserDamage > 0
		and (GetTime() - lastParserDamage) <= SOURCE_OWNERSHIP_WINDOW
end

local function IsMeterOwningDamage()
	return lastMeterDamage > 0
		and (GetTime() - lastMeterDamage) <= SOURCE_OWNERSHIP_WINDOW
end

local CRIT_MATCH_WINDOW = 1.5
local pendingCrits = {}

-- The damage meter knows which spell dealt the damage but not whether it
-- critted, while UNIT_COMBAT knows the opposite. Amounts seen as a critical
-- hit are parked here so the meter can upgrade a matching hit.
local function RecordCritAmount(amount)
	if not amount or amount <= 0 then
		return
	end

	local now = GetTime()
	for index = #pendingCrits, 1, -1 do
		if now - pendingCrits[index].time > CRIT_MATCH_WINDOW then
			table_remove(pendingCrits, index)
		end
	end

	pendingCrits[#pendingCrits + 1] = { amount = amount, time = now }
end

local function ConsumeCritAmount(amount)
	if not amount then
		return false
	end

	local now = GetTime()
	for index = 1, #pendingCrits do
		local entry = pendingCrits[index]
		if now - entry.time <= CRIT_MATCH_WINDOW and entry.amount == amount then
			table_remove(pendingCrits, index)
			return true
		end
	end

	return false
end

local function IsSecretValue(value)
	if type(issecretvalue) ~= "function" then
		return false
	end
	local ok, isSecret = pcall(issecretvalue, value)
	return ok and isSecret == true
end

local damageMeterSource = DamageMeterSource:New({
	label = "damage",
	isAvailable = IsDamageMeterUsable,
	isSecret = IsSecretValue,
	getTime = GetTime,
	unitGUID = UnitGUID,
	getPlayerGUID = function()
		return playerGUID
	end,
	extraUnits = { "pet", "vehicle" },
	createFrame = function()
		return CreateFrame("Frame")
	end,
	getSessionSource = function(sessionType, damageType, sourceGUID)
		return C_DamageMeter.GetCombatSessionSourceFromType(
			sessionType,
			damageType,
			sourceGUID
		)
	end,
	getSessionSourceByID = C_DamageMeter and C_DamageMeter.GetCombatSessionSourceFromID,
	sessionType = function()
		return Enum.DamageMeterSessionType.Current
	end,
	damageType = function()
		return Enum.DamageMeterType.DamageDone
	end,
	normalizeNumber = NormalizeNumber,
	consumeCrit = ConsumeCritAmount,
	isSuppressed = IsParserOwningDamage,
	queue = function(...)
		NoteMeterDamage()
		outgoingBatcher:Queue(...)
	end,
	newTicker = C_Timer.NewTicker,
	pollInterval = DAMAGE_METER_POLL_INTERVAL,
	freshDuration = DAMAGE_METER_FALLBACK_STALE_TIME,
})

local MAX_METER_ACTIONS_PER_POLL = 5
local CAST_DISPEL_CLAIM_WINDOW = 5
local castDispelClaims = {}

local function ClaimCastDispel()
	castDispelClaims[#castDispelClaims + 1] = GetTime()
end

local function ConsumeCastDispelClaim()
	local claims = castDispelClaims
	local now = GetTime()
	while claims[1] and now - claims[1] > CAST_DISPEL_CLAIM_WINDOW do
		table.remove(claims, 1)
	end
	if not claims[1] then
		return false
	end
	table.remove(claims, 1)
	return true
end

local function GetMeterSpellName(spellID)
	local name = GetSpellInfo(spellID)
	if type(name) == "string" and not IsSecretValue(name) then
		return name
	end
end

local function GetMeterTargetName(meterSpell)
	local details = type(meterSpell) == "table" and meterSpell.combatSpellDetails
	local unitName = type(details) == "table" and details.unitName
	if type(unitName) == "string" and not IsSecretValue(unitName) and unitName ~= "" then
		return unitName
	end
end

local function CreateActionMeterSource(meterType, eventType)
	return DamageMeterSource:New({
		label = meterType,
		isAvailable = function()
			return IsDamageMeterUsable() and Enum.DamageMeterType[meterType] ~= nil
		end,
		isSecret = IsSecretValue,
		getTime = GetTime,
		unitGUID = UnitGUID,
		getPlayerGUID = function()
			return playerGUID
		end,
		extraUnits = { "pet" },
		createFrame = function()
			return CreateFrame("Frame")
		end,
		getSessionSource = function(sessionType, damageType, sourceGUID)
			return C_DamageMeter.GetCombatSessionSourceFromType(
				sessionType,
				damageType,
				sourceGUID
			)
		end,
		getSessionSourceByID = C_DamageMeter and C_DamageMeter.GetCombatSessionSourceFromID,
		sessionType = function()
			return Enum.DamageMeterSessionType.Current
		end,
		damageType = function()
			return Enum.DamageMeterType[meterType]
		end,
		normalizeNumber = NormalizeNumber,
		primeBaseline = true,
		isSuppressed = function()
			return MSBTParser.IsCombatLogActive and MSBTParser.IsCombatLogActive()
		end,
		queue = function(spellID, count, _, sourceKey, meterSpell)
			local spellName = GetMeterSpellName(spellID)
			local targetName = GetMeterTargetName(meterSpell)
			local sourceUnit = sourceKey == "1" and "player" or "pet"
			for _ = 1, math.min(count, MAX_METER_ACTIONS_PER_POLL) do
				if eventType == "dispel" and sourceUnit == "player" and ConsumeCastDispelClaim() then
					Trace:Inc("dispel:meterskip")
				else
				ParserEventsHandler({
					eventType = eventType,
					sourceUnit = sourceUnit,
					recipientName = targetName,
					extraSkillID = spellID,
					extraSkillName = spellName,
				})
				end
			end
		end,
		newTicker = C_Timer.NewTicker,
		pollInterval = DAMAGE_METER_POLL_INTERVAL,
		freshDuration = DAMAGE_METER_FALLBACK_STALE_TIME,
	})
end

dispelMeterSource = CreateActionMeterSource("Dispels", "dispel")
interruptMeterSource = CreateActionMeterSource("Interrupts", "interrupt")

local combatLogMessageSource = CombatLogMessageSource:New({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	getTime = GetTime,
	ownershipWindow = 8,
	liveWindow = 600,
	expectWindow = 2.5,
	missLimit = 2,
	warnFilter = function(filterName)
		MikSBT.Print(string.format(L.MSG_CLM_FILTER, tostring(filterName),
			tostring(QUICKBUTTON_NAME_MY_ACTIONS)), 1, 0.82, 0)
	end,
	display = function(message, scrollArea, colorR, colorG, colorB)
		MSBTAnimations.DisplayMessage(message, scrollArea, false, colorR, colorG, colorB)
	end,
})
combatLogMessageSource.filterButton = MikSBT.Components.CombatLogFilterButton:New({
	label = function()
		return string.format(L.BUTTON_CLM_FILTER, tostring(QUICKBUTTON_NAME_MY_ACTIONS))
	end,
	isWanted = function()
		return combatLogMessageSource:IsEnabled() and combatLogMessageSource:GetFilterState() == false
	end,
})

local ClassifyCombatUnit, GetOverheal, GetDefaultHealTarget, GetAoeHeals
do
	local AOE_HEAL_SPELLS = {
		[596] = true, -- Prayer of Healing
		[1064] = true, -- Chain Heal
		[15237] = true, -- Holy Nova
		[740] = true, -- Tranquility
		[34861] = true, -- Circle of Healing
	}
	local aoeHealsByName
	local sawNameplateCombat = false
	local healthCache = {}
	local HEALTH_UNIT_PAIRS = {
		{ "player", "target" },
		{ "party1", "party2" },
		{ "party3", "party4" },
	}

	GetAoeHeals = function()
		if aoeHealsByName then
			return aoeHealsByName
		end
		local byName, complete = BuildSpellNameMap(AOE_HEAL_SPELLS)
		if complete then
			aoeHealsByName = byName
		end
		return byName
	end

	local function PlainNumber(value)
		if value == nil or (issecretvalue and issecretvalue(value)) then
			return nil
		end
		return NormalizeNumber(value)
	end

	local function OnHealthEvent(_, _, unitID)
		local health = PlainNumber(UnitHealth(unitID))
		if not health then
			healthCache[unitID] = nil
			return
		end
		local record = healthCache[unitID]
		if not record then
			record = {}
			healthCache[unitID] = record
		end
		record.prev = record.cur or health
		record.cur = health
		record.time = GetTime()
	end

	for _, units in ipairs(HEALTH_UNIT_PAIRS) do
		local frame = CreateFrame("Frame")
		frame:SetScript("OnEvent", OnHealthEvent)
		frame:RegisterUnitEvent("UNIT_HEALTH", units[1], units[2])
	end

	GetOverheal = function(unitID, amount)
		local health = PlainNumber(UnitHealth(unitID))
		local maxHealth = PlainNumber(UnitHealthMax(unitID))
		if not health or not maxHealth or maxHealth <= 0 then
			return nil
		end
		local before = health
		local record = healthCache[unitID]
		if record and record.time == GetTime() and record.cur == health then
			before = record.prev
		end
		local effective = math.max(0, math.min(amount, maxHealth - before))
		local overheal = amount - effective
		if overheal > 0 then
			return overheal
		end
	end

	GetDefaultHealTarget = function()
		if SafeUnitBoolean(UnitExists, "target") and SafeUnitBoolean(UnitCanAssist, "player", "target") then
			local name = UnitName("target")
			if IsPlainValue(name) then
				return name
			end
		end
		local name = UnitName("player")
		if IsPlainValue(name) then
			return name
		end
	end

	local function HasNameplate(unitID)
		if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then
			return false
		end
		local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unitID)
		return ok and plate ~= nil
	end

	ClassifyCombatUnit = function(unitID)
		if type(unitID) ~= "string" then
			return nil
		end
		if string_find(unitID, "^nameplate%d+$") then
			if SafeUnitBoolean(UnitCanAttack, "player", unitID) then
				sawNameplateCombat = true
				return "hostile"
			end
			return nil
		end
		if unitID == "target" then
			if SafeUnitBoolean(UnitIsUnit, "target", "player") then
				return nil
			end
			if SafeUnitBoolean(UnitCanAttack, "player", "target") then
				if sawNameplateCombat and HasNameplate("target") then
					return nil
				end
				return "hostile"
			end
			if SafeUnitBoolean(UnitCanAssist, "player", "target") then
				if (IsInGroup() or IsInRaid())
					and (SafeUnitBoolean(UnitInParty, "target") or SafeUnitBoolean(UnitInRaid, "target")) then
					return nil
				end
				return "friendly"
			end
			return nil
		end
		if string_find(unitID, "^raid%d+$") then
			return "friendly"
		end
		if string_find(unitID, "^party%d$") and not IsInRaid() then
			return "friendly"
		end
		return nil
	end
end

outgoingCombat = OutgoingCombat:New({
	batcher = outgoingBatcher,
	emit = function(parserEvent)
		ParserEventsHandler(parserEvent)
	end,
	classifyUnit = ClassifyCombatUnit,
	isCombatLogOwning = function()
		return combatLogMessageSource:IsOwning()
	end,
	isHostileUnit = function(unitID)
		return SafeUnitBoolean(UnitCanAttack, "player", unitID)
	end,
	unitName = function(unitID)
		local name = UnitName(unitID)
		return name
	end,
	defaultHealTarget = GetDefaultHealTarget,
	ownedSpellWindow = 5,
	aoeHeals = GetAoeHeals,
	getOverheal = GetOverheal,
	damageMeter = damageMeterSource,
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	normalizeNumber = NormalizeNumber,
	buildActionMessage = BuildActionMessage,
	display = DisplayEvent,
	getTime = GetTime,
	inCombat = InCombatLockdown,
	isTargetValid = IsOutgoingTargetContextValid,
	isInGroup = function()
		return IsInGroup() or IsInRaid()
	end,
	isMeterOwning = IsMeterOwningDamage,
	recordCrit = RecordCritAmount,
	getSpellTexture = function(spellID)
		local _, _, texture = GetSpellInfo(spellID)
		return texture
	end,
	isAutoAttack = IsAutoAttackSpellID,
	canUseAutoAttackFallback = CanUseAutoAttackFallback,
	hasPlayerDebuff = HasPlayerAnyDebuffOnTarget,
	isLikelySpellSchool = IsLikelySpellSchool,
	autoAttackSpellID = AUTOSHOT_SPELL_ID,
	fallbackAttributionWindow = OUTGOING_FALLBACK_ATTRIBUTION_WINDOW,
	delayedAttributionWindow = OUTGOING_DELAYED_SPELL_ATTRIBUTION_WINDOW,
	signalWindow = OUTGOING_SIGNAL_CONFIDENCE_WINDOW,
	dotDuration = DOT_FALLBACK_DURATION,
	dotSpells = DOT_FALLBACK_SPELLS,
	repeatShotSpells = REPEAT_SHOT_SPELLS,
	shotHitWindow = 1.5,
	namedDots = GetNamedDots,
	isChanneling = function()
		return select("#", UnitChannelInfo("player")) > 0
	end,
	namedHots = GetNamedHots,
	healDirectWindow = 2,
	isHelpfulSpell = function(spellID)
		if C_Spell and C_Spell.IsSpellHelpful then
			local ok, isHelpful = pcall(C_Spell.IsSpellHelpful, spellID)
			return ok and isHelpful == true
		end
		return false
	end,
	getSpellName = function(spellID)
		local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID)
		if type(name) == "string" and not IsSecretValue(name) then
			return name
		end
	end,
	timedDotSpells = DOT_FALLBACK_TIMED_SPELLS,
})
incomingCombat = IncomingCombat:New({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	normalizeNumber = NormalizeNumber,
	buildActionMessage = BuildActionMessage,
	shouldSplitCritBatch = ShouldSplitCritBatch,
	resolveBatchDisplaySettings = ResolveBatchDisplaySettings,
	display = DisplayEvent,
	after = C_Timer.After,
	getTime = GetTime,
	unitName = UnitName,
	unitCastingInfo = UnitCastingInfo,
	unitChannelInfo = UnitChannelInfo,
	safeUnitBoolean = SafeUnitBoolean,
	getSpellInfo = GetSpellInfo,
	isAutoAttackSpellID = IsAutoAttackSpellID,
	unknown = UNKNOWN,
	groupDelay = INCOMING_GROUP_DELAY,
	selfHealIconWindow = INCOMING_SELF_HEAL_ICON_ATTRIBUTION_WINDOW,
	getSpellName = function(spellID)
		return (GetSpellInfo(spellID))
	end,
	getLastPlayerSpell = function()
		return outgoingCombat:GetLastSpell()
	end,
	getHealSpell = function(now, window)
		return outgoingCombat:GetHealSpell(now, window)
	end,
	emit = function(parserEvent)
		ParserEventsHandler(parserEvent)
	end,
	getOverheal = function(unitID, amount)
		return GetOverheal(unitID, amount)
	end,
})

local combatTextSource = CombatTextSource:New({
	emit = function(parserEvent)
		ParserEventsHandler(parserEvent)
	end,
})

local EnableActionCastSource, DisableActionCastSource
do
	local dispelSpellNames, interruptSpellNames
	local castTargets = {}
	local pendingInterrupt

	local function BuildNameSet(spellTable)
		local names = {}
		for spellID in pairs(spellTable) do
			local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID)
			if type(name) == "string" and name ~= "" then
				names[name] = true
			end
		end
		return names
	end

	local function GetPlainSpellName(spellID)
		if spellID == nil or IsSecretValue(spellID) then
			return nil
		end
		local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID)
		if type(name) == "string" and not IsSecretValue(name) then
			return name
		end
	end

	local MAX_SCANNED_AURAS = 40
	local dispelSnapshots = {}

	local function IsPlainString(value)
		return not IsSecretValue(value) and type(value) == "string" and value ~= ""
	end

	local function UnitMatchesName(unitID, targetName)
		local name, surname = UnitName(unitID)
		if not IsPlainString(name) then
			return false
		end
		if name == targetName then
			return true
		end
		return IsPlainString(surname) and (name .. " " .. surname == targetName
			or name .. "-" .. surname == targetName)
	end

	local function FindUnitByName(targetName)
		local candidates = { "target", "player", "focus", "mouseover", "pet" }
		if IsInRaid() then
			for index = 1, 40 do
				candidates[#candidates + 1] = "raid" .. index
			end
		else
			for index = 1, 4 do
				candidates[#candidates + 1] = "party" .. index
			end
		end
		for _, unitID in ipairs(candidates) do
			if SafeUnitBoolean(UnitExists, unitID) and UnitMatchesName(unitID, targetName) then
				return unitID
			end
		end
	end

	-- The aura name may be secret in combat: it is kept for display only. The
	-- instance id stays readable, and it is all the before/after diff needs.
	local function DescribeAura(aura)
		local info = {}
		if IsSecretValue(aura) or type(aura) ~= "table" then
			return info
		end
		local name, spellID = aura.name, aura.spellId
		if IsSecretValue(name) or IsPlainString(name) then
			info.name = name
			info.hasName = true
		end
		if not IsSecretValue(spellID) then
			info.spellID = spellID
		end
		return info
	end

	local function CollectAuraList(auras, list)
		for _, aura in ipairs(list) do
			if IsSecretValue(aura) or type(aura) ~= "table" then
				return "entry hidden"
			end
			local instanceID = aura.auraInstanceID
			if IsSecretValue(instanceID) then
				return "id secret"
			end
			if type(instanceID) ~= "number" then
				return "id " .. type(instanceID)
			end
			auras[instanceID] = DescribeAura(aura)
		end
	end

	local function ScanByInstanceIDs(unitID, filter, auras)
		if type(C_UnitAuras.GetUnitAuraInstanceIDs) ~= "function"
			or type(C_UnitAuras.GetAuraDataByAuraInstanceID) ~= "function" then
			return "no api"
		end
		local ok, instanceIDs = pcall(C_UnitAuras.GetUnitAuraInstanceIDs, unitID, filter)
		if not ok then
			return "error " .. tostring(instanceIDs)
		end
		if IsSecretValue(instanceIDs) or type(instanceIDs) ~= "table" then
			return "result hidden"
		end
		for _, instanceID in ipairs(instanceIDs) do
			if IsSecretValue(instanceID) then
				return "id secret"
			end
			local okAura, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unitID, instanceID)
			if okAura then
				auras[instanceID] = DescribeAura(aura)
			else
				auras[instanceID] = {}
			end
		end
	end

	local function ScanByList(unitID, filter, auras)
		if type(C_UnitAuras.GetUnitAuras) ~= "function" then
			return "no api"
		end
		local ok, list = pcall(C_UnitAuras.GetUnitAuras, unitID, filter, MAX_SCANNED_AURAS)
		if not ok then
			return "error " .. tostring(list)
		end
		if IsSecretValue(list) or type(list) ~= "table" then
			return "result hidden"
		end
		return CollectAuraList(auras, list)
	end

	local function ScanByIndex(unitID, filter, auras)
		if type(C_UnitAuras.GetAuraDataByIndex) ~= "function" then
			return "no api"
		end
		local list = {}
		for index = 1, MAX_SCANNED_AURAS do
			local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unitID, index, filter)
			if not ok then
				return "error " .. tostring(aura)
			end
			if IsSecretValue(aura) then
				return "entry hidden"
			end
			if type(aura) ~= "table" then
				break
			end
			list[#list + 1] = aura
		end
		return CollectAuraList(auras, list)
	end

	local AURA_SCANNERS = {
		{ name = "ids", scan = ScanByInstanceIDs },
		{ name = "list", scan = ScanByList },
		{ name = "index", scan = ScanByIndex },
	}

	-- Returns auraInstanceID -> { name, spellID } for the auras a dispel on this
	-- unit can remove, or nil when the client does not expose them.
	local function ScanUnitAuras(unitID, filter, auras, traceKey)
		if not C_UnitAuras then
			return nil
		end
		local failures = {}
		for _, scanner in ipairs(AURA_SCANNERS) do
			local failure = scanner.scan(unitID, filter, auras)
			if not failure then
				Trace:Inc(traceKey .. " " .. scanner.name)
				return auras
			end
			failures[#failures + 1] = scanner.name .. ": " .. failure
		end
		Trace:Error(traceKey, unitID .. " " .. filter .. " - " .. table.concat(failures, "; "))
		return nil
	end

	local function ScanDispellableAuras(unitID)
		local filter = SafeUnitBoolean(UnitCanAttack, "player", unitID) and "HELPFUL" or "HARMFUL"
		return ScanUnitAuras(unitID, filter, {}, "dispel:scan")
	end

	local function SnapshotDispelTarget(castGUID, targetName)
		local unitID = IsPlainString(targetName) and FindUnitByName(targetName) or "target"
		if not SafeUnitBoolean(UnitExists, unitID) then
			Trace:Inc("dispel:nounit")
			return
		end
		Trace:Inc("dispel:snap " .. unitID)
		local auras = ScanDispellableAuras(unitID)
		if not auras then
			Trace:Inc("dispel:noscan")
		end
		dispelSnapshots[castGUID] = { unitID = unitID, auras = auras, time = GetTime() }
	end

	local PENDING_DISPEL_WINDOW = 1.2
	local auraCache = {}
	local pendingAuraDispels = {}

	local function IsCachedUnit(unitID)
		return unitID == "target" or unitID == "mouseover" or unitID == "focus"
			or unitID == "player" or unitID == "pet"
			or string.find(unitID, "^party%d$") ~= nil or string.find(unitID, "^raid%d+$") ~= nil
	end

	local function GetUnitKey(unitID)
		local guid = UnitGUID(unitID)
		if IsPlainString(guid) then
			return guid
		end
		return unitID
	end

	local function AreAurasHidden()
		if C_Secrets and type(C_Secrets.ShouldAurasBeSecret) == "function" then
			local ok, hidden = pcall(C_Secrets.ShouldAurasBeSecret)
			if ok and not IsSecretValue(hidden) then
				return hidden == true
			end
		end
		return InCombatLockdown()
	end

	local function HandleUnitAura(unitID, updateInfo)
		if not IsPlainString(unitID) or not IsCachedUnit(unitID) then
			return
		end
		if updateInfo == nil then
			Trace:Inc("aura:noinfo")
			return
		end
		if IsSecretValue(updateInfo) or type(updateInfo) ~= "table" then
			Trace:Inc("aura:info secret")
			return
		end
		if IsSecretValue(updateInfo.isFullUpdate) or IsSecretValue(updateInfo.addedAuras)
			or IsSecretValue(updateInfo.removedAuraInstanceIDs) then
			Trace:Inc("aura:info secret")
			return
		end
		local key = GetUnitKey(unitID)
		if updateInfo.isFullUpdate then
			Trace:Inc("aura:full")
			local cache = {}
			if ScanUnitAuras(unitID, "HARMFUL", cache, "aura:fullscan")
				and ScanUnitAuras(unitID, "HELPFUL", cache, "aura:fullscan") then
				auraCache[key] = cache
			else
				auraCache[key] = nil
			end
			return
		end
		local cache = auraCache[key]
		if not cache then
			cache = {}
			auraCache[key] = cache
		end
		local added = updateInfo.addedAuras
		if type(added) == "table" and not IsSecretValue(added) then
			for _, aura in ipairs(added) do
				local info = DescribeAura(aura)
				local instanceID = not IsSecretValue(aura) and type(aura) == "table" and aura.auraInstanceID or nil
				if instanceID == nil then
					Trace:Inc("aura:add noid")
				elseif IsSecretValue(instanceID) then
					Trace:Inc("aura:add id secret")
				else
					cache[instanceID] = info
					if not info.hasName then
						Trace:Inc("aura:add noname")
					elseif IsSecretValue(info.name) then
						Trace:Inc("aura:add name secret")
					else
						Trace:Inc("aura:add name plain")
					end
				end
			end
		elseif added ~= nil then
			Trace:Inc("aura:added secret")
		end
		local removed = updateInfo.removedAuraInstanceIDs
		if type(removed) == "table" and not IsSecretValue(removed) then
			for _, instanceID in ipairs(removed) do
				if IsSecretValue(instanceID) then
					Trace:Inc("aura:rm id secret")
				else
					local info = cache[instanceID]
					cache[instanceID] = nil
					local pending = pendingAuraDispels[key]
					if pending and GetTime() - pending.time <= PENDING_DISPEL_WINDOW then
						pending.matched = (pending.matched or 0) + 1
						Trace:Inc(info and "aura:rm dispel hit" or "aura:rm dispel nocache")
						local effectName = pending.spellName
						if info and info.hasName then
							effectName = info.name
						end
						pending.emit((info and info.spellID) or pending.spellID, effectName)
					else
						Trace:Inc(info and "aura:rm cached" or "aura:rm unknown")
					end
				end
			end
		elseif removed ~= nil then
			Trace:Inc("aura:removed secret")
		end
	end

	local auraCacheFrame = CreateFrame("Frame")
	auraCacheFrame:SetScript("OnEvent", function(_, _, unitID, updateInfo)
		HandleUnitAura(unitID, updateInfo)
	end)

	local function TakeDispelSnapshot(castGUID)
		if castGUID == nil or IsSecretValue(castGUID) then
			return nil
		end
		local snapshot = dispelSnapshots[castGUID]
		dispelSnapshots[castGUID] = nil
		return snapshot
	end

	local function IsCastSourceOpen()
		return not (MSBTParser.IsCombatLogActive and MSBTParser.IsCombatLogActive())
			and not combatLogMessageSource:IsOwning()
	end

	local function IsCastActionSourceActive()
		return IsCastSourceOpen() and not dispelMeterSource:IsActive()
	end

	local function IsDispelCastActive(unitID)
		return IsCastSourceOpen() and (unitID == "player" or not dispelMeterSource:IsActive())
	end

	local function HandleActionCast(unitID, castGUID, spellID)
		if unitID ~= "player" and unitID ~= "pet" then
			return
		end
		local spellName = GetPlainSpellName(spellID)
		if not spellName then
			Trace:Inc("cast:noname")
			return
		end

		dispelSpellNames = dispelSpellNames or BuildNameSet(DISPEL_SPELLS)
		interruptSpellNames = interruptSpellNames or BuildNameSet(INTERRUPT_SPELLS)

		local isDispel = dispelSpellNames[spellName] == true
		if isDispel then
			Trace:Inc("dispel:cast " .. unitID)
			if castGUID == nil or IsSecretValue(castGUID) then
				Trace:Inc("dispel:cast guid " .. (castGUID == nil and "nil" or "secret"))
			end
			if not IsDispelCastActive(unitID) then
				Trace:Inc("dispel:cast gated")
				return
			end
		elseif not IsCastActionSourceActive() then
			return
		end

		local targetName
		if castGUID and not IsSecretValue(castGUID) then
			targetName = castTargets[castGUID]
			castTargets[castGUID] = nil
		end

		if isDispel then
			if unitID == "player" then
				ClaimCastDispel()
			end
			local function Emit(effectID, effectName)
				ParserEventsHandler({
					eventType = "dispel",
					sourceUnit = unitID,
					recipientName = targetName,
					extraSkillID = effectID,
					extraSkillName = effectName,
				})
			end

			local snapshot = TakeDispelSnapshot(castGUID)
			local targetUnit = snapshot and snapshot.unitID
				or (IsPlainString(targetName) and FindUnitByName(targetName)) or "target"
			if not SafeUnitBoolean(UnitExists, targetUnit) then
				Trace:Inc("dispel:nosnapshot")
				Emit(spellID, "")
				return
			end

			if not (snapshot and snapshot.auras) and AreAurasHidden() then
				Trace:Inc("dispel:blind")
				Emit(spellID, "")
				return
			end

			Trace:Inc("dispel:pending")
			local key = GetUnitKey(targetUnit)
			local pending = { time = GetTime(), spellID = spellID, spellName = spellName, emit = Emit }
			pendingAuraDispels[key] = pending
			C_Timer.After(PENDING_DISPEL_WINDOW, function()
				if pendingAuraDispels[key] == pending then
					pendingAuraDispels[key] = nil
				end
				if pending.matched then
					Trace:Inc("dispel:aura")
					return
				end
				if snapshot and snapshot.auras then
					local current = ScanDispellableAuras(snapshot.unitID)
					if current then
						local removed = 0
						for instanceID, aura in pairs(snapshot.auras) do
							if not current[instanceID] then
								removed = removed + 1
								local effectName = spellName
								if aura.hasName then
									effectName = aura.name
								end
								Emit(aura.spellID or spellID, effectName)
							end
						end
						Trace:Inc(removed > 0 and "dispel:snapshot diff" or "dispel:nothing")
						return
					end
					Trace:Inc("dispel:norescan")
				end
				Trace:Inc("dispel:pending miss")
				Emit(spellID, "")
			end)
		elseif interruptSpellNames[spellName] then
			pendingInterrupt = {
				time = GetTime(),
				sourceUnit = unitID,
				spellID = spellID,
				spellName = spellName,
			}
		end
	end

	local actionCastFrame = CreateFrame("Frame")
	actionCastFrame:SetScript("OnEvent", function(_, event, unitID, arg1, arg2, arg3, arg4)
		if event == "UNIT_SPELLCAST_SENT" then
			local targetName, castGUID, spellID = arg1, arg2, arg3
			if castGUID == nil or IsSecretValue(castGUID) then
				Trace:Inc("sent:guid " .. (castGUID == nil and "nil" or "secret"))
				return
			end
			Trace:Inc("sent:target " .. (IsPlainString(targetName) and "plain" or (IsSecretValue(targetName) and "secret" or "none")))
			outgoingCombat:HandleSpellcastSent(unitID, targetName, castGUID)
			if IsPlainString(targetName) then
				castTargets[castGUID] = targetName
			end
			local spellName = GetPlainSpellName(spellID)
			dispelSpellNames = dispelSpellNames or BuildNameSet(DISPEL_SPELLS)
			if spellName and dispelSpellNames[spellName] then
				if IsDispelCastActive(unitID) then
					SnapshotDispelTarget(castGUID, targetName)
				else
					Trace:Inc("dispel:sent gated")
				end
			elseif not spellName then
				Trace:Inc("sent:noname")
			end
			return
		end

		if event == "UNIT_SPELLCAST_SUCCEEDED" then
			HandleActionCast(unitID, arg1, arg2)
			return
		end

		-- UNIT_SPELLCAST_INTERRUPTED on the target/focus: castGUID, spellID, interruptedBy
		local interruptedSpellID, interruptedBy = arg2, arg3
		local source = pendingInterrupt
		if not source or not IsCastActionSourceActive() then
			return
		end

		local byPlayer
		if interruptedBy ~= nil and not IsSecretValue(interruptedBy) then
			byPlayer = interruptedBy == UnitGUID(source.sourceUnit)
		else
			byPlayer = GetTime() - source.time <= INTERRUPT_MATCH_WINDOW
		end
		if not byPlayer then
			return
		end
		pendingInterrupt = nil

		local recipientName = UnitName(unitID)
		if recipientName ~= nil and IsSecretValue(recipientName) then
			recipientName = nil
		end
		ParserEventsHandler({
			eventType = "interrupt",
			sourceUnit = source.sourceUnit,
			recipientName = recipientName,
			extraSkillID = interruptedSpellID ~= nil and not IsSecretValue(interruptedSpellID)
				and interruptedSpellID or source.spellID,
			extraSkillName = GetPlainSpellName(interruptedSpellID) or source.spellName,
		})
	end)

	EnableActionCastSource = function()
		actionCastFrame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player", "pet")
		actionCastFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
		actionCastFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target", "focus")
		pcall(auraCacheFrame.RegisterEvent, auraCacheFrame, "UNIT_AURA")
	end

	DisableActionCastSource = function()
		actionCastFrame:UnregisterAllEvents()
		auraCacheFrame:UnregisterAllEvents()
		for key in pairs(auraCache) do
			auraCache[key] = nil
		end
		pendingInterrupt = nil
		for castGUID in pairs(castTargets) do
			castTargets[castGUID] = nil
		end
	end
end

function eventFrame:UNIT_SPELLCAST_SUCCEEDED(unitID, lineID, spellID)
	if not outgoingCombat:HandleSpellcastSucceeded(unitID, spellID, lineID) then
		return
	end
	if combatLogMessageSource:IsLive() and not combatLogMessageSource:IsRawMode()
		and outgoingCombat:IsDirectDamageCast(spellID)
		and SafeUnitBoolean(UnitCanAttack, "player", "target") then
		combatLogMessageSource:ExpectOwnLine(GetTime())
	end
end

local QueueOwnershipCheck, NotePlayerCombatEvent, QueuePlayerHeal
do
	local pendingFrames = {}
	local resolveScheduled = false

	local function GetFrame(now)
		local frame = pendingFrames[now]
		if not frame then
			frame = { time = now, playerHeals = 0, playerHealEvents = {}, events = {} }
			pendingFrames[now] = frame
		end
		return frame
	end

	local function EventKey(event)
		if IsSecretValue(event.action) or IsSecretValue(event.amount)
			or IsSecretValue(event.school) or IsSecretValue(event.flag) then
			return nil
		end
		return tostring(event.action) .. "|" .. tostring(event.amount) .. "|"
			.. tostring(event.school) .. "|" .. tostring(event.flag)
	end

	local function SelectCandidates(frame)
		local hasNameplate, hasOpaqueNameplate = false, false
		local nameplateKeys = {}
		for _, event in ipairs(frame.events) do
			if string_find(event.unit, "^nameplate%d+$") then
				hasNameplate = true
				local eventKey = EventKey(event)
				if eventKey then
					nameplateKeys[eventKey] = true
				else
					hasOpaqueNameplate = true
				end
			end
		end
		local candidates, seenTarget = {}, {}
		for _, event in ipairs(frame.events) do
			local unit = event.unit
			local kind
			if string_find(unit, "^nameplate%d+$") then
				kind = SafeUnitBoolean(UnitCanAttack, "player", unit) and "hostile" or nil
			elseif unit == "target" then
				local eventKey = EventKey(event)
				local mirrored = hasNameplate
					and (hasOpaqueNameplate or not eventKey or nameplateKeys[eventKey])
				if not mirrored and SafeUnitBoolean(UnitCanAttack, "player", "target") then
					kind = "hostile"
				else
					kind = ClassifyCombatUnit(unit)
					if kind == "hostile" then
						kind = nil
					end
				end
			elseif string_find(unit, "^party%d$") or string_find(unit, "^raid%d+$") then
				kind = ClassifyCombatUnit(unit)
			end
			if kind then
				local eventKey = EventKey(event)
				local key = eventKey and (unit .. "|" .. eventKey)
				if not key or not seenTarget[key] then
					if key then
						seenTarget[key] = true
					end
					event.kind = kind
					candidates[#candidates + 1] = event
				end
			end
		end
		return candidates
	end

	local SPELL_LOOKBACK = 0.12
	local SWING_LOOKBACK = 1.2

	local function CandidatePriority(event, frameTime)
		if event.kind == "friendly" and event.action == "HEAL" then
			return outgoingCombat:GetPendingHealCast(event.unit, frameTime) and 0 or 3
		end
		if event.kind == "hostile" and SafeUnitBoolean(UnitIsUnit, event.unit, "target") then
			return 1
		end
		return 2
	end

	local function OrderCandidates(candidates, frameTime)
		for index, event in ipairs(candidates) do
			event.order = index
			event.priority = CandidatePriority(event, frameTime)
		end
		table.sort(candidates, function(left, right)
			if left.priority ~= right.priority then
				return left.priority < right.priority
			end
			return left.order < right.order
		end)
	end

	local function ResolveFrame(frame)
		combatLogMessageSource:CheckExpectedCasts(GetTime())
		for _ = 1, frame.playerHeals do
			if not combatLogMessageSource:TakeMessage(frame.time, nil, "other") then
				combatLogMessageSource:TakeMessage(frame.time)
			end
		end
		for _, heal in ipairs(frame.playerHealEvents) do
			local isSelf = false
			if not combatLogMessageSource:TakeMessage(frame.time, nil, "other") then
				isSelf = combatLogMessageSource:TakeMessage(frame.time, nil, "mine")
			end
			Trace:Inc(isSelf and "heal:self" or "heal:byother")
			incomingCombat:HandleUnitCombat("player", "HEAL", heal.flag, heal.amount, heal.school, isSelf)
		end
		local candidates = SelectCandidates(frame)
		OrderCandidates(candidates, frame.time)
		for _, event in ipairs(candidates) do
			event.mine = combatLogMessageSource:TakeMessage(frame.time, nil, "mine")
		end
		for _, event in ipairs(candidates) do
			if not event.mine then
				local school = NormalizeNumber(event.school)
				local lookback = (school == nil or school == 1) and SWING_LOOKBACK or SPELL_LOOKBACK
				event.mine = combatLogMessageSource:TakeMessage(frame.time, lookback, "mine")
			end
			if event.mine then
				Trace:Inc("own:mine")
				if event.priority == 3 then
					Trace:Note("own:heal offtarget", string.format("%s, %d candidates, %d player heals",
						tostring(event.unit), #candidates, frame.playerHeals))
				end
				combatLogMessageSource:ConfirmOwnLine()
				outgoingCombat:HandleUnitCombat(event.unit, event.action, event.flag,
					event.amount, event.school, true, event.kind, frame.time)
			else
				if event.kind == "friendly" and event.action == "HEAL" then
					local castTime = outgoingCombat:GetPendingHealCast(event.unit, frame.time)
					if castTime then
						combatLogMessageSource:NoteMissedCast(castTime)
					end
				end
				if combatLogMessageSource:IsSuspect() then
					Trace:Inc("own:guess")
					outgoingCombat:HandleUnitCombat(event.unit, event.action, event.flag,
						event.amount, event.school, false, event.kind, frame.time)
				else
					Trace:Inc("own:other")
				end
			end
		end
	end

	local function ResolvePending()
		resolveScheduled = false
		local now = GetTime()
		for frameTime, frame in pairs(pendingFrames) do
			if frameTime < now then
				pendingFrames[frameTime] = nil
				ResolveFrame(frame)
			end
		end
		if next(pendingFrames) then
			resolveScheduled = true
			C_Timer.After(0, ResolvePending)
		end
	end

	local function Schedule()
		if not resolveScheduled then
			resolveScheduled = true
			C_Timer.After(0, ResolvePending)
		end
	end

	NotePlayerCombatEvent = function(action)
		if action == "HEAL" then
			local frame = GetFrame(GetTime())
			frame.playerHeals = frame.playerHeals + 1
			Schedule()
		end
	end

	QueuePlayerHeal = function(flagText, amount, schoolMask)
		local frame = GetFrame(GetTime())
		frame.playerHealEvents[#frame.playerHealEvents + 1] = {
			flag = flagText, amount = amount, school = schoolMask,
		}
		Schedule()
	end

	QueueOwnershipCheck = function(unitTarget, action, flagText, amount, schoolMask)
		local frame = GetFrame(GetTime())
		frame.events[#frame.events + 1] = {
			unit = unitTarget, action = action, flag = flagText,
			amount = amount, school = schoolMask,
		}
		Schedule()
	end
end

function eventFrame:UNIT_COMBAT(unitTarget, action, flagText, amount, schoolMask)
	Trace:Inc("unit_combat")
	-- UNIT_COMBAT carries no source or skill, so it can only ever be guessed
	-- at. Stand aside only while a source with real attribution is delivering.
	if IsParserOwningDamage() then
		if unitTarget == "player" then
			NotePlayerCombatEvent(action)
		end
		return
	end

	if unitTarget == "player" and action == "HEAL"
		and combatLogMessageSource:IsLive() and not combatLogMessageSource:IsRawMode() then
		QueuePlayerHeal(flagText, amount, schoolMask)
		return
	end
	if unitTarget == "player" then
		NotePlayerCombatEvent(action)
	end

	if incomingCombat:HandleUnitCombat(
		unitTarget,
		action,
		flagText,
		amount,
		schoolMask
	) then
		return
	end

	if combatLogMessageSource:IsLive() and not combatLogMessageSource:IsRawMode() then
		QueueOwnershipCheck(unitTarget, action, flagText, amount, schoolMask)
		return
	end

	outgoingCombat:HandleUnitCombat(
		unitTarget,
		action,
		flagText,
		amount,
		schoolMask
	)
end

local function UpdateFallbackSources()
	outgoingCombat:Start()
	dispelMeterSource:Start()
	interruptMeterSource:Start()
end

local function Enable()
	eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	eventFrame:RegisterEvent("UNIT_COMBAT")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	EnableActionCastSource()
	combatTextSource:Start()
	combatLogMessageSource:Start()
	combatLogMessageSource.filterButton:Start()
	UpdateFallbackSources()

	MSBTParser.RegisterHandler(ParserEventsHandler)
end

MSBTParser.OnCombatLogChanged = UpdateFallbackSources

local function Disable()
	eventFrame:Hide()
	eventFrame:UnregisterAllEvents()
	incomingCombat:Reset()
	outgoingCombat:Reset()
	outgoingCombat:Stop(true)
	dispelMeterSource:Stop(true)
	interruptMeterSource:Stop(true)
	DisableActionCastSource()
	combatTextSource:Stop()
	combatLogMessageSource:Stop()
	combatLogMessageSource.filterButton:Stop()

	MSBTParser.UnregisterHandler(ParserEventsHandler)
end

eventFrame:Hide()
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)


_, playerClass = UnitClass("player")
playerGUID = UnitGUID("player")

parserNotifications = ParserNotifications:New()

utilityNotifications = UtilityNotifications:New({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	display = DisplayEvent,
	format = function(...)
		return Formatter:FormatLegacyEvent(...)
	end,
	powerTypes = powerTypes,
	unitPower = UnitPower,
	unitPowerMax = UnitPowerMax,
	getPlayerClass = function()
		return playerClass
	end,
	unitName = UnitName,
	getTime = GetTime,
	unknown = UNKNOWN,
	emoteHoldTime = EMOTE_HOLD_TIME,
})

CombatRoutes:Register(eventRouter, {
	autoAttackSpellID = AUTOSHOT_SPELL_ID,
})
eventRouter:Register("honor", function(...)
	return parserNotifications:HandleHonor(...)
end)
eventRouter:Register("reputation", function(...)
	return parserNotifications:HandleReputation(...)
end)
eventRouter:Register("proficiency", function(...)
	return parserNotifications:HandleProficiency(...)
end)
eventRouter:Register("experience", function(...)
	return parserNotifications:HandleExperience(...)
end)
for powerToken, powerType in pairs(powerTypes) do
	powerTokens[powerType] = powerToken
end

CreateDamageMaps()

if string_find(GetLocale(), "en..") then
	isEnglish = true
end

Formatter:Configure({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	shortenNumber = ShortenNumber,
	formatLargeNumber = FormatLargeNumber,
	damageColorEntries = damageColorProfileEntries,
	damageTypes = damageTypeMap,
	powerTokens = powerTokens,
	isEnglish = not not isEnglish,
	unknown = UNKNOWN,
	unknownSchool = STRING_SCHOOL_UNKNOWN,
})

module.damageTypeMap				= damageTypeMap
module.damageColorProfileEntries	= damageColorProfileEntries

module.Enable						= Enable
module.ApplyCombatLogMessageOption	= function()
	combatLogMessageSource:ApplyOption()
	combatLogMessageSource.filterButton:Update()
end
module.IsCombatEventRegistered		= function()
	return eventFrame:IsEventRegistered("UNIT_COMBAT")
end
module.Disable						= Disable
module.GetSourceStatus				= function()
	return {
		combatLog = MSBTParser.IsCombatLogActive and MSBTParser.IsCombatLogActive() or false,
		parserOwning = IsParserOwningDamage(),
		meterOwning = IsMeterOwningDamage(),
		parserAge = lastParserDamage > 0 and (GetTime() - lastParserDamage) or -1,
		meterAge = lastMeterDamage > 0 and (GetTime() - lastMeterDamage) or -1,
		meterAvailable = damageMeterSource:IsAvailable(),
		meterActive = damageMeterSource:IsActive(),
		meterBlind = damageMeterSource.isBlind == true,
		dispelMeterActive = dispelMeterSource:IsActive(),
		dispelMeterBlind = dispelMeterSource.isBlind == true,
		interruptMeterActive = interruptMeterSource:IsActive(),
		interruptMeterBlind = interruptMeterSource.isBlind == true,
		clmEnabled = combatLogMessageSource:IsEnabled(),
		clmLive = combatLogMessageSource:IsLive(),
		clmSuspect = combatLogMessageSource:IsSuspect(),
		clmCoversOwn = combatLogMessageSource:CoversOwnActions(),
		clmMissedCasts = combatLogMessageSource.missedCasts,
	}
end

MikSBT.DISPLAYTYPE_INCOMING			= "Incoming"
MikSBT.DISPLAYTYPE_OUTGOING			= "Outgoing"
MikSBT.DISPLAYTYPE_NOTIFICATION		= "Notification"
MikSBT.DISPLAYTYPE_STATIC			= "Static"

MikSBT.RegisterFont					= MSBTMedia.RegisterFont
MikSBT.RegisterSound = MSBTMedia.RegisterSound
MikSBT.IterateSounds = MSBTMedia.IterateSounds
MikSBT.RegisterAnimationStyle		= MSBTAnimations.RegisterAnimationStyle
MikSBT.RegisterStickyAnimationStyle	= MSBTAnimations.RegisterStickyAnimationStyle
MikSBT.IterateFonts					= MSBTMedia.IterateFonts
MikSBT.IterateScrollAreas			= MSBTAnimations.IterateScrollAreas
MikSBT.DisplayMessage				= MSBTAnimations.DisplayMessage
MikSBT.IsModDisabled				= MSBTProfiles.IsModDisabled





