
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
local IncomingCombat = MikSBT.Components.IncomingCombat
local OutgoingBatcher = MikSBT.Components.OutgoingBatcher
local DamageMeterSource = MikSBT.Components.DamageMeterSource
local OutgoingCombat = MikSBT.Components.OutgoingCombat
local ParserNotifications = MikSBT.Components.ParserNotifications
local UtilityNotifications = MikSBT.Components.UtilityNotifications
local Client = MikSBT.Compatibility.Client

local string_find = string.find
local string_gsub = string.gsub
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
local USE_DAMAGE_METER_OUTGOING = true
local DOT_FALLBACK_DURATION = 18
local incomingCombat
local outgoingCombat
local parserNotifications
local utilityNotifications
local DOT_FALLBACK_SPELLS = {
	[8921] = {8921},
	[93402] = {93402},
	[106830] = {106830, 405233},
	[77758] = {77758, 405233},
}
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

local function ParserEventsHandler(parserEvent)
	local currentProfile = MSBTProfiles.currentProfile
	local eventTypeString, effectName, affectedUnitName, affectedUnitClass =
		eventRouter:Resolve(parserEvent, currentProfile)
	if not eventTypeString then
		return
	end
	if effectName and currentProfile.abilitySuppressions[effectName] then
		return
	end
	local eventSettings = currentProfile.events[eventTypeString]
	if not eventSettings or eventSettings.disabled
		or not IsScrollAreaActive(eventSettings.scrollArea) then
		return
	end
	local effectTexture
	if not currentProfile.skillIconsDisabled
		and IsScrollAreaIconShown(eventSettings.scrollArea) and effectName then
		_, _, effectTexture = GetSpellInfo(effectName)
	end
	local outputMessage = Formatter:FormatLegacyEvent(
		eventSettings.message, parserEvent.amount, nil, nil, nil, nil,
		affectedUnitName, affectedUnitClass, effectName,
		nil, nil, nil, nil, false, true
	)
	DisplayEvent(eventSettings, outputMessage, effectTexture)
end

function eventFrame:UNIT_POWER_UPDATE(unitID, powerToken)
	utilityNotifications:HandlePowerUpdate(unitID, powerToken)
end

function eventFrame:PLAYER_REGEN_ENABLED()
	incomingCombat:Reset()
	outgoingCombat:ResetCombatState()
	utilityNotifications:HandleCombatLeave()
end
function eventFrame:PLAYER_REGEN_DISABLED()
	incomingCombat:Reset()
	outgoingCombat:ResetCombatState()
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

local function SafeUnitBoolean(func, ...)
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
	local message = eventSettings.message
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

local damageMeterSource = DamageMeterSource:New({
	isAvailable = function()
		return USE_DAMAGE_METER_OUTGOING and HasModernAPI and C_DamageMeter
			and Enum and Enum.DamageMeterType
	end,
	inCombat = InCombatLockdown,
	getTime = GetTime,
	unitGUID = UnitGUID,
	getPlayerGUID = function()
		return playerGUID
	end,
	getSessionSource = function(sourceGUID, damageType)
		return C_DamageMeter.GetCombatSessionSourceFromType(
			0,
			damageType,
			sourceGUID
		)
	end,
	normalizeNumber = NormalizeNumber,
	queue = function(...)
		outgoingBatcher:Queue(...)
	end,
	newTicker = C_Timer.NewTicker,
	damageType = Enum and Enum.DamageMeterType
		and Enum.DamageMeterType.DamageDone,
	pollInterval = 0.1,
	freshDuration = DAMAGE_METER_FALLBACK_STALE_TIME,
})

outgoingCombat = OutgoingCombat:New({
	batcher = outgoingBatcher,
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
	getLastPlayerSpell = function()
		return outgoingCombat:GetLastSpell()
	end,
})

function eventFrame:UNIT_SPELLCAST_SUCCEEDED(unitID, lineID, spellID)
	outgoingCombat:HandleSpellcastSucceeded(unitID, spellID)
end

function eventFrame:UNIT_COMBAT(unitTarget, action, flagText, amount, schoolMask)
	if incomingCombat:HandleUnitCombat(
		unitTarget,
		action,
		flagText,
		amount,
		schoolMask
	) then
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

local function Enable()
	eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	eventFrame:RegisterEvent("UNIT_COMBAT")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	outgoingCombat:Start()

	MSBTParser.RegisterHandler(ParserEventsHandler)
end

local function Disable()
	eventFrame:Hide()
	eventFrame:UnregisterAllEvents()
	incomingCombat:Reset()
	outgoingCombat:Reset()
	outgoingCombat:Stop()

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
module.Disable						= Disable

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





