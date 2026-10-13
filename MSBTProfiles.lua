
local module = {}
local moduleName = "Profiles"
MikSBT[moduleName] = module

local L = MikSBT.translations

local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format

local CopyTable = MikSBT.CopyTable
local EraseTable = MikSBT.EraseTable
local GetSkillName = MikSBT.GetSkillName
local Print = MikSBT.Print
local SplitString = MikSBT.SplitString
local Client = MikSBT.Compatibility.Client

local IsClassic = Client.isClassicContent
local IsCataClassic = Client.isCataClassic

local DEFAULT_PROFILE_NAME = "Default"

local PET_SPACE = PET .. " "

local FLAG_YOU					= 0xF0000000
local TARGET_TARGET				= 0x00010000
local REACTION_HOSTILE			= 0x00000040

local SPELLID_ELUSIVE_BREW		= 126453
local SPELLID_EXECUTE			= 5308
local SPELLID_FIRST_AID			= 3273
local SPELLID_HAMMER_OF_WRATH	= 24275

local SPELLID_LAVA_SURGE		= not IsClassic and 77762
local SPELLID_REVENGE			= 6572
local SPELLID_VICTORY_RUSH		= not IsClassic and 34428

local SPELL_CLEARCASTING			= GetSkillName(16870)

local SPELL_ELUSIVE_BREW			= not IsClassic and GetSkillName(128939)
local SPELL_EXECUTE					= GetSkillName(SPELLID_EXECUTE)
local SPELL_FINGERS_OF_FROST		= not IsClassic and GetSkillName(112965)
local SPELL_FREEZING_FOG			= not IsClassic and GetSkillName(59052)
local SPELL_HAMMER_OF_WRATH			= GetSkillName(SPELLID_HAMMER_OF_WRATH)

local SPELL_KILLING_MACHINE			= not IsClassic and GetSkillName(51124)
local SPELL_LAVA_SURGE				= not IsClassic and GetSkillName(SPELLID_LAVA_SURGE)

local SPELL_MISSILE_BARRAGE			= not IsClassic and GetSkillName(62401)

local SPELL_PREDATORS_SWIFTNESS		= not IsClassic and GetSkillName(69369)
local SPELL_PVP_TRINKET				= not IsClassic and GetSkillName(42292)
local SPELL_REVENGE					= GetSkillName(SPELLID_REVENGE)
local SPELL_RIME 					= not IsClassic and GetSkillName(59057)
local SPELL_SHADOW_TRANCE			= GetSkillName(17941)
local SPELL_SHIELD_SLAM				= GetSkillName(23922)

local SPELL_SUDDEN_DEATH			= not IsClassic and GetSkillName(52437)
local SPELL_SUDDEN_DOOM				= not IsClassic and GetSkillName(81340)

local SPELL_TIDAL_WAVES				= not IsClassic and GetSkillName(53390)

local SPELL_VICTORY_RUSH			= not IsClassic and GetSkillName(SPELLID_VICTORY_RUSH)

local SPELL_DRAIN_LIFE				= not IsClassic and GetSkillName(234153)
local SPELL_SHADOWMEND				= not IsClassic and GetSkillName(39373)

local SPELL_UNDYING_RESOLVE			= not IsClassic and GetSkillName(51915)
local SPELL_VAMPIRIC_EMBRACE		= GetSkillName(15286)
local SPELL_VAMPIRIC_TOUCH			= not IsClassic and GetSkillName(34914)

local _

local eventFrame

local differentialMap = {}
local differential_mt = { __index = function(t, k) return differentialMap[t][k] end }
local differentialCache = {}

local savedVariables
local savedVariablesPerChar
local savedMedia

local currentProfile
local runtimeController

local pathTable = {}

local isFirstLoad

local function CreateClassSettingsTable(class)

	if (not RAID_CLASS_COLORS[class]) then return { disabled = true, colorR = 1, colorG = 1, colorB = 1 } end

	return { colorR = RAID_CLASS_COLORS[class].r, colorG = RAID_CLASS_COLORS[class].g, colorB = RAID_CLASS_COLORS[class].b }
end

local masterProfile
if IsClassic then
	masterProfile = {

		scrollAreas = {
			Incoming = {
				name					= L.MSG_INCOMING,
				offsetX					= -140,
				offsetY					= -160,
				animationStyle			= "Parabola",
				direction				= "Down",
				behavior				= "CurvedLeft",
				stickyBehavior			= "Jiggle",
				textAlignIndex			= 3,
				stickyTextAlignIndex	= 3,
			},
			Outgoing = {
				name					= L.MSG_OUTGOING,
				offsetX					= 100,
				offsetY					= -160,
				animationStyle			= "Parabola",
				direction				= "Down",
				behavior				= "CurvedRight",
				stickyBehavior			= "Jiggle",
				textAlignIndex			= 1,
				stickyTextAlignIndex	= 1,
				iconAlign				= "Right",
			},
			Notification = {
				name					= L.MSG_NOTIFICATION,
				offsetX					= -175,
				offsetY					= 120,
				scrollHeight			= 200,
				scrollWidth				= 350,
			},
			Static = {
				name					= L.MSG_STATIC,
				offsetX					= -20,
				offsetY					= -300,
				scrollHeight			= 125,
				animationStyle			= "Static",
				direction				= "Down",
			},
		},

		events = {
			INCOMING_DAMAGE = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%n) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_DAMAGE_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%n) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_MISS = {
				colorR		= 0,
				colorG		= 0,
				message		= MISS .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_DODGE = {
				colorR		= 0,
				colorG		= 0,
				message		= DODGE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_PARRY = {
				colorR		= 0,
				colorG		= 0,
				message		= PARRY .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_BLOCK = {
				colorR		= 0,
				colorG		= 0,
				message		= BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_DEFLECT = {
				colorR		= 0,
				colorG		= 0,
				message		= DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_ABSORB = {
				colorB		= 0,
				message		= ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			INCOMING_IMMUNE = {
				colorB		= 0,
				message		= IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DAMAGE = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DAMAGE_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_SPELL_DAMAGE_SHIELD = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_SPELL_DOT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DOT_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_SPELL_MISS = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. MISS .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DODGE = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. DODGE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_PARRY = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. PARRY .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_BLOCK = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DEFLECT = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_RESIST = {
				colorR		= 0.5,
				colorG		= 0,
				colorB		= 0.5,
				message		= "(%s) " .. RESIST .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_ABSORB = {
				colorB		= 0,
				message		= "(%s) " .. ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_IMMUNE = {
				colorB		= 0,
				message		= "(%s) " .. IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_REFLECT = {
				colorR		= 0.5,
				colorG		= 0,
				colorB		= 0.5,
				message		= "(%s) " .. REFLECT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_INTERRUPT = {
				colorB		= 0,
				message		= "(%s) " .. INTERRUPT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_HEAL = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			INCOMING_HEAL_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				fontSize		= 22,
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_HOT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			INCOMING_HOT_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			SELF_HEAL = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			SELF_HEAL_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				fontSize		= 22,
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			SELF_HOT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			SELF_HOT_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_ENVIRONMENTAL = {
				colorG		= 0,
				colorB		= 0,
				message		= "-%a %e",
				scrollArea	= "Incoming",
			},

			OUTGOING_DAMAGE = {
				message		= "%a",
				scrollArea	= "Outgoing",
			},
			OUTGOING_DAMAGE_CRIT = {
				message		= "%a",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_MISS = {
				message		= MISS .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_DODGE = {
				message		= DODGE .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_PARRY = {
				message		= PARRY .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_BLOCK = {
				message		= BLOCK .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_DEFLECT = {
				message		= DEFLECT.. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_ABSORB = {
				colorB		= 0,
				message		= "<%a> " .. ABSORB .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_IMMUNE = {
				colorB		= 0,
				message		= IMMUNE .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_EVADE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= EVADE .. "!",
				fontSize		= 22,
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DAMAGE = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DAMAGE_CRIT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_SPELL_DAMAGE_SHIELD = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_SPELL_DOT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DOT_CRIT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_SPELL_MISS = {
				message		= MISS .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DODGE = {
				message		= DODGE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_PARRY = {
				message		= PARRY .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_BLOCK = {
				message		= BLOCK .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DEFLECT = {
				message		= DEFLECT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_RESIST = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= RESIST .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_ABSORB = {
				colorB		= 0,
				message		= "<%a> " .. ABSORB .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_IMMUNE = {
				colorB		= 0,
				message		= IMMUNE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_REFLECT = {
				colorB		= 0,
				message		= REFLECT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_INTERRUPT = {
				colorB		= 0,
				message		= INTERRUPT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_EVADE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= EVADE .. "! (%s)",
				fontSize		= 22,
				scrollArea	= "Outgoing",
			},
			OUTGOING_HEAL = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_HEAL_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				fontSize		= 22,
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_HOT = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_HOT_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_DISPEL = {
				colorB		= 0.5,
				message		= L.MSG_DISPEL .. "! (%s)",
				scrollArea	= "Outgoing",
			},

			PET_INCOMING_DAMAGE = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%n) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_DAMAGE_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%n) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_MISS = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. MISS .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_DODGE = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. DODGE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_PARRY = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. PARRY .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_BLOCK = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_DEFLECT = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_ABSORB = {
				colorB		= 0.57,
				message		= PET .. " " .. ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_IMMUNE = {
				colorB		= 0.57,
				message		= PET .. " " .. IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DAMAGE = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DAMAGE_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_SPELL_DAMAGE_SHIELD = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_SPELL_DOT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DOT_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_SPELL_MISS = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. MISS .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DODGE = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. DODGE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_PARRY = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. PARRY .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_BLOCK = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DEFLECT = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_RESIST = {
				colorR		= 0.94,
				colorG		= 0,
				colorB		= 0.94,
				message		= "(%s) " .. PET .. " " .. RESIST .. "!",
				scrollArea		= "Incoming",
			},
			PET_INCOMING_SPELL_ABSORB = {
				colorB		= 0.57,
				message		= "(%s) " .. PET .. " " .. ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_IMMUNE = {
				colorB		= 0.57,
				message		= "(%s) " .. PET .. " " .. IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_HEAL = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_HEAL_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_HOT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_HOT_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},

			PET_OUTGOING_DAMAGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " %a",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_DAMAGE_CRIT = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " %a",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_MISS = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. MISS,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_DODGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. DODGE,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_PARRY = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. PARRY,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_BLOCK = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. BLOCK,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_DEFLECT = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. DEFLECT,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_ABSORB = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " <%a> " .. ABSORB,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_IMMUNE = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " " .. IMMUNE,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_EVADE = {
				colorG		= 0.77,
				colorB		= 0.57,
				message		= PET .. " " .. EVADE,
				fontSize		= 22,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DAMAGE = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DAMAGE_CRIT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_SPELL_DAMAGE_SHIELD = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_SPELL_DOT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DOT_CRIT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_SPELL_MISS = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. MISS .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DODGE = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. DODGE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_PARRY = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. PARRY .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_BLOCK = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. BLOCK .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DEFLECT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. DEFLECT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_RESIST = {
				colorR		= 0.73,
				colorG		= 0.73,
				colorB		= 0.84,
				message		= PET .. " " .. RESIST .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_ABSORB = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " <%a> " .. ABSORB .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_IMMUNE = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " " .. IMMUNE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_EVADE = {
				colorG		= 0.77,
				colorB		= 0.57,
				message		= PET .. " " .. EVADE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_HEAL = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_HEAL_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				fontSize		= 22,
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_HOT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_HOT_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_DISPEL = {
				colorB		= 0.73,
				message		= PET .. " " .. L.MSG_DISPEL .. "! (%s)",
				scrollArea	= "Outgoing",
			},

			NOTIFICATION_DEBUFF = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "[%sl]",
			},
			NOTIFICATION_DEBUFF_STACK = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "[%sl %a]",
			},
			NOTIFICATION_BUFF = {
				colorR		= 0.698,
				colorG		= 0.698,
				colorB		= 0,
				message		= "[%sl]",
			},
			NOTIFICATION_BUFF_STACK = {
				colorR		= 0.698,
				colorG		= 0.698,
				colorB		= 0,
				message		= "[%sl %a]",
			},
			NOTIFICATION_ITEM_BUFF = {
				colorR		= 0.698,
				colorG		= 0.698,
				colorB		= 0.698,
				message		= "[%sl]",
			},
			NOTIFICATION_DEBUFF_FADE = {
				colorR		= 0,
				colorG		= 0.835,
				colorB		= 0.835,
				message		= "-[%sl]",
			},
			NOTIFICATION_BUFF_FADE = {
				colorR		= 0.918,
				colorG		= 0.918,
				colorB		= 0,
				message		= "-[%sl]",
			},
			NOTIFICATION_ITEM_BUFF_FADE = {
				colorR		= 0.831,
				colorG		= 0.831,
				colorB		= 0.831,
				message		= "-[%sl]",
			},
			NOTIFICATION_COMBAT_ENTER = {
				message		= "+" .. L.MSG_COMBAT,
			},
			NOTIFICATION_COMBAT_LEAVE = {
				message		= "-" .. L.MSG_COMBAT,
			},
			NOTIFICATION_POWER_GAIN = {
				colorB		= 0,
				message		= "+%a %p",
			},
			NOTIFICATION_POWER_LOSS = {
				colorB		= 0,
				message		= "-%a %p",
			},
			NOTIFICATION_ALT_POWER_GAIN = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "+%a %p",
			},
			NOTIFICATION_ALT_POWER_LOSS = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "-%a %p",
			},
			NOTIFICATION_CHI_CHANGE = {
				colorR		= 0.5,
				colorG		= 0.8,
				colorB		= 0.7,
				message		= "%a " .. CHI,
			},
			NOTIFICATION_CHI_FULL = {
				colorR			= 0.5,
				colorG			= 0.8,
				colorB			= 0.7,
				message			= L.MSG_CHI_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_AC_CHANGE = {
				colorR		= 0.3,
				colorG		= 0.7,
				colorB		= 0.9,
				message		= "%a " .. L.MSG_AC,
			},
			NOTIFICATION_AC_FULL = {
				colorR			= 0.3,
				colorG			= 0.7,
				colorB			= 0.9,
				message			= L.MSG_AC_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_CP_GAIN = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%a " .. L.MSG_CP,
			},
			NOTIFICATION_CP_FULL = {
				colorR			= 0.8,
				colorG			= 0,
				colorB			= 0,
				message			= L.MSG_CP_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_HOLY_POWER_CHANGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%a " .. HOLY_POWER,
			},
			NOTIFICATION_HOLY_POWER_FULL = {
				colorG			= 0.5,
				colorB			= 0,
				message			= L.MSG_HOLY_POWER_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_ESSENCE_CHANGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%a " .. L.MSG_ESSENCE,
			},
			NOTIFICATION_ESSENCE_FULL = {
				colorG			= 0.5,
				colorB			= 0,
				message			= L.MSG_ESSENCE_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_HONOR_GAIN = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= "+%a " .. HONOR,
			},
			NOTIFICATION_REP_GAIN = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= "+%a " .. REPUTATION .. " (%e)",
			},
			NOTIFICATION_REP_LOSS = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= "-%a " .. REPUTATION .. " (%e)",
			},
			NOTIFICATION_SKILL_GAIN = {
				colorR		= 0.333,
				colorG		= 0.333,
				message		= "%sl: %a",
			},
			NOTIFICATION_EXPERIENCE_GAIN = {
				disabled		= true,
				colorR			= 0.756,
				colorG			= 0.270,
				colorB			= 0.823,
				message			= "%a " .. XP,
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_PC_KILLING_BLOW = {
				colorR			= 0.333,
				colorG			= 0.333,
				message			= L.MSG_KILLING_BLOW .. "! (%n)",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_NPC_KILLING_BLOW = {
				disabled		= true,
				colorR			= 0.333,
				colorG			= 0.333,
				message			= L.MSG_KILLING_BLOW .. "! (%n)",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_EXTRA_ATTACK = {
				colorB		= 0,
				message		= "%sl!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_ENEMY_BUFF = {
				colorB		= 0.5,
				message		= "%n: [%sl]",
				scrollArea	= "Static",
			},
			NOTIFICATION_MONSTER_EMOTE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%e",
				scrollArea	= "Static",
			},
			NOTIFICATION_MONEY = {
				message		= "+%e",
				scrollArea	= "Static",
			},
			NOTIFICATION_ITEM_COOLDOWN = {
				colorR = 0.784, colorG = 0.784, colorB = 0,
				message = " %e " .. L.MSG_READY_NOW .. "!",
				scrollArea = "Static", fontSize = 22,
				soundFile = "MSBT Cooldown",
				skillColorR = 1, skillColorG = 0.588, skillColorB = 0.588,
			},
			NOTIFICATION_LOOT = {
				colorB		= 0,
				message		= "+%a %e (%t)",
				scrollArea	= "Static",
			},
			NOTIFICATION_CURRENCY = {
				colorB		= 0,
				message		= "+%a %e (%t)",
				scrollArea	= "Static",
			},
		},

		triggers = {

			MSBT_TRIGGER_CLEARCASTING = {
				colorB			= 0,
				message			= SPELL_CLEARCASTING .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DRUID,MAGE,PRIEST,SHAMAN",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_CLEARCASTING .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},

			MSBT_TRIGGER_EXECUTE = {
				colorB			= 0,
				message			= SPELL_EXECUTE .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "WARRIOR",
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
				exceptions		= "unavailableSkill;;eq;;" .. SPELL_EXECUTE,
				iconSkill		= SPELLID_EXECUTE,
			},

			MSBT_TRIGGER_HAMMER_OF_WRATH = {
				colorB			= 0,
				message			= SPELL_HAMMER_OF_WRATH .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "PALADIN",
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
				exceptions		= "unavailableSkill;;eq;;" .. SPELL_HAMMER_OF_WRATH,
				iconSkill		= SPELLID_HAMMER_OF_WRATH,
			},

			MSBT_TRIGGER_LOW_HEALTH = {
				disabled		= true,
				colorG			= 0.5,
				colorB			= 0.5,
				message			= L.MSG_TRIGGER_LOW_HEALTH .. "! (%a)",
				alwaysSticky	= true,
				fontSize		= 26,
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;35}",
				exceptions		= "recentlyFired;;lt;;5",
				iconSkill		= SPELLID_FIRST_AID,
			},
			MSBT_TRIGGER_LOW_MANA = {
				disabled		= true,
				colorR			= 0.5,
				colorG			= 0.5,
				message			= L.MSG_TRIGGER_LOW_MANA .. "! (%a)",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DRUID,MAGE,PALADIN,PRIEST,SHAMAN,WARLOCK",
				mainEvents		= "UNIT_POWER_UPDATE{powerType;;eq;;0;;unitID;;eq;;player;;threshold;;lt;;35}",
				exceptions		= "recentlyFired;;lt;;5",
			},
			MSBT_TRIGGER_LOW_PET_HEALTH = {
				colorG			= 0.5,
				colorB			= 0.5,
				message			= L.MSG_TRIGGER_LOW_PET_HEALTH .. "! (%a)",
				fontSize		= 26,
				classes			= "HUNTER,MAGE,WARLOCK",
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;pet;;threshold;;lt;;40}",
				exceptions		= "recentlyFired;;lt;;5",
			},

			MSBT_TRIGGER_REVENGE = {
				colorB			= 0,
				message			= SPELL_REVENGE .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "WARRIOR",
				mainEvents		= "GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;BLOCK}&&GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;DODGE}&&GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;PARRY}",
				exceptions		= "warriorStance;;ne;;2;;unavailableSkill;;eq;;" .. SPELL_REVENGE .. ";;recentlyFired;;lt;;2",
				iconSkill		= SPELLID_REVENGE,
			},

		},

		normalFontName			= L.DEFAULT_FONT_NAME,
		normalOutlineIndex		= 1,
		normalFontSize			= 18,
		normalFontAlpha			= 100,
		critFontName			= L.DEFAULT_FONT_NAME,
		critOutlineIndex		= 1,
		critFontSize			= 26,
		critFontAlpha			= 100,

		animationSpeed			= 100,

		crushing		= { colorR = 0.5, colorG = 0, colorB = 0, trailer = string_gsub(CRUSHING_TRAILER, "%((.+)%)", "<%1>") },
		glancing		= { colorR = 1, colorG = 0, colorB = 0, trailer = string_gsub(GLANCING_TRAILER, "%((.+)%)", "<%1>") },
		absorb			= { colorR = 1, colorG = 1, colorB = 0, trailer = string_gsub(string_gsub(ABSORB_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
		block			= { colorR = 0.5, colorG = 0, colorB = 1, trailer = string_gsub(string_gsub(BLOCK_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
		resist			= { colorR = 0.5, colorG = 0, colorB = 0.5, trailer = string_gsub(string_gsub(RESIST_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
		overheal		= { colorR = 0, colorG = 0.705, colorB = 0.5, trailer = " <%a>" },
		overkill		= { disabled = true, colorR = 0.83, colorG = 0, colorB = 0.13, trailer = " <%a>" },

		physical		= { colorR = 1, colorG = 1, colorB = 1 },
		arcane			= { colorR = 0.956, colorG = 0.658, colorB = 0.894 },
		fire			= { colorR = 0.933, colorG = 0.490, colorB = 0.501 },
		frost			= { colorR = 0.462, colorG = 0.792, colorB = 0.929 },
		holy			= { colorR = 0.976, colorG = 0.945, colorB = 0.631 },
		nature			= { colorR = 0.631, colorG = 0.858, colorB = 0.396 },
		shadow			= { colorR = 0.356, colorG = 0.290, colorB = 0.596 },
		spellfire		= { colorR = 0.898, colorG = 0.360, colorB = 0.501 },
		spellfrost		= { colorR = 0.321, colorG = 0.321, colorB = 0.8 },
		divine			= { colorR = 0.956, colorG = 0.894, colorB = 0.572 },
		astral			= { colorR = 0.737, colorG = 0.411, colorB = 0.968 },
		spellshadow		= { colorR = 0.450, colorG = 0.215, colorB = 0.6 },
		radiant			= { colorR = 0.937, colorG = 0.690, colorB = 0.396 },
		holystorm		= { colorR = 0.752, colorG = 0.909, colorB = 0.545 },
		holyfrost		= { colorR = 0.545, colorG = 0.909, colorB = 0.874 },
		volcanic		= { colorR = 0.937, colorG = 0.545, colorB = 0.282 },
		shadowflame		= { colorR = 0.745, colorG = 0.333, colorB = 0.529 },
		frostfire		= { colorR = 0.262, colorG = 0.572, colorB = 0.666 },
		froststorm		= { colorR = 0.356, colorG = 0.698, colorB = 0.556 },
		shadowfrost		= { colorR = 0.2, colorG = 0.317, colorB = 0.607 },
		twilight		= { colorR = 0.631, colorG = 0.349, colorB = 0.698 },
		plague			= { colorR = 0.584, colorG = 0.8, colorB = 0.329 },
		spellstrike		= { colorR = 0.941, colorG = 0.866, colorB = 0.929 },
		flamestrike		= { colorR = 0.968, colorG = 0.764, colorB = 0.749 },
		froststrike		= { colorR = 0.678, colorG = 0.858, colorB = 0.890 },
		stormstrike		= { colorR = 0.698, colorG = 0.792, colorB = 0.8 },
		shadowstrike	= { colorR = 0.827, colorG = 0.8, colorB = 0.949 },
		holystrike		= { colorR = 0.968, colorG = 0.925, colorB = 0.796 },
		elemental		= { colorR = 0.337, colorG = 0.858, colorB = 0.682 },
		cosmic			= { colorR = 0.368, colorG = 0.627, colorB = 0.8 },
		chromatic		= { colorR = 0.573, colorG = 0.976, colorB = 0.098 },
		magic			= { colorR = 0.470, colorG = 0.937, colorB = 1 },
		chaos			= { colorR = 0.247, colorG = 0.152, colorB = 0.4 },

		DEATHKNIGHT		= CreateClassSettingsTable("DEATHKNIGHT"),
		DRUID			= CreateClassSettingsTable("DRUID"),
		HUNTER			= CreateClassSettingsTable("HUNTER"),
		MAGE			= CreateClassSettingsTable("MAGE"),
		MONK			= CreateClassSettingsTable("MONK"),
		PALADIN			= CreateClassSettingsTable("PALADIN"),
		PRIEST			= CreateClassSettingsTable("PRIEST"),
		ROGUE			= CreateClassSettingsTable("ROGUE"),
		SHAMAN			= CreateClassSettingsTable("SHAMAN"),
		WARLOCK			= CreateClassSettingsTable("WARLOCK"),
		WARRIOR			= CreateClassSettingsTable("WARRIOR"),
		DEMONHUNTER		= CreateClassSettingsTable("DEMONHUNTER"),
		EVOKER			= CreateClassSettingsTable("EVOKER"),

		dotThrottleDuration				= 3,
		hotThrottleDuration				= 3,
		powerThrottleDuration			= 3,
		throttleList = {

			[SPELL_VAMPIRIC_EMBRACE]	= 5,

		},

		mergeExclusions					= {},
		abilitySubstitutions			= {},
		abilitySuppressions				= {

		},
		damageThreshold					= 0,
		healThreshold					= 0,
		powerThreshold					= 0,
		hideFullHoTOverheals			= true,
		shortenNumbers					= false,
		stackSimilarHits				= false,
		disableOutgoingInGroup			= false,
		disableIncomingInGroup			= false,
		disableNotificationInGroup		= false,
		disableStaticInGroup			= false,
		enableBlizzardV2CombatText		= false,
		enableBlizzardV2CombatTextInGroup = false,
		shortenNumberPrecision			= 0,
		groupNumbers					= false,

		cooldownExclusions = {},
		ignoreCooldownThreshold = {},
		cooldownThreshold = 5,
		qualityExclusions				= {
			[LE_ITEM_QUALITY_POOR or Enum.ItemQuality.Poor] = true,
		},
		alwaysShowQuestItems			= true,
		itemsAllowed					= {},
		itemExclusions					= {},
	}
else
	masterProfile = {

		scrollAreas = {
			Incoming = {
				name					= L.MSG_INCOMING,
				offsetX					= -140,
				offsetY					= -160,
				animationStyle			= "Parabola",
				direction				= "Down",
				behavior				= "CurvedLeft",
				stickyBehavior			= "Jiggle",
				textAlignIndex			= 3,
				stickyTextAlignIndex	= 3,
			},
			Outgoing = {
				name					= L.MSG_OUTGOING,
				offsetX					= 100,
				offsetY					= -160,
				animationStyle			= "Parabola",
				direction				= "Down",
				behavior				= "CurvedRight",
				stickyBehavior			= "Jiggle",
				textAlignIndex			= 1,
				stickyTextAlignIndex	= 1,
				iconAlign				= "Right",
			},
			Notification = {
				name					= L.MSG_NOTIFICATION,
				offsetX					= -175,
				offsetY					= 120,
				scrollHeight			= 200,
				scrollWidth				= 350,
			},
			Static = {
				name					= L.MSG_STATIC,
				offsetX					= -20,
				offsetY					= -300,
				scrollHeight			= 125,
				animationStyle			= "Static",
				direction				= "Down",
			},
		},

		events = {
			INCOMING_DAMAGE = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%n) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_DAMAGE_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%n) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_MISS = {
				colorR		= 0,
				colorG		= 0,
				message		= MISS .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_DODGE = {
				colorR		= 0,
				colorG		= 0,
				message		= DODGE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_PARRY = {
				colorR		= 0,
				colorG		= 0,
				message		= PARRY .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_BLOCK = {
				colorR		= 0,
				colorG		= 0,
				message		= BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_DEFLECT = {
				colorR		= 0,
				colorG		= 0,
				message		= DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_ABSORB = {
				colorB		= 0,
				message		= ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			INCOMING_IMMUNE = {
				colorB		= 0,
				message		= IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DAMAGE = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DAMAGE_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_SPELL_DAMAGE_SHIELD = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_SPELL_DOT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DOT_CRIT = {
				colorG		= 0,
				colorB		= 0,
				message		= "(%s) -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_SPELL_MISS = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. MISS .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DODGE = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. DODGE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_PARRY = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. PARRY .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_BLOCK = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_DEFLECT = {
				colorR		= 0,
				colorG		= 0,
				message		= "(%s) " .. DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_RESIST = {
				colorR		= 0.5,
				colorG		= 0,
				colorB		= 0.5,
				message		= "(%s) " .. RESIST .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_ABSORB = {
				colorB		= 0,
				message		= "(%s) " .. ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_IMMUNE = {
				colorB		= 0,
				message		= "(%s) " .. IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_REFLECT = {
				colorR		= 0.5,
				colorG		= 0,
				colorB		= 0.5,
				message		= "(%s) " .. REFLECT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_SPELL_INTERRUPT = {
				colorB		= 0,
				message		= "(%s) " .. INTERRUPT .. "!",
				scrollArea	= "Incoming",
			},
			INCOMING_HEAL = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			INCOMING_HEAL_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				fontSize		= 22,
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_HOT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			INCOMING_HOT_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			SELF_HEAL = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			SELF_HEAL_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				fontSize		= 22,
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			SELF_HOT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
			},
			SELF_HOT_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "(%s - %n) +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			INCOMING_ENVIRONMENTAL = {
				colorG		= 0,
				colorB		= 0,
				message		= "-%a %e",
				scrollArea	= "Incoming",
			},

			OUTGOING_DAMAGE = {
				message		= "%a",
				scrollArea	= "Outgoing",
			},
			OUTGOING_DAMAGE_CRIT = {
				message		= "%a",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_MISS = {
				message		= MISS .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_DODGE = {
				message		= DODGE .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_PARRY = {
				message		= PARRY .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_BLOCK = {
				message		= BLOCK .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_DEFLECT = {
				message		= DEFLECT.. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_ABSORB = {
				colorB		= 0,
				message		= "<%a> " .. ABSORB .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_IMMUNE = {
				colorB		= 0,
				message		= IMMUNE .. "!",
				scrollArea	= "Outgoing",
			},
			OUTGOING_EVADE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= EVADE .. "!",
				fontSize		= 22,
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DAMAGE = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DAMAGE_CRIT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_SPELL_DAMAGE_SHIELD = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_SPELL_DOT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DOT_CRIT = {
				colorB		= 0,
				message		= "%a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_SPELL_MISS = {
				message		= MISS .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DODGE = {
				message		= DODGE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_PARRY = {
				message		= PARRY .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_BLOCK = {
				message		= BLOCK .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_DEFLECT = {
				message		= DEFLECT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_RESIST = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= RESIST .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_ABSORB = {
				colorB		= 0,
				message		= "<%a> " .. ABSORB .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_IMMUNE = {
				colorB		= 0,
				message		= IMMUNE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_REFLECT = {
				colorB		= 0,
				message		= REFLECT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_INTERRUPT = {
				colorB		= 0,
				message		= INTERRUPT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_SPELL_EVADE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= EVADE .. "! (%s)",
				fontSize		= 22,
				scrollArea	= "Outgoing",
			},
			OUTGOING_HEAL = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_HEAL_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				fontSize		= 22,
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_HOT = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			OUTGOING_HOT_CRIT = {
				colorR		= 0,
				colorB		= 0,
				message		= "+%a (%s - %n)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			OUTGOING_DISPEL = {
				colorB		= 0.5,
				message		= L.MSG_DISPEL .. "! (%s)",
				scrollArea	= "Outgoing",
			},

			PET_INCOMING_DAMAGE = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%n) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_DAMAGE_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%n) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_MISS = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. MISS .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_DODGE = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. DODGE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_PARRY = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. PARRY .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_BLOCK = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_DEFLECT = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= PET .. " " .. DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_ABSORB = {
				colorB		= 0.57,
				message		= PET .. " " .. ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_IMMUNE = {
				colorB		= 0.57,
				message		= PET .. " " .. IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DAMAGE = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DAMAGE_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_SPELL_DAMAGE_SHIELD = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_SPELL_DOT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DOT_CRIT = {
				colorG		= 0.41,
				colorB		= 0.41,
				message		= "(%s) " .. PET .. " -%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_SPELL_MISS = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. MISS .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DODGE = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. DODGE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_PARRY = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. PARRY .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_BLOCK = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. BLOCK .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_DEFLECT = {
				colorR		= 0.57,
				colorG		= 0.58,
				message		= "(%s) " .. PET .. " " .. DEFLECT .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_RESIST = {
				colorR		= 0.94,
				colorG		= 0,
				colorB		= 0.94,
				message		= "(%s) " .. PET .. " " .. RESIST .. "!",
				scrollArea		= "Incoming",
			},
			PET_INCOMING_SPELL_ABSORB = {
				colorB		= 0.57,
				message		= "(%s) " .. PET .. " " .. ABSORB .. "! <%a>",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_SPELL_IMMUNE = {
				colorB		= 0.57,
				message		= "(%s) " .. PET .. " " .. IMMUNE .. "!",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_HEAL = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_HEAL_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},
			PET_INCOMING_HOT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
			},
			PET_INCOMING_HOT_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= "(%s - %n) " .. PET .. " +%a",
				scrollArea	= "Incoming",
				isCrit		= true,
			},

			PET_OUTGOING_DAMAGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " %a",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_DAMAGE_CRIT = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " %a",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_MISS = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. MISS,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_DODGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. DODGE,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_PARRY = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. PARRY,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_BLOCK = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. BLOCK,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_DEFLECT = {
				colorG		= 0.5,
				colorB		= 0,
				message		= PET .. " " .. DEFLECT,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_ABSORB = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " <%a> " .. ABSORB,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_IMMUNE = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " " .. IMMUNE,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_EVADE = {
				colorG		= 0.77,
				colorB		= 0.57,
				message		= PET .. " " .. EVADE,
				fontSize		= 22,
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DAMAGE = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DAMAGE_CRIT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_SPELL_DAMAGE_SHIELD = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_SPELL_DOT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DOT_CRIT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " %a (%s)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_SPELL_MISS = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. MISS .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DODGE = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. DODGE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_PARRY = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. PARRY .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_BLOCK = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. BLOCK .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_DEFLECT = {
				colorR		= 0.33,
				colorG		= 0.33,
				message		= PET .. " " .. DEFLECT .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_RESIST = {
				colorR		= 0.73,
				colorG		= 0.73,
				colorB		= 0.84,
				message		= PET .. " " .. RESIST .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_ABSORB = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " <%a> " .. ABSORB .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_IMMUNE = {
				colorR		= 0.5,
				colorG		= 0.5,
				message		= PET .. " " .. IMMUNE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_SPELL_EVADE = {
				colorG		= 0.77,
				colorB		= 0.57,
				message		= PET .. " " .. EVADE .. "! (%s)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_HEAL = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_HEAL_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				fontSize		= 22,
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_HOT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				scrollArea	= "Outgoing",
			},
			PET_OUTGOING_HOT_CRIT = {
				colorR		= 0.57,
				colorB		= 0.57,
				message		= PET .. " " .. "+%a (%s - %n)",
				scrollArea	= "Outgoing",
				isCrit		= true,
			},
			PET_OUTGOING_DISPEL = {
				colorB		= 0.73,
				message		= PET .. " " .. L.MSG_DISPEL .. "! (%s)",
				scrollArea	= "Outgoing",
			},

			NOTIFICATION_DEBUFF = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "[%sl]",
			},
			NOTIFICATION_DEBUFF_STACK = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "[%sl %a]",
			},
			NOTIFICATION_BUFF = {
				colorR		= 0.698,
				colorG		= 0.698,
				colorB		= 0,
				message		= "[%sl]",
			},
			NOTIFICATION_BUFF_STACK = {
				colorR		= 0.698,
				colorG		= 0.698,
				colorB		= 0,
				message		= "[%sl %a]",
			},
			NOTIFICATION_ITEM_BUFF = {
				colorR		= 0.698,
				colorG		= 0.698,
				colorB		= 0.698,
				message		= "[%sl]",
			},
			NOTIFICATION_DEBUFF_FADE = {
				colorR		= 0,
				colorG		= 0.835,
				colorB		= 0.835,
				message		= "-[%sl]",
			},
			NOTIFICATION_BUFF_FADE = {
				colorR		= 0.918,
				colorG		= 0.918,
				colorB		= 0,
				message		= "-[%sl]",
			},
			NOTIFICATION_ITEM_BUFF_FADE = {
				colorR		= 0.831,
				colorG		= 0.831,
				colorB		= 0.831,
				message		= "-[%sl]",
			},
			NOTIFICATION_COMBAT_ENTER = {
				message		= "+" .. L.MSG_COMBAT,
			},
			NOTIFICATION_COMBAT_LEAVE = {
				message		= "-" .. L.MSG_COMBAT,
			},
			NOTIFICATION_POWER_GAIN = {
				colorB		= 0,
				message		= "+%a %p",
			},
			NOTIFICATION_POWER_LOSS = {
				colorB		= 0,
				message		= "-%a %p",
			},
			NOTIFICATION_ALT_POWER_GAIN = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "+%a %p",
			},
			NOTIFICATION_ALT_POWER_LOSS = {
				colorR		= 0,
				colorG		= 0.5,
				colorB		= 0.5,
				message		= "-%a %p",
			},
			NOTIFICATION_CHI_CHANGE = {
				colorR		= 0.5,
				colorG		= 0.8,
				colorB		= 0.7,
				message		= "%a " .. CHI,
			},
			NOTIFICATION_CHI_FULL = {
				colorR			= 0.5,
				colorG			= 0.8,
				colorB			= 0.7,
				message			= L.MSG_CHI_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_AC_CHANGE = {
				colorR		= 0.3,
				colorG		= 0.7,
				colorB		= 0.9,
				message		= "%a " .. L.MSG_AC,
			},
			NOTIFICATION_AC_FULL = {
				colorR			= 0.3,
				colorG			= 0.7,
				colorB			= 0.9,
				message			= L.MSG_AC_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_CP_GAIN = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%a " .. L.MSG_CP,
			},
			NOTIFICATION_CP_FULL = {
				colorR			= 0.8,
				colorG			= 0,
				colorB			= 0,
				message			= L.MSG_CP_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_HOLY_POWER_CHANGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%a " .. HOLY_POWER,
			},
			NOTIFICATION_HOLY_POWER_FULL = {
				colorG			= 0.5,
				colorB			= 0,
				message			= L.MSG_HOLY_POWER_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_ESSENCE_CHANGE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%a " .. L.MSG_ESSENCE,
			},
			NOTIFICATION_ESSENCE_FULL = {
				colorG			= 0.5,
				colorB			= 0,
				message			= L.MSG_ESSENCE_FULL .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_HONOR_GAIN = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= "+%a " .. HONOR,
			},
			NOTIFICATION_REP_GAIN = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= "+%a " .. REPUTATION .. " (%e)",
			},
			NOTIFICATION_REP_LOSS = {
				colorR		= 0.5,
				colorG		= 0.5,
				colorB		= 0.698,
				message		= "-%a " .. REPUTATION .. " (%e)",
			},
			NOTIFICATION_SKILL_GAIN = {
				colorR		= 0.333,
				colorG		= 0.333,
				message		= "%sl: %a",
			},
			NOTIFICATION_EXPERIENCE_GAIN = {
				disabled		= true,
				colorR			= 0.756,
				colorG			= 0.270,
				colorB			= 0.823,
				message			= "%a " .. XP,
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_PC_KILLING_BLOW = {
				colorR			= 0.333,
				colorG			= 0.333,
				message			= L.MSG_KILLING_BLOW .. "! (%n)",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_NPC_KILLING_BLOW = {
				disabled		= true,
				colorR			= 0.333,
				colorG			= 0.333,
				message			= L.MSG_KILLING_BLOW .. "! (%n)",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_EXTRA_ATTACK = {
				colorB		= 0,
				message		= "%sl!",
				alwaysSticky	= true,
				fontSize		= 26,
			},
			NOTIFICATION_ENEMY_BUFF = {
				colorB		= 0.5,
				message		= "%n: [%sl]",
				scrollArea	= "Static",
			},
			NOTIFICATION_MONSTER_EMOTE = {
				colorG		= 0.5,
				colorB		= 0,
				message		= "%e",
				scrollArea	= "Static",
			},
			NOTIFICATION_MONEY = {
				message		= "+%e",
				scrollArea	= "Static",
			},
			NOTIFICATION_ITEM_COOLDOWN = {
				colorR = 0.784, colorG = 0.784, colorB = 0,
				message = " %e " .. L.MSG_READY_NOW .. "!",
				scrollArea = "Static", fontSize = 22,
				soundFile = "MSBT Cooldown",
				skillColorR = 1, skillColorG = 0.588, skillColorB = 0.588,
			},
			NOTIFICATION_LOOT = {
				colorB		= 0,
				message		= "+%a %e (%t)",
				scrollArea	= "Static",
			},
			NOTIFICATION_CURRENCY = {
				colorB		= 0,
				message		= "+%a %e (%t)",
				scrollArea	= "Static",
			},
		},

		triggers = {

			MSBT_TRIGGER_CLEARCASTING = {
				colorB			= 0,
				message			= SPELL_CLEARCASTING .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DRUID,MAGE,PRIEST,SHAMAN",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_CLEARCASTING .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},

			MSBT_TRIGGER_ELUSIVE_BREW = {
				colorB			= 0,
				message			= SPELL_ELUSIVE_BREW .. " x%a!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "MONK",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ELUSIVE_BREW .. ";;amount;;eq;;5;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}&&" ..
								"SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ELUSIVE_BREW .. ";;amount;;eq;;10;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}&&" ..
								"SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ELUSIVE_BREW .. ";;amount;;eq;;15;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},
			MSBT_TRIGGER_EXECUTE = {
				colorB			= 0,
				message			= SPELL_EXECUTE .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "WARRIOR",
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
				exceptions		= "unavailableSkill;;eq;;" .. SPELL_EXECUTE,
				iconSkill		= SPELLID_EXECUTE,
			},
			MSBT_TRIGGER_FINGERS_OF_FROST = {
				colorR			= 0.118,
				colorG			= 0.882,
				message			= SPELL_FINGERS_OF_FROST .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "MAGE",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_FINGERS_OF_FROST .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
				exceptions		= "recentlyFired;;lt;;2",
			},
			MSBT_TRIGGER_HAMMER_OF_WRATH = {
				colorB			= 0,
				message			= SPELL_HAMMER_OF_WRATH .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "PALADIN",
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
				exceptions		= "unavailableSkill;;eq;;" .. SPELL_HAMMER_OF_WRATH,
				iconSkill		= SPELLID_HAMMER_OF_WRATH,
			},

			MSBT_TRIGGER_KILLING_MACHINE = {
				colorR			= 0.118,
				colorG			= 0.882,
				message			= SPELL_KILLING_MACHINE .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DEATHKNIGHT",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_KILLING_MACHINE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},
			MSBT_TRIGGER_LAVA_SURGE = {
				colorG			= 0.341,
				colorB			= 0.129,
				message			= SPELL_LAVA_SURGE,
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "SHAMAN",
				mainEvents		= "SPELL_CAST_SUCCESS{sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;skillID;;eq;;" .. SPELLID_LAVA_SURGE .. "}",
			},

			MSBT_TRIGGER_LOW_HEALTH = {
				disabled		= true,
				colorG			= 0.5,
				colorB			= 0.5,
				message			= L.MSG_TRIGGER_LOW_HEALTH .. "! (%a)",
				alwaysSticky	= true,
				fontSize		= 26,
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;35}",
				exceptions		= "recentlyFired;;lt;;5",
				iconSkill		= SPELLID_FIRST_AID,
			},
			MSBT_TRIGGER_LOW_MANA = {
				disabled		= true,
				colorR			= 0.5,
				colorG			= 0.5,
				message			= L.MSG_TRIGGER_LOW_MANA .. "! (%a)",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DRUID,MAGE,PALADIN,PRIEST,SHAMAN,WARLOCK",
				mainEvents		= "UNIT_POWER_UPDATE{powerType;;eq;;0;;unitID;;eq;;player;;threshold;;lt;;35}",
				exceptions		= "recentlyFired;;lt;;5",
			},
			MSBT_TRIGGER_LOW_PET_HEALTH = {
				colorG			= 0.5,
				colorB			= 0.5,
				message			= L.MSG_TRIGGER_LOW_PET_HEALTH .. "! (%a)",
				fontSize		= 26,
				classes			= "HUNTER,MAGE,WARLOCK",
				mainEvents		= "UNIT_HEALTH{unitID;;eq;;pet;;threshold;;lt;;40}",
				exceptions		= "recentlyFired;;lt;;5",
			},

			MSBT_TRIGGER_MISSILE_BARRAGE = {
				colorG			= 0.725,
				message			= SPELL_MISSILE_BARRAGE .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "MAGE",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_MISSILE_BARRAGE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},

			MSBT_TRIGGER_PVP_TRINKET = {
				colorB			= 0,
				message			= SPELL_PVP_TRINKET .. "! (%r)",
				alwaysSticky	= true,
				fontSize		= 26,
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_PVP_TRINKET .. ";;recipientReaction;;eq;;" .. REACTION_HOSTILE .. "}",
				exceptions		= "zoneType;;ne;;arena",
			},
			MSBT_TRIGGER_PREDATORS_SWIFTNESS = {
				colorR			= 0.5,
				colorB			= 0.5,
				message			= SPELL_PREDATORS_SWIFTNESS .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DRUID",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_PREDATORS_SWIFTNESS .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},
			MSBT_TRIGGER_REVENGE = {
				colorB			= 0,
				message			= SPELL_REVENGE .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "WARRIOR",
				mainEvents		= "GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;BLOCK}&&GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;DODGE}&&GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;PARRY}",
				exceptions		= "warriorStance;;ne;;2;;unavailableSkill;;eq;;" .. SPELL_REVENGE .. ";;recentlyFired;;lt;;2",
				iconSkill		= SPELLID_REVENGE,
			},
			MSBT_TRIGGER_RIME = {
				colorR			= 0,
				colorG			= 0.5,
				message			= SPELL_RIME .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "DEATHKNIGHT",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_FREEZING_FOG .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},

			MSBT_TRIGGER_SUDDEN_DEATH = {
				colorG			= 0,
				colorB			= 0,
				message			= SPELL_SUDDEN_DEATH .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "WARRIOR",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_SUDDEN_DEATH .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},

			MSBT_TRIGGER_TIDAL_WAVES = {
				colorR			= 0,
				colorG			= 0.5,
				message			= SPELL_TIDAL_WAVES .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "SHAMAN",
				mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_TIDAL_WAVES .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
			},

			MSBT_TRIGGER_VICTORY_RUSH = {
				colorG			= 0.25,
				colorB			= 0.25,
				message			= SPELL_VICTORY_RUSH .. "!",
				alwaysSticky	= true,
				fontSize		= 26,
				classes			= "WARRIOR",
				mainEvents		= "PARTY_KILL{sourceAffiliation;;eq;;" .. FLAG_YOU .. "}",
				exceptions		= "unavailableSkill;;eq;;" .. SPELL_VICTORY_RUSH .. ";;trivialTarget;;eq;;true;;recentlyFired;;lt;;2",
				iconSkill		= SPELLID_VICTORY_RUSH,
			},

		},

		normalFontName			= L.DEFAULT_FONT_NAME,
		normalOutlineIndex		= 1,
		normalFontSize			= 18,
		normalFontAlpha			= 100,
		critFontName			= L.DEFAULT_FONT_NAME,
		critOutlineIndex		= 1,
		critFontSize			= 26,
		critFontAlpha			= 100,

		animationSpeed			= 100,

		crushing		= { colorR = 0.5, colorG = 0, colorB = 0, trailer = string_gsub(CRUSHING_TRAILER, "%((.+)%)", "<%1>") },
		glancing		= { colorR = 1, colorG = 0, colorB = 0, trailer = string_gsub(GLANCING_TRAILER, "%((.+)%)", "<%1>") },
		absorb			= { colorR = 1, colorG = 1, colorB = 0, trailer = string_gsub(string_gsub(ABSORB_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
		block			= { colorR = 0.5, colorG = 0, colorB = 1, trailer = string_gsub(string_gsub(BLOCK_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
		resist			= { colorR = 0.5, colorG = 0, colorB = 0.5, trailer = string_gsub(string_gsub(RESIST_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
		overheal		= { colorR = 0, colorG = 0.705, colorB = 0.5, trailer = " <%a>" },
		overkill		= { disabled = true, colorR = 0.83, colorG = 0, colorB = 0.13, trailer = " <%a>" },

		physical		= { colorR = 1, colorG = 1, colorB = 1 },
		arcane			= { colorR = 0.956, colorG = 0.658, colorB = 0.894 },
		fire			= { colorR = 0.933, colorG = 0.490, colorB = 0.501 },
		frost			= { colorR = 0.462, colorG = 0.792, colorB = 0.929 },
		holy			= { colorR = 0.976, colorG = 0.945, colorB = 0.631 },
		nature			= { colorR = 0.631, colorG = 0.858, colorB = 0.396 },
		shadow			= { colorR = 0.356, colorG = 0.290, colorB = 0.596 },
		spellfire		= { colorR = 0.898, colorG = 0.360, colorB = 0.501 },
		spellfrost		= { colorR = 0.321, colorG = 0.321, colorB = 0.8 },
		divine			= { colorR = 0.956, colorG = 0.894, colorB = 0.572 },
		astral			= { colorR = 0.737, colorG = 0.411, colorB = 0.968 },
		spellshadow		= { colorR = 0.450, colorG = 0.215, colorB = 0.6 },
		radiant			= { colorR = 0.937, colorG = 0.690, colorB = 0.396 },
		holystorm		= { colorR = 0.752, colorG = 0.909, colorB = 0.545 },
		holyfrost		= { colorR = 0.545, colorG = 0.909, colorB = 0.874 },
		volcanic		= { colorR = 0.937, colorG = 0.545, colorB = 0.282 },
		shadowflame		= { colorR = 0.745, colorG = 0.333, colorB = 0.529 },
		frostfire		= { colorR = 0.262, colorG = 0.572, colorB = 0.666 },
		froststorm		= { colorR = 0.356, colorG = 0.698, colorB = 0.556 },
		shadowfrost		= { colorR = 0.2, colorG = 0.317, colorB = 0.607 },
		twilight		= { colorR = 0.631, colorG = 0.349, colorB = 0.698 },
		plague			= { colorR = 0.584, colorG = 0.8, colorB = 0.329 },
		spellstrike		= { colorR = 0.941, colorG = 0.866, colorB = 0.929 },
		flamestrike		= { colorR = 0.968, colorG = 0.764, colorB = 0.749 },
		froststrike		= { colorR = 0.678, colorG = 0.858, colorB = 0.890 },
		stormstrike		= { colorR = 0.698, colorG = 0.792, colorB = 0.8 },
		shadowstrike	= { colorR = 0.827, colorG = 0.8, colorB = 0.949 },
		holystrike		= { colorR = 0.968, colorG = 0.925, colorB = 0.796 },
		elemental		= { colorR = 0.337, colorG = 0.858, colorB = 0.682 },
		cosmic			= { colorR = 0.368, colorG = 0.627, colorB = 0.8 },
		chromatic		= { colorR = 0.573, colorG = 0.976, colorB = 0.098 },
		magic			= { colorR = 0.470, colorG = 0.937, colorB = 1 },
		chaos			= { colorR = 0.247, colorG = 0.152, colorB = 0.4 },

		DEATHKNIGHT		= CreateClassSettingsTable("DEATHKNIGHT"),
		DRUID			= CreateClassSettingsTable("DRUID"),
		HUNTER			= CreateClassSettingsTable("HUNTER"),
		MAGE			= CreateClassSettingsTable("MAGE"),
		MONK			= CreateClassSettingsTable("MONK"),
		PALADIN			= CreateClassSettingsTable("PALADIN"),
		PRIEST			= CreateClassSettingsTable("PRIEST"),
		ROGUE			= CreateClassSettingsTable("ROGUE"),
		SHAMAN			= CreateClassSettingsTable("SHAMAN"),
		WARLOCK			= CreateClassSettingsTable("WARLOCK"),
		WARRIOR			= CreateClassSettingsTable("WARRIOR"),
		DEMONHUNTER		= CreateClassSettingsTable("DEMONHUNTER"),
		EVOKER			= CreateClassSettingsTable("EVOKER"),

		dotThrottleDuration				= 3,
		hotThrottleDuration				= 3,
		powerThrottleDuration			= 3,
		throttleList = {

			[SPELL_DRAIN_LIFE]			= 3,
			[SPELL_SHADOWMEND]			= 5,

			[SPELL_VAMPIRIC_EMBRACE]	= 5,
			[SPELL_VAMPIRIC_TOUCH]		= 5,
		},

		mergeExclusions					= {},
		abilitySubstitutions			= {},
		abilitySuppressions				= {
			[SPELL_UNDYING_RESOLVE]		= true,
		},
		damageThreshold					= 0,
		healThreshold					= 0,
		powerThreshold					= 0,
		hideFullHoTOverheals			= true,
		shortenNumbers					= false,
		stackSimilarHits				= false,
		disableOutgoingInGroup			= false,
		disableIncomingInGroup			= false,
		disableNotificationInGroup		= false,
		disableStaticInGroup			= false,
		enableBlizzardV2CombatText		= false,
		enableBlizzardV2CombatTextInGroup = false,
		shortenNumberPrecision			= 0,
		groupNumbers					= false,

		cooldownExclusions = {},
		ignoreCooldownThreshold = {},
		cooldownThreshold = 5,
		qualityExclusions				= {
			[LE_ITEM_QUALITY_POOR or Enum.ItemQuality.Poor] = true,
		},
		alwaysShowQuestItems			= true,
		itemsAllowed					= {},
		itemExclusions					= {},
	}
end

local function ShowOptions()
	if (MSBTOptions and MSBTOptions.Main and MSBTOptions.Main.ShowMainFrame) then
		MSBTOptions.Main.ShowMainFrame()
		return
	end

	Print("MSBT options are unavailable. Ensure embedded options files are enabled in MikScrollingBattleText.toc.")
end

local function RemoveEmptyDifferentials(currentTable)

	for fieldName, fieldValue in pairs(currentTable) do
		if (type(fieldValue) == "table") then

			RemoveEmptyDifferentials(fieldValue)

			if (not next(fieldValue)) then
				differentialMap[fieldValue] = nil
				differentialCache[#differentialCache+1] = fieldValue
				currentTable[fieldName] = nil
			end
		end
	end
end

local function AssociateDifferentialTables(savedTable, masterTable)

	differentialMap[savedTable] = masterTable
	setmetatable(savedTable, differential_mt)

	for fieldName, fieldValue in pairs(savedTable) do
		if (type(fieldValue) == "table" and type(masterTable[fieldName]) == "table") then

			AssociateDifferentialTables(fieldValue, masterTable[fieldName])
		end
	end
end

local function SetOption(optionPath, optionName, optionValue, optionDefault)

	EraseTable(pathTable)

	if (optionPath) then SplitString(optionPath, "%.", pathTable) end

	local masterOption = masterProfile
	for _, fieldName in ipairs(pathTable) do
		masterOption = masterOption[fieldName]
		if (not masterOption) then break end
	end

	masterOption = masterOption and masterOption[optionName]

	local needsOverride = false
	if (optionValue ~= masterOption) then needsOverride = true end

	if ((optionValue == false or optionValue == optionDefault) and not masterOption) then
		needsOverride = false
	end

	if (optionValue == nil and masterOption) then optionValue = false end

	local currentTable = currentProfile
	local masterTable = masterProfile

	if (needsOverride and optionValue ~= nil) then

		for _, fieldName in ipairs(pathTable) do

			if (not rawget(currentTable, fieldName)) then

				currentTable[fieldName] = table.remove(differentialCache) or {}
				if (masterTable and masterTable[fieldName]) then
					differentialMap[currentTable[fieldName]] = masterTable[fieldName]
					setmetatable(currentTable[fieldName], differential_mt)
				end
			end

			currentTable = currentTable[fieldName]
			masterTable = masterTable and masterTable[fieldName]
		end

		currentTable[optionName] = optionValue

	else

		for _, fieldName in ipairs(pathTable) do
			currentTable = rawget(currentTable, fieldName)
			if (not currentTable) then return end
		end

		if (currentTable) then
			currentTable[optionName] = nil
			RemoveEmptyDifferentials(currentProfile)
		end
	end
end

local function SetupBlizzardOptions()

	local frame = CreateFrame("Frame")
	frame.name = "MikScrollingBattleText"

	local button = CreateFrame("Button", nil, frame, IsCataClassic and "OptionsButtonTemplate" or "UIPanelButtonTemplate")
	button:SetSize(100, 24)
	button:SetPoint("CENTER")
	button:SetText(MikSBT.COMMAND)
	button:SetScript("OnClick", function(this)
		ShowOptions()
	end)

	if Settings and Settings.RegisterCanvasLayoutCategory then
		local category = Settings.RegisterCanvasLayoutCategory(frame, frame.name)
		category.ID = frame.name
		Settings.RegisterAddOnCategory(category)
	else
		InterfaceOptions_AddCategory(frame)
	end
end

local function DisableBlizzardCombatText()
	if not IsClassic then
		SetCVar("floatingCombatTextCombatHealing", 0)
	end
	SetCVar("floatingCombatTextCombatDamage", 0)
	SetCVar("floatingCombatTextCombatHealing_v2", 0)
	SetCVar("floatingCombatTextCombatDamage_v2", 0)
	SetCVar("floatingCombatTextCombatLogPeriodicSpells_v2", 0)
	SetCVar("floatingCombatTextPetMeleeDamage_v2", 0)
	SetCVar("floatingCombatTextPetSpellDamage_v2", 0)
	SHOW_COMBAT_TEXT = "0"
	if (not Client.hasModernAPI and CombatText_UpdateDisplayedMessages) then CombatText_UpdateDisplayedMessages() end
end

local function SetBlizzardCombatTextV2Enabled(isEnabled)
	local value = isEnabled and 1 or 0
	if not IsClassic then
		SetCVar("floatingCombatTextCombatHealing", value)
	end
	SetCVar("floatingCombatTextCombatDamage", value)
	SetCVar("floatingCombatTextCombatHealing_v2", value)
	SetCVar("floatingCombatTextCombatDamage_v2", value)
	SetCVar("floatingCombatTextCombatLogPeriodicSpells_v2", value)
	SetCVar("floatingCombatTextPetMeleeDamage_v2", value)
	SetCVar("floatingCombatTextPetSpellDamage_v2", value)
	SHOW_COMBAT_TEXT = isEnabled and "1" or "0"
	if (not Client.hasModernAPI and CombatText_UpdateDisplayedMessages) then CombatText_UpdateDisplayedMessages() end
end

local function IsInGroupContext()
	return IsInGroup() or IsInRaid()
end

local function SetAddonEnabled(isEnabled)
	if isEnabled then
		MikSBT.Main.Enable()
		MikSBT.Parser.Enable()
		MikSBT.Triggers.Enable()
		MikSBT.Cooldowns.Enable()
	else
		MikSBT.Cooldowns.Disable()
		MikSBT.Triggers.Disable()
		MikSBT.Parser.Disable()
		MikSBT.Main.Disable()
	end
end

local function GetRuntimeController()
	if runtimeController then
		return runtimeController
	end

	runtimeController = MikSBT.Configuration.RuntimeController:New({
		isInGroup = IsInGroupContext,
		isAddonDisabled = function()
			return savedVariables and savedVariables.userDisabled
		end,
		getProfile = function()
			return currentProfile
		end,
		setAddonEnabled = SetAddonEnabled,
		setBlizzardEnabled = SetBlizzardCombatTextV2Enabled,
	})

	return runtimeController
end

local function ApplyBlizzardCombatTextOptions()
	GetRuntimeController():ApplyBlizzardState()
end

local function ResetOfficialBlizzardCombatText()
	if currentProfile then
		SetOption(nil, "enableBlizzardV2CombatText", false)
		SetOption(nil, "enableBlizzardV2CombatTextInGroup", false)
		SetOption(nil, "disableOutgoingInGroup", false)
		SetOption(nil, "disableIncomingInGroup", false)
		SetOption(nil, "disableNotificationInGroup", false)
		SetOption(nil, "disableStaticInGroup", false)
	end

	if savedVariables then
		savedVariables.userDisabled = true
	end

	SetCVar("floatingCombatTextCombatDamage_v2", 1)
	SetCVar("floatingCombatTextCombatLogPeriodicSpells_v2", 1)
	SetCVar("floatingCombatTextPetMeleeDamage_v2", 1)
	SetCVar("floatingCombatTextPetSpellDamage_v2", 1)

	if (not Client.hasModernAPI and CombatText_UpdateDisplayedMessages) then
		CombatText_UpdateDisplayedMessages()
	end

	module.ApplyContextOptions()
end

local function ApplyContextOptions()
	GetRuntimeController():Apply()
end

local function SetOptionUserDisabled(isDisabled)
	savedVariables.userDisabled = isDisabled or nil
	ApplyContextOptions()
end

local function IsModDisabled()
	return savedVariables and savedVariables.userDisabled
end

local function UpdateCustomClassColors()
	for class, colors in pairs(CUSTOM_CLASS_COLORS) do
		if (masterProfile[class]) then
			masterProfile[class].colorR = colors.r or masterProfile[class].colorR
			masterProfile[class].colorG = colors.g or masterProfile[class].colorG
			masterProfile[class].colorB = colors.b or masterProfile[class].colorB
		end
	end
end

local function LoadUsedFonts()

		local usedFonts = {}
		if currentProfile.normalFontName then usedFonts[currentProfile.normalFontName] = true end
		if currentProfile.critFontName then usedFonts[currentProfile.critFontName] = true end

		if currentProfile.scrollAreas then
			for saKey, saSettings in pairs(currentProfile.scrollAreas) do
				if saSettings.normalFontName then usedFonts[saSettings.normalFontName] = true end
				if saSettings.critFontName then usedFonts[saSettings.critFontName] = true end
			end
		end

		if currentProfile.events then
			for eventName, eventSettings in pairs(currentProfile.events) do
				if eventSettings.fontName then usedFonts[eventSettings.fontName] = true end
			end
		end

		if currentProfile.triggers then
			for triggerName, triggerSettings in pairs(currentProfile.triggers) do
				if type(triggerSettings) == "table" then
					if triggerSettings.fontName then usedFonts[triggerSettings.fontName] = true end
				end
			end
		end

		for fontName in pairs(usedFonts) do MikSBT.Animations.LoadFont(fontName) end
end

local function UpdateProfiles(profiles)

	for profileName, profile in pairs(profiles) do

		local creationVersion = tonumber(select(3, string_find(tostring(profile.creationVersion), "(%d+%.%d+)")))

		if (creationVersion < 5.2) then
			profile.triggers = nil
			profile.creationVersion = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION
		end
	end
end

local function SelectProfile(profileName)

	if (savedVariables.profiles[profileName]) then

		savedVariablesPerChar.currentProfileName = profileName

		currentProfile = savedVariables.profiles[profileName]
		module.currentProfile = currentProfile

		EraseTable(differentialMap)

		AssociateDifferentialTables(currentProfile, masterProfile)

		LoadUsedFonts()

		MikSBT.Animations.UpdateScrollAreas()
		MikSBT.Triggers.UpdateTriggers()
		if savedVariables then
			ApplyContextOptions()
		end
	end
end

local function CopyProfile(srcProfileName, destProfileName)

	if (not destProfileName or destProfileName == "") then return end

	if (savedVariables.profiles[srcProfileName] and not savedVariables.profiles[destProfileName]) then

		savedVariables.profiles[destProfileName] = CopyTable(savedVariables.profiles[srcProfileName])
	end
end

local function DeleteProfile(profileName)

	if (profileName == DEFAULT_PROFILE_NAME) then return end

	if (savedVariables.profiles[profileName]) then

		if (profileName == savedVariablesPerChar.currentProfileName) then

			SelectProfile(DEFAULT_PROFILE_NAME)
		end

		savedVariables.profiles[profileName] = nil
	end
end

local function ResetProfile(profileName, showOutput)

	if (not profileName) then profileName = savedVariablesPerChar.currentProfileName end

	if (savedVariables.profiles[profileName]) then

		EraseTable(savedVariables.profiles[profileName])

		savedVariables.profiles[profileName].creationVersion = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION

		if (profileName == savedVariablesPerChar.currentProfileName) then

			SelectProfile(profileName)
		end

		if (showOutput) then

			Print(profileName .. " " .. L.MSG_PROFILE_RESET, 0, 1, 0)
		end
	end
end

local function GetProfileTransfer()
	return MikSBT.Configuration.ProfileTransfer:New({
		masterProfile = masterProfile,
		version = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION,
		client = Client.interfaceVersion,
		locale = GetLocale(),
	})
end

local function ExportProfile(profileName)
	local profile = savedVariables.profiles[profileName]
	if not profile then return nil, "INVALID_NAME" end
	return GetProfileTransfer():Export(profileName, profile, {
		fonts = MikSBT.Media.fonts,
		sounds = MikSBT.Media.sounds,
	})
end

local function ImportProfile(text, profileName)
	if InCombatLockdown() then return nil, "IN_COMBAT" end
	local name, details = GetProfileTransfer():Import(
		text, profileName, savedVariables.profiles, savedMedia)
	if not name then return nil, details end
	MikSBT.Media.OnVariablesInitialized()
	SelectProfile(name)
	return name, details
end

local function InitSavedVariables()
	local store = MikSBT.Configuration.ProfileStore:New({
		globals = _G,
		version = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION,
		defaultProfileName = DEFAULT_PROFILE_NAME,
		migrateProfiles = function(profiles)
			UpdateProfiles(profiles)
		end,
	})
	local state = store:Initialize()

	savedVariables = state.savedVariables
	savedVariablesPerChar = state.savedVariablesPerChar
	savedMedia = state.savedMedia
	isFirstLoad = state.isFirstLoad

	SelectProfile(state.currentProfileName)

	module.savedVariables = savedVariables
	module.savedMedia = savedMedia
end

local function GetNextParameter(paramString)
	local remainingParams
	local currentParam = paramString

	local index = string_find(paramString, " ", 1, true)
	if (index) then

		currentParam = string.sub(paramString, 1, index-1)
		remainingParams = string.sub(paramString, index+1)
	end

	return currentParam, remainingParams
end

local function CommandHandler(params)

	local currentParam, remainingParams
	currentParam, remainingParams = GetNextParameter(params)

	local showUsage = true

	if (currentParam) then currentParam = string.lower(currentParam) end

	if (currentParam == "") then

		ShowOptions()

		showUsage = false

		elseif (currentParam == L.COMMAND_RESET) then

		ResetProfile(nil, true)

		showUsage = false

	elseif (currentParam == L.COMMAND_DISABLE) then

		SetOptionUserDisabled(true)

		Print(L.MSG_DISABLE, 1, 1, 1)

		showUsage = false

	elseif (currentParam == L.COMMAND_ENABLE) then

		SetOptionUserDisabled(false)

		Print(L.MSG_ENABLE, 1, 1, 1)

		showUsage = false

	elseif (currentParam == L.COMMAND_SHOWVER) then

		Print(MikSBT.VERSION_STRING, 1, 1, 1)

		showUsage = false

	end

	if (showUsage) then

		for _, msg in ipairs(L.COMMAND_USAGE) do
			Print(msg, 1, 1, 1)
		end
	end
end

local function OnEvent(this, event, arg1)
	if (event == "ADDON_LOADED") then

		if (arg1 ~= "MikScrollingBattleText") then return end

		this:UnregisterEvent("ADDON_LOADED")

		SLASH_MSBT1 = MikSBT.COMMAND
		SlashCmdList["MSBT"] = CommandHandler

		InitSavedVariables()

		SetupBlizzardOptions()

		MikSBT.Media.OnVariablesInitialized()

	elseif (event == "VARIABLES_LOADED") then
		SetOptionUserDisabled(IsModDisabled())

		if (isFirstLoad) then DisableBlizzardCombatText() end
		ApplyBlizzardCombatTextOptions()

		if (CUSTOM_CLASS_COLORS) then
			UpdateCustomClassColors()
			if (CUSTOM_CLASS_COLORS.RegisterCallback) then CUSTOM_CLASS_COLORS:RegisterCallback(UpdateCustomClassColors) end
		end
		collectgarbage("collect")
	elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" or event == "GROUP_ROSTER_UPDATE" then
		ApplyContextOptions()
	end
end

eventFrame = CreateFrame("Frame", "MSBTProfileFrame", UIParent)
eventFrame:SetPoint("BOTTOM")
eventFrame:SetWidth(0.0001)
eventFrame:SetHeight(0.0001)
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

module.masterProfile = masterProfile

module.CopyProfile					= CopyProfile
module.DeleteProfile				= DeleteProfile
module.ResetProfile					= ResetProfile
module.SelectProfile				= SelectProfile
module.ExportProfile				= ExportProfile
module.ImportProfile				= ImportProfile
module.SetOption					= SetOption
module.SetOptionUserDisabled		= SetOptionUserDisabled
module.IsModDisabled				= IsModDisabled
module.ApplyContextOptions			= ApplyContextOptions
module.ResetOfficialBlizzardCombatText = ResetOfficialBlizzardCombatText

