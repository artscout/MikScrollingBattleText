
local module = {}
local moduleName = "Parser"
MikSBT[moduleName] = module

local string_find = string.find
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_len = string.len
local bit_band = bit.band
local bit_bor = bit.bor
local UnitGUID = UnitGUID
local UnitName = UnitName

local Print = MikSBT.Print
local Client = MikSBT.Compatibility.Client


local IsRetail = Client.isMainline

local AFFILIATION_MINE		= 0x00000001
local AFFILIATION_PARTY		= 0x00000002
local AFFILIATION_RAID		= 0x00000004
local AFFILIATION_OUTSIDER	= 0x00000008
local REACTION_FRIENDLY		= 0x00000010
local REACTION_NEUTRAL		= 0x00000020
local REACTION_HOSTILE		= 0x00000040
local CONTROL_HUMAN			= 0x00000100
local CONTROL_SERVER		= 0x00000200
local UNITTYPE_PLAYER		= 0x00000400
local UNITTYPE_NPC			= 0x00000800
local UNITTYPE_PET			= 0x00001000
local UNITTYPE_GUARDIAN		= 0x00002000
local UNITTYPE_OBJECT		= 0x00004000
local TARGET_TARGET			= 0x00010000
local TARGET_FOCUS			= 0x00020000
local OBJECT_NONE			= 0x80000000

local GUID_NONE				= "0x0000000000000000"



local UNIT_MAP_UPDATE_DELAY = 0.2

local FLAGS_ME			= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_PLAYER)


local eventFrame
local isEnabled
local eventsRegistered

local playerName
local playerGUID

local lastUnitMapUpdate = 0





local searchMap
local searchCaptureFuncs
local rareWords = {}
local searchPatterns = {}
local captureOrders = {}

local captureTable = {}
local parserEvent = {}

local handlers = {}



local function RegisterHandler(handler)
	handlers[handler] = true
end

local function UnregisterHandler(handler)
	handlers[handler] = nil
end

local function TestFlagsAny(unitFlags, testFlags)
	if bit_band(unitFlags, testFlags) > 0 then
		return true
	end
end

local function TestFlagsAll(unitFlags, testFlags)
	if bit_band(unitFlags, testFlags) == testFlags then
		return true
	end
end

local function SendParserEvent()
	for handler in pairs(handlers) do
		local success, ret = pcall(handler, parserEvent)
		if not success then
			geterrorhandler()(ret)
		end
	end
end

local function GlobalStringCompareFunc(globalStringNameOne, globalStringNameTwo)

	local globalStringOne = _G[globalStringNameOne]
	local globalStringTwo = _G[globalStringNameTwo]

	local gsOneStripped = string_gsub(globalStringOne, "%%%d?%$?[sd]", "")
	local gsTwoStripped = string_gsub(globalStringTwo, "%%%d?%$?[sd]", "")

	if string_len(gsOneStripped) == string_len(gsTwoStripped) then

		local numCapturesOne = 0
		for _ in string_gmatch(globalStringOne, "%%%d?%$?[sd]") do
			numCapturesOne = numCapturesOne + 1
		end

		local numCapturesTwo = 0
		for _ in string_gmatch(globalStringTwo, "%%%d?%$?[sd]") do
			numCapturesTwo = numCapturesTwo + 1
		end

		return numCapturesOne < numCapturesTwo

	else

		return string_len(gsOneStripped) > string_len(gsTwoStripped)
	end
end

local function ConvertGlobalString(globalStringName)

	local globalString = _G[globalStringName]
	if globalString == nil then
		return
	end

	if searchPatterns[globalStringName] then
		return searchPatterns[globalStringName], captureOrders[globalStringName]
	end

	local captureOrder
	local numCaptures = 0

	local searchPattern = string.gsub(globalString, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")

	for captureIndex in string_gmatch(searchPattern, "%%(%d)%$[sd]") do
		if not captureOrder then
			captureOrder = {}
		end
		numCaptures = numCaptures + 1
		captureOrder[tonumber(captureIndex)] = numCaptures
	end

	searchPattern = string.gsub(searchPattern, "%%%d?%$?s", "(.+)")
	searchPattern = string.gsub(searchPattern, "%%%d?%$?d", "(%%d+)")

	searchPattern = string.gsub(searchPattern, "%$", "%%$")

	searchPatterns[globalStringName] = searchPattern
	captureOrders[globalStringName] = captureOrder

	return searchPattern, captureOrder
end

local function CaptureData(matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9)

	if matchStart then
		captureTable[1] = c1
		captureTable[2] = c2
		captureTable[3] = c3
		captureTable[4] = c4
		captureTable[5] = c5
		captureTable[6] = c6
		captureTable[7] = c7
		captureTable[8] = c8
		captureTable[9] = c9

		return matchEnd
	end

	return nil
end

local function ReorderCaptures(capOrder)
	local t, o = captureTable, capOrder

	t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9] = t[o[1] or 1], t[o[2] or 2], t[o[3] or 3], t[o[4] or 4], t[o[5] or 5], t[o[6] or 6], t[o[7] or 7], t[o[8] or 8], t[o[9] or 9]
end

local function ParseSearchMessage(event, combatMessage)
	if not searchMap[event] then
		return
	end

	if type(combatMessage) ~= "string" then
		return
	end

	for _, globalStringName in pairs(searchMap[event]) do

		local captureFunc = searchCaptureFuncs[globalStringName]
		if captureFunc then

			local canSearch = true
			if rareWords[globalStringName] then
				local okRareWord, rareWordMatch = pcall(string_find, combatMessage, rareWords[globalStringName], 1, true)
				if not okRareWord then
					canSearch = false
				elseif not rareWordMatch then
					canSearch = false
				end
			end

			if canSearch then

				local okPattern, matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9 = pcall(string_find, combatMessage, searchPatterns[globalStringName])
				if not okPattern then
					return
				end

				matchEnd = CaptureData(matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9)

				if matchEnd then

					if captureOrders[globalStringName] then
						ReorderCaptures(captureOrders[globalStringName])
					end

					for key in pairs(parserEvent) do
						parserEvent[key] = nil
					end

					parserEvent.sourceGUID = GUID_NONE
					parserEvent.sourceFlags = OBJECT_NONE
					parserEvent.recipientGUID = playerGUID
					parserEvent.recipientName = playerName
					parserEvent.recipientFlags = FLAGS_ME
					parserEvent.recipientUnit = "player"

					captureFunc(parserEvent, captureTable)

					SendParserEvent()
					return
				end
			end
		end
	end
end

local function CreateSearchMap()
	searchMap = {

		CHAT_MSG_COMBAT_HONOR_GAIN = {"COMBATLOG_HONORGAIN", "COMBATLOG_HONORAWARD"},

		CHAT_MSG_COMBAT_FACTION_CHANGE = {"FACTION_STANDING_INCREASED", "FACTION_STANDING_DECREASED"},

		CHAT_MSG_SKILL = {"SKILL_RANK_UP"},

		CHAT_MSG_COMBAT_XP_GAIN = {"COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"},

		CHAT_MSG_LOOT = {
			"LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
			"LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_SELF"
		},

		CHAT_MSG_MONEY = {"YOU_LOOT_MONEY", "LOOT_MONEY_SPLIT"},

		CHAT_MSG_CURRENCY = { "CURRENCY_GAINED", "CURRENCY_GAINED_MULTIPLE", "CURRENCY_GAINED_MULTIPLE_BONUS" },
	}

	for event, map in pairs(searchMap) do

		for i = #map, 1, -1 do
			if not _G[map[i]] then
				table.remove(map, i)
			end
		end

		table.sort(map, GlobalStringCompareFunc)
	end
end

local function CreateSearchCaptureFuncs()
	searchCaptureFuncs = {

		COMBATLOG_HONORAWARD = function(p, c) p.eventType, p.amount = "honor", c[1] end,
		COMBATLOG_HONORGAIN = function(p, c) p.eventType, p.sourceName, p.sourceRank, p.amount = "honor", c[1], c[2], c[3] end,

		COMBATLOG_XPGAIN_FIRSTPERSON = function(p, c) p.eventType, p.sourceName, p.amount = "experience", c[1], c[2] end,
		COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = function(p, c) p.eventType, p.amount = "experience", c[1] end,

		FACTION_STANDING_DECREASED = function(p, c) p.eventType, p.isLoss, p.factionName, p.amount = "reputation", true, c[1], c[2] end,
		FACTION_STANDING_INCREASED = function(p, c) p.eventType, p.factionName, p.amount = "reputation", c[1], c[2] end,
		FACTION_STANDING_DECREASED_ACCOUNT_WIDE = function(p, c) p.eventType, p.isLoss, p.factionName, p.amount = "reputation", true, c[1], c[2] end,
		FACTION_STANDING_INCREASED_ACCOUNT_WIDE = function(p, c) p.eventType, p.factionName, p.amount = "reputation", c[1], c[2] end,

		SKILL_RANK_UP = function(p, c) p.eventType, p.skillName, p.amount = "proficiency", c[1], c[2] end,

		LOOT_ITEM_SELF = function(p, c) p.eventType, p.itemLink, p.amount = "loot", c[1], c[2] end,
		LOOT_ITEM_CREATED_SELF = function(p, c) p.eventType, p.isCreate, p.itemLink, p.amount = "loot", true, c[1], c[2] end,
		LOOT_MONEY_SPLIT = function(p, c) p.eventType, p.isMoney, p.moneyString = "loot", true, c[1] end,
		CURRENCY_GAINED = function(p, c) p.eventType, p.isCurrency, p.itemLink, p.amount = "loot", true, c[1], c[2] end,
	}

	if not IsRetail then
		searchCaptureFuncs["FACTION_STANDING_DECREASED_ACCOUNT_WIDE"] = nil
		searchCaptureFuncs["FACTION_STANDING_INCREASED_ACCOUNT_WIDE"] = nil
	end

	searchCaptureFuncs["LOOT_ITEM_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_SELF"]
	searchCaptureFuncs["LOOT_ITEM_CREATED_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
	searchCaptureFuncs["LOOT_ITEM_PUSHED_SELF"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
	searchCaptureFuncs["LOOT_ITEM_PUSHED_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
	searchCaptureFuncs["YOU_LOOT_MONEY"] = searchCaptureFuncs["LOOT_MONEY_SPLIT"]
	searchCaptureFuncs["CURRENCY_GAINED_MULTIPLE"] = searchCaptureFuncs["CURRENCY_GAINED"]
	searchCaptureFuncs["CURRENCY_GAINED_MULTIPLE_BONUS"] = searchCaptureFuncs["CURRENCY_GAINED"]

	for globalStringName in pairs(searchCaptureFuncs) do
		if not _G[globalStringName] then
			Print("Unable to find global string: " .. globalStringName, 1, 0, 0)
			searchCaptureFuncs[globalStringName] = nil
		end
	end
end

local function FindRareWords()

	local wordCounts = {}

	for globalStringName in pairs(searchCaptureFuncs) do

		local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "")

		for word in string_gmatch(strippedGS, "%w+") do
			wordCounts[word] = (wordCounts[word] or 0) + 1
		end
	end

	for globalStringName in pairs(searchCaptureFuncs) do
		local leastSeen, rarestWord

		local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "")

		for word in string_gmatch(strippedGS, "%w+") do
			if not leastSeen or wordCounts[word] < leastSeen then
				leastSeen = wordCounts[word]
				rarestWord = word
			end
		end

		rareWords[globalStringName] = rarestWord
	end
end

local function ValidateRareWords()

	for globalStringName, rareWord in pairs(rareWords) do

		if not string_find(_G[globalStringName], rareWord, 1, true) then
			rareWords[globalStringName] = nil
		end
	end
end

local function ConvertGlobalStrings()

	for globalStringName in pairs(searchCaptureFuncs) do

		searchPatterns[globalStringName] = "^" .. ConvertGlobalString(globalStringName)
	end
end

local function OnEvent(this, event, arg1, arg2, ...)
	if not isEnabled then
		return
	end

	ParseSearchMessage(event, arg1)
end

local function OnUpdatePlayerGUID(this, elapsed)
	lastUnitMapUpdate = lastUnitMapUpdate + elapsed
	if lastUnitMapUpdate >= UNIT_MAP_UPDATE_DELAY then
		if not playerGUID then
			playerGUID = UnitGUID("player")
		end
		if playerGUID then
			this:Hide()
		end
		lastUnitMapUpdate = 0
	end
end

local function Enable()
	if not eventsRegistered then
		for event in pairs(searchMap) do
			eventFrame:RegisterEvent(event)
		end
		eventsRegistered = true
	end
	isEnabled = true
	eventFrame:Show()
end

local function Disable()
	isEnabled = false

	eventFrame:Hide()

end

eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdatePlayerGUID)

playerName = UnitName("player")
playerGUID = UnitGUID("player")

CreateSearchMap()
CreateSearchCaptureFuncs()


FindRareWords()
ValidateRareWords()

ConvertGlobalStrings()

module.AFFILIATION_MINE		= AFFILIATION_MINE
module.AFFILIATION_PARTY	= AFFILIATION_PARTY
module.AFFILIATION_RAID		= AFFILIATION_RAID
module.AFFILIATION_OUTSIDER	= AFFILIATION_OUTSIDER
module.REACTION_FRIENDLY	= REACTION_FRIENDLY
module.REACTION_NEUTRAL		= REACTION_NEUTRAL
module.REACTION_HOSTILE		= REACTION_HOSTILE
module.CONTROL_HUMAN		= CONTROL_HUMAN
module.CONTROL_SERVER		= CONTROL_SERVER
module.UNITTYPE_PLAYER		= UNITTYPE_PLAYER
module.UNITTYPE_NPC			= UNITTYPE_NPC
module.UNITTYPE_PET			= UNITTYPE_PET
module.UNITTYPE_GUARDIAN	= UNITTYPE_GUARDIAN
module.UNITTYPE_OBJECT		= UNITTYPE_OBJECT
module.TARGET_TARGET		= TARGET_TARGET
module.TARGET_FOCUS			= TARGET_FOCUS
module.OBJECT_NONE			= OBJECT_NONE


module.RegisterHandler				= RegisterHandler
module.UnregisterHandler			= UnregisterHandler
module.TestFlagsAny					= TestFlagsAny
module.TestFlagsAll					= TestFlagsAll
module.Enable						= Enable
module.Disable						= Disable
module.RefreshCombatLogAccess		= function() end
module.IsCombatLogActive			= function() return false end
module.IsCombatLogUsable			= function() return false end

