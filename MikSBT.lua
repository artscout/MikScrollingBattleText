local mod = {}
local modName = "MikSBT"
_G[modName] = mod
mod.Configuration = {}

local string_find = string.find
local string_sub = string.sub
local string_gsub = string.gsub

local function GetComboPoints()
	if UnitPower and Enum and Enum.PowerType and Enum.PowerType.ComboPoints then
		return UnitPower("player", Enum.PowerType.ComboPoints) or 0
	end
	if _G.GetComboPoints then
		return _G.GetComboPoints("player", "target") or 0
	end
	return 0
end

local function IsRestrictedContext()
	if not UnitAffectingCombat("player") then
		return false
	end

	local inInstance, instanceType = IsInInstance()
	if not inInstance then
		return false
	end

	if instanceType == "arena" or instanceType == "pvp" then
		return true
	end

	if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive() then
		return true
	end

	if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		return true
	end

	return false
end

local TOC_VERSION = string_gsub(C_AddOns.GetAddOnMetadata("MikScrollingBattleText", "Version"), "wowi:revision", 0)
mod.VERSION = tonumber(select(3, string_find(TOC_VERSION, "(%d+%.%d+)")))
mod.VERSION_STRING = "v" .. TOC_VERSION
mod.SVN_REVISION = tonumber(select(3, string_find(TOC_VERSION, "%d+%.%d+.(%d+)")))
mod.CLIENT_VERSION = tonumber((select(4, GetBuildInfo())))

mod.COMMAND = "/msbt"

local translations = {}


local function CopyTable(srcTable)

	local newTable = {}

	for key, value in pairs(srcTable) do

		if (type(value) == "table") then value = CopyTable(value) end

		newTable[key] = value
	end

	return newTable
end

local function EraseTable(t)

	for key in next, t do
		t[key] = nil
	end
end

local function SplitString(text, delimeter, splitTable)
	local start = 1
	local splitStart, splitEnd = string_find(text, delimeter, start)
	while splitStart do
		splitTable[#splitTable + 1] = string_sub(text, start, splitStart - 1)
		start = splitEnd + 1
		splitStart, splitEnd = string_find(text, delimeter, start)
	end
	splitTable[#splitTable + 1] = string_sub(text, start)
end

local function Print(msg, r, g, b)

	DEFAULT_CHAT_FRAME:AddMessage("MSBT: " .. tostring(msg), r, g, b)
end

local function ShortenNumber(number, precision)
	local formatter = ("%%.%df"):format(precision or 0)
	if type(number) ~= "number" then
		number = tonumber(number)
	end
	if not number then
		return 0
	elseif number >= 1e12 then
		return formatter:format(number / 1e12).."T"
	elseif number >= 1e9 then
		return formatter:format(number / 1e9).."G"
	elseif number >= 1e6 then
		return formatter:format(number / 1e6).."M"
	elseif number >= 1e3 then
		return formatter:format(number / 1e3).."k"
	else
		return number
	end
	return number
end

mod.translations = translations

mod.CopyTable			= CopyTable
mod.EraseTable			= EraseTable
mod.SplitString			= SplitString
mod.Print				= Print
mod.ShortenNumber		= ShortenNumber
mod.GetComboPoints		= GetComboPoints
mod.IsRestrictedContext	= IsRestrictedContext
