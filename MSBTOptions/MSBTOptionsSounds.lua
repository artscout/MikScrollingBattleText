local module = {}
MSBTOptions.Sounds = module

local Controls = MSBTOptions.Controls
local Popups = MSBTOptions.Popups
local Media = MikSBT.Media
local SoundAPI = MikSBT.API.Sounds
local L = MikSBT.translations

local function ValidateRegistration(name, file)
	if type(name) ~= "string" or name:match("^%s*$") then
		return L.MSG_INVALID_CUSTOM_SOUND_NAME
	end
	if name == "None" or Media.sounds[name] then
		return L.MSG_SOUND_NAME_ALREADY_EXISTS
	end
	if not SoundAPI:NormalizeFile(file) then return L.MSG_INVALID_SOUND_FILE end
end

function module.ShowAddSound(parent, anchor, hideHandler)
	local nameLocale = L.EDITBOXES.customSoundName
	local pathLocale = L.EDITBOXES.customSoundPath
	Popups.ShowInput({
		title = L.BUTTONS.addCustomSound.label,
		parentFrame = parent,
		anchorFrame = anchor,
		anchorPoint = "BOTTOMLEFT",
		relativePoint = "TOPLEFT",
		editboxLabel = nameLocale.label,
		editboxTooltip = nameLocale.tooltip,
		showSecondEditbox = true,
		secondEditboxLabel = pathLocale.label,
		secondEditboxTooltip = pathLocale.tooltip,
		validateHandler = ValidateRegistration,
		hideHandler = hideHandler,
		saveHandler = function(settings)
			local name = settings.inputText
			local file = SoundAPI:NormalizeFile(settings.secondInputText)
			local problem = ValidateRegistration(name, file)
			if problem then MikSBT.Print(problem); return end
			if Media.RegisterSound(name, file) then
				local saved = MikSBT.Profiles.savedMedia
				if type(saved.sounds) ~= "table" then saved.sounds = {} end
				saved.sounds[name] = file
			end
		end,
	})
end

function module.PopulateEventSound(frame, selected)
	local dropdown = frame.controls.soundDropdown
	dropdown:Clear()
	for name in Media.IterateSounds() do dropdown:AddItem(name, name) end
	dropdown:Sort()
	dropdown:AddItem(NONE, "")
	if selected and selected ~= "" and not Media.sounds[selected] then
		dropdown:AddItem(tostring(selected), selected)
	end
	dropdown:SetSelectedID(selected or "")
end

function module.CreateEventControls(frame, enableControls)
	local controls = frame.controls
	local locale = L.DROPDOWNS.sound
	local dropdown = Controls.CreateDropdown(frame)
	dropdown:Configure(150, locale.label, locale.tooltip)
	dropdown:SetPoint("TOPLEFT", controls.messageEditbox, "BOTTOMLEFT", 0, -20)
	controls.soundDropdown = dropdown

	local custom = Controls.CreateIconButton(frame, "Configure")
	custom:SetTooltip(L.BUTTONS.customSound.tooltip)
	custom:SetPoint("LEFT", dropdown, "RIGHT", 10, -5)
	custom:SetClickHandler(function()
		Popups.DisableControls(controls)
		Popups.ShowInput({
			parentFrame = frame,
			anchorFrame = custom,
			editboxLabel = L.EDITBOXES.soundFile.label,
			editboxTooltip = L.EDITBOXES.soundFile.tooltip,
			validateHandler = function(file)
				if not SoundAPI:NormalizeFile(file) then
					return L.MSG_INVALID_SOUND_FILE
				end
			end,
			saveHandler = function(settings)
				local file = SoundAPI:NormalizeFile(settings.inputText)
				if file then module.PopulateEventSound(frame, file) end
			end,
			hideHandler = enableControls,
		})
	end)
	controls.customSoundButton = custom

	local play = Controls.CreateOptionButton(frame)
	locale = L.BUTTONS.playSound
	play:Configure(20, locale.label, locale.tooltip)
	play:SetPoint("LEFT", custom, "RIGHT", 10, 0)
	play:SetClickHandler(function()
		local selected = dropdown:GetSelectedID()
		if not selected or selected == "" then return end
		if not Media.PlaySound(selected) then
			MikSBT.Print(L.MSG_SOUND_PLAYBACK_FAILED)
		end
	end)
	controls.playSoundButton = play
end
