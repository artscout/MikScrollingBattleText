local ProfileTransfer = {}
ProfileTransfer.__index = ProfileTransfer

local PREFIX = "!MSBT:1!"
local MAX_TEXT = 65536
local MAX_DATA = 262144
local MAX_NODES = 20000
local RETIRED_SETTINGS = {
	enableBlizzardDamage = true, enableBlizzardHealing = true,
	enableBlizzardV2GroupDamage = true, enableBlizzardV2GroupHealing = true,
}
local RETIRED_EVENTS = {
	NOTIFICATION_COOLDOWN = true, NOTIFICATION_PET_COOLDOWN = true,
}
local SECTION_KEYS = {
	scrollAreas = "ScrollAreas", events = "Events", triggers = "Triggers",
	dotThrottleDuration = "SpamControl", hotThrottleDuration = "SpamControl",
	powerThrottleDuration = "SpamControl", throttleList = "SpamControl",
	mergeExclusions = "SpamControl", abilitySubstitutions = "SpamControl",
	abilitySuppressions = "SpamControl", damageThreshold = "SpamControl",
	healThreshold = "SpamControl", powerThreshold = "SpamControl",
	hideFullHoTOverheals = "SpamControl",
	qualityExclusions = "LootAlerts", alwaysShowQuestItems = "LootAlerts",
	itemsAllowed = "LootAlerts", itemExclusions = "LootAlerts",
	cooldownExclusions = "Cooldowns", ignoreCooldownThreshold = "Cooldowns",
	cooldownThreshold = "Cooldowns",
}
local COLLECTIONS = {
	ScrollAreas = "scrollAreas", Events = "events", Triggers = "triggers",
}
local LIST_TYPES = {
	throttleList = "number", abilitySubstitutions = "string",
	mergeExclusions = "boolean", abilitySuppressions = "boolean",
	qualityExclusions = "boolean", itemsAllowed = "boolean",
	itemExclusions = "boolean", cooldownExclusions = "boolean",
	ignoreCooldownThreshold = "boolean",
}
local OPTIONAL_TYPES = {
	soundsDisabled = "boolean", stickyCritsDisabled = "boolean",
	skillIconsDisabled = "boolean", classColoringDisabled = "boolean",
	skillColoringDisabled = "boolean", partialColoringDisabled = "boolean",
	damageColoringDisabled = "boolean",
}
local RECORD_TYPES = {
	name = "string", message = "string", mainEvents = "string",
	exceptions = "string", classes = "string", scrollArea = "string",
	fontName = "string", normalFontName = "string", critFontName = "string",
	animationStyle = "string", stickyAnimationStyle = "string",
	direction = "string", stickyDirection = "string", behavior = "string",
	stickyBehavior = "string", iconAlign = "string", trailer = "string",
	disabled = "boolean", alwaysSticky = "boolean", isCrit = "boolean",
	skillIconsDisabled = "boolean",
	offsetX = "number", offsetY = "number", scrollHeight = "number",
	scrollWidth = "number", animationSpeed = "number",
	textAlignIndex = "number", stickyTextAlignIndex = "number",
	colorR = "number", colorG = "number", colorB = "number",
	skillColorR = "number", skillColorG = "number", skillColorB = "number",
	fontSize = "number", fontAlpha = "number", outlineIndex = "number",
	normalFontSize = "number", normalFontAlpha = "number",
	normalOutlineIndex = "number", critFontSize = "number",
	critFontAlpha = "number", critOutlineIndex = "number",
}

local function IsFinite(value)
	return value == value and value ~= math.huge and value ~= -math.huge
end

local function IsPlainData(value, seen, budget, depth)
	budget.count = budget.count + 1
	if budget.count > MAX_NODES or depth > 12 then return false end
	local valueType = type(value)
	if valueType == "number" then return IsFinite(value) end
	if valueType == "string" then return #value <= MAX_DATA end
	if valueType == "boolean" then return true end
	if valueType ~= "table" or seen[value] then return false end
	seen[value] = true
	for key, child in pairs(value) do
		if type(key) ~= "string" and type(key) ~= "number" then return false end
		if not IsPlainData(key, seen, budget, depth + 1)
			or not IsPlainData(child, seen, budget, depth + 1) then
			return false
		end
	end
	return true
end

local function Snapshot(overrides, defaults)
	if type(overrides) ~= "table" then
		if overrides ~= nil then return overrides end
		overrides = {}
	end
	local result = {}
	for key, value in pairs(defaults or {}) do
		local override = rawget(overrides, key)
		if type(value) == "table" then
			result[key] = Snapshot(override, value)
		elseif override ~= nil then
			result[key] = override
		else
			result[key] = value
		end
	end
	for key, value in pairs(overrides) do
		if result[key] == nil then
			result[key] = type(value) == "table" and Snapshot(value) or value
		end
	end
	return result
end

local function IsValidNumber(key, value)
	if key == "soundFile" or key == "iconSkill" then
		return value > 0 and value <= 2147483647 and value == math.floor(value)
	end
	if key:match("^[cC]olor[RGB]$") or key:match("Color[RGB]$") then
		return value >= 0 and value <= 1
	end
	if key:match("OutlineIndex$") or key == "outlineIndex" then
		return value >= 1 and value <= 6 and value == math.floor(value)
	end
	if key:match("TextAlignIndex$") or key == "textAlignIndex" then
		return value >= 1 and value <= 3 and value == math.floor(value)
	end
	if key:match("FontSize$") or key == "fontSize" then
		return value > 0 and value <= 256
	end
	if key:match("FontAlpha$") or key == "fontAlpha" then
		return value >= 0 and value <= 100
	end
	if key == "animationSpeed" then return value > 0 and value <= 1000 end
	if key == "scrollHeight" or key == "scrollWidth" then
		return value > 0 and value <= 10000
	end
	return math.abs(value) <= 1000000
end

local function IsRecord(record)
	if type(record) ~= "table" then return false end
	for key, value in pairs(record) do
		if type(key) ~= "string" then return false end
		local expectedType = RECORD_TYPES[key]
		if key == "soundFile" or key == "iconSkill" then
			if type(value) ~= "string" and type(value) ~= "number"
				and value ~= false then return false end
		elseif not expectedType or (type(value) ~= expectedType
			and value ~= false) then
			return false
		end
		if type(value) == "number" and not IsValidNumber(key, value) then
			return false
		end
		if (key == "name" or key == "message" or key == "mainEvents")
			and type(value) ~= "string" then return false end
		if key:match("[cC]olor[RGB]$") and type(value) ~= "number" then
			return false
		end
	end
	return true
end

local function IsSetting(key, value, defaults)
	if LIST_TYPES[key] then
		if type(value) ~= "table" then return false end
		for _, entry in pairs(value) do
			if type(entry) ~= LIST_TYPES[key] and entry ~= false then return false end
		end
		return true
	end
	local expectedType = OPTIONAL_TYPES[key] or type(defaults[key])
	if expectedType == "nil" then return false end
	if expectedType == "table" then return IsRecord(value) end
	return type(value) == expectedType
		and (expectedType ~= "number" or IsValidNumber(key, value))
end

local function CollectMedia(value, available, result)
	for key, child in pairs(value) do
		if type(child) == "table" then
			CollectMedia(child, available, result)
		elseif type(child) == "string" then
			local mediaType
			if key == "fontName" or key == "normalFontName"
				or key == "critFontName" then mediaType = "fonts" end
			if key == "soundFile" then mediaType = "sounds" end
			if mediaType and available[mediaType] then
				result[mediaType][child] = available[mediaType][child]
			end
		end
	end
end

function ProfileTransfer:New(options)
	local transfer = setmetatable({}, self)
	transfer.masterProfile = options.masterProfile
	transfer.version = options.version
	transfer.client = options.client
	transfer.locale = options.locale
	transfer.serializer = LibStub("LibSerialize")
	transfer.deflate = LibStub("MSBTLibDeflate")
	return transfer
end

function ProfileTransfer:Export(name, profile, availableMedia)
	if type(profile) ~= "table"
		or not IsPlainData(profile, {}, { count = 0 }, 0) then
		return nil, "INVALID_DATA"
	end
	local settings = Snapshot(profile, self.masterProfile)
	for key in pairs(RETIRED_SETTINGS) do settings[key] = nil end
	if type(settings.events) == "table" then
		for key in pairs(RETIRED_EVENTS) do settings.events[key] = nil end
	end
	local sections = {
		General = {}, ScrollAreas = {}, Events = {}, Triggers = {},
		SpamControl = {}, LootAlerts = {}, Cooldowns = {},
	}
	for key, value in pairs(settings) do
		if key ~= "creationVersion" then
			local section = SECTION_KEYS[key] or "General"
			if COLLECTIONS[section] then
				sections[section] = value
			else
				sections[section][key] = value
			end
		end
	end
	local media = { fonts = {}, sounds = {} }
	CollectMedia(settings, availableMedia or {}, media)
	local payload = {
		format = 1, name = name, version = self.version,
		client = self.client, locale = self.locale,
		sections = sections, media = media,
	}
	if not self:Validate(payload) then return nil, "INVALID_DATA" end
	local serialized = self.serializer:SerializeEx({ stable = true }, payload)
	if #serialized > MAX_DATA then return nil, "TOO_LARGE" end
	local compressed = self.deflate:CompressZlib(serialized)
	local text = PREFIX .. self.deflate:EncodeForPrint(compressed)
	if #text > MAX_TEXT then return nil, "TOO_LARGE" end
	return text
end

function ProfileTransfer:Validate(payload)
	if not IsPlainData(payload, {}, { count = 0 }, 0)
		or type(payload) ~= "table" or payload.format ~= 1
		or type(payload.name) ~= "string" or type(payload.version) ~= "string"
		or type(payload.client) ~= "number" or type(payload.locale) ~= "string"
		or type(payload.sections) ~= "table" or type(payload.media) ~= "table" then
		return false
	end
	local allowed = {
		General = true, ScrollAreas = true, Events = true, Triggers = true,
		SpamControl = true, LootAlerts = true, Cooldowns = true,
	}
	for section in pairs(payload.sections) do
		if not allowed[section] then return false end
	end
	for section in pairs(allowed) do
		local settings = payload.sections[section]
		if type(settings) ~= "table" then return false end
		for key, value in pairs(settings) do
			if type(key) ~= "string" and not COLLECTIONS[section] then
				return false
			end
			if COLLECTIONS[section] then
				if type(key) ~= "string" or key == "" then return false end
				if value == false then
					if section ~= "Triggers" then return false end
				else
					if not IsRecord(value) then return false end
					if section == "ScrollAreas" and type(value.name) ~= "string" then
						return false
					end
					if section ~= "ScrollAreas" and type(value.message) ~= "string" then
						return false
					end
					if section == "Triggers" and type(value.mainEvents) ~= "string" then
						return false
					end
				end
			else
				if (SECTION_KEYS[key] or "General") ~= section
					or not IsSetting(key, value, self.masterProfile) then return false end
			end
		end
	end
	for _, mediaType in ipairs({ "fonts", "sounds" }) do
		if type(payload.media[mediaType]) ~= "table" then return false end
		for name, reference in pairs(payload.media[mediaType]) do
			if type(name) ~= "string" or name == "" then return false end
			if type(reference) ~= "string"
				and (mediaType ~= "sounds" or type(reference) ~= "number") then
				return false
			end
		end
	end
	return true
end

function ProfileTransfer:Decode(text)
	if type(text) ~= "string" then return nil, "INVALID_TEXT" end
	if #text > MAX_TEXT * 2 then return nil, "TOO_LARGE" end
	text = text:gsub("%s", "")
	if #text > MAX_TEXT then return nil, "TOO_LARGE" end
	if text:sub(1, #PREFIX) ~= PREFIX then return nil, "INVALID_TEXT" end
	local compressed = self.deflate:DecodeForPrint(text:sub(#PREFIX + 1))
	if not compressed then return nil, "INVALID_TEXT" end
	local serialized, remaining = self.deflate:DecompressZlibBounded(
		compressed, MAX_DATA)
	if remaining == -18 then return nil, "TOO_LARGE" end
	if not serialized or remaining ~= 0 then return nil, "INVALID_TEXT" end
	if #serialized > MAX_DATA then return nil, "TOO_LARGE" end
	local success, payload, extra = self.serializer:Deserialize(serialized)
	if not success or extra ~= nil or not self:Validate(payload) then
		return nil, "INVALID_DATA"
	end
	return payload
end

function ProfileTransfer:Import(text, name, profiles, savedMedia)
	if type(name) ~= "string" then return nil, "INVALID_NAME" end
	name = name:match("^%s*(.-)%s*$")
	if name == "" or #name > 64 or name:find("[%c|]") then
		return nil, "INVALID_NAME"
	end
	if profiles[name] then return nil, "PROFILE_EXISTS" end
	local payload, errorCode = self:Decode(text)
	if not payload then return nil, errorCode end
	local profile = { creationVersion = self.version }
	for section, settings in pairs(payload.sections) do
		if COLLECTIONS[section] then
			profile[COLLECTIONS[section]] = settings
		else
			for key, value in pairs(settings) do profile[key] = value end
		end
	end
	for _, mediaType in ipairs({ "fonts", "sounds" }) do
		savedMedia[mediaType] = savedMedia[mediaType] or {}
		for mediaName, reference in pairs(payload.media[mediaType]) do
			if savedMedia[mediaType][mediaName] == nil then
				savedMedia[mediaType][mediaName] = reference
			end
		end
	end
	profiles[name] = profile
	return name, {
		clientMismatch = payload.client ~= self.client,
		localeMismatch = payload.locale ~= self.locale,
	}
end

MikSBT.Configuration.ProfileTransfer = ProfileTransfer
return ProfileTransfer
