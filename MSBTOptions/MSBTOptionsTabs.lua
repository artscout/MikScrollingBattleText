
local module = {}
local moduleName = "Tabs"
MSBTOptions[moduleName] = module



local MSBTOptMain = MSBTOptions.Main
local MSBTControls = MSBTOptions.Controls
local MSBTPopups = MSBTOptions.Popups
local MSBTProfiles = MikSBT.Profiles
local MSBTTriggers = MikSBT.Triggers
local MSBTAnimations = MikSBT.Animations
local MSBTMedia = MikSBT.Media
local L = MikSBT.translations

local EraseTable = MikSBT.EraseTable
local Print = MikSBT.Print
local DisableControls = MSBTPopups.DisableControls

local fonts = MSBTMedia.fonts

local IsClassic = MikSBT.Compatibility.Client.isClassicContent



local _

local DEFAULT_PROFILE_NAME = "Default"
local DEFAULT_FONT_NAME = L.DEFAULT_FONT_NAME
local DEFAULT_SCROLL_AREA = "Notification"
local DEFAULT_FONT_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Fonts\\"

local EVENT_CATEGORY_MAP = {
	"INCOMING_PLAYER_EVENTS", "INCOMING_PET_EVENTS",
	"OUTGOING_PLAYER_EVENTS", "OUTGOING_PET_EVENTS",
	"NOTIFICATION_EVENTS"
}


local tabFrames = {}

local configTable = {}

local listTable = {}

local orderedEvents = {}



local function SortKeysByValue(t)
	local sortedKeys = {}
	local sortedValues = {}

	for k, v in pairs(t) do
		sortedKeys[#sortedKeys+1] = k
		sortedValues[#sortedValues+1] = v
	end

	local tempKey, tempValue, j
	for i = 2, #sortedValues do
		tempValue = sortedValues[i]
		tempKey = sortedKeys[i]
		j = i - 1
		while (j > 0 and sortedValues[j] > tempValue) do
			sortedValues[j + 1] = sortedValues[j]
			sortedKeys[j + 1] = sortedKeys[j]
			j = j - 1
		end
		sortedValues[j + 1] = tempValue
		sortedKeys[j + 1] = tempKey
	end

	return sortedKeys
end


local function PopulateList(listName)
	EraseTable(listTable)
	local currentProfileList = rawget(MSBTProfiles.currentProfile, listName)
	if (currentProfileList) then
		for name, value in pairs(currentProfileList) do
			listTable[name] = value
		end
	end

	for name, value in pairs(MSBTProfiles.masterProfile[listName]) do
		if (listTable[name] == nil) then listTable[name] = value end
	end
end


local function SaveList(listName)
	for skillName, value in pairs(listTable) do
		MSBTProfiles.SetOption(listName, skillName, value)
	end
end



local GeneralTab_Populate

local function RefreshGeneralTabIfCreated()
	if tabFrames.general and tabFrames.general.created then
		GeneralTab_Populate()
	end
end

local function ProfileTab_ToggleDeleteButton()
	if not tabFrames.profile or not tabFrames.profile.controls then
		return
	end
	local controls = tabFrames.profile.controls

	if (controls.profileDropdown:GetSelectedID() == DEFAULT_PROFILE_NAME) then
		controls.deleteProfileButton:Disable()
	else
		controls.deleteProfileButton:Enable()
	end
end

local function GeneralTab_EnableControls()
	for name, frame in pairs(tabFrames.general.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


GeneralTab_Populate = function()
	local currentProfile = MSBTProfiles.currentProfile
	local controls = tabFrames.general.controls

	controls.enableCheckbox:SetChecked(not MSBTProfiles.IsModDisabled())
	controls.disableOutgoingInGroupCheckbox:SetChecked(not not currentProfile.disableOutgoingInGroup)
	controls.disableIncomingInGroupCheckbox:SetChecked(not not currentProfile.disableIncomingInGroup)
	controls.disableNotificationInGroupCheckbox:SetChecked(not not currentProfile.disableNotificationInGroup)
	controls.disableStaticInGroupCheckbox:SetChecked(not not currentProfile.disableStaticInGroup)
	if controls.showGuessedOutgoingInGroupCheckbox then
		controls.showGuessedOutgoingInGroupCheckbox:SetChecked(not not currentProfile.showGuessedOutgoingInGroup)
	end
	controls.stickyCritsCheckbox:SetChecked(not currentProfile.stickyCritsDisabled)
	controls.shortenNumbersCheckbox:SetChecked(currentProfile.shortenNumbers)
	controls.stackSimilarHitsCheckbox:SetChecked(currentProfile.stackSimilarHits)
	controls.enableSoundsCheckbox:SetChecked(not currentProfile.soundsDisabled)
	controls.enableIconsCheckbox:SetChecked(not currentProfile.skillIconsDisabled)
	if controls.blizzardCombatTextV2Checkbox then
		controls.blizzardCombatTextV2Checkbox:SetChecked(not not currentProfile.enableBlizzardV2CombatText)
	end
	if controls.blizzardCombatTextV2InGroupCheckbox then
		controls.blizzardCombatTextV2InGroupCheckbox:SetChecked(not not currentProfile.enableBlizzardV2CombatTextInGroup)
	end
	controls.animationSpeedSlider:SetValue(currentProfile.animationSpeed)
end


local function GeneralTab_CopyProfile(settings)
	local profileName = settings.inputText
	local controls = tabFrames.profile.controls

	local dropdown = controls.profileDropdown
	MSBTProfiles.CopyProfile(dropdown:GetSelectedID(), profileName)
	dropdown:AddItem(profileName, profileName)
	dropdown:Sort()

	dropdown:SetSelectedID(profileName)
	MSBTProfiles.SelectProfile(profileName)
	RefreshGeneralTabIfCreated()
	ProfileTab_ToggleDeleteButton()
end


local function GeneralTab_ResetProfile()
	local controls = tabFrames.profile.controls

	MSBTProfiles.ResetProfile(controls.profileDropdown:GetSelectedID())
	RefreshGeneralTabIfCreated()
end


local function GeneralTab_DeleteProfile()
	local controls = tabFrames.profile.controls

	local dropdown = controls.profileDropdown
	local profileName = dropdown:GetSelectedID()
	MSBTProfiles.DeleteProfile(profileName)
	dropdown:RemoveItem(profileName)

	dropdown:SetSelectedID(DEFAULT_PROFILE_NAME)
	RefreshGeneralTabIfCreated()
	ProfileTab_ToggleDeleteButton()
end


local function GeneralTab_SaveFontSettings(fontSettings)
	MSBTProfiles.SetOption(nil, "normalFontName", fontSettings.normalFontName)
	MSBTProfiles.SetOption(nil, "normalOutlineIndex", fontSettings.normalOutlineIndex)
	MSBTProfiles.SetOption(nil, "normalFontSize", fontSettings.normalFontSize)
	MSBTProfiles.SetOption(nil, "normalFontAlpha", fontSettings.normalFontAlpha)

	MSBTProfiles.SetOption(nil, "critFontName", fontSettings.critFontName)
	MSBTProfiles.SetOption(nil, "critOutlineIndex", fontSettings.critOutlineIndex)
	MSBTProfiles.SetOption(nil, "critFontSize", fontSettings.critFontSize)
	MSBTProfiles.SetOption(nil, "critFontAlpha", fontSettings.critFontAlpha)
end


local function GeneralTab_Create()
	local tabFrame = tabFrames.general
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local checkbox = MSBTControls.CreateCheckbox(tabFrame)
	local objLocale = L.CHECKBOXES["enableMSBT"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOptionUserDisabled(not isChecked)
		end
	)
	controls.enableCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["disableOutgoingInGroup"] or { label = "Disable Outgoing In Group", tooltip = "While in a party or raid, hide events assigned to the Outgoing scroll area." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.enableCheckbox, "BOTTOMLEFT", 18, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "disableOutgoingInGroup", isChecked)
			if MSBTProfiles.ApplyContextOptions then
				MSBTProfiles.ApplyContextOptions()
			end
		end
	)
	controls.disableOutgoingInGroupCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["disableIncomingInGroup"] or { label = "Disable Incoming In Group", tooltip = "While in a party or raid, hide events assigned to the Incoming scroll area." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.disableOutgoingInGroupCheckbox, "BOTTOMLEFT", 0, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "disableIncomingInGroup", isChecked)
			if MSBTProfiles.ApplyContextOptions then
				MSBTProfiles.ApplyContextOptions()
			end
		end
	)
	controls.disableIncomingInGroupCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["disableNotificationInGroup"] or { label = "Disable Notification In Group", tooltip = "While in a party or raid, hide events assigned to the Notification scroll area." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.disableIncomingInGroupCheckbox, "BOTTOMLEFT", 0, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "disableNotificationInGroup", isChecked)
			if MSBTProfiles.ApplyContextOptions then
				MSBTProfiles.ApplyContextOptions()
			end
		end
	)
	controls.disableNotificationInGroupCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["disableStaticInGroup"] or { label = "Disable Static In Group", tooltip = "While in a party or raid, hide events assigned to the Static scroll area." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.disableNotificationInGroupCheckbox, "BOTTOMLEFT", 0, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "disableStaticInGroup", isChecked)
			if MSBTProfiles.ApplyContextOptions then
				MSBTProfiles.ApplyContextOptions()
			end
		end
	)
	controls.disableStaticInGroupCheckbox = checkbox

	-- Guessed outgoing damage in group checkbox.
	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["showGuessedOutgoingInGroup"] or { label = "Outgoing Damage In Group", tooltip = "Without the combat log outgoing damage is attributed from UNIT_COMBAT, which also reports hits dealt by other players. In a party or raid only hits that match your own casts, damage-over-time ticks and auto attack swings are counted. Uncheck to hide outgoing damage while in a group." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.disableStaticInGroupCheckbox, "BOTTOMLEFT", 0, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "showGuessedOutgoingInGroup", isChecked)
		end
	)
	controls.showGuessedOutgoingInGroupCheckbox = checkbox

	-- Blizzard floating combat text (v2) checkbox.
	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["enableBlizzardV2CombatText"] or { label = "Disable Blizzard CT While Solo", tooltip = "When checked, disables Blizzard floating combat text damage/healing while solo." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.enableCheckbox, "TOPRIGHT", 30, 0)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "enableBlizzardV2CombatText", isChecked)
			if MSBTProfiles.ApplyContextOptions then
				MSBTProfiles.ApplyContextOptions()
			end
		end
	)
	controls.blizzardCombatTextV2Checkbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["enableBlizzardV2InGroup"] or { label = "Enable Blizzard CT In Group", tooltip = "Enable Blizzard Combat Text only while in a party or raid. This overrides Disable Blizzard CT While Solo while grouped." }
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.blizzardCombatTextV2Checkbox, "BOTTOMLEFT", 0, -5)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "enableBlizzardV2CombatTextInGroup", isChecked)
			if MSBTProfiles.ApplyContextOptions then
				MSBTProfiles.ApplyContextOptions()
			end
		end
	)
	controls.blizzardCombatTextV2InGroupCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["enableSounds"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -30, 15)
	checkbox:SetClickHandler(function(this, isChecked)
		MSBTProfiles.SetOption(nil, "soundsDisabled", not isChecked)
	end)
	controls.enableSoundsCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["shortenNumbers"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", controls.enableSoundsCheckbox, "TOPLEFT", 0, 0)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "shortenNumbers", isChecked)
		end
	)
	controls.shortenNumbersCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["stackSimilarHits"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", controls.shortenNumbersCheckbox, "TOPLEFT", 0, 0)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "stackSimilarHits", isChecked)
		end
	)
	controls.stackSimilarHitsCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["stickyCrits"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", controls.stackSimilarHitsCheckbox, "TOPLEFT", 0, 0)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "stickyCritsDisabled", not isChecked)
		end
	)
	controls.stickyCritsCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["enableIcons"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", controls.stickyCritsCheckbox, "TOPLEFT", 0, 0)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "skillIconsDisabled", not isChecked)
		end
	)
	controls.enableIconsCheckbox = checkbox

	local slider = MSBTControls.CreateSlider(tabFrame)
	objLocale = L.SLIDERS["animationSpeed"]
	slider:Configure(180, objLocale.label, objLocale.tooltip)
	slider:SetPoint("BOTTOMRIGHT", controls.enableIconsCheckbox, "TOPRIGHT", 0, 10)
	slider:SetMinMaxValues(20, 250)
	slider:SetValueStep(10)
	slider:SetValueChangedHandler(
		function(this, value)
			MSBTProfiles.SetOption(nil, "animationSpeed", value)
		end
	)
	controls.animationSpeedSlider = slider



	local button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["classColors"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", tabFrame, "BOTTOMLEFT", 5, 15)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.anchorPoint = "BOTTOMLEFT"
			configTable.relativePoint = "TOPLEFT"
			configTable.hideHandler = GeneralTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowClassColors(configTable)
		end
	)
	controls.classColorsButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["damageColors"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", controls.classColorsButton, "TOPLEFT", 0, 10)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.anchorPoint = "BOTTOMLEFT"
			configTable.relativePoint = "TOPLEFT"
			configTable.hideHandler = GeneralTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowDamageColors(configTable)
		end
	)
	controls.damageColorsButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["partialEffects"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", controls.damageColorsButton, "TOPLEFT", 0, 10)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.anchorPoint = "BOTTOMLEFT"
			configTable.relativePoint = "TOPLEFT"
			configTable.hideHandler = GeneralTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowPartialEffects(configTable)
		end
	)
	controls.partialEffectsButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["masterFont"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", controls.partialEffectsButton, "TOPLEFT", 0, 10)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.title = objLocale.label

			local fontName = MSBTProfiles.currentProfile.normalFontName
			if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
			configTable.normalFontName = fontName
			configTable.normalOutlineIndex = MSBTProfiles.currentProfile.normalOutlineIndex
			configTable.normalFontSize = MSBTProfiles.currentProfile.normalFontSize
			configTable.normalFontAlpha = MSBTProfiles.currentProfile.normalFontAlpha

			fontName = MSBTProfiles.currentProfile.critFontName
			if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
			configTable.critFontName = fontName
			configTable.critOutlineIndex = MSBTProfiles.currentProfile.critOutlineIndex
			configTable.critFontSize = MSBTProfiles.currentProfile.critFontSize
			configTable.critFontAlpha = MSBTProfiles.currentProfile.critFontAlpha
			configTable.hideInherit = true
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = tabFrame
			configTable.anchorPoint = "BOTTOM"
			configTable.relativePoint = "BOTTOM"
			configTable.saveHandler = GeneralTab_SaveFontSettings
			configTable.hideHandler = GeneralTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowFont(configTable)
		end
	)
	controls.masterFontButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["addCustomSound"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", controls.masterFontButton, "TOPLEFT", 0, 10)
	button:SetClickHandler(function(this)
		DisableControls(controls)
		MSBTOptions.Sounds.ShowAddSound(tabFrame, this, GeneralTab_EnableControls)
	end)
	controls.addCustomSoundButton = button

	local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fontString:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0)
	fontString:SetText("Test")
	fontString:SetAlpha(0)
	tabFrame.fontPathValidationFontString = fontString


	tabFrame.created = true
end


local function GeneralTab_OnShow()
	if (not tabFrames.general.created) then GeneralTab_Create() end

	GeneralTab_Populate()
end



local function ProfileTab_EnableControls()
	for _, frame in pairs(tabFrames.profile.controls) do
		if (frame.Enable) then frame:Enable() end
	end
	ProfileTab_ToggleDeleteButton()
end

local function ProfileTab_Populate()
	local controls = tabFrames.profile.controls
	local currentProfileName
	for profileName, profile in pairs(MSBTProfiles.savedVariables.profiles) do
		if (profile == MSBTProfiles.currentProfile) then
			currentProfileName = profileName
			break
		end
	end
	controls.profileDropdown:SetSelectedID(currentProfileName or DEFAULT_PROFILE_NAME)
	ProfileTab_ToggleDeleteButton()
end

local function ProfileTab_ImportSucceeded(name, details)
	local dropdown = tabFrames.profile.controls.profileDropdown
	dropdown:AddItem(name, name)
	dropdown:Sort()
	ProfileTab_Populate()
	RefreshGeneralTabIfCreated()
	local locale = L.PROFILE_TRANSFER
	Print(string.format(locale.imported, name), 0, 1, 0)
	if details.clientMismatch or details.localeMismatch then
		Print(locale.compatibility, 1, 0.8, 0)
	end
end

local function ProfileTab_ShowTransfer(isExport)
	local tabFrame = tabFrames.profile
	local controls = tabFrame.controls
	local text, errorCode
	if isExport then
		text, errorCode = MSBTProfiles.ExportProfile(
			controls.profileDropdown:GetSelectedID())
		if not text then
			Print(L.PROFILE_TRANSFER.errors[errorCode], 1, 0.3, 0.3)
			return
		end
	end
	local config = {
		parentFrame = tabFrame,
		hideHandler = ProfileTab_EnableControls,
		importHandler = MSBTProfiles.ImportProfile,
		successHandler = ProfileTab_ImportSucceeded,
	}
	DisableControls(controls)
	if isExport then
		MSBTOptions.ProfileTransfer.ShowExport(config, text)
	else
		MSBTOptions.ProfileTransfer.ShowImport(config)
	end
end

local function ProfileTab_Create()
	local tabFrame = tabFrames.profile
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local dropdown = MSBTControls.CreateDropdown(tabFrame)
	local objLocale = L.DROPDOWNS["profile"]
	dropdown:Configure(220, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -20)
	dropdown:SetChangeHandler(
		function (this, id)
			MSBTProfiles.SelectProfile(id)
			ProfileTab_Populate()
			RefreshGeneralTabIfCreated()
		end
	)
	controls.profileDropdown = dropdown

	for profileName in pairs(MSBTProfiles.savedVariables.profiles) do
		dropdown:AddItem(profileName, profileName)
	end
	dropdown:Sort()

	local button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["copyProfile"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -20)
	button:SetClickHandler(
		function (this)
			local editLocale = L.EDITBOXES["copyProfile"]
			EraseTable(configTable)
			configTable.defaultText = L.MSG_NEW_PROFILE
			configTable.editboxLabel = editLocale.label
			configTable.editboxTooltip = editLocale.tooltip
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.validateHandler = GeneralTab_ValidateProfileName
			configTable.saveHandler = GeneralTab_CopyProfile
			configTable.hideHandler = ProfileTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowInput(configTable)
		end
	)
	controls.copyProfileButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["resetProfile"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("LEFT", controls.copyProfileButton, "RIGHT", 10, 0)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.acknowledgeHandler = GeneralTab_ResetProfile
			configTable.hideHandler = ProfileTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowAcknowledge(configTable)
		end
	)
	controls.resetProfileButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["deleteProfile"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("LEFT", controls.resetProfileButton, "RIGHT", 10, 0)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.anchorPoint = "TOPRIGHT"
			configTable.relativePoint = "BOTTOMRIGHT"
			configTable.acknowledgeHandler = GeneralTab_DeleteProfile
			configTable.hideHandler = ProfileTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowAcknowledge(configTable)
		end
	)
	controls.deleteProfileButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	button:Configure(20, L.PROFILE_TRANSFER.export,
		L.PROFILE_TRANSFER.exportHelp)
	button:SetPoint("TOPLEFT", controls.copyProfileButton, "BOTTOMLEFT", 0, -20)
	button:SetClickHandler(function() ProfileTab_ShowTransfer(true) end)
	controls.exportProfileButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	button:Configure(20, L.PROFILE_TRANSFER.import,
		L.PROFILE_TRANSFER.importHelp)
	button:SetPoint("LEFT", controls.exportProfileButton, "RIGHT", 10, 0)
	button:SetClickHandler(function() ProfileTab_ShowTransfer(false) end)
	controls.importProfileButton = button

	ProfileTab_Populate()
	tabFrame.created = true
end

local function ProfileTab_OnShow()
	if (not tabFrames.profile.created) then ProfileTab_Create() end
	ProfileTab_Populate()
end



local function ScrollAreasTab_EnableControls()
	for name, frame in pairs(tabFrames.scrollAreas.controls) do
		if (frame.Enable) then frame:Enable() end
	end

	tabFrames.scrollAreas.controls.scrollAreasListbox:Refresh()
end


local function ScrollAreasTab_ValidateScrollAreaName(scrollAreaName)
	if (not scrollAreaName or scrollAreaName == "") then
		return L.MSG_INVALID_SCROLL_AREA_NAME
	end

	for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
		if (saSettings.name == scrollAreaName) then return L.MSG_SCROLL_AREA_ALREADY_EXISTS end
	end
end


local function ScrollAreasTab_AddScrollArea(settings)
	local nextAvailable = 1
	while (MSBTProfiles.currentProfile.scrollAreas["Custom" .. nextAvailable]) do
		nextAvailable = nextAvailable + 1
	end

	local newKey = "Custom" .. nextAvailable
	local saSettings = {}
	saSettings.name = settings.inputText
	MSBTProfiles.SetOption("scrollAreas", newKey, saSettings)
	MSBTAnimations.UpdateScrollAreas()
	tabFrames.scrollAreas.controls.scrollAreasListbox:AddItem(newKey, true)
end


local function ScrollAreasTab_EnableOnClick(this, isChecked)
	local line = this:GetParent()
	MSBTProfiles.SetOption("scrollAreas." .. line.scrollAreaKey, "disabled", not isChecked)
	MSBTAnimations.UpdateScrollAreas()
end


local function ScrollAreasTab_ChangeScrollAreaName(settings)
	MSBTProfiles.SetOption("scrollAreas." .. settings.saveArg1, "name", settings.inputText)
	MSBTAnimations.UpdateScrollAreas()
	tabFrames.scrollAreas.controls.scrollAreasListbox:Refresh()
end


local function ScrollAreasTab_EditNameButtonOnClick(this)
	local saKey = this:GetParent().scrollAreaKey
	local objLocale = L.EDITBOXES["scrollAreaName"]
	EraseTable(configTable)
	configTable.defaultText = MSBTProfiles.currentProfile.scrollAreas[saKey].name
	configTable.editboxLabel = objLocale.label
	configTable.editboxTooltip = objLocale.tooltip
	configTable.parentFrame = tabFrames.scrollAreas
	configTable.anchorFrame = this
	configTable.anchorPoint = this:GetParent().lineNumber > 5 and "BOTTOMRIGHT" or "TOPRIGHT"
	configTable.relativePoint = this:GetParent().lineNumber > 5 and "TOPRIGHT" or "BOTTOMRIGHT"
	configTable.validateHandler = ScrollAreasTab_ValidateScrollAreaName
	configTable.saveHandler = ScrollAreasTab_ChangeScrollAreaName
	configTable.saveArg1 = saKey
	configTable.hideHandler = ScrollAreasTab_EnableControls
	DisableControls(tabFrames.scrollAreas.controls)
	MSBTPopups.ShowInput(configTable)
end


local function ScrollAreasTab_DeleteScrollArea(line)
	MSBTProfiles.SetOption("scrollAreas", line.scrollAreaKey, nil)
	tabFrames.scrollAreas.controls.scrollAreasListbox:RemoveItem(line.itemNumber)
	MSBTAnimations.UpdateScrollAreas()
end


local function ScrollAreasTab_DeleteButtonOnClick(this)
	EraseTable(configTable)
	configTable.parentFrame = tabFrames.scrollAreas
	configTable.anchorFrame = this
	configTable.anchorPoint = this:GetParent().lineNumber > 5 and "BOTTOMRIGHT" or "TOPRIGHT"
	configTable.relativePoint = this:GetParent().lineNumber > 5 and "TOPRIGHT" or "BOTTOMRIGHT"
	configTable.acknowledgeHandler = ScrollAreasTab_DeleteScrollArea
	configTable.saveArg1 = this:GetParent()
	configTable.hideHandler = ScrollAreasTab_EnableControls
	DisableControls(tabFrames.scrollAreas.controls)
	MSBTPopups.ShowAcknowledge(configTable)
end


local function ScrollAreasTab_SaveFontSettings(fontSettings, scrollAreaKey)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalFontName", fontSettings.normalFontName)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalOutlineIndex", fontSettings.normalOutlineIndex)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalFontSize", fontSettings.normalFontSize)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalFontAlpha", fontSettings.normalFontAlpha)

	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critFontName", fontSettings.critFontName)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critOutlineIndex", fontSettings.critOutlineIndex)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critFontSize", fontSettings.critFontSize)
	MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critFontAlpha", fontSettings.critFontAlpha)

	MSBTAnimations.UpdateScrollAreas()
end


local function ScrollAreasTab_FontButtonOnClick(this)
	local saKey = this:GetParent().scrollAreaKey
	local saSettings = MSBTProfiles.currentProfile.scrollAreas[saKey]

	EraseTable(configTable)
	configTable.title = saSettings.name
	local fontName = MSBTProfiles.currentProfile.normalFontName
	if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
	configTable.inheritedNormalFontName = fontName
	configTable.inheritedNormalOutlineIndex = MSBTProfiles.currentProfile.normalOutlineIndex
	configTable.inheritedNormalFontSize = MSBTProfiles.currentProfile.normalFontSize
	configTable.inheritedNormalFontAlpha = MSBTProfiles.currentProfile.normalFontAlpha

	fontName = MSBTProfiles.currentProfile.critFontName
	if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
	configTable.inheritedCritFontName = fontName
	configTable.inheritedCritFontName = MSBTProfiles.currentProfile.critFontName
	configTable.inheritedCritOutlineIndex = MSBTProfiles.currentProfile.critOutlineIndex
	configTable.inheritedCritFontSize = MSBTProfiles.currentProfile.critFontSize
	configTable.inheritedCritFontAlpha = MSBTProfiles.currentProfile.critFontAlpha

	fontName = saSettings.normalFontName
	if (not fonts[fontName]) then fontName = nil end
	configTable.normalFontName = fontName
	configTable.normalOutlineIndex = saSettings.normalOutlineIndex
	configTable.normalFontSize = saSettings.normalFontSize
	configTable.normalFontAlpha = saSettings.normalFontAlpha

	fontName = saSettings.critFontName
	if (not fonts[fontName]) then fontName = nil end
	configTable.critFontName = fontName
	configTable.critOutlineIndex = saSettings.critOutlineIndex
	configTable.critFontSize = saSettings.critFontSize
	configTable.critFontAlpha = saSettings.critFontAlpha

	configTable.parentFrame = tabFrames.scrollAreas
	configTable.anchorFrame = tabFrames.scrollAreas
	configTable.anchorPoint = "BOTTOM"
	configTable.relativePoint = "BOTTOM"
	configTable.saveHandler = ScrollAreasTab_SaveFontSettings
	configTable.saveArg1 = saKey
	configTable.hideHandler = ScrollAreasTab_EnableControls
	DisableControls(tabFrames.scrollAreas.controls)
	MSBTPopups.ShowFont(configTable)
end


local function ScrollAreasTab_CreateLine(this)
	local controls = tabFrames.scrollAreas.controls

	local frame = CreateFrame("Button", nil, this)
	frame:EnableMouse(false)

	local checkbox = MSBTControls.CreateCheckbox(frame)
	local objLocale = L.CHECKBOXES["enableScrollArea"]
	checkbox:Configure(24, nil, objLocale.tooltip)
	checkbox:SetPoint("LEFT", frame, "LEFT", 5, 0)
	checkbox:SetClickHandler(ScrollAreasTab_EnableOnClick)
	frame.enableCheckbox = checkbox
	controls[#controls+1] = checkbox

	local button = MSBTControls.CreateIconButton(frame, "Delete")
	objLocale = L.BUTTONS["deleteScrollArea"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
	button:SetClickHandler(ScrollAreasTab_DeleteButtonOnClick)
	frame.deleteButton = button
	controls[#controls+1] = button

	local button = MSBTControls.CreateIconButton(frame, "Configure")
	objLocale = L.BUTTONS["editScrollAreaName"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
	button:SetClickHandler(ScrollAreasTab_EditNameButtonOnClick)
	controls[#controls+1] = button


	button = MSBTControls.CreateIconButton(frame, "FontSettings")
	objLocale = L.BUTTONS["scrollAreaFontSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
	button:SetClickHandler(ScrollAreasTab_FontButtonOnClick)
	controls[#controls+1] = button

	return frame
end


local function ScrollAreasTab_DisplayLine(this, line, key, isSelected)
	local saSettings = MSBTProfiles.currentProfile.scrollAreas[key]
	line.scrollAreaKey = key
	line.enableCheckbox:SetLabel(saSettings.name)
	line.enableCheckbox:SetChecked(not saSettings.disabled)

	if (MSBTProfiles.masterProfile.scrollAreas[key]) then
		line.deleteButton:Disable()
	else
		line.deleteButton:Enable()
	end
end


local function ScrollAreasTab_Create()
	local tabFrame = tabFrames.scrollAreas
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local texture = tabFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
	texture:SetHeight(4)
	texture:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -45)
	texture:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", 0, -45)
	texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

	local button = MSBTControls.CreateOptionButton(tabFrame)
	local objLocale = L.BUTTONS["addScrollArea"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 5, 15)
	button:SetClickHandler(
		function (this)
			objLocale = L.EDITBOXES["scrollAreaName"]
			EraseTable(configTable)
			configTable.defaultText = L.MSG_NEW_SCROLL_AREA
			configTable.editboxLabel = objLocale.label
			configTable.editboxTooltip = objLocale.tooltip
			configTable.parentFrame = tabFrames.scrollAreas
			configTable.anchorFrame = this
			configTable.validateHandler = ScrollAreasTab_ValidateScrollAreaName
			configTable.saveHandler = ScrollAreasTab_AddScrollArea
			configTable.hideHandler = ScrollAreasTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowInput(configTable)
		end
	)
	controls.addScrollAreaButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["configScrollAreas"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", texture, "TOPRIGHT", -5, 15)
	button:SetClickHandler(
		function (this)
			MSBTOptMain.HideMainFrame()
			MSBTPopups.ShowScrollAreaConfig()
		end
	)
	controls.configScrollAreasButton = button

	local listbox = MSBTControls.CreateListbox(tabFrame)
	listbox:Configure(400, 300, 25)
	listbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50)
	listbox:SetCreateLineHandler(ScrollAreasTab_CreateLine)
	listbox:SetDisplayHandler(ScrollAreasTab_DisplayLine)
	controls.scrollAreasListbox = listbox

	tabFrame.scrollAreasTable = {}

	tabFrame.created = true
end


local function ScrollAreasTab_OnShow()
	if (not tabFrames.scrollAreas.created) then ScrollAreasTab_Create() end

	local listbox = tabFrames.scrollAreas.controls.scrollAreasListbox

	local scrollAreasTable = tabFrames.scrollAreas.scrollAreasTable
	EraseTable(scrollAreasTable)
	for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
		scrollAreasTable[saKey] = saSettings.name
	end
	local sortedKeys = SortKeysByValue(scrollAreasTable)

	local previousOffset = listbox:GetOffset()
	listbox:Clear()
	for _, key in ipairs(sortedKeys) do
		listbox:AddItem(key)
	end
	listbox:SetOffset(previousOffset)
end



local function EventsTab_AddEvent(category, eventType, codes)
	local event = L[category][eventType]
	if (not event) then return end

	orderedEvents[category][#orderedEvents[category]+1] = event
	event.eventType = eventType
	event.codes = codes
end


local function EventsTab_SetupEvents()
	for index, category in ipairs(EVENT_CATEGORY_MAP) do orderedEvents[category] = {} end

	local c = L.EVENT_CODES
	local category = "INCOMING_PLAYER_EVENTS"
	EventsTab_AddEvent(category, "INCOMING_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_MISS", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_DODGE", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_PARRY", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_BLOCK", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_DEFLECT", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_IMMUNE", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DOT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DOT_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE_SHIELD", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "INCOMING_SPELL_MISS", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DODGE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_PARRY", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_BLOCK", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_DEFLECT", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_RESIST", c.ATTACKER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_IMMUNE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_REFLECT", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_SPELL_INTERRUPT", c.ATTACKER_NAME .. c.SPELL_NAME)
	EventsTab_AddEvent(category, "INCOMING_HEAL", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_HEAL_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_HOT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_HOT_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "SELF_HEAL", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "SELF_HEAL_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "SELF_HOT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "SELF_HOT_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "INCOMING_ENVIRONMENTAL", c.DAMAGE_TAKEN .. c.ENVIRONMENTAL_DAMAGE)

	category = "INCOMING_PET_EVENTS"
	EventsTab_AddEvent(category, "PET_INCOMING_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_MISS", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_DODGE", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_PARRY", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_BLOCK", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_DEFLECT", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_IMMUNE", c.ATTACKER_NAME)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DOT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DOT_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE_SHIELD", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_MISS", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DODGE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_PARRY", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_BLOCK", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DEFLECT", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_RESIST", c.ATTACKER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_SPELL_IMMUNE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_HEAL", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_HEAL_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_HOT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_INCOMING_HOT_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)

	category = "OUTGOING_PLAYER_EVENTS"
	EventsTab_AddEvent(category, "OUTGOING_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_MISS", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_DODGE", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_PARRY", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_BLOCK", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_DEFLECT", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_IMMUNE", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_EVADE", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DOT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DOT_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE_SHIELD", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_MISS", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DODGE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_PARRY", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_BLOCK", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_DEFLECT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_RESIST", c.ATTACKED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_IMMUNE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_REFLECT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_INTERRUPT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_SPELL_EVADE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_HEAL", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_HEAL_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_HOT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_HOT_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "OUTGOING_DISPEL", c.ATTACKED_NAME .. c.BUFF_NAME .. c.SKILL_LONG)

	category = "OUTGOING_PET_EVENTS"
	EventsTab_AddEvent(category, "PET_OUTGOING_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_MISS", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_DODGE", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_PARRY", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_BLOCK", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_DEFLECT", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_IMMUNE", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_EVADE", c.ATTACKED_NAME)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DOT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DOT_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE_SHIELD", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_MISS", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DODGE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_PARRY", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_BLOCK", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DEFLECT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_RESIST", c.ATTACKED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_IMMUNE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_EVADE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_HEAL", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_HEAL_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_HOT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_HOT_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "PET_OUTGOING_DISPEL", c.BUFF_NAME .. c.SKILL_LONG)

	category = "NOTIFICATION_EVENTS"
	EventsTab_AddEvent(category, "NOTIFICATION_DEBUFF", c.DEBUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_DEBUFF_STACK", c.AURA_AMOUNT .. c.DEBUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_BUFF", c.BUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_BUFF_STACK", c.AURA_AMOUNT .. c.BUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_ITEM_BUFF", c.ITEM_BUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_DEBUFF_FADE", c.DEBUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_BUFF_FADE", c.BUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_ITEM_BUFF_FADE", c.ITEM_BUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_ITEM_COOLDOWN", c.ITEM_COOLDOWN_NAME)
	EventsTab_AddEvent(category, "NOTIFICATION_COMBAT_ENTER", "")
	EventsTab_AddEvent(category, "NOTIFICATION_COMBAT_LEAVE", "")
	EventsTab_AddEvent(category, "NOTIFICATION_POWER_GAIN", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_POWER_LOSS", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_ALT_POWER_GAIN", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_ALT_POWER_LOSS", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_CHI_CHANGE", c.CHI_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_CHI_FULL", c.CHI_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_AC_CHANGE", c.AC_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_AC_FULL", c.AC_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_CP_GAIN", c.CP_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_CP_FULL", c.CP_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_HOLY_POWER_CHANGE", c.HOLY_POWER_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_HOLY_POWER_FULL", c.HOLY_POWER_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_ESSENCE_CHANGE", c.ESSENCE_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_ESSENCE_FULL", c.ESSENCE_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_HONOR_GAIN", c.HONOR_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_REP_GAIN", c.REP_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_REP_LOSS", c.REP_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_SKILL_GAIN", c.SKILL_AMOUNT .. c.SKILL_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_EXPERIENCE_GAIN", c.EXPERIENCE_AMOUNT)
	EventsTab_AddEvent(category, "NOTIFICATION_PC_KILLING_BLOW", c.UNIT_KILLED)
	EventsTab_AddEvent(category, "NOTIFICATION_NPC_KILLING_BLOW", c.UNIT_KILLED)
	EventsTab_AddEvent(category, "NOTIFICATION_EXTRA_ATTACK", c.EXTRA_ATTACKS .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_ENEMY_BUFF", c.BUFFED_NAME .. c.BUFF_NAME .. c.SKILL_LONG)
	EventsTab_AddEvent(category, "NOTIFICATION_MONSTER_EMOTE", c.EMOTE_TEXT)
end


local function EventsTab_ChangeEventCategory(category)
	local controls = tabFrames.events.controls

	controls.eventsListbox:Clear()
	for index in ipairs(orderedEvents[category]) do
		controls.eventsListbox:AddItem(index)
	end
end


local function EventsTab_EnableControls()
	for name, frame in pairs(tabFrames.events.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


local function EventsTab_MoveAll(scrollArea)
	local events = orderedEvents[tabFrames.events.controls.eventCategoryDropdown:GetSelectedID()]
	for index, eventData in ipairs(events) do
		MSBTProfiles.SetOption("events." .. eventData.eventType, "scrollArea", scrollArea)
	end
end


local function EventsTab_ColorswatchOnChanged(this)
	local eventType = this:GetParent().eventType
	MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
	MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
	MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
end


local function EventsTab_EnableOnClick(this, isChecked)
	local eventType = this:GetParent().eventType
	MSBTProfiles.SetOption("events." .. eventType, "disabled", not isChecked)
end


local function EventsTab_SaveEventSettings(settings, eventType)
	MSBTProfiles.SetOption("events." .. eventType, "soundFile", settings.soundFile)
	MSBTProfiles.SetOption("events." .. eventType, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
	MSBTProfiles.SetOption("events." .. eventType, "message", settings.message)
	MSBTProfiles.SetOption("events." .. eventType, "alwaysSticky", settings.alwaysSticky)

	tabFrames.events.controls.eventsListbox:Refresh()
end


local function EventsTab_SettingsButtonOnClick(this)
	local eventType = this:GetParent().eventType
	local eventSettings = MSBTProfiles.currentProfile.events[eventType]
	local categoryText = tabFrames.events.controls.eventCategoryDropdown:GetSelectedText()

	EraseTable(configTable)
	configTable.title = categoryText .. " - " .. this:GetParent().enableCheckbox.fontString:GetText()
	configTable.message = eventSettings.message
	configTable.soundFile = eventSettings.soundFile
	configTable.codes = this:GetParent().codes
	configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
	configTable.alwaysSticky = eventSettings.alwaysSticky
	configTable.isCrit = eventSettings.isCrit
	configTable.parentFrame = tabFrames.events
	configTable.anchorFrame = tabFrames.events
	configTable.anchorPoint = "TOPRIGHT"
	configTable.relativePoint = "TOPRIGHT"
	configTable.saveHandler = EventsTab_SaveEventSettings
	configTable.saveArg1 = eventType
	configTable.hideHandler = EventsTab_EnableControls
	DisableControls(tabFrames.events.controls)
	MSBTPopups.ShowEvent(configTable)
end


local function EventsTab_SaveFontSettings(settings, eventType)
	local isCrit = MSBTProfiles.currentProfile.events[eventType].isCrit
	MSBTProfiles.SetOption("events." .. eventType, "fontName", isCrit and settings.critFontName or settings.normalFontName)
	MSBTProfiles.SetOption("events." .. eventType, "outlineIndex", isCrit and settings.critOutlineIndex or settings.normalOutlineIndex)
	MSBTProfiles.SetOption("events." .. eventType, "fontSize", isCrit and settings.critFontSize or settings.normalFontSize)
	MSBTProfiles.SetOption("events." .. eventType, "fontAlpha", isCrit and settings.critFontAlpha or settings.normalFontAlpha)
end


local function EventsTab_FontButtonOnClick(this)
	local categoryText = tabFrames.events.controls.eventCategoryDropdown:GetSelectedText()
	local eventType = this:GetParent().eventType
	local eventSettings = MSBTProfiles.currentProfile.events[eventType]

	local saKey = eventSettings.scrollArea
	local saSettings = MSBTProfiles.currentProfile.scrollAreas[saKey]
	if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end

	EraseTable(configTable)
	configTable.title = categoryText .. " - " .. this:GetParent().enableCheckbox.fontString:GetText()

	local fontName
	if (not eventSettings.isCrit) then
		fontName = saSettings.normalFontName
		if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
		if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
		configTable.inheritedNormalFontName = fontName
		configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
		configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
		configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

		fontName = eventSettings.fontName
		if (not fonts[fontName]) then fontName = nil end
		configTable.normalFontName = fontName
		configTable.normalOutlineIndex = eventSettings.outlineIndex
		configTable.normalFontSize = eventSettings.fontSize
		configTable.normalFontAlpha = eventSettings.fontAlpha

		configTable.hideCrit = true
	else
		fontName = saSettings.critFontName
		if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.critFontName end
		if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
		configTable.inheritedCritFontName = fontName
		configTable.inheritedCritOutlineIndex = saSettings.critOutlineIndex or MSBTProfiles.currentProfile.critOutlineIndex
		configTable.inheritedCritFontSize = saSettings.critFontSize or MSBTProfiles.currentProfile.critFontSize
		configTable.inheritedCritFontAlpha = saSettings.critFontAlpha or MSBTProfiles.currentProfile.critFontAlpha

		fontName = eventSettings.fontName
		if (not fonts[fontName]) then fontName = nil end
		configTable.critFontName = fontName
		configTable.critOutlineIndex = eventSettings.outlineIndex
		configTable.critFontSize = eventSettings.fontSize
		configTable.critFontAlpha = eventSettings.fontAlpha

		configTable.hideNormal = true
	end

	configTable.parentFrame = tabFrames.events
	configTable.anchorFrame = tabFrames.events
	configTable.anchorPoint = "BOTTOM"
	configTable.relativePoint = "BOTTOM"
	configTable.saveHandler = EventsTab_SaveFontSettings
	configTable.saveArg1 = eventType
	configTable.hideHandler = EventsTab_EnableControls
	DisableControls(tabFrames.events.controls)
	MSBTPopups.ShowFont(configTable)
end


local function EventsTab_CreateLine(this)
	local controls = tabFrames.events.controls

	local frame = CreateFrame("Button", nil, this)
	frame:EnableMouse(false)

	local colorswatch = MSBTControls.CreateColorswatch(frame)
	colorswatch:SetPoint("LEFT", frame, "LEFT", 5, 0)
	colorswatch:SetColorChangedHandler(EventsTab_ColorswatchOnChanged)
	frame.colorSwatch = colorswatch
	controls[#controls+1] = colorswatch

	local checkbox = MSBTControls.CreateCheckbox(frame)
	checkbox:Configure(24, nil, nil)
	checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
	checkbox:SetPoint("RIGHT", frame, "LEFT", 190, 0)
	checkbox:SetClickHandler(EventsTab_EnableOnClick)
	frame.enableCheckbox = checkbox
	controls[#controls+1] = checkbox

	local button = MSBTControls.CreateIconButton(frame, "Configure")
	local objLocale = L.BUTTONS["eventSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
	button:SetClickHandler(EventsTab_SettingsButtonOnClick)
	controls[#controls+1] = button

	button = MSBTControls.CreateIconButton(frame, "FontSettings")
	objLocale = L.BUTTONS["eventFontSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
	button:SetClickHandler(EventsTab_FontButtonOnClick)
	controls[#controls+1] = button

	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
	fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
	fontString:SetJustifyH("LEFT")
	frame.messageFontString = fontString

	return frame
end


local function EventsTab_DisplayLine(this, line, key, isSelected)
	local events = orderedEvents[tabFrames.events.controls.eventCategoryDropdown:GetSelectedID()]
	local eventType = events[key].eventType
	local eventSettings = MSBTProfiles.currentProfile.events[eventType]
	local objLocale = events[key]
	line.eventType = eventType
	line.codes = events[key].codes

	line.colorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
	line.enableCheckbox:SetLabel(objLocale.label)
	line.enableCheckbox:SetTooltip(objLocale.tooltip)
	line.enableCheckbox:SetChecked(not eventSettings.disabled)
	line.messageFontString:SetText(eventSettings.message)
end


local function EventsTab_Create()
	local tabFrame = tabFrames.events
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local texture = tabFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
	texture:SetHeight(4)
	texture:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -45)
	texture:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", 0, -45)
	texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

	local button = MSBTControls.CreateOptionButton(tabFrame)
	local objLocale = L.BUTTONS["moveAll"]
	button:Configure(15, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 5, 5)
	button:SetClickHandler(
		function (this)
			EraseTable(configTable)
			configTable.title = this:GetText() .. " - " .. controls.eventCategoryDropdown:GetSelectedText()
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.saveHandler = EventsTab_MoveAll
			configTable.hideHandler = EventsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowScrollAreaSelection(configTable)
		end
	)
	controls.moveButton = button

	local button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["toggleAll"]
	button:Configure(15, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", controls.moveButton, "TOPLEFT", 0, 10)
	button:SetClickHandler(
		function (this)
			local events = orderedEvents[controls.eventCategoryDropdown:GetSelectedID()]
			for index, eventData in ipairs(events) do
				MSBTProfiles.SetOption("events." .. eventData.eventType, "disabled", not MSBTProfiles.currentProfile.events[eventData.eventType].disabled)
				controls.eventsListbox:Refresh()
			end
		end
	)
	controls.toggleButton = button

	local dropdown = MSBTControls.CreateDropdown(tabFrame)
	objLocale = L.DROPDOWNS["eventCategory"]
	dropdown:Configure(180, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("BOTTOMRIGHT", texture, "TOPRIGHT", -5, 8)
	dropdown:SetChangeHandler(
		function (this, id)
			EventsTab_ChangeEventCategory(id)
		end
	)
	controls.eventCategoryDropdown = dropdown

	local listbox = MSBTControls.CreateListbox(tabFrame)
	listbox:Configure(400, 300, 25)
	listbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50)
	listbox:SetCreateLineHandler(EventsTab_CreateLine)
	listbox:SetDisplayHandler(EventsTab_DisplayLine)
	controls.eventsListbox = listbox


	EventsTab_SetupEvents()

	for index, category in ipairs(L.EVENT_CATEGORIES) do
		dropdown:AddItem(category, EVENT_CATEGORY_MAP[index])
	end
	dropdown:SetSelectedID(EVENT_CATEGORY_MAP[1])
	EventsTab_ChangeEventCategory(EVENT_CATEGORY_MAP[1])

	tabFrame.created = true
end


local function EventsTab_OnShow()
	if (not tabFrames.events.created) then EventsTab_Create() end

	tabFrames.events.controls.eventsListbox:Refresh()
end



local function LootAlertsTab_EnableControls()
	for name, frame in pairs(tabFrames.lootAlerts.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


local function LootAlertsTab_SaveEventSettings(settings, eventType)
	MSBTProfiles.SetOption("events." .. eventType, "soundFile", settings.soundFile)
	MSBTProfiles.SetOption("events." .. eventType, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
	MSBTProfiles.SetOption("events." .. eventType, "message", settings.message)
	MSBTProfiles.SetOption("events." .. eventType, "alwaysSticky", settings.alwaysSticky)

	local fontString = tabFrames.lootAlerts.lootedItemsFontString
	if (eventType == "NOTIFICATION_MONEY") then fontString = tabFrames.lootAlerts.moneyGainsFontString end
	if (eventType == "NOTIFICATION_CURRENCY") then fontString = tabFrames.lootAlerts.currencyGainsFontString end
	fontString:SetText(settings.message)
end


local function LootAlertsTab_SaveFontSettings(settings, eventType)
	MSBTProfiles.SetOption("events." .. eventType, "fontName", settings.normalFontName)
	MSBTProfiles.SetOption("events." .. eventType, "outlineIndex", settings.normalOutlineIndex)
	MSBTProfiles.SetOption("events." .. eventType, "fontSize", settings.normalFontSize)
	MSBTProfiles.SetOption("events." .. eventType, "fontAlpha", settings.normalFontAlpha)
end


local function LootAlertsTab_Create()
	local tabFrame = tabFrames.lootAlerts
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
	colorswatch:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
	colorswatch:SetColorChangedHandler(
		function (this)
			local eventType = "NOTIFICATION_LOOT"
			MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
			MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
			MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
		end
	)
	controls.lootAlertsColorSwatch = colorswatch

	local checkbox = MSBTControls.CreateCheckbox(tabFrame)
	local objLocale = L.CHECKBOXES["lootedItems"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
	checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption("events.NOTIFICATION_LOOT", "disabled", not isChecked)
		end
	)
	controls.lootedItemsEnableCheckbox = checkbox

	local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
	objLocale = L.BUTTONS["eventSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -5)
	button:SetClickHandler(
		function (this)
			local eventType = "NOTIFICATION_LOOT"
			local eventSettings = MSBTProfiles.currentProfile.events[eventType]

			EraseTable(configTable)
			configTable.title = L.CHECKBOXES.lootedItems.label
			configTable.message = eventSettings.message
			configTable.soundFile = eventSettings.soundFile
			configTable.codes = L.EVENT_CODES["ITEM_AMOUNT"] .. L.EVENT_CODES["ITEM_NAME"] .. L.EVENT_CODES["TOTAL_ITEMS"]
			configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
			configTable.alwaysSticky = eventSettings.alwaysSticky
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = tabFrame
			configTable.anchorPoint = "TOPRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveArg1 = eventType
			configTable.saveHandler = LootAlertsTab_SaveEventSettings
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowEvent(configTable)
		end
	)
	controls.lootAlertsEventSettingButton = button

	button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
	objLocale = L.BUTTONS["eventFontSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls.lootAlertsEventSettingButton, "LEFT", 0, 0)
	button:SetClickHandler(
		function (this)
			local eventType = "NOTIFICATION_LOOT"
			local eventSettings = MSBTProfiles.currentProfile.events[eventType]
			local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
			if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end

			EraseTable(configTable)
			configTable.title = L.CHECKBOXES.lootedItems.label

			local fontName = saSettings.normalFontName
			if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
			if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
			configTable.inheritedNormalFontName = fontName
			configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
			configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
			configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

			fontName = eventSettings.fontName
			if (not fonts[fontName]) then fontName = nil end
			configTable.normalFontName = fontName
			configTable.normalOutlineIndex = eventSettings.outlineIndex
			configTable.normalFontSize = eventSettings.fontSize
			configTable.normalFontAlpha = eventSettings.fontAlpha

			configTable.hideCrit = true
			configTable.parentFrame = tabFrames.lootAlerts
			configTable.anchorFrame = tabFrames.lootAlerts
			configTable.anchorPoint = "BOTTOM"
			configTable.relativePoint = "BOTTOM"
			configTable.saveArg1 = eventType
			configTable.saveHandler = LootAlertsTab_SaveFontSettings
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowFont(configTable)
		end
	)
	controls[#controls+1] = button

	local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
	fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
	fontString:SetJustifyH("LEFT")
	tabFrame.lootedItemsFontString = fontString


	local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
	colorswatch:SetPoint("TOPLEFT", controls.lootAlertsColorSwatch, "BOTTOMLEFT", 0, -10)
	colorswatch:SetColorChangedHandler(
		function (this)
			local eventType = "NOTIFICATION_MONEY"
			MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
			MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
			MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
		end
	)
	controls.moneyGainsColorSwatch = colorswatch

	local checkbox = MSBTControls.CreateCheckbox(tabFrame)
	local objLocale = L.CHECKBOXES["moneyGains"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
	checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption("events.NOTIFICATION_MONEY", "disabled", not isChecked)
		end
	)
	controls.moneyGainsEnableCheckbox = checkbox

	local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
	objLocale = L.BUTTONS["eventSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("TOPRIGHT", controls.lootAlertsEventSettingButton, "BOTTOMRIGHT", 0, -5)
	button:SetClickHandler(
		function (this)
			local eventType = "NOTIFICATION_MONEY"
			local eventSettings = MSBTProfiles.currentProfile.events[eventType]

			EraseTable(configTable)
			configTable.title = L.CHECKBOXES.moneyGains.label
			configTable.message = eventSettings.message
			configTable.soundFile = eventSettings.soundFile
			configTable.codes = L.EVENT_CODES["MONEY_TEXT"]
			configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
			configTable.alwaysSticky = eventSettings.alwaysSticky
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = tabFrame
			configTable.anchorPoint = "TOPRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveArg1 = eventType
			configTable.saveHandler = LootAlertsTab_SaveEventSettings
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowEvent(configTable)
		end
	)
	controls.moneyGainsEventSettingButton = button

	button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
	objLocale = L.BUTTONS["eventFontSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls.moneyGainsEventSettingButton, "LEFT", 0, 0)
	button:SetClickHandler(
		function (this)
			local eventType = "NOTIFICATION_MONEY"
			local eventSettings = MSBTProfiles.currentProfile.events[eventType]
			local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
			if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end

			EraseTable(configTable)
			configTable.title = L.CHECKBOXES.moneyGains.label

			local fontName = saSettings.normalFontName
			if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
			if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
			configTable.inheritedNormalFontName = fontName
			configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
			configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
			configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

			fontName = eventSettings.fontName
			if (not fonts[fontName]) then fontName = nil end
			configTable.normalFontName = fontName
			configTable.normalOutlineIndex = eventSettings.outlineIndex
			configTable.normalFontSize = eventSettings.fontSize
			configTable.normalFontAlpha = eventSettings.fontAlpha

			configTable.hideCrit = true
			configTable.parentFrame = tabFrames.lootAlerts
			configTable.anchorFrame = tabFrames.lootAlerts
			configTable.anchorPoint = "BOTTOM"
			configTable.relativePoint = "BOTTOM"
			configTable.saveArg1 = eventType
			configTable.saveHandler = LootAlertsTab_SaveFontSettings
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowFont(configTable)
		end
	)
	controls[#controls+1] = button

	local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
	fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
	fontString:SetJustifyH("LEFT")
	tabFrame.moneyGainsFontString = fontString


	local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
	colorswatch:SetPoint("TOPLEFT", controls.moneyGainsColorSwatch, "BOTTOMLEFT", 0, -10)
	colorswatch:SetColorChangedHandler(
		function (this)
			local eventType = "NOTIFICATION_CURRENCY"
			MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
			MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
			MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
		end
	)
	controls.currencyGainsColorSwatch = colorswatch

	local checkbox = MSBTControls.CreateCheckbox(tabFrame)
	local objLocale = L.CHECKBOXES["currencyGains"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
	checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption("events.NOTIFICATION_CURRENCY", "disabled", not isChecked)
		end
	)
	controls.currencyGainsEnableCheckbox = checkbox

	local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
	objLocale = L.BUTTONS["eventSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("TOPRIGHT", controls.moneyGainsEventSettingButton, "BOTTOMRIGHT", 0, -5)
	button:SetClickHandler(
		function (this)
			local eventType = "NOTIFICATION_CURRENCY"
			local eventSettings = MSBTProfiles.currentProfile.events[eventType]

			EraseTable(configTable)
			configTable.title = L.CHECKBOXES.currencyGains.label
			configTable.message = eventSettings.message
			configTable.soundFile = eventSettings.soundFile
			configTable.codes = L.EVENT_CODES["ITEM_AMOUNT"] .. L.EVENT_CODES["ITEM_NAME"] .. L.EVENT_CODES["TOTAL_ITEMS"]
			configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
			configTable.alwaysSticky = eventSettings.alwaysSticky
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = tabFrame
			configTable.anchorPoint = "TOPRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveArg1 = eventType
			configTable.saveHandler = LootAlertsTab_SaveEventSettings
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowEvent(configTable)
		end
	)
	controls.currencyGainsEventSettingButton = button

	button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
	objLocale = L.BUTTONS["eventFontSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls.currencyGainsEventSettingButton, "LEFT", 0, 0)
	button:SetClickHandler(
		function (this)
			local eventType = "NOTIFICATION_CURRENCY"
			local eventSettings = MSBTProfiles.currentProfile.events[eventType]
			local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
			if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end

			EraseTable(configTable)
			configTable.title = L.CHECKBOXES.currencyGains.label

			local fontName = saSettings.normalFontName
			if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
			if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
			configTable.inheritedNormalFontName = fontName
			configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
			configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
			configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

			fontName = eventSettings.fontName
			if (not fonts[fontName]) then fontName = nil end
			configTable.normalFontName = fontName
			configTable.normalOutlineIndex = eventSettings.outlineIndex
			configTable.normalFontSize = eventSettings.fontSize
			configTable.normalFontAlpha = eventSettings.fontAlpha

			configTable.hideCrit = true
			configTable.parentFrame = tabFrames.lootAlerts
			configTable.anchorFrame = tabFrames.lootAlerts
			configTable.anchorPoint = "BOTTOM"
			configTable.relativePoint = "BOTTOM"
			configTable.saveArg1 = eventType
			configTable.saveHandler = LootAlertsTab_SaveFontSettings
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowFont(configTable)
		end
	)
	controls[#controls+1] = button

	local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
	fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
	fontString:SetJustifyH("LEFT")
	tabFrame.currencyGainsFontString = fontString

	local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("TOPLEFT", controls.currencyGainsColorSwatch, "BOTTOMLEFT", 0, -30)
	fontString:SetJustifyH("LEFT")
	fontString:SetText(L.MSG_ITEM_QUALITIES .. ":")

	local anchor = fontString
	for quality = LE_ITEM_QUALITY_POOR or Enum.ItemQuality.Poor, LE_ITEM_QUALITY_EPIC or Enum.ItemQuality.Epic do
		local checkbox = MSBTControls.CreateCheckbox(tabFrame)
		local label = _G["ITEM_QUALITY" .. quality .. "_DESC"]
		local color = ITEM_QUALITY_COLORS[quality]
		if color then label = string.format("|cFF%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, label) end
		checkbox:Configure(24, label, L.MSG_DISPLAY_QUALITY)
		checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == fontString and 5 or 0, anchor == fontString and -10 or 0)
		checkbox:SetClickHandler(
			function (this, isChecked)
				MSBTProfiles.SetOption("qualityExclusions", quality, not isChecked)
			end
		)
		controls["quality" .. quality .. "Checkbox"] = checkbox
		anchor = checkbox
	end

	local checkbox = MSBTControls.CreateCheckbox(tabFrame)
	local objLocale = L.CHECKBOXES["alwaysShowQuestItems"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.quality0Checkbox, "TOPRIGHT", 100, 0)
		checkbox:SetClickHandler(
			function (this, isChecked)
				MSBTProfiles.SetOption(nil, "alwaysShowQuestItems", isChecked)
			end
		)
	controls.alwaysShowQuestItemsCheckbox = checkbox

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["itemsAllowed"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", tabFrame, "BOTTOMLEFT", 5, 40)
	button:SetClickHandler(
		function (this)
			local listName = "itemsAllowed"
			PopulateList(listName)
			EraseTable(configTable)
			configTable.title = this:GetText()
			configTable.items = listTable
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = tabFrame
			configTable.anchorPoint = "TOPRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveHandler = SaveList
			configTable.saveArg1 = listName
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowItemList(configTable)
		end
	)
	controls.itemsAllowedButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["itemExclusions"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -10, 40)
	button:SetClickHandler(
		function (this)
			local listName = "itemExclusions"
			PopulateList(listName)
			EraseTable(configTable)
			configTable.title = this:GetText()
			configTable.items = listTable
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = tabFrame
			configTable.anchorPoint = "TOPRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveHandler = SaveList
			configTable.saveArg1 = listName
			configTable.hideHandler = LootAlertsTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowItemList(configTable)
		end
	)
	controls.itemExclusionsButton = button

	tabFrame.created = true
end


local function LootAlertsTab_OnShow()
	if (not tabFrames.lootAlerts.created) then LootAlertsTab_Create() end

	local tabFrame = tabFrames.lootAlerts
	local controls = tabFrame.controls
	local currentProfile = MSBTProfiles.currentProfile

	local eventSettings = currentProfile.events["NOTIFICATION_LOOT"]
	controls.lootAlertsColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
	controls.lootedItemsEnableCheckbox:SetChecked(not eventSettings.disabled)
	tabFrame.lootedItemsFontString:SetText(eventSettings.message)

	local eventSettings = currentProfile.events["NOTIFICATION_MONEY"]
	controls.moneyGainsColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
	controls.moneyGainsEnableCheckbox:SetChecked(not eventSettings.disabled)
	tabFrame.moneyGainsFontString:SetText(eventSettings.message)

	local eventSettings = currentProfile.events["NOTIFICATION_CURRENCY"]
	controls.currencyGainsColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
	controls.currencyGainsEnableCheckbox:SetChecked(not eventSettings.disabled)
	tabFrame.currencyGainsFontString:SetText(eventSettings.message)


	for quality = LE_ITEM_QUALITY_POOR or Enum.ItemQuality.Poor, LE_ITEM_QUALITY_EPIC or Enum.ItemQuality.Epic do
		controls["quality" .. quality .. "Checkbox"]:SetChecked(not currentProfile.qualityExclusions[quality])
	end

	controls.alwaysShowQuestItemsCheckbox:SetChecked(currentProfile.alwaysShowQuestItems)
end



local function LanguageTab_Create()
	local tabFrame = tabFrames.language
	tabFrame.controls = {}

	local localeMap = {
		enUS = "English (US)",
		deDE = "Deutsch",
		frFR = "Francais",
		itIT = "Italiano",
		koKR = "Korean",
		ruRU = "Russian",
		zhCN = "Chinese (Simplified)",
		zhTW = "Chinese (Traditional)",
	}

	local localeID = GetLocale()
	local localeName = localeMap[localeID] or localeID

	local header = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	header:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 10, -18)
	header:SetText("Language")
	tabFrame.headerFontString = header

	local current = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
	current:SetJustifyH("LEFT")
	current:SetText("Current game locale: " .. localeName .. " (" .. localeID .. ")")
	tabFrame.currentLocaleFontString = current

	local body = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	body:SetPoint("TOPLEFT", current, "BOTTOMLEFT", 0, -12)
	body:SetPoint("RIGHT", tabFrame, "RIGHT", -14, 0)
	body:SetJustifyH("LEFT")
	body:SetJustifyV("TOP")
	body:SetText(
		"MSBT uses your game client locale. In-addon language switching is not supported because localization is loaded at startup based on GetLocale().\n\n"
		.. "To use another language, change the game language in the Battle.net app, then restart/reload the game UI."
	)
	tabFrame.languageInfoFontString = body

	tabFrame.created = true
end


local function LanguageTab_OnShow()
	if (not tabFrames.language.created) then LanguageTab_Create() end
end



local function ResetBlizzardSCTTab_EnableControls()
	for _, frame in pairs(tabFrames.resetBlizzardSCT.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end

local function ResetBlizzardSCTTab_ConfirmReset()
	MSBTProfiles.ResetOfficialBlizzardCombatText()
	RefreshGeneralTabIfCreated()
	Print("Blizzard scrolling combat text restored.", 0, 1, 0)
end

local function ResetBlizzardSCTTab_Create()
	local tabFrame = tabFrames.resetBlizzardSCT
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local header = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	header:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 10, -18)
	header:SetText("Reset Blizzard SCT")
	tabFrame.headerFontString = header

	local body = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
	body:SetPoint("RIGHT", tabFrame, "RIGHT", -14, 0)
	body:SetJustifyH("LEFT")
	body:SetJustifyV("TOP")
	body:SetText(
		"Use this to restore Blizzard's scrolling combat text for damage, periodic damage, and pet damage.\n\n"
		.. "This also clears MSBT's Blizzard combat text override checkboxes so MSBT stops changing those CVars."
	)
	tabFrame.bodyFontString = body

	local button = MSBTControls.CreateOptionButton(tabFrame)
	local objLocale = L.BUTTONS["resetBlizzardSCT"] or {
		label = "Reset Blizzard SCT",
		tooltip = "Restore Blizzard scrolling combat text settings and stop MSBT from overriding them.",
	}
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -20)
	button:SetClickHandler(
		function(this)
			EraseTable(configTable)
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.acknowledgeHandler = ResetBlizzardSCTTab_ConfirmReset
			configTable.hideHandler = ResetBlizzardSCTTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowAcknowledge(configTable)
		end
	)
	controls.resetButton = button

	tabFrame.created = true
end

local function ResetBlizzardSCTTab_OnShow()
	if (not tabFrames.resetBlizzardSCT.created) then
		ResetBlizzardSCTTab_Create()
	end
end


-- ****************************************************************************
-- Enables the controls on the triggers tab.
-- ****************************************************************************
local function TriggersTab_EnableControls()
	for name, frame in pairs(tabFrames.triggers.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


-- ****************************************************************************
-- Saves the trigger settings selected by the user.
-- ****************************************************************************
local function TriggersTab_SaveTriggerSettings(settings, triggerKey)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "classes", settings.classes)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "mainEvents", settings.mainEvents)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "exceptions", settings.exceptions)
	MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Adds a new trigger with the passed output message.
-- ****************************************************************************
local function TriggersTab_AddTrigger(settings)
	local nextAvailable = 1
	while (MSBTProfiles.currentProfile.triggers["Custom" .. nextAvailable]) do
		nextAvailable = nextAvailable + 1
	end

	local newKey = "Custom" .. nextAvailable
	local triggerSettings = {}
	triggerSettings.message = settings.inputText
	triggerSettings.alwaysSticky = true
	triggerSettings.fontSize = 26
	MSBTProfiles.SetOption("triggers", newKey, triggerSettings)
	MSBTTriggers.UpdateTriggers()
	tabFrames.triggers.controls.triggersListbox:AddItem(newKey, true)

	-- Launch the trigger settings dialog for the new trigger.
	EraseTable(configTable)
	configTable.title = settings.inputText
	configTable.triggerKey = newKey
	configTable.parentFrame = tabFrames.triggers
	configTable.anchorFrame = tabFrames.triggers
	configTable.anchorPoint = "RIGHT"
	configTable.relativePoint = "RIGHT"
	configTable.saveHandler = TriggersTab_SaveTriggerSettings
	configTable.saveArg1 = newKey
	configTable.hideHandler = TriggersTab_EnableControls
	DisableControls(tabFrames.triggers.controls)
	MSBTPopups.ShowTrigger(configTable)
end


-- ****************************************************************************
-- Called when one of the trigger color swatches is changed.
-- ****************************************************************************
local function TriggersTab_ColorswatchOnChanged(this)
	local triggerKey = this:GetParent().triggerKey
	MSBTProfiles.SetOption("triggers." .. triggerKey, "colorR", this.r, 1)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "colorG", this.g, 1)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "colorB", this.b, 1)
	MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the trigger enable checkboxes is clicked.
-- ****************************************************************************
local function TriggersTab_EnableOnClick(this, isChecked)
	local triggerKey = this:GetParent().triggerKey
	MSBTProfiles.SetOption("triggers." .. triggerKey, "disabled", not isChecked)
	MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the trigger settings buttons is clicked.
-- ****************************************************************************
local function TriggersTab_TriggerSettingsButtonOnClick(this)
	local triggerKey = this:GetParent().triggerKey
	local triggerSettings = MSBTProfiles.currentProfile.triggers[triggerKey]

	EraseTable(configTable)
	configTable.title = this:GetParent().enableCheckbox.fontString:GetText()
	configTable.triggerKey = triggerKey
	configTable.parentFrame = tabFrames.triggers
	configTable.anchorFrame = tabFrames.triggers
	configTable.anchorPoint = "RIGHT"
	configTable.relativePoint = "RIGHT"
	configTable.saveHandler = TriggersTab_SaveTriggerSettings
	configTable.saveArg1 = triggerKey
	configTable.hideHandler = TriggersTab_EnableControls
	DisableControls(tabFrames.triggers.controls)
	MSBTPopups.ShowTrigger(configTable)
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function TriggersTab_SaveFontSettings(settings, triggerKey)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "fontName", settings.normalFontName)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "outlineIndex", settings.normalOutlineIndex)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "fontSize", settings.normalFontSize)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "fontAlpha", settings.normalFontAlpha)
	MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the font settings buttons is clicked.
-- ****************************************************************************
local function TriggersTab_FontButtonOnClick(this)
	local triggerKey = this:GetParent().triggerKey
	local triggerSettings = MSBTProfiles.currentProfile.triggers[triggerKey]

	local saKey = triggerSettings.scrollArea
	local saSettings = MSBTProfiles.currentProfile.scrollAreas[saKey]
	if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end

	EraseTable(configTable)
	configTable.title = this:GetParent().enableCheckbox.fontString:GetText()

	local fontName
	fontName = saSettings.normalFontName
	if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
	if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
	configTable.inheritedNormalFontName = fontName
	configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
	configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
	configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

	fontName = triggerSettings.fontName
	if (not fonts[fontName]) then fontName = nil end
	configTable.normalFontName = fontName
	configTable.normalOutlineIndex = triggerSettings.outlineIndex
	configTable.normalFontSize = triggerSettings.fontSize
	configTable.normalFontAlpha = triggerSettings.fontAlpha

	configTable.hideCrit = true


	configTable.parentFrame = tabFrames.triggers
	configTable.anchorFrame = tabFrames.triggers
	configTable.anchorPoint = "BOTTOM"
	configTable.relativePoint = "BOTTOM"
	configTable.saveHandler = TriggersTab_SaveFontSettings
	configTable.saveArg1 = triggerKey
	configTable.hideHandler = TriggersTab_EnableControls
	DisableControls(tabFrames.triggers.controls)
	MSBTPopups.ShowFont(configTable)
end


-- ****************************************************************************
-- Saves the additional event settings selected by the user.
-- ****************************************************************************
local function TriggersTab_SaveEventSettings(settings, triggerKey)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "message", settings.message)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "alwaysSticky", settings.alwaysSticky)
	MSBTProfiles.SetOption("triggers." .. triggerKey, "soundFile", settings.soundFile, "")
	MSBTProfiles.SetOption("triggers." .. triggerKey, "iconSkill", settings.iconSkill, "")
	MSBTTriggers.UpdateTriggers()

	tabFrames.triggers.controls.triggersListbox:Refresh()
end


-- ****************************************************************************
-- Called when one of the event settings buttons is clicked.
-- ****************************************************************************
local function TriggersTab_EventSettingsButtonOnClick(this)
	local triggerKey = this:GetParent().triggerKey
	local triggerSettings = MSBTProfiles.currentProfile.triggers[triggerKey]

	EraseTable(configTable)
	configTable.title = this:GetParent().enableCheckbox.fontString:GetText()
	configTable.message = triggerSettings.message
	configTable.scrollArea = triggerSettings.scrollArea or DEFAULT_SCROLL_AREA
	configTable.alwaysSticky = triggerSettings.alwaysSticky
	configTable.soundFile = triggerSettings.soundFile
	configTable.showIconSkillEditbox = true
	configTable.iconSkill = triggerSettings.iconSkill
	configTable.parentFrame = tabFrames.triggers
	configTable.anchorFrame = tabFrames.triggers
	configTable.anchorPoint = "TOPRIGHT"
	configTable.relativePoint = "TOPRIGHT"
	configTable.saveHandler = TriggersTab_SaveEventSettings
	configTable.saveArg1 = triggerKey
	configTable.hideHandler = TriggersTab_EnableControls
	DisableControls(tabFrames.triggers.controls)
	MSBTPopups.ShowEvent(configTable)
end


-- ****************************************************************************
-- Deletes the trigger for the passed line and removes the line.
-- ****************************************************************************
local function TriggersTab_DeleteTrigger(line)
	MSBTProfiles.SetOption("triggers", line.triggerKey, false)
	tabFrames.triggers.controls.triggersListbox:RemoveItem(line.itemNumber)
	MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the delete buttons is clicked.
-- ****************************************************************************
local function TriggersTab_DeleteButtonOnClick(this)
	EraseTable(configTable)
	configTable.parentFrame = tabFrames.triggers
	configTable.anchorFrame = this
	configTable.anchorPoint = this:GetParent().lineNumber > 5 and "BOTTOMRIGHT" or "TOPRIGHT"
	configTable.relativePoint = this:GetParent().lineNumber > 5 and "TOPRIGHT" or "BOTTOMRIGHT"
	configTable.acknowledgeHandler = TriggersTab_DeleteTrigger
	configTable.saveArg1 = this:GetParent()
	configTable.hideHandler = TriggersTab_EnableControls
	DisableControls(tabFrames.triggers.controls)
	MSBTPopups.ShowAcknowledge(configTable)
end


-- ****************************************************************************
-- Called by listbox to create a line for triggers.
-- ****************************************************************************
local function TriggersTab_CreateLine(this)
	local controls = tabFrames.triggers.controls

	local frame = CreateFrame("Button", nil, this)
	frame:EnableMouse(false)

	-- Event colorswatch.
	local colorswatch = MSBTControls.CreateColorswatch(frame)
	colorswatch:SetPoint("LEFT", frame, "LEFT", 5, 0)
	colorswatch:SetColorChangedHandler(TriggersTab_ColorswatchOnChanged)
	frame.colorSwatch = colorswatch
	controls[#controls+1] = colorswatch

	-- Enable checkbox.
	local checkbox = MSBTControls.CreateCheckbox(frame)
	local objLocale = L.CHECKBOXES["enableTrigger"]
	checkbox:Configure(24, nil, objLocale.tooltip)
	checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
	checkbox:SetPoint("RIGHT", frame, "LEFT", 190, 0)
	checkbox:SetClickHandler(TriggersTab_EnableOnClick)
	frame.enableCheckbox = checkbox
	controls[#controls+1] = checkbox

	-- Delete trigger button.
	local button = MSBTControls.CreateIconButton(frame, "Delete")
	objLocale = L.BUTTONS["deleteTrigger"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
	button:SetClickHandler(TriggersTab_DeleteButtonOnClick)
	controls[#controls+1] = button

	-- Event settings button.
	button = MSBTControls.CreateIconButton(frame, "Configure")
	objLocale = L.BUTTONS["eventSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
	button:SetClickHandler(TriggersTab_EventSettingsButtonOnClick)
	controls[#controls+1] = button

	-- Event font settings button.
	button = MSBTControls.CreateIconButton(frame, "FontSettings")
	objLocale = L.BUTTONS["eventFontSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
	button:SetClickHandler(TriggersTab_FontButtonOnClick)
	controls[#controls+1] = button

	-- Trigger settings button.
	button = MSBTControls.CreateIconButton(frame, "TriggerSettings")
	objLocale = L.BUTTONS["triggerSettings"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
	button:SetClickHandler(TriggersTab_TriggerSettingsButtonOnClick)
	controls[#controls+1] = button

	return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function TriggersTab_DisplayLine(this, line, key, isSelected)
	local triggerSettings = MSBTProfiles.currentProfile.triggers[key]
	line.triggerKey = key

	line.colorSwatch:SetColor(triggerSettings.colorR or 1, triggerSettings.colorG or 1, triggerSettings.colorB or 1)
	line.enableCheckbox:SetLabel(triggerSettings.message)
	line.enableCheckbox:SetChecked(not triggerSettings.disabled)
end


-- ****************************************************************************
-- Creates the triggers tab frame contents.
-- ****************************************************************************
local function TriggersTab_Create()
	local tabFrame = tabFrames.triggers
	tabFrame.controls = {}
	local controls = tabFrame.controls

	-- Horizontal bar.
	local texture = tabFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
	texture:SetHeight(4)
	texture:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -45)
	texture:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", 0, -45)
	texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

	-- Add trigger button.
	local button = MSBTControls.CreateOptionButton(tabFrame)
	local objLocale = L.BUTTONS["addTrigger"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 5, 15)
	button:SetClickHandler(
		function (this)
			objLocale = L.EDITBOXES["eventMessage"]
			EraseTable(configTable)
			configTable.defaultText = L.MSG_NEW_TRIGGER
			configTable.editboxLabel = objLocale.label
			configTable.editboxTooltip = objLocale.tooltip
			configTable.parentFrame = tabFrames.triggers
			configTable.anchorFrame = this
			configTable.saveHandler = TriggersTab_AddTrigger
			configTable.hideHandler = TriggersTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowInput(configTable)
		end
	)
	controls.addTriggerButton = button


	-- Triggers listbox.
	local listbox = MSBTControls.CreateListbox(tabFrame)
	listbox:Configure(400, 300, 25)
	listbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50)
	listbox:SetCreateLineHandler(TriggersTab_CreateLine)
	listbox:SetDisplayHandler(TriggersTab_DisplayLine)
	controls.triggersListbox = listbox

	-- Reusable table for triggers.
	tabFrame.triggerTable = {}

	tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function TriggersTab_OnShow()
	if (not tabFrames.triggers.created) then TriggersTab_Create() end

	-- Set the frame up to populate the profile options when it is shown.
	local triggersListbox = tabFrames.triggers.controls.triggersListbox

	-- Get triggers from the current profile.
	local triggerTable = tabFrames.triggers.triggerTable
	EraseTable(triggerTable)
	local currentProfileTriggers = rawget(MSBTProfiles.currentProfile, "triggers")
	if (currentProfileTriggers) then
		for triggerKey, triggerSettings in pairs(currentProfileTriggers) do
			if (triggerSettings) then triggerTable[triggerKey] = triggerSettings.message end
		end
	end

	-- Get triggers available in the master profile that aren't in the current profile.
	for triggerKey, triggerSettings in pairs(MSBTProfiles.masterProfile.triggers) do
		if (not currentProfileTriggers or rawget(currentProfileTriggers, triggerKey) == nil) then
			triggerTable[triggerKey] = triggerSettings.message
		end
	end

	-- Set the frame up to populate the profile options when it is shown.
	local listbox = tabFrames.triggers.controls.triggersListbox
	local sortedKeys = SortKeysByValue(triggerTable)

	local previousOffset = listbox:GetOffset()
	listbox:Clear()
	for _, key in ipairs(sortedKeys) do
		listbox:AddItem(key)
	end
	listbox:SetOffset(previousOffset)
end


local function SpamTab_EnableControls()
	local controls = tabFrames.spam.controls
	for name, frame in pairs(controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


local function SpamTab_Create()
	local tabFrame = tabFrames.spam
	tabFrame.controls = {}
	local controls = tabFrame.controls

	local checkbox, objLocale
	local previous
	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["hideSkills"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	if previous then
		checkbox:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
	else
		checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
	end
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "hideSkills", isChecked)
		end
	)
	controls.hideSkillsCheckbox = checkbox
	previous = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["hideNames"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	if previous then
		checkbox:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
	else
		checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
	end
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "hideNames", isChecked)
		end
	)
	controls.hideNamesCheckbox = checkbox
	previous = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["abbreviateSkills"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	if previous then
		checkbox:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
	else
		checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
	end
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "abbreviateAbilities", isChecked)
		end
	)
	controls.abbreviateCheckbox = checkbox
	previous = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["groupNumbers"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	if previous then
		checkbox:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
	else
		checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
	end
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "groupNumbers", isChecked)
		end
	)
	controls.groupNumbersCheckbox = checkbox
	previous = checkbox

	checkbox = MSBTControls.CreateCheckbox(tabFrame)
	objLocale = L.CHECKBOXES["allPowerGains"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	if previous then
		checkbox:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
	else
		checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
	end
	checkbox:SetClickHandler(
		function (this, isChecked)
			MSBTProfiles.SetOption(nil, "showAllPowerGains", isChecked)
		end
	)
	controls.allPowerCheckbox = checkbox
	previous = checkbox

	local button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["skillSubstitutions"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -10, 15)
	button:SetClickHandler(
		function (this)
			local listName = "abilitySubstitutions"
			PopulateList(listName)
			EraseTable(configTable)
			configTable.title = this:GetText()
			configTable.skills = listTable
			configTable.listType = "substitution"
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.anchorPoint = "BOTTOMRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveHandler = SaveList
			configTable.saveArg1 = listName
			configTable.hideHandler = SpamTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowSkillList(configTable)
		end
	)
	controls.skillSubstitutionsButton = button

	button = MSBTControls.CreateOptionButton(tabFrame)
	objLocale = L.BUTTONS["skillSuppressions"]
	button:Configure(20, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", controls.skillSubstitutionsButton, "TOPLEFT", 0, 10)
	button:SetClickHandler(
		function (this)
			local listName = "abilitySuppressions"
			PopulateList(listName)
			EraseTable(configTable)
			configTable.title = this:GetText()
			configTable.skills = listTable
			configTable.parentFrame = tabFrame
			configTable.anchorFrame = this
			configTable.anchorPoint = "BOTTOMRIGHT"
			configTable.relativePoint = "TOPRIGHT"
			configTable.saveHandler = SaveList
			configTable.saveArg1 = listName
			configTable.hideHandler = SpamTab_EnableControls
			DisableControls(controls)
			MSBTPopups.ShowSkillList(configTable)
		end
	)
	controls.skillSuppressionsButton = button

	tabFrame.created = true
end


local function SpamTab_OnShow()
	if (not tabFrames.spam.created) then SpamTab_Create() end

	local currentProfile = MSBTProfiles.currentProfile
	local controls = tabFrames.spam.controls

	controls.hideSkillsCheckbox:SetChecked(currentProfile.hideSkills)
	controls.hideNamesCheckbox:SetChecked(currentProfile.hideNames)
	controls.abbreviateCheckbox:SetChecked(currentProfile.abbreviateAbilities)
	controls.groupNumbersCheckbox:SetChecked(currentProfile.groupNumbers)
	controls.allPowerCheckbox:SetChecked(currentProfile.showAllPowerGains)
end






-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

local objLocale = L.TABS.general
local tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", GeneralTab_OnShow)
tabFrames.general = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

objLocale = L.TABS.profile or { label = "Profile", tooltip = "Manage profiles and profile switching." }
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", ProfileTab_OnShow)
tabFrames.profile = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip, 8999.5)

objLocale = L.TABS.scrollAreas
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", ScrollAreasTab_OnShow)
tabFrames.scrollAreas = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

objLocale = L.TABS.events
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", EventsTab_OnShow)
tabFrames.events = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the triggers tab that will be dynamically created when shown.
objLocale = L.TABS.triggers or { label = "Triggers", tooltip = "Display options for the trigger system.\n\nMouse over the icon buttons for more information." }
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", TriggersTab_OnShow)
tabFrames.triggers = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the spam tab that will be dynamically created when shown.
objLocale = L.TABS.spamControl or { label = "Spam Control", tooltip = "Display options for controlling spam." }
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", SpamTab_OnShow)
tabFrames.spam = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the loot alerts tab that will be dynamically created when shown.
objLocale = L.TABS.lootAlerts
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", LootAlertsTab_OnShow)
tabFrames.lootAlerts = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the language tab that will be dynamically created when shown.
objLocale = L.TABS.language or { label = "Language", tooltip = "Shows the current locale and language behavior." }
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", LanguageTab_OnShow)
tabFrames.language = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip, 9500)

objLocale = L.TABS.resetBlizzardSCT or { label = "Reset Blizzard SCT", tooltip = "Restore Blizzard scrolling combat text CVars and clear MSBT Blizzard CT overrides." }
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", ResetBlizzardSCTTab_OnShow)
tabFrames.resetBlizzardSCT = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip, 9000)

