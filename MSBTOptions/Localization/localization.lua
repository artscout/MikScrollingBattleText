
MSBTOptions = {}

local L = MikSBT.translations



L.TABS = {}
L.CHECKBOXES = {}
L.DROPDOWNS = {}
L.BUTTONS = {}
L.EDITBOXES = {}
L.SLIDERS = {}
L.EVENT_CATEGORIES = {}
L.EVENT_CODES = {}
L.INCOMING_PLAYER_EVENTS = {}
L.INCOMING_PET_EVENTS = {}
L.OUTGOING_PLAYER_EVENTS = {}
L.OUTGOING_PET_EVENTS = {}
L.NOTIFICATION_EVENTS = {}
L.OUTLINES = {}
L.TEXT_ALIGNS = {}
L.ANIMATION_STYLE_DATA = {}




L.MSG_NEW_PROFILE					= "New Profile"
L.MSG_PROFILE_ALREADY_EXISTS		= "Profile already exists."
L.MSG_INVALID_PROFILE_NAME			= "Invalid profile name."
L.MSG_NEW_SCROLL_AREA				= "New Scroll Area"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Scroll area name already exists."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Invalid scroll area name."
L.MSG_ACKNOWLEDGE_TEXT				= "Are you sure you wish to perform this action?"
L.POPUP_CONFIRM_TITLE = "Confirm Action"
L.MSG_NORMAL_PREVIEW_TEXT			= "Normal"
L.MSG_DISPLAY_QUALITY				= "Display alerts for items of this quality."
L.MSG_ITEM_QUALITIES				= "Item qualities"
L.MSG_ITEMS							= "Items"
L.MSG_ITEM_ALREADY_EXISTS			= "Item name already exists."
L.MSG_INVALID_ITEM_NAME				= "Invalid item name."

L.PROFILE_TRANSFER = {
	exportTitle = "Export Profile", importTitle = "Import Profile",
	export = "Export", import = "Import", close = "Close",
	selectAll = "Select All", name = "2. Name your new profile",
	copy = "Copy (Ctrl+C)",
	exportLabel = "Profile string", importLabel = "1. Paste profile string",
	importAction = "Import Profile",
	pasteHint = "Click here and press Ctrl+V to paste your profile string.",
	exportHelp = "Press Ctrl+C to copy the selected profile string.",
	importHelp = "Paste a profile string, then give it a new name.\n" ..
		"Importing creates and selects the new profile.",
	mediaNote = "Custom font and sound files must be installed separately. " ..
		"Settings and spells may differ between game versions or languages.",
	imported = "Profile imported: %s",
	compatibility = "This profile came from a different game version or " ..
		"language. Check spell settings, triggers, fonts, and sounds.",
	errors = {
		INVALID_NAME = "Enter a profile name (1-64 characters).",
		PROFILE_EXISTS = "That profile already exists. Choose a new name.",
		INVALID_TEXT = "Invalid or damaged profile string. Copy the full export.",
		INVALID_DATA = "The profile contains invalid or unsupported settings.",
		TOO_LARGE = "The profile exceeds the supported transfer size.",
		IN_COMBAT = "Wait until combat ends before importing a profile.",
	},
}



obj = L.TABS
obj["profile"]		= { label="Profile", tooltip="Display options for profile management and profile switching."}
obj["general"]		= { label="General", tooltip="Display general options."}
obj["scrollAreas"]	= { label="Scroll Areas", tooltip="Display options for creating, deleting, and configuring scroll areas.\n\nMouse over the icon buttons for more information."}
obj["events"]		= { label="Events", tooltip="Display options for incoming, outgoing, and notification events.\n\nMouse over the icon buttons for more information."}
obj["lootAlerts"]	= { label="Loot Alerts", tooltip="Display options for loot related notifications."}
obj["language"]		= { label="Language", tooltip="Shows the current game locale and how language selection works for MSBT."}
obj["resetBlizzardSCT"] = { label="Reset Blizzard SCT", tooltip="Restore Blizzard scrolling combat text CVars and clear MSBT Blizzard CT overrides."}



obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Enable Mik's Scrolling Battle Text", tooltip="Enable MSBT."}
obj["disableOutgoingInGroup"]	= { label="Disable Outgoing In Group", tooltip="While in a party or raid, hide events assigned to the Outgoing scroll area."}
obj["disableIncomingInGroup"]	= { label="Disable Incoming In Group", tooltip="While in a party or raid, hide events assigned to the Incoming scroll area."}
obj["disableNotificationInGroup"]= { label="Disable Notification In Group", tooltip="While in a party or raid, hide events assigned to the Notification scroll area."}
obj["disableStaticInGroup"]		= { label="Disable Static In Group", tooltip="While in a party or raid, hide events assigned to the Static scroll area."}
obj["enableBlizzardV2CombatText"]= { label="Disable Blizzard CT While Solo", tooltip="When checked, disables Blizzard floating combat text damage/healing while solo." }
obj["enableBlizzardV2InGroup"]	= { label="Enable Blizzard CT In Group", tooltip="Enable Blizzard Combat Text only while in a party or raid. This overrides Disable Blizzard CT While Solo while grouped." }
obj["stickyCrits"]				= { label="Sticky Crits", tooltip="Display crits using the sticky style."}
obj["colorPartialEffects"]		= { label="Color Partial Effects", tooltip="Apply specified colors to partial effects."}
obj["crushing"]					= { label="Crushing Blows", tooltip="Display the crushing blows trailer."}
obj["glancing"]					= { label="Glancing Hits", tooltip="Display the glancing hits trailer."}
obj["absorb"]					= { label="Partial Absorbs", tooltip="Display partial absorb amounts."}
obj["block"]					= { label="Partial Blocks", tooltip="Display partial block amounts."}
obj["resist"]					= { label="Partial Resists", tooltip="Display partial resist amounts."}
obj["vulnerability"]			= { label="Vulnerability Bonuses", tooltip="Display vulnerabliity bonus amounts."}
obj["overheal"]					= { label="Overheals", tooltip="Display overhealing amounts."}
obj["overkill"]					= { label="Overkills", tooltip="Display overkill amounts."}
obj["colorDamageAmounts"]		= { label="Color Damage Amounts", tooltip="Apply specified colors to damage amounts."}
obj["colorDamageEntry"]			= { tooltip="Enable coloring for this damage type."}
obj["colorUnitNames"]			= { label="Color Unit Names", tooltip="Apply specified class colors to unit names."}
obj["colorClassEntry"]			= { tooltip="Enable coloring for this class."}
obj["enableScrollArea"]			= { tooltip="Enable the scroll area."}
obj["inheritField"]				= { label="Inherit", tooltip="Inherit the field's value. Uncheck to override."}
obj["hideSkillIcons"]			= { label="Hide Icons", tooltip="Do not show icons in this scroll area."}
obj["stickyEvent"]				= { label="Always Sticky", tooltip="Always display the event using the sticky style."}
obj["enableTrigger"]			= { tooltip="Enable the trigger."}
obj["allPowerGains"]			= { label="ALL Power Gains", tooltip="Display all power gains including those that are not reported to the combat log.\n\nWARNING: This option is very spammy and will ignore the power threshold and throttling mechanics.\n\nNOT RECOMMENDED."}
obj["abbreviateSkills"]			= { label="Abbreviate Skills", tooltip="Abbreviates skill names (English only).\n\nThis can be overriden by each event with the %sl event code."}
obj["mergeSwings"]				= { label="Merge Swings", tooltip="Merge regular melee swings that hit within a short time span."}
obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
obj["stackSimilarHits"]			= { label="Stack Similar Hits", tooltip="For repeated hits from the same ability in a short window, append hit/crit counts (example: 3 hits, 1 crit). Single hits stay as amount only."}
obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="Hide Skills", tooltip="Don't display skill names for incoming and outgoing events.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %s event code to be ignored."}
obj["hideNames"]				= { label="Hide Names", tooltip="Don't display unit names for incoming and outgoing events.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %n event code to be ignored."}
obj["hideFullOverheals"]		= { label="Hide Full Overheals", tooltip="Don't display non periodic heals that have an effective heal amount of zero."}
obj["hideFullHoTOverheals"]		= { label="Hide Full HoT Overheals", tooltip="Don't display heals over time that have an effective heal amount of zero."}
obj["hideMergeTrailer"]			= { label="Hide Merge Trailer", tooltip="Don't display the trailer that specifies the number of hits and crits at the end of merged events."}
obj["lootedItems"]				= { label="Looted Items", tooltip="Display notifications when items are looted."}
obj["moneyGains"]				= { label="Money Gains", tooltip="Enable money you gain."}
obj["currencyGains"]			= { label="Currency Gains", tooltip="Display notifications for gained currency."}
obj["alwaysShowQuestItems"]		= { label="Always show quest items", tooltip="Always show quest items regardless of quality selections."}
obj["enableIcons"]				= { label="Enable Skill Icons", tooltip="Displays icons for events that have a skill when possible."}



obj = L.DROPDOWNS
obj["profile"]				= { label="Current Profile:", tooltip="Sets the current profile."}
obj["normalFont"]			= { label="Normal Font:", tooltip="Sets the font that will be used for non-crits."}
obj["critFont"]				= { label="Crit Font:", tooltip="Sets the font that will be used for crits."}
obj["normalOutline"]		= { label="Normal Outline:", tooltip="Sets the outline style that will be used for non-crits."}
obj["critOutline"]			= { label="Crit Outline:", tooltip="Sets the outline style that will be used for crits."}
obj["scrollArea"]			= { label="Scroll Area:", tooltip="Selects the scroll area to configure."}
obj["animationStyle"]		= { label="Animation Style:", tooltip="The animation style for non-sticky animations in the scroll area."}
obj["stickyAnimationStyle"]	= { label="Sticky Style:", tooltip="The animation style for sticky animations in the scroll area."}
obj["direction"]			= { label="Direction:", tooltip="The direction of the animation."}
obj["behavior"]				= { label="Behavior:", tooltip="The behavior of the animation."}
obj["textAlign"]			= { label="Text Align:", tooltip="The alignment of the text for the animation."}
obj["iconAlign"]			= { label="Icon Align:", tooltip="The alignment of skill icons relative to the text."}
obj["eventCategory"]		= { label="Event Category:", tooltip="The category of events to configure."}
obj["outputScrollArea"]		= { label="Output Scroll Area:", tooltip="Selects the scroll area to use for output."}



obj = L.BUTTONS
obj["copyProfile"]				= { label="Copy Profile", tooltip="Copies the profile to a new profile with the name you specify."}
obj["resetProfile"]				= { label="Reset Profile", tooltip="Resets the profile to the default settings."}
obj["deleteProfile"]			= { label="Delete Profile", tooltip="Deletes the profile."}
obj["resetBlizzardSCT"]		= { label="Reset Blizzard SCT", tooltip="Restore Blizzard scrolling combat text settings and stop MSBT from overriding them."}
obj["masterFont"]				= { label="Master Fonts", tooltip="Allows you to setup the master font settings which will be inherited by all scroll areas and events within them, unless overridden."}
obj["partialEffects"]			= { label="Partial Effects", tooltip="Allows you to setup which partial effects will be shown, if they are color coded, and in what color."}
obj["damageColors"]				= { label="Damage Colors", tooltip="Allows you to setup whether or not amounts are color coded by damage type and what colors to use for each type."}
obj["classColors"]				= { label="Class Colors", tooltip="Allows you to setup whether or not unit names are color coded by their class and what colors to use for each class." }
obj["inputOkay"]				= { label=OKAY, tooltip="Accepts the input."}
obj["inputCancel"]				= { label=CANCEL, tooltip="Cancels the input."}
obj["genericSave"]				= { label=SAVE, tooltip="Saves the changes."}
obj["genericCancel"]			= { label=CANCEL, tooltip="Cancels the changes."}
obj["addScrollArea"]			= { label="Add Scroll Area", tooltip="Add a new scroll area the events and triggers can be assigned to."}
obj["configScrollAreas"]		= { label="Configure Scroll Areas", tooltip="Configure the normal and sticky animation styles, text alignment, scroll width/height, and location of the scroll areas."}
obj["editScrollAreaName"]		= { tooltip="Click to edit the name of the scroll area."}
obj["scrollAreaFontSettings"]	= { tooltip="Click to edit the font settings for the scroll area which will be inherited by all events shown in the scroll area, unless overriden."}
obj["deleteScrollArea"]			= { tooltip="Click to delete the scroll area."}
obj["scrollAreasPreview"]		= { label="Preview", tooltip="Previews the changes."}
obj["toggleAll"]				= { label="Toggle All", tooltip="Toggle the enable state of all events in the selected category."}
obj["moveAll"]					= { label="Move All", tooltip="Moves all of the events in the selected category to the specified scroll area."}
obj["eventFontSettings"]		= { tooltip="Click to edit the font settings for the event."}
obj["eventSettings"]			= { tooltip="Click to edit the event settings such as the output scroll area, output message, sound, etc."}
obj["itemsAllowed"]				= { label="Items Allowed", tooltip="Always show specified items regardless of item quality."}
obj["itemExclusions"]			= { label="Item Exclusions", tooltip="Prevent specified items from being displayed."}
obj["addItem"]					= { label="Add Item", tooltip="Add a new item to the list."}
obj["deleteItem"]				= { tooltip="Click to delete the item."}



obj = L.EDITBOXES
obj["copyProfile"]		= { label="New profile name:", tooltip="Name of the new profile to copy the currently selected one to."}
obj["partialEffect"]	= { tooltip="The trailer that will be appended when the partial effect occurs."}
obj["scrollAreaName"]	= { label="New scroll area name:", tooltip="New name for the scroll area."}
obj["xOffset"]			= { label="X Offset:", tooltip="The X offset of the selected scroll area."}
obj["yOffset"]			= { label="Y Offset:", tooltip="The Y offset of the selected scroll area."}
obj["eventMessage"]		= { label="Output message:", tooltip="The message that will be displayed when the event occurs."}
obj["iconSkill"]		= { label="Icon Skill:", tooltip="The name or spell ID of a skill whose icon will be displayed when the event occurs.\n\nMSBT will automatically try to figure out an appropriate icon if one is not specified.\n\nNOTE: A spell ID must be used in place of a name if the skill is not in the spellbook for the class that is playing when the event occurs. Most online databases such as wowhead can be used to discover it."}
obj["itemName"]			= { label="Item name:", tooltip="The name of the item to add."}



obj = L.SLIDERS
obj["animationSpeed"]		= { label="Animation Speed", tooltip="Sets the master animation speed.\n\nEach scroll area may also be configured to have its own independent speed."}
obj["normalFontSize"]		= { label="Normal Size", tooltip="Sets the font size for non-crits."}
obj["normalFontOpacity"]	= { label="Normal Opacity", tooltip="Sets the font opacity for non-crits."}
obj["critFontSize"]			= { label="Crit Font Size", tooltip="Sets the font size for crits."}
obj["critFontOpacity"]		= { label="Crit Opacity", tooltip="Sets the font opacity for crits."}
obj["scrollHeight"]			= { label="Scroll Height", tooltip="The height of the scroll area."}
obj["scrollWidth"]			= { label="Scroll Width", tooltip="The width of the scroll area."}
obj["scrollAnimationSpeed"]	= { label="Animation Speed", tooltip="Sets the animation speed for the scroll area."}
obj["powerThreshold"]		= { label="Power Threshold", tooltip="The threshold that power gains must exceed to be displayed."}
obj["healThreshold"]		= { label="Heal Threshold", tooltip="The threshold that heals must exceed to be displayed."}
obj["damageThreshold"]		= { label="Damage Threshold", tooltip="The threshold that damage must exceed to be displayed."}
obj["dotThrottleTime"]		= { label="DoT Throttle Time", tooltip="The number of seconds to throttle DoTs."}
obj["hotThrottleTime"]		= { label="HoT Throttle Time", tooltip="The number of seconds to throttle HoTs."}
obj["powerThrottleTime"]	= { label="Power Throttle Time", tooltip="The number of seconds to throttle power changes."}


obj = L.EVENT_CATEGORIES
obj[1] = "Incoming Player"
obj[2] = "Incoming Pet"
obj[3] = "Outgoing Player"
obj[4] = "Outgoing Pet"
obj[5] = "Notification"



obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Amount of damage taken.\n"
obj["HEALING_TAKEN"]		= "%a - Amount of healing taken.\n"
obj["DAMAGE_DONE"]			= "%a - Amount of damage done.\n"
obj["HEALING_DONE"]			= "%a - Amount of healing done.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Amount of damage absorbed.\n"
obj["AURA_AMOUNT"]			= "%a - Amount of stacks for the aura.\n"
obj["ENERGY_AMOUNT"]		= "%a - Amount of energy.\n"
obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["AC_AMOUNT"]			= "%a - Amount of arcane power you have.\n"
obj["CP_AMOUNT"]			= "%a - Amount of combo points you have.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Amount of holy power you have.\n"
obj["ESSENCE_AMOUNT"]		= "%a - Amount of essence you have.\n"
obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - Amount of honor.\n"
obj["REP_AMOUNT"]			= "%a - Amount of reputation.\n"
obj["ITEM_AMOUNT"]			= "%a - Amount of the item looted.\n"
obj["SKILL_AMOUNT"]			= "%a - Amount of points you have in the skill.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Amount of experience you gained.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Amount of the partial effect.\n"
obj["ATTACKER_NAME"]		= "%n - Name of the attacker.\n"
obj["HEALER_NAME"]			= "%n - Name of the healer.\n"
obj["ATTACKED_NAME"]		= "%n - Name of the attacked unit.\n"
obj["HEALED_NAME"]			= "%n - Name of the healed unit.\n"
obj["BUFFED_NAME"]			= "%n - Name of the buffed unit.\n"
obj["UNIT_KILLED"]			= "%n - Name of the unit killed.\n"
obj["SKILL_NAME"]			= "%s - Name of the skill.\n"
obj["SPELL_NAME"]			= "%s - Name of the spell.\n"
obj["DEBUFF_NAME"]			= "%s - Name of the debuff.\n"
obj["BUFF_NAME"]			= "%s - Name of the buff.\n"
obj["ITEM_BUFF_NAME"]		= "%s - Name of the item buff.\n"
obj["ITEM_COOLDOWN_NAME"] = "%e - Name of the item whose cooldown is ready.\n"
obj["EXTRA_ATTACKS"]		= "%s - Name of skill granting the extra attacks.\n"
obj["SKILL_LONG"]			= "%sl - Long form of %s. Used to override abbreviation for the event.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Type of damage taken.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Type of damage done.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Name of the source of the damage (falling, drowning, lava, etc...)\n"
obj["FACTION_NAME"]			= "%e - Name of the faction.\n"
obj["EMOTE_TEXT"]			= "%e - The text of the emote.\n"
obj["MONEY_TEXT"]			= "%e - The money gained text.\n"
obj["ITEM_NAME"]			= "%e - The name of the looted item.\n"
obj["POWER_TYPE"]			= "%p - Type of power (energy, rage, mana).\n"
obj["TOTAL_ITEMS"]			= "%t - Total number of the looted item in inventory."



obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Melee Hits", tooltip="Enable incoming melee hits."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Melee Crits", tooltip="Enable incoming melee crits."}
obj["INCOMING_MISS"]						= { label="Melee Misses", tooltip="Enable incoming melee misses."}
obj["INCOMING_DODGE"]						= { label="Melee Dodges", tooltip="Enable incoming melee dodges."}
obj["INCOMING_PARRY"]						= { label="Melee Parries", tooltip="Enable incoming melee parries."}
obj["INCOMING_BLOCK"]						= { label="Melee Blocks", tooltip="Enable incoming melee blocks."}
obj["INCOMING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable incoming melee deflects."}
obj["INCOMING_ABSORB"]						= { label="Melee Absorbs", tooltip="Enable absorbed incoming melee damage."}
obj["INCOMING_IMMUNE"]						= { label="Melee Immunes", tooltip="Enable incoming melee damage you are immune to."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Skill Hits", tooltip="Enable incoming skill hits."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Skill Crits", tooltip="Enable incoming skill crits."}
obj["INCOMING_SPELL_DOT"]					= { label="Skill DoTs", tooltip="Enable incoming skill damage over time."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Skill DoT Crits", tooltip="Enable incoming skill damage over time crits."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Damage Shield Hits", tooltip="Enable incoming damage done by damage shields."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Damage Shield Crits", tooltip="Enable incoming crits done by damage shields."}
obj["INCOMING_SPELL_MISS"]					= { label="Skill Misses", tooltip="Enable incoming skill misses."}
obj["INCOMING_SPELL_DODGE"]					= { label="Skill Dodges", tooltip="Enable incoming skill dodges."}
obj["INCOMING_SPELL_PARRY"]					= { label="Skill Parries", tooltip="Enable incoming skill parries."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Skill Blocks", tooltip="Enable incoming skill blocks."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable incoming skill deflects."}
obj["INCOMING_SPELL_RESIST"]				= { label="Spell Resists", tooltip="Enable incoming spell resists."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Skill Absorbs", tooltip="Enable absorbed damage from incoming skills."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Skill Immunes", tooltip="Enable incoming skill damage you are immune to."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Skill Reflects", tooltip="Enable incoming skill damage you reflected."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Spell Interrupts", tooltip="Enable incoming spell interrupts."}
obj["INCOMING_HEAL"]						= { label="Incoming Heals", tooltip="Enable incoming heals from other players."}
obj["INCOMING_HEAL_CRIT"]					= { label="Incoming Crit Heals", tooltip="Enable incoming crit heals from other players."}
obj["INCOMING_HOT"]							= { label="Incoming Heals Over Time", tooltip="Enable incoming heals over time from other players."}
obj["INCOMING_HOT_CRIT"]					= { label="Incoming Crit Heals Over Time", tooltip="Enable incoming crit heals over time from other players."}
obj["SELF_HEAL"]							= { label="Self Heals", tooltip="Enable self heals."}
obj["SELF_HEAL_CRIT"]						= { label="Self Crit Heals", tooltip="Enable self crit heals."}
obj["SELF_HOT"]								= { label="Self Heals Over Time", tooltip="Enable self heals over time."}
obj["SELF_HOT_CRIT"]						= { label="Self Crit Heals Over Time", tooltip="Enable self crit heals over time."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Environmental Damage", tooltip="Enable environmental (falling, drowning, lava, etc...) damage."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Melee Hits", tooltip="Enable your pet's incoming melee hits."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Melee Crits", tooltip="Enable your pet's incoming melee crits."}
obj["PET_INCOMING_MISS"]						= { label="Melee Misses", tooltip="Enable your pet's incoming melee misses."}
obj["PET_INCOMING_DODGE"]						= { label="Melee Dodges", tooltip="Enable your pet's incoming melee dodges."}
obj["PET_INCOMING_PARRY"]						= { label="Melee Parries", tooltip="Enable your pet's incoming melee parries."}
obj["PET_INCOMING_BLOCK"]						= { label="Melee Blocks", tooltip="Enable your pet's incoming melee blocks."}
obj["PET_INCOMING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable your pet's incoming melee deflects."}
obj["PET_INCOMING_ABSORB"]						= { label="Melee Absorbs", tooltip="Enable your pet's absorbed incoming melee damage."}
obj["PET_INCOMING_IMMUNE"]						= { label="Melee Immunes", tooltip="Enable melee damage your is pet immune to."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Skill Hits", tooltip="Enable your pet's incoming skill hits."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Skill Crits", tooltip="Enable your pet's incoming skill crits."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="Skill DoTs", tooltip="Enable your pet's incoming skill damage over time."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Skill DoT Crits", tooltip="Enable your pet's incoming skill damage over time crits."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Damage Shield Hits", tooltip="Enable incoming damage done to your pet by damage shields."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Damage Shield Crits", tooltip="Enable incoming crits done to your pet by damage shields."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Skill Misses", tooltip="Enable your pet's incoming skill misses."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Skill Dodges", tooltip="Enable your pet's incoming skill dodges."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Skill Parries", tooltip="Enable your pet's incoming skill parries."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Skill Blocks", tooltip="Enable your pet's incoming skill blocks."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable your pet's incoming skill deflects."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Spell Resists", tooltip="Enable your pet's incoming spell resists."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Skill Absorbs", tooltip="Enable absorbed damage from your pet's incoming skills."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Skill Immunes", tooltip="Enable incoming skill damage your pet is immune to."}
obj["PET_INCOMING_HEAL"]						= { label="Heals", tooltip="Enable your pet's incoming heals."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Crit Heals", tooltip="Enable your pet's incoming crit heals."}
obj["PET_INCOMING_HOT"]							= { label="Heals Over Time", tooltip="Enable your pet's incoming heals over time."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable your pet's incoming crit heals over time."}



obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Melee Hits", tooltip="Enable outgoing melee hits."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Melee Crits", tooltip="Enable outgoing melee crits."}
obj["OUTGOING_MISS"]						= { label="Melee Misses", tooltip="Enable outgoing melee misses."}
obj["OUTGOING_DODGE"]						= { label="Melee Dodges", tooltip="Enable outgoing melee dodges."}
obj["OUTGOING_PARRY"]						= { label="Melee Parries", tooltip="Enable outgoing melee parries."}
obj["OUTGOING_BLOCK"]						= { label="Melee Blocks", tooltip="Enable outgoing melee blocks."}
obj["OUTGOING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable outgoing melee deflects."}
obj["OUTGOING_ABSORB"]						= { label="Melee Absorbs", tooltip="Enable absorbed outgoing melee damage."}
obj["OUTGOING_IMMUNE"]						= { label="Melee Immunes", tooltip="Enable outgoing melee damage the enemy is immune to."}
obj["OUTGOING_EVADE"]						= { label="Melee Evades", tooltip="Enable outgoing melee evades."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Skill Hits", tooltip="Enable outgoing skill hits."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Skill Crits", tooltip="Enable outgoing skill crits."}
obj["OUTGOING_SPELL_DOT"]					= { label="Skill DoTs", tooltip="Enable outgoing skill damage over time."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Skill DoT Crits", tooltip="Enable outgoing skill damage over time crits."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Damage Shield Hits", tooltip="Enable outgoing damage done by damage shields."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Damage Shield Crits", tooltip="Enable outgoing crits done by damage shields."}
obj["OUTGOING_SPELL_MISS"]					= { label="Skill Misses", tooltip="Enable outgoing skill misses."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Skill Dodges", tooltip="Enable outgoing skill dodges."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Skill Parries", tooltip="Enable outgoing skill parries."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Skill Blocks", tooltip="Enable outgoing skill blocks."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable outgoing skill deflects."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Spell Resists", tooltip="Enable outgoing spell resists."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Skill Absorbs", tooltip="Enable absorbed damage from outgoing skills."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Skill Immunes", tooltip="Enable outgoing skill damage the enemy is immune to."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Skill Reflects", tooltip="Enable outgoing skill damage reflected back to you."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Spell Interrupts", tooltip="Enable outgoing spell interrupts."}
obj["OUTGOING_SPELL_EVADE"]					= { label="Skill Evades", tooltip="Enable outgoing skill evades."}
obj["OUTGOING_HEAL"]						= { label="Heals", tooltip="Enable outgoing heals."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Crit Heals", tooltip="Enable outgoing crit heals."}
obj["OUTGOING_HOT"]							= { label="Heals Over Time", tooltip="Enable outgoing heals over time."}
obj["OUTGOING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable outgoing crit heals over time."}
obj["OUTGOING_DISPEL"]						= { label="Dispels", tooltip="Enable outgoing dispels."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Melee Hits", tooltip="Enable your pet's outgoing melee hits."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Melee Crits", tooltip="Enable your pet's outgoing melee crits."}
obj["PET_OUTGOING_MISS"]						= { label="Melee Misses", tooltip="Enable your pet's outgoing melee misses."}
obj["PET_OUTGOING_DODGE"]						= { label="Melee Dodges", tooltip="Enable your pet's outgoing melee dodges."}
obj["PET_OUTGOING_PARRY"]						= { label="Melee Parries", tooltip="Enable your pet's outgoing melee parries."}
obj["PET_OUTGOING_BLOCK"]						= { label="Melee Blocks", tooltip="Enable your pet's outgoing melee blocks."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable your pet's outgoing melee deflects."}
obj["PET_OUTGOING_ABSORB"]						= { label="Melee Absorbs", tooltip="Enable your pet's absorbed outgoing melee damage."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Melee Immunes", tooltip="Enable your pet's outgoing melee damage the enemy is immune to."}
obj["PET_OUTGOING_EVADE"]						= { label="Melee Evades", tooltip="Enable your pet's outgoing melee evades."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Skill Hits", tooltip="Enable your pet's outgoing skill hits."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Skill Crits", tooltip="Enable your pet's outgoing skill crits."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="Skill DoTs", tooltip="Enable outgoing skill damage over time."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Skill DoT Crits", tooltip="Enable outgoing skill damage over time crits."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Damage Shield Hits", tooltip="Enable outgoing damage done by your pet's damage shields."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Damage Shield Crits", tooltip="Enable outgoing crits done by your pet's damage shields."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Skill Misses", tooltip="Enable your pet's outgoing skill misses."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Skill Dodges", tooltip="Enable your pet's outgoing skill dodges."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Skill Parries", tooltip="Enable your pet's outgoing ability parries."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Skill Blocks", tooltip="Enable your pet's outgoing skill blocks."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable your pet's outgoing skill deflects."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Spell Resists", tooltip="Enable your pet's outgoing spell resists."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Skill Absorbs", tooltip="Enable your pet's absorbed damage from outgoing skills."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Skill Immunes", tooltip="Enable your pet's outgoing skill damage the enemy is immune to."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="Skill Evades", tooltip="Enable your pet's outgoing skill evades."}
obj["PET_OUTGOING_HEAL"]						= { label="Heals", tooltip="Enable your pet's outgoing heals."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Crit Heals", tooltip="Enable your pet's outgoing crit heals."}
obj["PET_OUTGOING_HOT"]							= { label="Heals Over Time", tooltip="Enable your pet's outgoing heals over time."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable your pet's outgoing crit heals over time."}
obj["PET_OUTGOING_DISPEL"]						= { label="Dispels", tooltip="Enable your pet's outgoing dispels."}



obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuffs", tooltip="Enable debuffs you are afflicted by."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Debuff Stacks", tooltip="Enable debuff stacks you are afflicted by."}
obj["NOTIFICATION_BUFF"]				= { label="Buffs", tooltip="Enable buffs you receive."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Buff Stacks", tooltip="Enable buff stacks you receive."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Item Buffs", tooltip="Enable buffs your items receive."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Debuff Fades", tooltip="Enable debuffs that have faded from you."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Buff Fades", tooltip="Enable buffs that have faded from you."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Item Buff Fades", tooltip="Enable item buffs that have faded from you."}
obj["NOTIFICATION_ITEM_COOLDOWN"] = { label="Item Ready", tooltip="Notify when a used trinket or potion cooldown finishes."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Enter Combat", tooltip="Enable when you have entered combat."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Leave Combat", tooltip="Enable when you have left combat."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Power Gains", tooltip="Enable when you gain extra mana, rage, or energy."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Power Losses", tooltip="Enable when you lose mana, rage, or energy from drains."}
obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_AC_CHANGE"]			= { label="Arcane Charges Changes", tooltip="Enable when you change arcane power."}
obj["NOTIFICATION_AC_FULL"]				= { label="Arcane Charges Full", tooltip="Enable when you attain full arcane power."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Combo Point Gains", tooltip="Enable when you gain combo points."}
obj["NOTIFICATION_CP_FULL"]				= { label="Combo Points Full", tooltip="Enable when you attain full combo points."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Holy Power Changes", tooltip="Enable when you change holy power."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Holy Power Full", tooltip="Enable when you attain full holy power."}
obj["NOTIFICATION_ESSENCE_CHANGE"]		= { label="Essence Changes", tooltip="Enable when you change essence."}
obj["NOTIFICATION_ESSENCE_FULL"]		= { label="Essence Full", tooltip="Enable when you attain full essence."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Honor Gains", tooltip="Enable when you gain honor."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Reputation Gains", tooltip="Enable when you gain reputation."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Reputation Losses", tooltip="Enable when you lose reputation."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Skill Gains", tooltip="Enable when you gain skill points."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Experience Gains", tooltip="Enable when you gain experience points."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Player Killing Blows", tooltip="Enable when you get a killing blow against a hostile player."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="NPC Killing Blows", tooltip="Enable when you get a killing blow against an NPC."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Extra Attacks", tooltip="Enable when you gain extra attacks such as windfury, thrash, sword spec, etc."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Enemy Buff Gains", tooltip="Enable buffs your currently targeted enemy gains."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Monster Emotes", tooltip="Enable emotes by the currently targeted monster."}



obj = L.OUTLINES
obj[1] = "None"
obj[2] = "Thin"
obj[3] = "Thick"
obj[4] = "Monochrome"
obj[5] = "Monochrome + Thin"
obj[6] = "Monochrome + Thick"

obj = L.TEXT_ALIGNS
obj[1] = "Left"
obj[2] = "Center"
obj[3] = "Right"






obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Angled"
obj["Horizontal"]	= "Horizontal"
obj["Parabola"]		= "Parabola"
obj["Straight"]		= "Straight"
obj["Static"]		= "Static"
obj["Pow"]			= "Pow"

obj["Alternate"]	= "Alternate"
obj["Left"]			= "Left"
obj["Right"]		= "Right"
obj["Up"]			= "Up"
obj["Down"]			= "Down"

obj["AngleUp"]			= "Angle Upwards"
obj["AngleDown"]		= "Angle Downwards"
obj["GrowUp"]			= "Grow Upwards"
obj["GrowDown"]			= "Grow Downwards"
obj["CurvedLeft"]		= "Curved Left"
obj["CurvedRight"]		= "Curved Right"
obj["Jiggle"]			= "Jiggle"
obj["Normal"]			= "Normal"

L.MSG_SOUND_PLAYBACK_FAILED = "Sound could not be played. Check the file path and restart WoW after adding new sound files."
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Invalid sound name."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Sound name already exists."
L.MSG_INVALID_SOUND_FILE			= "Sound must be an .mp3 or .ogg file."
L.CHECKBOXES["enableSounds"] = { label="Enable Sounds", tooltip="Play custom sounds assigned to displayed events."}
L.DROPDOWNS["sound"]				= { label="Sound:", tooltip="Selects the sound to play when the event occurs."}
L.BUTTONS["addCustomSound"]			= { label="Add Sound", tooltip="Adds a custom sound to the list of available sounds.\n\nWARNING: The sound file must exist in the target location *BEFORE* WoW was started.\n\nIt is highly recommended to place the file in the MikScrollingBattleText\\Sounds directory to avoid issues."}
L.BUTTONS["customSound"]				= { tooltip="Click to enter a custom sound file." }
L.BUTTONS["playSound"]				= { label="Play", tooltip="Click to play the selected sound."}
L.EDITBOXES["customSoundName"]	= { label="Sound name:", tooltip="The name used to identify the sound.\n\nExample: My Sound"}
L.EDITBOXES["customSoundPath"]	= { label="Sound path:", tooltip="The path to the sounds's file.\n\nNOTE: If the file is located in the recommended MikScrollingBattleText\\Sounds directory, only the filename needs to be entered here instead of th full path.\n\nExample: mySound.ogg "}
L.EDITBOXES["soundFile"]		= { label="Sound filename:", tooltip="The name of the sound file to play when the event occurs."}

L.TRIGGER_DATA = {}
L.MSG_NEW_TRIGGER = "New Trigger"
L.MSG_TRIGGER_CLASSES = "Trigger Classes"
L.MSG_MAIN_EVENTS = "Main Events"
L.MSG_TRIGGER_EXCEPTIONS = "Trigger Exceptions"
L.MSG_EVENT_CONDITIONS = "Event Conditions"
L.MSG_SKILLS = "Skills"
L.MSG_SKILL_ALREADY_EXISTS = "Skill name already exists."
L.MSG_INVALID_SKILL_NAME = "Invalid skill name."
L.MSG_CONDITION = "Condition"
L.MSG_CONDITIONS = "Conditions"
L.CHECKBOXES["allClasses"] = { label="All Classes"}
L.DROPDOWNS["mainEvent"] = { label="Main Event:"}
L.DROPDOWNS["triggerCondition"] = { label="Condition:", tooltip="The condition to test."}
L.DROPDOWNS["triggerRelation"] = { label="Relation:"}
L.DROPDOWNS["triggerParameter"] = { label="Parameter:"}
L.BUTTONS["addTrigger"] = { label="Add New Trigger", tooltip="Add a new trigger."}
L.BUTTONS["triggerSettings"] = { tooltip="Click to configure the trigger conditions."}
L.BUTTONS["deleteTrigger"] = { tooltip="Click to delete the trigger."}
L.BUTTONS["editTriggerClasses"] = { tooltip="Click to edit the classes the trigger applies to."}
L.BUTTONS["addMainEvent"] = { label="Add Event", tooltip="When ANY of these events occur and their defined conditions are true, the trigger will fire unless one of the specified exceptions is true."}
L.BUTTONS["addTriggerException"] = { label="Add Exception", tooltip="When ANY of these exceptions are true, the trigger will not fire."}
L.BUTTONS["editEventConditions"] = { tooltip="Click to edit the conditions for the event."}
L.BUTTONS["deleteMainEvent"] = { tooltip="Click to delete the event."}
L.BUTTONS["addEventCondition"] = { label="Add Condition", tooltip="When ALL of these conditions are true for the selected event, the trigger will fire unless one of the specified exceptions is true."}
L.BUTTONS["editCondition"] = { tooltip="Click to edit the condition."}
L.BUTTONS["deleteCondition"] = { tooltip="Click to delete the condition."}
L.BUTTONS["throttleList"] = { label="Throttle List", tooltip="Set custom throttle times for specified skills."}
L.BUTTONS["mergeExclusions"] = { label="Merge Exclusions", tooltip="Prevent specified skills from being merged."}
L.BUTTONS["skillSuppressions"] = { label="Skill Suppressions", tooltip="Suppress skills by their name."}
L.BUTTONS["skillSubstitutions"] = { label="Skill Substitutions", tooltip="Substitute skill names with customized values."}
L.BUTTONS["addSkill"] = { label="Add Skill", tooltip="Add a new skill to the list."}
L.BUTTONS["deleteSkill"] = { tooltip="Click to delete the skill."}
L.EDITBOXES["skillName"] = { label="Skill name:", tooltip="The name of the skill to add."}
L.EDITBOXES["substitutionText"] = { label="Substition text:", tooltip="The text to be substituted for the skill name."}
L.SLIDERS["skillThrottleTime"] = { label="Throttle Time", tooltip="The number of seconds to throttle the skill."}
L.TRIGGER_DATA["SWING_DAMAGE"] = "Swing Damage"
L.TRIGGER_DATA["RANGE_DAMAGE"] = "Range Damage"
L.TRIGGER_DATA["SPELL_DAMAGE"] = "Skill Damage"
L.TRIGGER_DATA["GENERIC_DAMAGE"] = "Swing/Range/Skill Damage"
L.TRIGGER_DATA["SPELL_PERIODIC_DAMAGE"] = "Periodic Skill Damage (DoT)"
L.TRIGGER_DATA["DAMAGE_SHIELD"] = "Damage Shield Damage"
L.TRIGGER_DATA["DAMAGE_SPLIT"] = "Split Damage"
L.TRIGGER_DATA["ENVIRONMENTAL_DAMAGE"] = "Environmental Damage"
L.TRIGGER_DATA["SWING_MISSED"] = "Swing Miss"
L.TRIGGER_DATA["RANGE_MISSED"] = "Range Miss"
L.TRIGGER_DATA["SPELL_MISSED"] = "Skill Miss"
L.TRIGGER_DATA["GENERIC_MISSED"] = "Swing/Range/Skill Miss"
L.TRIGGER_DATA["SPELL_PERIODIC_MISSED"] = "Periodic Skill Miss"
L.TRIGGER_DATA["SPELL_DISPEL_FAILED"] = "Dispel Failed"
L.TRIGGER_DATA["DAMAGE_SHIELD_MISSED"] = "Damage Shield Miss"
L.TRIGGER_DATA["SPELL_HEAL"] = "Heal"
L.TRIGGER_DATA["SPELL_PERIODIC_HEAL"] = "Periodic Heal (HoT)"
L.TRIGGER_DATA["SPELL_ENERGIZE"] = "Power Gain"
L.TRIGGER_DATA["SPELL_PERIODIC_ENERGIZE"] = "Periodic Power Gain"
L.TRIGGER_DATA["SPELL_DRAIN"] = "Power Drain"
L.TRIGGER_DATA["SPELL_PERIODIC_DRAIN"] = "Periodic Power Drain"
L.TRIGGER_DATA["SPELL_LEECH"] = "Power Leech"
L.TRIGGER_DATA["SPELL_PERIODIC_LEECH"] = "Periodic Power Leech"
L.TRIGGER_DATA["SPELL_INTERRUPT"] = "Skill Interrupt"
L.TRIGGER_DATA["SPELL_AURA_APPLIED"] = "Aura Application"
L.TRIGGER_DATA["SPELL_AURA_REMOVED"] = "Aura Removal"
L.TRIGGER_DATA["SPELL_STOLEN"] = "Aura Stolen"
L.TRIGGER_DATA["SPELL_DISPEL"] = "Aura Dispel"
L.TRIGGER_DATA["SPELL_AURA_REFRESH"] = "Aura Refresh"
L.TRIGGER_DATA["SPELL_AURA_BROKEN_SPELL"] = "Aura Broken"
L.TRIGGER_DATA["ENCHANT_APPLIED"] = "Enchant Application"
L.TRIGGER_DATA["ENCHANT_REMOVED"] = "Enchant Removal"
L.TRIGGER_DATA["SPELL_CAST_START"] = "Cast Start"
L.TRIGGER_DATA["SPELL_CAST_SUCCESS"] = "Cast Success"
L.TRIGGER_DATA["SPELL_CAST_FAILED"] = "Cast Failure"
L.TRIGGER_DATA["SPELL_SUMMON"] = "Summon"
L.TRIGGER_DATA["SPELL_CREATE"] = "Create"
L.TRIGGER_DATA["PARTY_KILL"] = "Killing Blow"
L.TRIGGER_DATA["UNIT_DESTROYED"] = "Unit Destroy"
L.TRIGGER_DATA["SPELL_EXTRA_ATTACKS"] = "Extra Attacks"
L.TRIGGER_DATA["UNIT_HEALTH"] = "Health Change"
L.TRIGGER_DATA["UNIT_POWER"] = "Power Change"
L.TRIGGER_DATA["sourceName"] = "Source Unit Name"
L.TRIGGER_DATA["sourceAffiliation"] = "Source Unit Affiliation"
L.TRIGGER_DATA["sourceReaction"] = "Source Unit Reaction"
L.TRIGGER_DATA["sourceControl"] = "Source Unit Control"
L.TRIGGER_DATA["sourceUnitType"] = "Source Unit Type"
L.TRIGGER_DATA["recipientName"] = "Recipient Unit Name"
L.TRIGGER_DATA["recipientAffiliation"] = "Recipient Unit Affiliation"
L.TRIGGER_DATA["recipientReaction"] = "Recipient Unit Reaction"
L.TRIGGER_DATA["recipientControl"] = "Recipient Unit Control"
L.TRIGGER_DATA["recipientUnitType"] = "Recipient Unit Type"
L.TRIGGER_DATA["skillID"] = "Skill ID"
L.TRIGGER_DATA["skillName"] = "Skill Name"
L.TRIGGER_DATA["skillSchool"] = "Skill School"
L.TRIGGER_DATA["extraSkillID"] = "Extra Skill ID"
L.TRIGGER_DATA["extraSkillName"] = "Extra Skill Name"
L.TRIGGER_DATA["extraSkillSchool"] = "Extra Skill School"
L.TRIGGER_DATA["amount"] = "Amount"
L.TRIGGER_DATA["overkillAmount"] = "Overkill Amount"
L.TRIGGER_DATA["damageType"] = "Damage Type"
L.TRIGGER_DATA["resistAmount"] = "Resist Amount"
L.TRIGGER_DATA["blockAmount"] = "Block Amount"
L.TRIGGER_DATA["absorbAmount"] = "Absorb Amount"
L.TRIGGER_DATA["isCrit"] = "Crit"
L.TRIGGER_DATA["isGlancing"] = "Glancing Hit"
L.TRIGGER_DATA["isCrushing"] = "Crushing Blow"
L.TRIGGER_DATA["extraAmount"] = "Extra Amount"
L.TRIGGER_DATA["missType"] = "Miss Type"
L.TRIGGER_DATA["hazardType"] = "Hazard Type"
L.TRIGGER_DATA["powerType"] = "Power Type"
L.TRIGGER_DATA["auraType"] = "Aura Type"
L.TRIGGER_DATA["threshold"] = "Threshold"
L.TRIGGER_DATA["unitID"] = "Unit ID"
L.TRIGGER_DATA["unitReaction"] = "Unit Reaction"
L.TRIGGER_DATA["itemID"] = "Item ID"
L.TRIGGER_DATA["itemName"] = "Item Name"
L.TRIGGER_DATA["activeTalents"] = "Active Talents"
L.TRIGGER_DATA["buffActive"] = "Buff Active"
L.TRIGGER_DATA["buffInactive"] = "Buff Inactive"
L.TRIGGER_DATA["currentCP"] = "Current Combo Points"
L.TRIGGER_DATA["currentPower"] = "Current Power"
L.TRIGGER_DATA["inCombat"] = "In Combat"
L.TRIGGER_DATA["recentlyFired"] = "Trigger Recently Fired"
L.TRIGGER_DATA["trivialTarget"] = "Trivial Target"
L.TRIGGER_DATA["unavailableSkill"] = "Unavailable Skill"
L.TRIGGER_DATA["warriorStance"] = "Warrior Stance"
L.TRIGGER_DATA["zoneName"] = "Zone Name"
L.TRIGGER_DATA["zoneType"] = "Zone Type"
L.TRIGGER_DATA["eq"] = "Is Equal To"
L.TRIGGER_DATA["ne"] = "Is Not Equal To"
L.TRIGGER_DATA["like"] = "Is Like"
L.TRIGGER_DATA["unlike"] = "Is Not Like"
L.TRIGGER_DATA["lt"] = "Is Less Than"
L.TRIGGER_DATA["gt"] = "Is Greater Than"
L.TRIGGER_DATA["affiliationMine"] = "Mine"
L.TRIGGER_DATA["affiliationParty"] = "Party Member"
L.TRIGGER_DATA["affiliationRaid"] = "Raid Member"
L.TRIGGER_DATA["affiliationOutsider"] = "Outsider"
L.TRIGGER_DATA["affiliationTarget"] = TARGET
L.TRIGGER_DATA["affiliationFocus"] = FOCUS
L.TRIGGER_DATA["affiliationYou"] = YOU
L.TRIGGER_DATA["reactionFriendly"] = "Friendly"
L.TRIGGER_DATA["reactionNeutral"] = "Neutral"
L.TRIGGER_DATA["reactionHostile"] = HOSTILE
L.TRIGGER_DATA["controlServer"] = "Server"
L.TRIGGER_DATA["controlHuman"] = "Human"
L.TRIGGER_DATA["unitTypePlayer"] = PLAYER
L.TRIGGER_DATA["unitTypeNPC"] = "NPC"
L.TRIGGER_DATA["unitTypePet"] = PET
L.TRIGGER_DATA["unitTypeGuardian"] = "Guardian"
L.TRIGGER_DATA["unitTypeObject"] = "Object"
L.TRIGGER_DATA["auraTypeBuff"] = "Buff"
L.TRIGGER_DATA["auraTypeDebuff"] = "Debuff"
L.TRIGGER_DATA["zoneTypeArena"] = "Arena"
L.TRIGGER_DATA["zoneTypePvP"] = BATTLEGROUND
L.TRIGGER_DATA["zoneTypeParty"] = "5 man instance"
L.TRIGGER_DATA["zoneTypeRaid"] = "Raid instance"
L.TRIGGER_DATA["booleanTrue"] = "True"
L.TRIGGER_DATA["booleanFalse"] = "False"
