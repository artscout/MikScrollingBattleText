
local module = {}
local moduleName = "Popups"
MSBTOptions[moduleName] = module



local MSBTControls = MSBTOptions.Controls
local MSBTProfiles = MikSBT.Profiles
local MSBTAnimations = MikSBT.Animations
local MSBTMain = MikSBT.Main
local MSBTMedia = MikSBT.Media
local L = MikSBT.translations

local EraseTable = MikSBT.EraseTable

local fonts = MSBTMedia.fonts

local Client = MikSBT.Compatibility.Client
local IsCataClassic = Client.isCataClassic
local IsVanillaClassic = Client.isVanillaContent




local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROME,OUTLINE", "MONOCHROME,THICKOUTLINE"}
local DEFAULT_TEXT_ALIGN_INDEX = 2
local DEFAULT_SCROLL_HEIGHT = 260
local DEFAULT_SCROLL_WIDTH = 40
local DEFAULT_ANIMATION_STYLE = "Straight"
local DEFAULT_STICKY_ANIMATION_STYLE = "Pow"
local DEFAULT_ICON_ALIGN = "Left"
local PREVIEW_ICON_PATH = "Interface\\Icons\\INV_Misc_AhnQirajTrinket_03"

local CLASS_NAMES = {}


local _

local popupFrames = {}

local moverBackdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
}

local returnSettings = {}

local tempConfig = {}



local function OnHidePopup(this)
	PlaySound(799)
	if (this.hideHandler) then this.hideHandler() end
end


local function CreateMenuArtwork(frame, topHeight)
	topHeight = topHeight or 128
	local artworkPath = "Interface\\PaperDollInfoFrame\\UI-Character-General-"
	local sections = {
		{ texture = "TopLeft", x = 0, width = 256,
			coords = { 0, 1, 0, topHeight / 256 } },
		{ texture = "TopLeft", x = 256,
			coords = { 0.45, 0.95, 0, topHeight / 256 } },
		{ texture = "TopRight", width = 100,
			coords = { 0, 0.78125, 0, topHeight / 256 } },
		{ texture = "BottomLeft", x = 0, width = 256,
			coords = { 0, 1, 0, 0.71875 } },
		{ texture = "BottomLeft", x = 256,
			coords = { 0.5, 1, 0, 0.71875 } },
		{ texture = "BottomRight", width = 100,
			coords = { 0, 0.78125, 0, 0.71875 } },
	}
	for index, section in ipairs(sections) do
		local texture = frame:CreateTexture(nil, "BACKGROUND")
		texture:SetTexture(artworkPath .. section.texture)
		texture:SetTexCoord(unpack(section.coords))
		local y = index <= 3 and 0 or -topHeight
		if section.x then
			texture:SetPoint("TOPLEFT", frame, "TOPLEFT", section.x, y)
		end
		if not section.x or not section.width then
			local x = section.width and 0 or -100
			texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", x, y)
		end
		if section.width then texture:SetWidth(section.width) end
		if index <= 3 then
			texture:SetHeight(topHeight)
		else
			local anchor = section.x and "BOTTOMLEFT" or "BOTTOMRIGHT"
			texture:SetPoint(anchor, frame, anchor, section.x or 0, 0)
		end
	end
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetTexture("Interface\\FriendsFrame\\FriendsFrameScrollIcon")
	icon:SetSize(64, 64)
	icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, 1)
end


local function CreatePopup(closeOnly)
	local frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetFrameLevel(UIParent:GetFrameLevel() + 3)
	frame:SetClampedToScreen(true)
	CreateMenuArtwork(frame)

	local panel = CreateFrame("Frame", nil, frame,
		BackdropTemplateMixin and "BackdropTemplate")
	panel:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -68)
	panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 58)
	panel:SetFrameLevel(frame:GetFrameLevel())
	panel:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	panel:SetBackdropColor(0.02, 0.02, 0.02, 0.9)
	panel:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
	frame.contentPanel = panel

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", frame, "TOPLEFT", 76, -18)
	title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, -18)
	title:SetJustifyH("CENTER")
	frame.titleFontString = title

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -12)
	close:SetScript("OnClick", function() frame:Hide() end)
	frame.headerCloseButton = close
	if closeOnly then
		local button = MSBTControls.CreateOptionButton(frame)
		button:Configure(24, L.PROFILE_TRANSFER.close)
		button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 22)
		button:SetClickHandler(function() frame:Hide() end)
	end
	frame:SetScript("OnHide", OnHidePopup)

	frame:SetScript("OnShow", function(self)
		PlaySound(852)
	end)
	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
	MSBTOptions.Main.RegisterPopupFrame(frame)
	return frame
end


local function ChangePopupParent(frame, parent)
	local oldHandler = frame.hideHandler
	frame.hideHandler = nil
	frame:SetParent(parent or UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 3)
	frame.hideHandler = oldHandler
end


local function DisableControls(controlsTable)
	for _, frame in pairs(controlsTable) do
		if (frame.Disable) then frame:Disable() end
	end
end


local function ToggleDropdownInheritState(dropdown, isInherited, inheritedValue)
	if (isInherited) then
		dropdown:SetSelectedID(inheritedValue)
		dropdown:Disable()
		dropdown:SetAlpha(0.3)
	else
		dropdown:SetAlpha(1)
		dropdown:Enable()
	end
end


local function ToggleSliderInheritState(slider, isInherited, inheritedValue)
	if (isInherited) then
		slider:SetValue(inheritedValue)
		slider:Disable()
		slider:SetAlpha(0.3)
	else
		slider:SetAlpha(1)
		slider:Enable()
	end
end





local function ValidateInputCallback(message)
	local frame = popupFrames.inputFrame

	frame.validateFontString:SetText("")
	frame.okayButton:Enable()

	if (message) then
		frame.validateFontString:SetText(message)
		frame.okayButton:Disable()
	end
end

local function ValidateInput(this)
	local frame = popupFrames.inputFrame

	frame.validateFontString:SetText("")
	frame.okayButton:Enable()

	if (frame.validateHandler) then
		local firstText = frame.inputEditbox:GetText()
		local secondText = frame.secondInputEditbox:GetText()
		local message = frame.validateHandler(firstText, frame.showSecondEditbox and secondText, ValidateInputCallback)

		if (message) then
			frame.validateFontString:SetText(message)
			frame.okayButton:Disable()
		end
	end
end


local function SaveInput()
	local frame = popupFrames.inputFrame
	if (frame.saveHandler and frame.okayButton:IsEnabled() ~= 0) then
		EraseTable(returnSettings)
		returnSettings.inputText = frame.inputEditbox:GetText()
		returnSettings.secondInputText = frame.secondInputEditbox:GetText()
		returnSettings.saveArg1 = frame.saveArg1
		frame:Hide()
		frame.saveHandler(returnSettings)
	end
end


local function CreateInput()
	local frame = CreatePopup()
	frame:SetWidth(420)
	frame:SetHeight(240)

	local editbox = MSBTControls.CreateEditbox(frame)
	editbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -85)
	editbox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -44, -85)
	editbox:SetEscapeHandler(function(this)
		frame:Hide()
	end)
	editbox:SetEnterHandler(SaveInput)
	editbox:SetTextChangedHandler(ValidateInput)
	frame.inputEditbox = editbox

	editbox = MSBTControls.CreateEditbox(frame)
	editbox:SetPoint("TOPLEFT", frame.inputEditbox, "BOTTOMLEFT", 0, -10)
	editbox:SetPoint("TOPRIGHT", frame.inputEditbox, "BOTTOMRIGHT", 0, -10)
	editbox:SetEscapeHandler(function(this)
		frame:Hide()
	end)
	editbox:SetEnterHandler(SaveInput)
	editbox:SetTextChangedHandler(ValidateInput)
	frame.secondInputEditbox = editbox


	local button = MSBTControls.CreateOptionButton(frame)
	local objLocale = L.BUTTONS["inputOkay"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(SaveInput)
	frame.okayButton = button

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["inputCancel"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
	end)

	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 44, 68)
	fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -44, 68)
	fontString:SetJustifyH("LEFT")
	fontString:SetTextColor(1, 0.2, 0.2)
	frame.validateFontString = fontString

	return frame
end


local function ShowInput(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.inputFrame) then popupFrames.inputFrame = CreateInput() end

	local frame = popupFrames.inputFrame
	ChangePopupParent(frame, configTable.parentFrame)
	frame.titleFontString:SetText(configTable.title
		or (configTable.editboxLabel or ""):gsub(":%s*$", ""))

	local editbox = frame.inputEditbox
	editbox:SetLabel(configTable.editboxLabel)
	editbox:SetTooltip(configTable.editboxTooltip)
	editbox:SetText("")
	editbox:SetText(configTable.defaultText)

	editbox = frame.secondInputEditbox
	if (configTable.showSecondEditbox) then
		editbox:Show()
		editbox:SetLabel(configTable.secondEditboxLabel)
		editbox:SetTooltip(configTable.secondEditboxTooltip)
		editbox:SetText(configTable.secondDefaultText)
		frame:SetHeight(280)
	else
		editbox:SetText(nil)
		editbox:Hide()
		frame:SetHeight(240)
	end


	frame.showSecondEditbox = configTable.showSecondEditbox
	frame.validateHandler = configTable.validateHandler
	frame.saveHandler = configTable.saveHandler
	frame.saveArg1 = configTable.saveArg1
	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
	frame.inputEditbox:SetFocus()
end



local function CreateAcknowledge()
	local frame = CreatePopup()
	frame:SetWidth(380)
	frame:SetHeight(220)
	frame.titleFontString:SetText(L.POPUP_CONFIRM_TITLE)

	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -85)
	fontString:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -44, -85)
	fontString:SetText(L.MSG_ACKNOWLEDGE_TEXT)

	local button = MSBTControls.CreateOptionButton(frame)
	button:Configure(24, YES, nil)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(function(this)
		if (frame.acknowledgeHandler) then
			frame.acknowledgeHandler(frame.saveArg1)
			frame:Hide()
		end
	end)

	button = MSBTControls.CreateOptionButton(frame)
	button:Configure(24, NO, nil)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
	end)

	return frame
end


local function ShowAcknowledge(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.acknowledgeFrame) then popupFrames.acknowledgeFrame = CreateAcknowledge() end


	local frame = popupFrames.acknowledgeFrame
	ChangePopupParent(frame, configTable.parentFrame)

	frame.acknowledgeHandler = configTable.acknowledgeHandler
	frame.saveArg1 = configTable.saveArg1
	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



local function UpdateFontSettings()
	local frame = popupFrames.fontFrame

	EraseTable(returnSettings)

	if (not frame.hideNormal) then
		returnSettings.normalFontName = not frame.normalFontCheckbox:GetChecked() and frame.normalFontDropdown:GetSelectedID() or nil
		returnSettings.normalOutlineIndex = not frame.normalOutlineCheckbox:GetChecked() and frame.normalOutlineDropdown:GetSelectedID() or nil
		returnSettings.normalFontSize = not frame.normalFontSizeCheckbox:GetChecked() and frame.normalFontSizeSlider:GetValue() or nil
		returnSettings.normalFontAlpha = not frame.normalFontOpacityCheckbox:GetChecked() and frame.normalFontOpacitySlider:GetValue() or nil
	end

	if (not frame.hideCrit) then
		returnSettings.critFontName = not frame.critFontCheckbox:GetChecked() and frame.critFontDropdown:GetSelectedID() or nil
		returnSettings.critOutlineIndex = not frame.critOutlineCheckbox:GetChecked() and frame.critOutlineDropdown:GetSelectedID() or nil
		returnSettings.critFontSize = not frame.critFontSizeCheckbox:GetChecked() and frame.critFontSizeSlider:GetValue() or nil
		returnSettings.critFontAlpha = not frame.critFontOpacityCheckbox:GetChecked() and frame.critFontOpacitySlider:GetValue() or nil
	end
end


local function UpdateFontPreviews()
	local frame = popupFrames.fontFrame

	local fontPath, fontSize, outline

	if (not frame.hideNormal) then
		fontPath = fonts[frame.normalFontDropdown:GetSelectedID()]
		fontSize = frame.normalFontSizeSlider:GetValue()
		outline = OUTLINE_MAP[frame.normalOutlineDropdown:GetSelectedID()]
		frame.normalPreviewFontString:SetFont(fontPath, fontSize, outline)
		frame.normalPreviewFontString:SetText("")
		frame.normalPreviewFontString:SetText(L.MSG_NORMAL_PREVIEW_TEXT)
		frame.normalPreviewFontString:SetAlpha(frame.normalFontOpacitySlider:GetValue() / 100)
	end

	if (not frame.hideCrit) then
		fontPath = fonts[frame.critFontDropdown:GetSelectedID()]
		fontSize = frame.critFontSizeSlider:GetValue()
		outline = OUTLINE_MAP[frame.critOutlineDropdown:GetSelectedID()]
		if (fontPath and outline) then
			frame.critPreviewFontString:SetFont(fontPath, fontSize, outline)
			frame.critPreviewFontString:SetText("")
			frame.critPreviewFontString:SetText(L.MSG_CRIT)
		end
		frame.critPreviewFontString:SetAlpha(frame.critFontOpacitySlider:GetValue() / 100)
	end
end


local function CreateFontPopup()
	local frame = CreatePopup()
	frame:SetWidth(500)
	frame:SetHeight(430)
	local fontString


	local normalFrame = CreateFrame("Frame", nil, frame)
	normalFrame:SetWidth(195)
	normalFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -90)
	normalFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 44, 60)
	frame.normalFrame = normalFrame


	local normalControlsFrame = CreateFrame("Frame", nil, normalFrame)
	normalControlsFrame:SetWidth(155)
	normalControlsFrame:SetPoint("TOPLEFT")
	normalControlsFrame:SetPoint("BOTTOMLEFT")
	frame.normalControlsFrame = normalControlsFrame

	local dropdown = MSBTControls.CreateDropdown(normalControlsFrame)
	local objLocale = L.DROPDOWNS["normalFont"]
	dropdown:Configure(150, objLocale.label, objLocale.tooltip)
	dropdown:SetListboxHeight(200)
	dropdown:SetPoint("TOPLEFT")
	dropdown:SetChangeHandler(function(this, id)
		UpdateFontPreviews()
	end)
	frame.normalFontDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(normalControlsFrame)
	objLocale = L.DROPDOWNS["normalOutline"]
	dropdown:Configure(150, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.normalFontDropdown, "BOTTOMLEFT", 0, -20)
	dropdown:SetChangeHandler(function(this, id)
		UpdateFontPreviews()
	end	)
	for outlineIndex, outlineName in ipairs(L.OUTLINES) do
		dropdown:AddItem(outlineName, outlineIndex)
	end
	frame.normalOutlineDropdown = dropdown

	local slider = MSBTControls.CreateSlider(normalControlsFrame)
	objLocale = L.SLIDERS["normalFontSize"]
	slider:Configure(150, objLocale.label, objLocale.tooltip)
	slider:SetPoint("TOPLEFT", frame.normalOutlineDropdown, "BOTTOMLEFT", 0, -30)
	slider:SetMinMaxValues(4, 38)
	slider:SetValueStep(1)
	slider:SetValueChangedHandler(function(this, value)
		UpdateFontPreviews()
	end)
	frame.normalFontSizeSlider = slider

	slider = MSBTControls.CreateSlider(normalControlsFrame)
	objLocale = L.SLIDERS["normalFontOpacity"]
	slider:Configure(150, objLocale.label, objLocale.tooltip)
	slider:SetPoint("TOPLEFT", frame.normalFontSizeSlider, "BOTTOMLEFT", 0, -10)
	slider:SetMinMaxValues(1, 100)
	slider:SetValueStep(1)
	slider:SetValueChangedHandler(function(this, value)
		UpdateFontPreviews()
	end)
	frame.normalFontOpacitySlider = slider

	fontString = normalControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("BOTTOM", normalControlsFrame, "BOTTOM", 0, 10)
	fontString:SetText(L.MSG_NORMAL_PREVIEW_TEXT)
	frame.normalPreviewFontString = fontString



	local normalInheritFrame = CreateFrame("Frame", nil, normalFrame)
	normalInheritFrame:SetWidth(40)
	normalInheritFrame:SetPoint("TOPLEFT", normalControlsFrame, "TOPRIGHT")
	normalInheritFrame:SetPoint("BOTTOMLEFT", normalControlsFrame, "BOTTOMRIGHT")
	frame.normalInheritFrame = normalInheritFrame

	local checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
	objLocale = L.CHECKBOXES["inheritField"]
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.normalFontDropdown, "BOTTOMRIGHT", 10, 0)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleDropdownInheritState(frame.normalFontDropdown, isChecked, frame.inheritedNormalFontName)
		UpdateFontPreviews()
	end)
	frame.normalFontCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.normalOutlineDropdown, "BOTTOMRIGHT", 10, 0)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleDropdownInheritState(frame.normalOutlineDropdown, isChecked, frame.inheritedNormalOutlineIndex)
		UpdateFontPreviews()
	end)
	frame.normalOutlineCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.normalFontSizeSlider, "BOTTOMRIGHT", 10, 5)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleSliderInheritState(frame.normalFontSizeSlider, isChecked, frame.inheritedNormalFontSize)
		UpdateFontPreviews()
	end)
	frame.normalFontSizeCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.normalFontOpacitySlider, "BOTTOMRIGHT", 10, 5)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleSliderInheritState(frame.normalFontOpacitySlider, isChecked, frame.inheritedNormalFontAlpha)
		UpdateFontPreviews()
	end)
	frame.normalFontOpacityCheckbox = checkbox

	fontString = normalInheritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("BOTTOM", frame.normalFontCheckbox, "TOP", 0, 7)
	fontString:SetText(L.CHECKBOXES["inheritField"].label)




	local critFrame = CreateFrame("Frame", nil, frame)
	critFrame:SetWidth(195)
	critFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -44, -90)
	critFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -44, 60)
	frame.critFrame = critFrame


	local critControlsFrame = CreateFrame("Frame", nil, critFrame)
	critControlsFrame:SetWidth(155)
	critControlsFrame:SetPoint("TOPLEFT")
	critControlsFrame:SetPoint("BOTTOMLEFT")
	frame.critControlsFrame = critControlsFrame

	dropdown = MSBTControls.CreateDropdown(critControlsFrame)
	objLocale = L.DROPDOWNS["critFont"]
	dropdown:Configure(150, objLocale.label, objLocale.tooltip)
	dropdown:SetListboxHeight(200)
	dropdown:SetPoint("TOPLEFT")
	dropdown:SetChangeHandler(function(this, id)
		UpdateFontPreviews()
	end)
	frame.critFontDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(critControlsFrame)
	objLocale = L.DROPDOWNS["critOutline"]
	dropdown:Configure(150, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.critFontDropdown, "BOTTOMLEFT", 0, -20)
	dropdown:SetChangeHandler(function(this, id)
		UpdateFontPreviews()
	end)
	for outlineIndex, outlineName in ipairs(L.OUTLINES) do
		dropdown:AddItem(outlineName, outlineIndex)
	end
	frame.critOutlineDropdown = dropdown

	slider = MSBTControls.CreateSlider(critControlsFrame)
	objLocale = L.SLIDERS["critFontSize"]
	slider:Configure(150, objLocale.label, objLocale.tooltip)
	slider:SetPoint("TOPLEFT", frame.critOutlineDropdown, "BOTTOMLEFT", 0, -30)
	slider:SetMinMaxValues(4, 38)
	slider:SetValueStep(1)
	slider:SetValueChangedHandler(function(this, value)
		UpdateFontPreviews()
	end)
	frame.critFontSizeSlider = slider

	slider = MSBTControls.CreateSlider(critControlsFrame)
	objLocale = L.SLIDERS["critFontOpacity"]
	slider:Configure(150, objLocale.label, objLocale.tooltip)
	slider:SetPoint("TOPLEFT", frame.critFontSizeSlider, "BOTTOMLEFT", 0, -10)
	slider:SetMinMaxValues(1, 100)
	slider:SetValueStep(1)
	slider:SetValueChangedHandler(function(this, value)
		UpdateFontPreviews()
	end)
	frame.critFontOpacitySlider = slider

	fontString = critControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("BOTTOM", critControlsFrame, "BOTTOM", 0, 10)
	fontString:SetText(L.MSG_CRIT)
	frame.critPreviewFontString = fontString



	local critInheritFrame = CreateFrame("Frame", nil, critFrame)
	critInheritFrame:SetWidth(40)
	critInheritFrame:SetPoint("TOPLEFT", critControlsFrame, "TOPRIGHT")
	critInheritFrame:SetPoint("BOTTOMLEFT", critControlsFrame, "BOTTOMRIGHT")
	frame.critInheritFrame = critInheritFrame


	local checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
	objLocale = L.CHECKBOXES["inheritField"]
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.critFontDropdown, "BOTTOMRIGHT", 10, 0)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleDropdownInheritState(frame.critFontDropdown, isChecked, frame.inheritedCritFontName)
		UpdateFontPreviews()
	end)
	frame.critFontCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.critOutlineDropdown, "BOTTOMRIGHT", 10, 0)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleDropdownInheritState(frame.critOutlineDropdown, isChecked, frame.inheritedCritOutlineIndex)
		UpdateFontPreviews()
	end)
	frame.critOutlineCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.critFontSizeSlider, "BOTTOMRIGHT", 10, 5)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleSliderInheritState(frame.critFontSizeSlider, isChecked, frame.inheritedCritFontSize)
		UpdateFontPreviews()
	end)
	frame.critFontSizeCheckbox = checkbox

	checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
	checkbox:Configure(20, nil, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.critFontOpacitySlider, "BOTTOMRIGHT", 10, 5)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleSliderInheritState(frame.critFontOpacitySlider, isChecked, frame.inheritedCritFontAlpha)
		UpdateFontPreviews()
	end)
	frame.critFontOpacityCheckbox = checkbox

	fontString = critInheritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("BOTTOM", frame.critFontCheckbox, "TOP", 0, 7)
	fontString:SetText(L.CHECKBOXES["inheritField"].label)

	local button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericSave"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(function(this)
		UpdateFontSettings()
		frame:Hide()
		if frame.saveHandler then
			frame.saveHandler(returnSettings, frame.saveArg1)
		end
	end)

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericCancel"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
	end)


	MSBTOptions.Main.RegisterPopupFrame(frame)
	return frame
end


local function ShowFont(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.fontFrame) then popupFrames.fontFrame = CreateFontPopup() end

	local frame = popupFrames.fontFrame
	ChangePopupParent(frame, configTable.parentFrame)

	if (configTable.hideNormal) then frame.normalFrame:Hide() else frame.normalFrame:Show() end
	if (configTable.hideCrit) then frame.critFrame:Hide() else frame.critFrame:Show() end
	if (configTable.hideInherit) then frame.normalInheritFrame:Hide() else frame.normalInheritFrame:Show() end
	if (configTable.hideInherit) then frame.critInheritFrame:Hide() else frame.critInheritFrame:Show() end
	frame.hideNormal = configTable.hideNormal
	frame.hideCrit = configTable.hideCrit


	local dropdown, checkbox, slider
	frame.titleFontString:SetText(configTable.title)

	if (not configTable.hideNormal) then
		dropdown = frame.normalFontDropdown
		dropdown:Clear()
		for fontName in pairs(fonts) do
			dropdown:AddItem(fontName, fontName)
		end
		dropdown:Sort()
		checkbox = frame.normalFontCheckbox
		checkbox:SetChecked(not configTable.normalFontName or false)
		if (configTable.normalFontName) then dropdown:SetSelectedID(configTable.normalFontName) end
		ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedNormalFontName)

		dropdown = frame.normalOutlineDropdown
		checkbox = frame.normalOutlineCheckbox
		checkbox:SetChecked(not configTable.normalOutlineIndex or false)
		if (configTable.normalOutlineIndex) then dropdown:SetSelectedID(configTable.normalOutlineIndex) end
		ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedNormalOutlineIndex)

		slider = frame.normalFontSizeSlider
		checkbox = frame.normalFontSizeCheckbox
		checkbox:SetChecked(not configTable.normalFontSize or false)
		if (configTable.normalFontSize) then slider:SetValue(configTable.normalFontSize) end
		ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedNormalFontSize)

		slider = frame.normalFontOpacitySlider
		checkbox = frame.normalFontOpacityCheckbox
		checkbox:SetChecked(not configTable.normalFontAlpha or false)
		if (configTable.normalFontAlpha) then slider:SetValue(configTable.normalFontAlpha) end
		ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedNormalFontAlpha)
	end


	if (not configTable.hideCrit) then
		dropdown = frame.critFontDropdown
		dropdown:Clear()
		for fontName in pairs(fonts) do
			dropdown:AddItem(fontName, fontName)
		end
		dropdown:Sort()
		checkbox = frame.critFontCheckbox
		checkbox:SetChecked(not configTable.critFontName or false)
		if (configTable.critFontName) then dropdown:SetSelectedID(configTable.critFontName) end
		ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedCritFontName)

		dropdown = frame.critOutlineDropdown
		checkbox = frame.critOutlineCheckbox
		checkbox:SetChecked(not configTable.critOutlineIndex or false)
		if (configTable.critOutlineIndex) then dropdown:SetSelectedID(configTable.critOutlineIndex) end
		ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedCritOutlineIndex)

		slider = frame.critFontSizeSlider
		checkbox = frame.critFontSizeCheckbox
		checkbox:SetChecked(not configTable.critFontSize or false)
		if (configTable.critFontSize) then slider:SetValue(configTable.critFontSize) end
		ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedCritFontSize)

		slider = frame.critFontOpacitySlider
		checkbox = frame.critFontOpacityCheckbox
		checkbox:SetChecked(not configTable.critFontAlpha or false)
		if (configTable.critFontAlpha) then slider:SetValue(configTable.critFontAlpha) end
		ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedCritFontAlpha)
	end


	frame.inheritedNormalFontName = configTable.inheritedNormalFontName
	frame.inheritedNormalOutlineIndex = configTable.inheritedNormalOutlineIndex
	frame.inheritedNormalFontSize = configTable.inheritedNormalFontSize
	frame.inheritedNormalFontAlpha = configTable.inheritedNormalFontAlpha
	frame.inheritedCritFontName = configTable.inheritedCritFontName
	frame.inheritedCritOutlineIndex = configTable.inheritedCritOutlineIndex
	frame.inheritedCritFontSize = configTable.inheritedCritFontSize
	frame.inheritedCritFontAlpha = configTable.inheritedCritFontAlpha


	frame.saveHandler = configTable.saveHandler
	frame.saveArg1 = configTable.saveArg1
	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()

	UpdateFontPreviews()
end



local function CreatePartialEffects()
	local frame = CreatePopup(true)
	frame.titleFontString:SetText(L.BUTTONS.partialEffects.label)

	local checkbox = MSBTControls.CreateCheckbox(frame)
	local objLocale = L.CHECKBOXES["colorPartialEffects"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -80)
	checkbox:SetClickHandler(function(this, isChecked)
		MSBTProfiles.SetOption(nil, "partialColoringDisabled", not isChecked)
	end)
	frame.colorCheckbox = checkbox


	local anchor = checkbox
	local colorswatch, editbox
	local maxWidth = 0
	for effectType in string.gmatch("crushing glancing absorb block resist overheal overkill", "[^%s]+") do
		colorswatch = MSBTControls.CreateColorswatch(frame)
		colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, -10)
		colorswatch:SetColorChangedHandler(function(this)
			MSBTProfiles.SetOption(effectType, "colorR", this.r)
			MSBTProfiles.SetOption(effectType, "colorG", this.g)
			MSBTProfiles.SetOption(effectType, "colorB", this.b)
		end)

		checkbox = MSBTControls.CreateCheckbox(frame)
		objLocale = L.CHECKBOXES[effectType]
		checkbox:Configure(24, objLocale.label, objLocale.tooltip)
		checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
		checkbox:SetClickHandler(function(this, isChecked)
			MSBTProfiles.SetOption(effectType, "disabled", not isChecked)
		end)

		if (checkbox:GetWidth() > maxWidth) then maxWidth = checkbox:GetWidth() end

		local tooltip = L.EDITBOXES["partialEffect"].tooltip
		if (effectType ~= "crushing" and effectType ~= "glancing") then tooltip = tooltip .. "\n\n" .. L.EVENT_CODES["PARTIAL_AMOUNT"] end
		editbox = MSBTControls.CreateEditbox(frame)
		editbox:Configure(130, nil, tooltip)
		editbox:SetPoint("RIGHT", frame, "RIGHT", -44, 0)
		editbox:SetPoint("TOP", checkbox, "TOP", 0, 10)
		editbox:SetTextChangedHandler(function(this)
			MSBTProfiles.SetOption(effectType, "trailer", this:GetText())
		end)
		frame[effectType .. "Colorswatch"] = colorswatch
		frame[effectType .. "Checkbox"] = checkbox
		frame[effectType .. "Editbox"] = editbox

		anchor = colorswatch
	end

	frame:SetWidth(math.max(440, maxWidth + 278))
	frame:SetHeight(370)

	return frame
end


local function ShowPartialEffects(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.partialEffectsFrame) then popupFrames.partialEffectsFrame = CreatePartialEffects() end

	local frame = popupFrames.partialEffectsFrame
	ChangePopupParent(frame, configTable.parentFrame)

	frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.partialColoringDisabled)

	local profileEntry
	for effectType in string.gmatch("crushing glancing absorb block resist overheal overkill", "[^%s]+") do
		profileEntry = MSBTProfiles.currentProfile[effectType]
		frame[effectType .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB)
		frame[effectType .. "Checkbox"]:SetChecked(not profileEntry.disabled)
		frame[effectType .. "Editbox"]:SetText(profileEntry.trailer)
	end

	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



local function CreateDamageColors()
	local frame = CreatePopup(true)
	frame:SetSize(380, 410)
	frame.titleFontString:SetText(L.BUTTONS.damageColors.label)

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -116)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -64, 68)

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(270, 5)
	scrollFrame:SetScrollChild(content)

	local checkbox = MSBTControls.CreateCheckbox(frame)
	local objLocale = L.CHECKBOXES["colorDamageAmounts"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -80)
	checkbox:SetClickHandler(function(this, isChecked)
		MSBTProfiles.SetOption(nil, "damageColoringDisabled", not isChecked)
	end)
	frame.colorCheckbox = checkbox


	local anchor = content
	local globalStringSchoolIndex = 0
	local colorswatch, fontString
	for damageType, profileKey in pairs(MSBTMain.damageColorProfileEntries) do
		colorswatch = MSBTControls.CreateColorswatch(content)
		colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == content and 20 or 0, anchor == content and -10 or -5)
		colorswatch:SetColorChangedHandler(function(this)
			MSBTProfiles.SetOption(profileKey, "colorR", this.r)
			MSBTProfiles.SetOption(profileKey, "colorG", this.g)
			MSBTProfiles.SetOption(profileKey, "colorB", this.b)
		end)
		checkbox = MSBTControls.CreateCheckbox(content)
		objLocale = L.CHECKBOXES["colorDamageEntry"]
		checkbox:Configure(24, MSBTMain.damageTypeMap[damageType], objLocale.tooltip)
		checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
		checkbox:SetClickHandler(function(this, isChecked)
			MSBTProfiles.SetOption(profileKey, "disabled", not isChecked)
		end)
		frame[profileKey .. "Colorswatch"] = colorswatch
		frame[profileKey .. "Checkbox"] = checkbox

		anchor = colorswatch
		globalStringSchoolIndex = globalStringSchoolIndex + 1
	end
	content:SetHeight(15 + globalStringSchoolIndex * 21)

	return frame
end


local function ShowDamageColors(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.damageColorsFrame) then popupFrames.damageColorsFrame = CreateDamageColors() end

	local frame = popupFrames.damageColorsFrame
	ChangePopupParent(frame, configTable.parentFrame)

	frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.damageColoringDisabled)

	local profileEntry
	for damageType, profileKey in pairs(MSBTMain.damageColorProfileEntries) do
		profileEntry = MSBTProfiles.currentProfile[profileKey]
		frame[profileKey .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB)
		frame[profileKey .. "Checkbox"]:SetChecked(not profileEntry.disabled)
	end

	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



local classString = "DEATHKNIGHT DRUID HUNTER MAGE MONK PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR DEMONHUNTER EVOKER"
if IsCataClassic then
	classString = "DEATHKNIGHT DRUID HUNTER MAGE PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR"
elseif IsVanillaClassic then
	classString = "DRUID HUNTER MAGE PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR"
end

local function CreateClassColors()
	local frame = CreatePopup(true)
	frame:SetWidth(380)
	frame:SetHeight(460)
	frame.titleFontString:SetText(L.BUTTONS.classColors.label)

	local checkbox = MSBTControls.CreateCheckbox(frame)
	local objLocale = L.CHECKBOXES["colorUnitNames"]
	checkbox:Configure(24, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -80)
	checkbox:SetClickHandler(function(this, isChecked)
		MSBTProfiles.SetOption(nil, "classColoringDisabled", not isChecked)
	end)
	frame.colorCheckbox = checkbox


	local anchor = checkbox
	local globalStringSchoolIndex = 0
	local colorswatch, fontString
	for class in string.gmatch(classString, "[^%s]+") do
		colorswatch = MSBTControls.CreateColorswatch(frame)
		colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, anchor == checkbox and -10 or -5)
		colorswatch:SetColorChangedHandler(function(this)
			MSBTProfiles.SetOption(class, "colorR", this.r)
			MSBTProfiles.SetOption(class, "colorG", this.g)
			MSBTProfiles.SetOption(class, "colorB", this.b)
		end)
		checkbox = MSBTControls.CreateCheckbox(frame)
		objLocale = L.CHECKBOXES["colorClassEntry"]
		checkbox:Configure(24, CLASS_NAMES[class], objLocale.tooltip)
		checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
		checkbox:SetClickHandler(function(this, isChecked)
			MSBTProfiles.SetOption(class, "disabled", not isChecked)
		end)
		frame[class .. "Colorswatch"] = colorswatch
		frame[class .. "Checkbox"] = checkbox

		anchor = colorswatch
	end

	return frame
end


local function ShowClassColors(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.classColorsFrame) then popupFrames.classColorsFrame = CreateClassColors() end

	local frame = popupFrames.classColorsFrame
	ChangePopupParent(frame, configTable.parentFrame)

	frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.classColoringDisabled)

	local profileEntry
	for class in string.gmatch(classString, "[^%s]+") do
		profileEntry = MSBTProfiles.currentProfile[class]
		frame[class .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB)
		frame[class .. "Checkbox"]:SetChecked(not profileEntry.disabled)
	end

	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



local function CopyTempScrollAreaSettings(settingsTable)
	local frame = popupFrames.scrollAreaConfigFrame
	EraseTable(settingsTable)

	local tempSettings
	for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
		settingsTable[saKey] = {}
		tempSettings = settingsTable[saKey]

		tempSettings.animationStyle = saSettings.animationStyle or DEFAULT_ANIMATION_STYLE
		tempSettings.direction = saSettings.direction
		tempSettings.behavior = saSettings.behavior
		tempSettings.textAlignIndex = saSettings.textAlignIndex or DEFAULT_TEXT_ALIGN_INDEX

		tempSettings.stickyAnimationStyle = saSettings.stickyAnimationStyle or DEFAULT_STICKY_ANIMATION_STYLE
		tempSettings.stickyDirection = saSettings.stickyDirection
		tempSettings.stickyBehavior = saSettings.stickyBehavior
		tempSettings.stickyTextAlignIndex = saSettings.stickyTextAlignIndex or DEFAULT_TEXT_ALIGN_INDEX

		tempSettings.scrollHeight = saSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT
		tempSettings.scrollWidth = saSettings.scrollWidth or DEFAULT_SCROLL_WIDTH
		tempSettings.offsetX = saSettings.offsetX or 0
		tempSettings.offsetY = saSettings.offsetY or 0

		tempSettings.inheritedAnimationSpeed = MSBTProfiles.currentProfile.animationSpeed
		tempSettings.animationSpeed = saSettings.animationSpeed

		tempSettings.iconAlign = saSettings.iconAlign or DEFAULT_ICON_ALIGN
		tempSettings.skillIconsDisabled = saSettings.skillIconsDisabled
	end
end


local function ChangeAnimationStyle(styleKey)
	local frame = popupFrames.scrollAreaConfigFrame
	local styleSettings = MSBTAnimations.animationStyles[styleKey]
	local firstEntry, name, objLocale

	frame.directionDropdown:Clear()
	if (styleSettings.availableDirections) then
		for direction in string.gmatch(styleSettings.availableDirections, "[^;]+") do
			if (not firstEntry) then firstEntry = direction end
			objLocale = styleSettings.localizationTable
			name = objLocale and objLocale[direction] or L.ANIMATION_STYLE_DATA[direction] or direction
			frame.directionDropdown:AddItem(name, direction)
		end
		frame.directionDropdown:SetSelectedID(firstEntry)
	else
		frame.directionDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
		frame.directionDropdown:SetSelectedID("MSBT_NORMAL")
	end

	firstEntry = nil
	frame.behaviorDropdown:Clear()
	if (styleSettings.availableBehaviors) then
		for behavior in string.gmatch(styleSettings.availableBehaviors, "[^;]+") do
			if (not firstEntry) then firstEntry = behavior end
			objLocale = styleSettings.localizationTable
			name = objLocale and objLocale[behavior] or L.ANIMATION_STYLE_DATA[behavior] or behavior
			frame.behaviorDropdown:AddItem(name, behavior)
		end
		frame.behaviorDropdown:SetSelectedID(firstEntry)
	else
		frame.behaviorDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
		frame.behaviorDropdown:SetSelectedID("MSBT_NORMAL")
	end
end


local function ChangeStickyAnimationStyle(styleKey)
	local frame = popupFrames.scrollAreaConfigFrame
	local styleSettings = MSBTAnimations.stickyAnimationStyles[styleKey]
	local firstEntry, name, objLocale

	frame.stickyDirectionDropdown:Clear()
	if (styleSettings.availableDirections) then
		for direction in string.gmatch(styleSettings.availableDirections, "[^;]+") do
			if (not firstEntry) then firstEntry = direction end
			objLocale = styleSettings.localizationTable
			name = objLocale and objLocale[direction] or L.ANIMATION_STYLE_DATA[direction] or direction
			frame.stickyDirectionDropdown:AddItem(name, direction)
		end
		frame.stickyDirectionDropdown:SetSelectedID(firstEntry)
	else
		frame.stickyDirectionDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
		frame.stickyDirectionDropdown:SetSelectedID("MSBT_NORMAL")
	end

	firstEntry = nil
	frame.stickyBehaviorDropdown:Clear()
	if (styleSettings.availableBehaviors) then
		for behavior in string.gmatch(styleSettings.availableBehaviors, "[^;]+") do
			if (not firstEntry) then firstEntry = behavior end
			objLocale = styleSettings.localizationTable
			name = objLocale and objLocale[behavior] or L.ANIMATION_STYLE_DATA[behavior] or behavior
			frame.stickyBehaviorDropdown:AddItem(name, behavior)
		end
		frame.stickyBehaviorDropdown:SetSelectedID(firstEntry)
	else
		frame.stickyBehaviorDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
		frame.stickyBehaviorDropdown:SetSelectedID("MSBT_NORMAL")
	end
end


local function ChangeConfigScrollArea(scrollArea)
	local frame = popupFrames.scrollAreaConfigFrame
	frame.currentScrollArea = scrollArea
	local saSettings = frame.previewSettings[scrollArea]
	local name, objLocale

	frame.animationStyleDropdown:Clear()
	for styleKey, settings in pairs(MSBTAnimations.animationStyles) do
		objLocale = settings.localizationTable
		name = objLocale and objLocale[styleKey] or L.ANIMATION_STYLE_DATA[styleKey] or styleKey
		frame.animationStyleDropdown:AddItem(name, styleKey)
	end
	frame.animationStyleDropdown:SetSelectedID(saSettings.animationStyle)
	ChangeAnimationStyle(saSettings.animationStyle)

	if (saSettings.direction) then frame.directionDropdown:SetSelectedID(saSettings.direction) end
	if (saSettings.behavior) then frame.behaviorDropdown:SetSelectedID(saSettings.behavior) end
	frame.textAlignDropdown:SetSelectedID(saSettings.textAlignIndex)


	frame.stickyAnimationStyleDropdown:Clear()
	for styleKey, settings in pairs(MSBTAnimations.stickyAnimationStyles) do
		objLocale = settings.localizationTable
		name = objLocale and objLocale[styleKey] or L.ANIMATION_STYLE_DATA[styleKey] or styleKey
		frame.stickyAnimationStyleDropdown:AddItem(name, styleKey)
	end
	frame.stickyAnimationStyleDropdown:SetSelectedID(saSettings.stickyAnimationStyle)
	ChangeStickyAnimationStyle(saSettings.stickyAnimationStyle)

	if (saSettings.stickyDirection) then frame.stickyDirectionDropdown:SetSelectedID(saSettings.stickyDirection) end
	if (saSettings.stickyBehavior) then frame.stickyBehaviorDropdown:SetSelectedID(saSettings.stickyBehavior) end
	frame.stickyTextAlignDropdown:SetSelectedID(saSettings.stickyTextAlignIndex)

	frame.scrollHeightSlider:SetValue(saSettings.scrollHeight)
	frame.scrollWidthSlider:SetValue(saSettings.scrollWidth)

	local isSpeedInherited = not saSettings.animationSpeed or saSettings.animationSpeed == saSettings.inheritedAnimationSpeed
	frame.animationSpeedCheckbox:SetChecked(isSpeedInherited)
	if (saSettings.animationSpeed) then frame.animationSpeedSlider:SetValue(saSettings.animationSpeed) end
	ToggleSliderInheritState(frame.animationSpeedSlider, isSpeedInherited , saSettings.inheritedAnimationSpeed)

	frame.xOffsetEditbox:SetText(saSettings.offsetX)
	frame.yOffsetEditbox:SetText(saSettings.offsetY)

	frame.iconAlignDropdown:SetSelectedID(saSettings.iconAlign)
	frame.iconsDisabledCheckbox:SetChecked(saSettings.skillIconsDisabled)

	for _, moverFrame in pairs(frame.moverFrames) do
		moverFrame:SetBackdropColor(0.8, 0.8, 0.8, 1.0)
	end

	frame.moverFrames[scrollArea]:SetBackdropColor(0.5, 0.05, 0.05, 1.0)
	frame.moverFrames[scrollArea]:Raise()
end


local function RepositionScrollAreaMoverFrame(scrollArea)
	local configFrame = popupFrames.scrollAreaConfigFrame
	local frame = configFrame.moverFrames[scrollArea]
	local saSettings = configFrame.previewSettings[scrollArea]

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "CENTER", saSettings.offsetX, saSettings.offsetY)
	frame:SetHeight(saSettings.scrollHeight)
	frame:SetWidth(saSettings.scrollWidth)
	frame.fontString:SetText(MSBTAnimations.scrollAreas[scrollArea].name .. " (" .. saSettings.offsetX .. ", " .. saSettings.offsetY .. ")")
	frame:Show()
end


local function SaveScrollAreaMoverCoordinates(frame)
	local uiParentX, uiParentY = UIParent:GetCenter()
	local xOffset = math.ceil(frame:GetLeft() - uiParentX)
	local yOffset = math.ceil(frame:GetBottom() - uiParentY)

	local configFrame = popupFrames.scrollAreaConfigFrame
	configFrame.previewSettings[frame.scrollArea].offsetX = xOffset
	configFrame.previewSettings[frame.scrollArea].offsetY = yOffset

	if (frame.scrollArea == configFrame.scrollAreaDropdown:GetSelectedID()) then
		configFrame.xOffsetEditbox:SetText(xOffset)
		configFrame.yOffsetEditbox:SetText(yOffset)
	end

	RepositionScrollAreaMoverFrame(frame.scrollArea)
end


local function MoverFrameOnMouseDown(this, button)
	if (button == "LeftButton") then this:StartMoving() end
end


local function MoverFrameOnMouseUp(this)
	this:StopMovingOrSizing()
	SaveScrollAreaMoverCoordinates(this)

	local configFrame = popupFrames.scrollAreaConfigFrame
	if (this.scrollArea ~= configFrame.scrollAreaDropdown:GetSelectedID()) then
		configFrame.scrollAreaDropdown:SetSelectedID(this.scrollArea)
		ChangeConfigScrollArea(this.scrollArea)
	end
end


local function CreateScrollAreaMoverFrame(scrollArea)
	local moverFrames = popupFrames.scrollAreaConfigFrame.moverFrames

	if (not moverFrames[scrollArea]) then
		local frame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
		frame:Hide()
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:SetFrameStrata("HIGH")
		frame:SetClampedToScreen(true)
		frame:SetBackdrop(moverBackdrop)
		frame:SetScript("OnMouseDown", MoverFrameOnMouseDown)
		frame:SetScript("OnMouseUp", MoverFrameOnMouseUp)

		local fontString = frame:CreateFontString(nil, "OVERLAY")
		local fontPath = "Fonts\\ARIALN.TTF"
		if (GetLocale() == "koKR") then fontPath = "Fonts\\2002.TTF" end
		fontString:SetFont(fontPath, 12)
		fontString:SetPoint("CENTER")
		frame.fontString = fontString

		frame.scrollArea = scrollArea
		moverFrames[scrollArea] = frame
	end
end


local function SaveScrollAreaSettings(settingsTable)
	local frame = popupFrames.scrollAreaConfigFrame

	for saKey, saSettings in pairs(settingsTable) do
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "animationStyle", saSettings.animationStyle, DEFAULT_ANIMATION_STYLE)
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "direction", saSettings.direction, "MSBT_NORMAL")
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "behavior", saSettings.behavior, "MSBT_NORMAL")
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "textAlignIndex", saSettings.textAlignIndex, DEFAULT_TEXT_ALIGN_INDEX)

		MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyAnimationStyle", saSettings.stickyAnimationStyle, DEFAULT_STICKY_ANIMATION_STYLE)
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyDirection", saSettings.stickyDirection, "MSBT_NORMAL")
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyBehavior", saSettings.stickyBehavior, "MSBT_NORMAL")
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyTextAlignIndex", saSettings.stickyTextAlignIndex, DEFAULT_TEXT_ALIGN_INDEX)

		MSBTProfiles.SetOption("scrollAreas." .. saKey, "scrollHeight", saSettings.scrollHeight, DEFAULT_SCROLL_HEIGHT)
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "scrollWidth", saSettings.scrollWidth, DEFAULT_SCROLL_WIDTH)
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "offsetX", saSettings.offsetX)
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "offsetY", saSettings.offsetY)

		local animationSpeed = saSettings.animationSpeed
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "animationSpeed", animationSpeed, saSettings.inheritedAnimationSpeed)

		MSBTProfiles.SetOption("scrollAreas." .. saKey, "iconAlign", saSettings.iconAlign, DEFAULT_ICON_ALIGN)
		MSBTProfiles.SetOption("scrollAreas." .. saKey, "skillIconsDisabled", saSettings.skillIconsDisabled)
	end
	MSBTAnimations.UpdateScrollAreas()
end


local function CreateScrollAreaConfig()
	local frame = CreatePopup()
	frame:SetWidth(380)
	frame:SetHeight(635)
	frame.titleFontString:SetText(L.TABS.scrollAreas.label)
	frame:SetPoint("RIGHT")
	frame.headerCloseButton:SetScript("OnClick", function()
		SaveScrollAreaSettings(frame.originalSettings)
		frame:Hide()
	end)
	frame:SetScript("OnHide", function(this)
		for _, moverFrame in pairs(this.moverFrames) do
			moverFrame:Hide()
		end
		MSBTOptions.Main.ShowMainFrame()
	end)

	local dropdown = MSBTControls.CreateDropdown(frame)
	local objLocale = L.DROPDOWNS["scrollArea"]
	dropdown:Configure(200, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOP", frame, "TOP", 0, -80)
	dropdown:SetChangeHandler(function(this, id)
		ChangeConfigScrollArea(id)
	end)
	frame.scrollAreaDropdown = dropdown


	local texture = frame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
	texture:SetHeight(4)
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 39, -130)
	texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -39, -130)
	texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)


	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["animationStyle"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", texture, "BOTTOMLEFT", 5, -15)
	dropdown:SetChangeHandler(function(this, id)
		ChangeAnimationStyle(id)
		frame.previewSettings[frame.currentScrollArea].animationStyle = id
		frame.previewSettings[frame.currentScrollArea].direction = frame.directionDropdown:GetSelectedID()
		frame.previewSettings[frame.currentScrollArea].behavior = frame.behaviorDropdown:GetSelectedID()
	end)
	frame.animationStyleDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["stickyAnimationStyle"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("LEFT", frame.animationStyleDropdown, "RIGHT", 15, 0)
	dropdown:SetChangeHandler(function(this, id)
		ChangeStickyAnimationStyle(id)
		frame.previewSettings[frame.currentScrollArea].stickyAnimationStyle = id
		frame.previewSettings[frame.currentScrollArea].stickyDirection = frame.stickyDirectionDropdown:GetSelectedID()
		frame.previewSettings[frame.currentScrollArea].stickyBehavior = frame.stickyBehaviorDropdown:GetSelectedID()
	end)
	frame.stickyAnimationStyleDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["direction"]
	dropdown:Configure(135,objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.animationStyleDropdown, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.currentScrollArea].direction = id
	end)
	frame.directionDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["direction"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.stickyAnimationStyleDropdown, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.scrollAreaDropdown:GetSelectedID()].stickyDirection = id
	end)
	frame.stickyDirectionDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["behavior"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.directionDropdown, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.currentScrollArea].behavior = id
	end)
	frame.behaviorDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["behavior"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.stickyDirectionDropdown, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.currentScrollArea].stickyBehavior = id
	end)
	frame.stickyBehaviorDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["textAlign"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.behaviorDropdown, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.currentScrollArea].textAlignIndex = id
	end)
	for index, anchorPoint in ipairs(L.TEXT_ALIGNS) do
		dropdown:AddItem(anchorPoint, index)
	end
	frame.textAlignDropdown = dropdown

	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["textAlign"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.stickyBehaviorDropdown, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.currentScrollArea].stickyTextAlignIndex = id
	end)
	for index, anchorPoint in ipairs(L.TEXT_ALIGNS) do
		dropdown:AddItem(anchorPoint, index)
	end
	frame.stickyTextAlignDropdown = dropdown


	texture = frame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
	texture:SetHeight(4)
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 39, -355)
	texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -39, -355)
	texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)


	local slider = MSBTControls.CreateSlider(frame)
	objLocale = L.SLIDERS["scrollHeight"]
	slider:Configure(135, objLocale.label, objLocale.tooltip)
	slider:SetPoint("TOPLEFT", texture, "BOTTOMLEFT", 5, -15)
	slider:SetMinMaxValues(50, 600)
	slider:SetValueStep(5)
	slider:SetValueChangedHandler(function(this, value)
		frame.previewSettings[frame.currentScrollArea].scrollHeight = value
		RepositionScrollAreaMoverFrame(frame.currentScrollArea)
	end)
	frame.scrollHeightSlider = slider

	slider = MSBTControls.CreateSlider(frame)
	objLocale = L.SLIDERS["scrollWidth"]
	slider:Configure(135, objLocale.label, objLocale.tooltip)
	slider:SetPoint("LEFT", frame.scrollHeightSlider, "RIGHT", 15, 0)
	slider:SetMinMaxValues(10, 800)
	slider:SetValueStep(10)
	slider:SetValueChangedHandler(function(this, value)
		frame.previewSettings[frame.currentScrollArea].scrollWidth = value
		RepositionScrollAreaMoverFrame(frame.currentScrollArea)
	end)
	frame.scrollWidthSlider = slider

	slider = MSBTControls.CreateSlider(frame)
	objLocale = L.SLIDERS["scrollAnimationSpeed"]
	slider:Configure(135, objLocale.label, objLocale.tooltip)
	slider:SetPoint("TOPLEFT", frame.scrollHeightSlider, "BOTTOMLEFT", 0, -10)
	slider:SetMinMaxValues(20, 250)
	slider:SetValueStep(10)
	slider:SetValueChangedHandler(function(this, value)
		frame.previewSettings[frame.currentScrollArea].animationSpeed = value
	end)
	frame.animationSpeedSlider = slider

	local checkbox = MSBTControls.CreateCheckbox(frame)
	objLocale = L.CHECKBOXES["inheritField"]
	checkbox:Configure(20, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("BOTTOMLEFT", frame.animationSpeedSlider, "BOTTOMRIGHT", 10, 5)
	checkbox:SetClickHandler(function(this, isChecked)
		ToggleSliderInheritState(frame.animationSpeedSlider, isChecked, frame.previewSettings[frame.currentScrollArea].inheritedAnimationSpeed)
	end)
	frame.animationSpeedCheckbox = checkbox


	local editbox = MSBTControls.CreateEditbox(frame)
	objLocale = L.EDITBOXES["xOffset"]
	editbox:Configure(135, objLocale.label, objLocale.tooltip)
	editbox:SetPoint("TOPLEFT", frame.animationSpeedSlider, "BOTTOMLEFT", 0, -10)
	editbox:SetTextChangedHandler(function(this)
		local newOffset = tonumber(this:GetText())
		if newOffset then
			frame.previewSettings[frame.currentScrollArea].offsetX = newOffset
			RepositionScrollAreaMoverFrame(frame.currentScrollArea)
		end
	end)
	frame.xOffsetEditbox = editbox


	editbox = MSBTControls.CreateEditbox(frame)
	objLocale = L.EDITBOXES["yOffset"]
	editbox:Configure(135, objLocale.label, objLocale.tooltip)
	editbox:SetPoint("LEFT", frame.xOffsetEditbox, "RIGHT", 15, 0)
	editbox:SetTextChangedHandler(function(this)
		local newOffset = tonumber(this:GetText())
		if newOffset then
			frame.previewSettings[frame.currentScrollArea].offsetY = newOffset
			RepositionScrollAreaMoverFrame(frame.currentScrollArea)
		end
	end)
	frame.yOffsetEditbox = editbox


	dropdown = MSBTControls.CreateDropdown(frame)
	objLocale = L.DROPDOWNS["iconAlign"]
	dropdown:Configure(135, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame.xOffsetEditbox, "BOTTOMLEFT", 0, -10)
	dropdown:SetChangeHandler(function(this, id)
		frame.previewSettings[frame.currentScrollArea].iconAlign = id
	end)
	dropdown:AddItem(L.TEXT_ALIGNS[1], "Left")
	dropdown:AddItem(L.TEXT_ALIGNS[3], "Right")
	frame.iconAlignDropdown = dropdown

	checkbox = MSBTControls.CreateCheckbox(frame)
	objLocale = L.CHECKBOXES["hideSkillIcons"]
	checkbox:Configure(20, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("LEFT", frame.iconAlignDropdown, "RIGHT", 10, -5)
	checkbox:SetClickHandler(function(this, isChecked)
		frame.previewSettings[frame.currentScrollArea].skillIconsDisabled = isChecked
	end)
	frame.iconsDisabledCheckbox = checkbox

	texture = frame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
	texture:SetHeight(4)
	texture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 80)
	texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 80)
	texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)


	local button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["scrollAreasPreview"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 50)
	button:SetClickHandler(function(this)
		SaveScrollAreaSettings(frame.previewSettings)
		local name
		for saKey in pairs(frame.previewSettings) do
			name = MSBTAnimations.scrollAreas[saKey].name
			MikSBT.DisplayMessage(name, saKey, nil, 255, 0, 0, nil, nil, nil, PREVIEW_ICON_PATH)
			MikSBT.DisplayMessage(name, saKey, nil, 255, 255, 255, nil, nil, nil, PREVIEW_ICON_PATH)
			MikSBT.DisplayMessage(name, saKey, true, 0, 0, 255, 28, nil, nil, PREVIEW_ICON_PATH)
		end
	end)

	local button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericSave"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(function(this)
		SaveScrollAreaSettings(frame.previewSettings)
		frame:Hide()
	end)

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericCancel"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		SaveScrollAreaSettings(frame.originalSettings)
		frame:Hide()
	end)

	frame.moverFrames = {}
	frame.originalSettings = {}
	frame.previewSettings = {}

	_G["MSBTScrollAreasConfigFrame"] = frame
	return frame
end


local function ShowScrollAreaConfig()
	if (not popupFrames.scrollAreaConfigFrame) then popupFrames.scrollAreaConfigFrame = CreateScrollAreaConfig() end

	local frame = popupFrames.scrollAreaConfigFrame

	CopyTempScrollAreaSettings(frame.originalSettings)
	CopyTempScrollAreaSettings(frame.previewSettings)

	frame.scrollAreaDropdown:Clear()
	for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
		frame.scrollAreaDropdown:AddItem(saSettings.name, saKey)

		CreateScrollAreaMoverFrame(saKey)
		RepositionScrollAreaMoverFrame(saKey)
	end
	frame.scrollAreaDropdown:Sort()
	frame.currentScrollArea = "Incoming"
	frame.scrollAreaDropdown:SetSelectedID(frame.currentScrollArea)
	ChangeConfigScrollArea(frame.currentScrollArea)

	frame:Show()
end



local function CreateScrollAreaSelection()
	local frame = CreatePopup()
	frame:SetWidth(380)
	frame:SetHeight(220)


	local dropdown = MSBTControls.CreateDropdown(frame)
	local objLocale = L.DROPDOWNS["outputScrollArea"]
	dropdown:Configure(150, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -85)
	frame.scrollAreaDropdown = dropdown


	local button = MSBTControls.CreateOptionButton(frame)
	local objLocale = L.BUTTONS["inputOkay"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
		if frame.saveHandler then
			frame.saveHandler(frame.scrollAreaDropdown:GetSelectedID(), frame.saveArg1)
		end
	end)
	frame.okayButton = button

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["inputCancel"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
	end)

	return frame
end


local function ShowScrollAreaSelection(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.scrollAreaSelectionFrame) then popupFrames.scrollAreaSelectionFrame = CreateScrollAreaSelection() end

	local frame = popupFrames.scrollAreaSelectionFrame
	ChangePopupParent(frame, configTable.parentFrame)

	frame.titleFontString:SetText(configTable.title)

	frame.scrollAreaDropdown:Clear()
	for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
		frame.scrollAreaDropdown:AddItem(saSettings.name, saKey)
	end
	frame.scrollAreaDropdown:Sort()
	frame.scrollAreaDropdown:SetSelectedID("Incoming")


	frame.saveHandler = configTable.saveHandler
	frame.saveArg1 = configTable.saveArg1
	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



local function EnableEventControls()
	for name, frame in pairs(popupFrames.eventFrame.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


local function CreateEvent()
	local frame = CreatePopup()
	frame:SetWidth(380)
	frame:SetHeight(410)
	frame.controls = {}
	local controls = frame.controls

	local dropdown = MSBTControls.CreateDropdown(frame)
	local objLocale = L.DROPDOWNS["outputScrollArea"]
	dropdown:Configure(150, objLocale.label, objLocale.tooltip)
	dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -85)
	controls.scrollAreaDropdown = dropdown

	local editbox = MSBTControls.CreateEditbox(frame)
	local objLocale = L.EDITBOXES["eventMessage"]
	editbox:Configure(250, objLocale.label, nil)
	editbox:SetPoint("TOPLEFT", controls.scrollAreaDropdown, "BOTTOMLEFT", 0, -20)
	controls.messageEditbox = editbox

	MSBTOptions.Sounds.CreateEventControls(frame, EnableEventControls)

	local checkbox = MSBTControls.CreateCheckbox(frame)
	objLocale = L.CHECKBOXES["stickyEvent"]
	checkbox:Configure(28, objLocale.label, objLocale.tooltip)
	checkbox:SetPoint("TOPLEFT", controls.soundDropdown, "BOTTOMLEFT", 0, -20)
	controls.stickyCheckbox = checkbox


	editbox = MSBTControls.CreateEditbox(frame)
	local objLocale = L.EDITBOXES["iconSkill"]
	editbox:Configure(250, objLocale.label, objLocale.tooltip)
	editbox:SetPoint("TOPLEFT", controls.stickyCheckbox, "BOTTOMLEFT", 0, -20)
	controls.iconSkillEditbox = editbox



	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericSave"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(function(this)
		EraseTable(returnSettings)
		returnSettings.scrollArea = controls.scrollAreaDropdown:GetSelectedID()
		returnSettings.message = controls.messageEditbox:GetText()
		returnSettings.soundFile = controls.soundDropdown:GetSelectedID()
		returnSettings.alwaysSticky = controls.stickyCheckbox:GetChecked()
		returnSettings.iconSkill = controls.iconSkillEditbox:GetText()
		frame:Hide()
		if frame.saveHandler then
			frame.saveHandler(returnSettings, frame.saveArg1)
		end
	end)
	controls[#controls + 1] = button

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericCancel"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
	end)
	controls[#controls + 1] = button

	return frame
end


local function ShowEvent(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

	if (not popupFrames.eventFrame) then popupFrames.eventFrame = CreateEvent() end

	local frame = popupFrames.eventFrame
	ChangePopupParent(frame, configTable.parentFrame)

	frame.titleFontString:SetText(configTable.title)

	local controls = frame.controls
	controls.scrollAreaDropdown:Clear()
	for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
		controls.scrollAreaDropdown:AddItem(saSettings.name, saKey)
	end
	controls.scrollAreaDropdown:Sort()
	controls.scrollAreaDropdown:SetSelectedID(configTable.scrollArea)

	local objLocale = L.EDITBOXES["eventMessage"]
	controls.messageEditbox:SetText(configTable.message)
	controls.messageEditbox:SetTooltip(objLocale.tooltip .. "\n\n" .. (configTable.codes or ""))
	MSBTOptions.Sounds.PopulateEventSound(frame, configTable.soundFile)
	controls.stickyCheckbox:SetChecked(configTable.alwaysSticky)
	controls.iconSkillEditbox:SetText(configTable.iconSkill)


	if (configTable.isCrit) then controls.stickyCheckbox:Hide() else controls.stickyCheckbox:Show() end

	if (configTable.showIconSkillEditbox) then
		frame:SetHeight(430)
		controls.iconSkillEditbox:Show()
	else
		controls.iconSkillEditbox:Hide()
		frame:SetHeight(370)
	end

	frame.saveHandler = configTable.saveHandler
	frame.saveArg1 = configTable.saveArg1
	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



local function EnableItemListControls()
	for name, frame in pairs(popupFrames.itemListFrame.controls) do
		if (frame.Enable) then frame:Enable() end
	end
end


local function ValidateItemListName(itemName)
	if (not itemName or itemName == "") then
		return L.MSG_INVALID_ITEM_NAME
	end

	if (popupFrames.itemListFrame.items[itemName]) then
		return L.MSG_ITEM_ALREADY_EXISTS
	end
end


local function SaveItemListName(settings)
	local itemName = settings.inputText
	local frame = popupFrames.itemListFrame
	frame.items[itemName] = true

	frame.itemsListbox:AddItem(itemName, true)
end


local function DeleteItemButtonOnClick(this)
	local line = this:GetParent()
	popupFrames.itemListFrame.items[line.itemName] = false
	popupFrames.itemListFrame.itemsListbox:RemoveItem(line.itemNumber)
end


local function CreateItemListLine(this)
	local controls = popupFrames.itemListFrame.controls
	local frame = CreateFrame("Button", nil, this)
	frame:EnableMouse(false)

	local button = MSBTControls.CreateIconButton(frame, "Delete")
	local objLocale = L.BUTTONS["deleteItem"]
	button:SetTooltip(objLocale.tooltip)
	button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
	button:SetClickHandler(DeleteItemButtonOnClick)
	frame.deleteButton = button
	controls[#controls + 1] = button

	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("LEFT", frame, "LEFT", 5, 0)
	fontString:SetPoint("RIGHT", frame.deleteButton, "LEFT", -10, 0)
	fontString:SetJustifyH("LEFT")
	fontString:SetTextColor(1, 1, 1)
	frame.itemFontString = fontString

	return frame
end


local function DisplayItemListLine(this, line, key, isSelected)
	local frame = popupFrames.itemListFrame
	line.itemName = key
	line.itemFontString:SetText(key)
end



local function CreateItemList()
	local frame = CreatePopup()
	frame:SetWidth(440)
	frame:SetHeight(360)
	frame.controls = {}
	local controls = frame.controls

	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -85)
	fontString:SetText(L.MSG_ITEMS .. ":")
	frame.itemsFontString = fontString

	local button = MSBTControls.CreateOptionButton(frame)
	local objLocale = L.BUTTONS["addItem"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("LEFT", frame.itemsFontString, "RIGHT", 10, 0)
	button:SetClickHandler(function(this)
		local objLocale = L.EDITBOXES["itemName"]
		EraseTable(tempConfig)
		tempConfig.title = L.BUTTONS.addItem.label
		tempConfig.editboxLabel = objLocale.label
		tempConfig.editboxTooltip = objLocale.tooltip
		tempConfig.parentFrame = frame
		tempConfig.anchorFrame = this
		tempConfig.validateHandler = ValidateItemListName
		tempConfig.saveHandler = SaveItemListName
		tempConfig.hideHandler = EnableItemListControls
		DisableControls(controls)
		ShowInput(tempConfig)
	end)
	frame.addItemButton = button
	controls[#controls + 1] = button

	local listbox = MSBTControls.CreateListbox(frame)
	listbox:Configure(352, 180, 30)
	listbox:SetPoint("TOPLEFT", frame.itemsFontString, "BOTTOMLEFT", 0, -16)
	listbox:SetCreateLineHandler(CreateItemListLine)
	listbox:SetDisplayHandler(DisplayItemListLine)
	frame.itemsListbox = listbox
	controls[#controls + 1] = listbox

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericSave"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
		if frame.saveHandler then
			frame.saveHandler(frame.saveArg1)
		end
	end)
	controls[#controls + 1] = button

	button = MSBTControls.CreateOptionButton(frame)
	objLocale = L.BUTTONS["genericCancel"]
	button:Configure(24, objLocale.label, objLocale.tooltip)
	button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
	button:SetClickHandler(function(this)
		frame:Hide()
	end)
	controls[#controls + 1] = button

	return frame
end


local function ShowItemList(configTable)
	if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.items) then return end

	if (not popupFrames.itemListFrame) then popupFrames.itemListFrame = CreateItemList() end

	local frame = popupFrames.itemListFrame
	ChangePopupParent(frame, configTable.parentFrame)


	frame.titleFontString:SetText(configTable.title)

	frame.items = configTable.items
	frame.itemsListbox:Clear()
	for itemName, value in pairs(configTable.items) do
		if (value) then frame.itemsListbox:AddItem(itemName) end
	end

	frame.saveHandler = configTable.saveHandler
	frame.saveArg1 = configTable.saveArg1
	frame.hideHandler = configTable.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
	frame:Show()
	frame:Raise()
end



if type(FillLocalizedClassList) == "function" then
	FillLocalizedClassList(CLASS_NAMES)
else
	CLASS_NAMES = LocalizedClassList()
end





module.DisableControls				= DisableControls
module.CreateMenuArtwork			= CreateMenuArtwork
module.ShowInput					= ShowInput
module.ShowAcknowledge				= ShowAcknowledge
module.ShowFont						= ShowFont
module.ShowPartialEffects			= ShowPartialEffects
module.ShowDamageColors				= ShowDamageColors
module.ShowClassColors				= ShowClassColors
module.ShowScrollAreaConfig			= ShowScrollAreaConfig
module.ShowScrollAreaSelection		= ShowScrollAreaSelection
module.ShowEvent					= ShowEvent
module.ShowItemList					= ShowItemList
