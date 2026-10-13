local module = {}
MSBTOptions.ProfileTransfer = module

local Controls = MSBTOptions.Controls
local L = MikSBT.translations.PROFILE_TRANSFER
local popup

local function ClosePopup(frame)
	local hideHandler = frame.hideHandler
	frame.dataEditbox:ClearFocus()
	frame.nameEditbox.editboxFrame:ClearFocus()
	frame.exportText = nil
	frame.importHandler = nil
	frame.successHandler = nil
	frame.hideHandler = nil
	frame.dataEditbox:SetText("")
	frame.nameEditbox:SetText("")
	if hideHandler then hideHandler() end
end

local function Submit(frame)
	if frame.exportText then
		frame.dataEditbox:SetFocus()
		frame.dataEditbox:HighlightText()
		return
	end
	local name, details = frame.importHandler(
		frame.dataEditbox:GetText(), frame.nameEditbox:GetText())
	if not name then
		local field = frame.dataPanel
		if details == "INVALID_NAME" or details == "PROFILE_EXISTS"
			or details == "IN_COMBAT" then
			field = frame.nameEditbox
		end
		frame.statusText:ClearAllPoints()
		frame.statusText:SetPoint("TOPLEFT", field, "BOTTOMLEFT", 0, -8)
		frame.statusText:SetText(L.errors[details] or L.errors.INVALID_DATA)
		return
	end
	local successHandler = frame.successHandler
	frame:Hide()
	successHandler(name, details)
end

local function CreatePopup()
	local frame = CreateFrame("Frame", nil, UIParent,
		BackdropTemplateMixin and "BackdropTemplate")
	frame:Hide()
	frame:SetSize(560, 520)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	MSBTOptions.Popups.CreateMenuArtwork(frame, 256)
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	frame:SetScript("OnHide", ClosePopup)
	MSBTOptions.Main.RegisterPopupFrame(frame)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", frame, "TOP", 0, -18)
	frame.titleText = title
	local headerClose = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	headerClose:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -12)
	headerClose:SetScript("OnClick", function() frame:Hide() end)
	local instructions = frame:CreateFontString(nil, "OVERLAY",
		"GameFontHighlightSmall")
	instructions:SetPoint("TOPLEFT", 30, -78)
	instructions:SetWidth(500)
	instructions:SetJustifyH("LEFT")
	frame.instructionsText = instructions

	local name = Controls.CreateEditbox(frame)
	name:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 30, 178)
	name:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -30, 178)
	name:SetLabel(L.name)
	name.editboxFrame:SetMaxLetters(64)
	name:SetEscapeHandler(function() frame:Hide() end)
	name:SetEnterHandler(function() Submit(frame) end)
	name:SetTextChangedHandler(function() frame.statusText:SetText("") end)
	frame.nameEditbox = name

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("TOPLEFT", 30, -118)
	frame.dataLabel = label
	local panel = CreateFrame("Frame", nil, frame,
		BackdropTemplateMixin and "BackdropTemplate")
	panel:SetPoint("TOPLEFT", 30, -138)
	panel:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	panel:SetBackdropColor(0.02, 0.02, 0.02, 1)
	panel:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
	frame.dataPanel = panel
	local scroll = CreateFrame("ScrollFrame", nil, panel,
		"UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 12, -12)
	scroll:SetPoint("BOTTOMRIGHT", -32, 12)
	frame.scrollFrame = scroll
	local hint = scroll:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT")
	hint:SetWidth(456)
	hint:SetJustifyH("LEFT")
	hint:SetText(L.pasteHint)
	frame.dataHint = hint

	local data = CreateFrame("EditBox", nil, scroll)
	data:SetMultiLine(true)
	data:SetAutoFocus(false)
	data:SetFontObject(ChatFontNormal)
	data:SetWidth(456)
	data:SetHeight(160)
	data:SetMaxLetters(131072)
	data:SetScript("OnEscapePressed", function() frame:Hide() end)
	data:SetScript("OnTabPressed", function(self)
		if not frame.exportText then
			self:ClearFocus()
			frame.nameEditbox.editboxFrame:SetFocus()
		end
	end)
	data:SetScript("OnTextChanged", function(self)
		frame.statusText:SetText("")
		if not frame.exportText and self:GetText() == "" then
			frame.dataHint:Show()
		else
			frame.dataHint:Hide()
		end
		if frame.exportText and self:GetText() ~= frame.exportText then
			self:SetText(frame.exportText)
			self:HighlightText()
		end
		scroll:UpdateScrollChildRect()
	end)
	data:SetScript("OnCursorChanged", function(_, _, y, _, height)
		if frame.exportText then return end
		local cursor = -y
		local offset = scroll:GetVerticalScroll()
		if cursor < offset then
			scroll:SetVerticalScroll(cursor)
		elseif cursor + height > offset + scroll:GetHeight() then
			scroll:SetVerticalScroll(cursor + height - scroll:GetHeight())
		end
	end)
	scroll:SetScrollChild(data)
	frame.dataEditbox = data

	local note = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	note:SetPoint("BOTTOMLEFT", 30, 68)
	note:SetWidth(500)
	note:SetJustifyH("LEFT")
	note:SetText(L.mediaNote)
	local status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	status:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -8)
	status:SetWidth(500)
	status:SetJustifyH("LEFT")
	status:SetTextColor(1, 0.3, 0.3)
	frame.statusText = status

	local action = Controls.CreateOptionButton(frame)
	action:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 15)
	action:SetClickHandler(function() Submit(frame) end)
	frame.actionButton = action
	local copy = Controls.CreateOptionButton(frame)
	copy:Configure(24, L.copy, L.exportHelp)
	copy:SetPoint("BOTTOM", frame, "BOTTOM", 0, 22)
	copy:SetClickHandler(function() Submit(frame) end)
	frame.copyButton = copy
	local close = Controls.CreateOptionButton(frame)
	close:Configure(24, L.close)
	close:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 15)
	close:SetClickHandler(function() frame:Hide() end)
	frame.closeButton = close
	return frame
end

local function Show(config, exportText)
	if not popup then popup = CreatePopup() end
	local frame = popup
	frame.hideHandler = nil
	frame:SetParent(config.parentFrame)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetFrameLevel(config.parentFrame:GetFrameLevel() + 3)
	frame.exportText = exportText
	frame.importHandler = config.importHandler
	frame.successHandler = config.successHandler
	frame.hideHandler = config.hideHandler
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", config.parentFrame, "CENTER")
	frame.titleText:SetText(exportText and L.exportTitle or L.importTitle)
	frame.instructionsText:SetText(exportText and L.exportHelp or L.importHelp)
	frame.actionButton:Configure(24,
		exportText and L.selectAll or L.importAction)
	frame.dataLabel:SetText(exportText and L.exportLabel or L.importLabel)
	frame.actionButton:ClearAllPoints()
	frame.closeButton:ClearAllPoints()
	frame.dataPanel:ClearAllPoints()
	frame.dataPanel:SetPoint("TOPLEFT", 30, -138)
	if exportText then
		frame.copyButton:Show()
		frame.actionButton:SetPoint("BOTTOMRIGHT", frame.copyButton,
			"BOTTOMLEFT", -10, 0)
		frame.closeButton:SetPoint("BOTTOMLEFT", frame.copyButton,
			"BOTTOMRIGHT", 10, 0)
		frame.nameEditbox:Hide()
		frame.dataPanel:SetPoint("BOTTOMRIGHT", -30, 150)
	else
		frame.copyButton:Hide()
		frame.actionButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 22)
		frame.closeButton:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 22)
		frame.nameEditbox:Show()
		frame.nameEditbox:SetText("")
		frame.dataPanel:SetPoint("BOTTOMRIGHT", -30, 224)
	end
	frame.dataEditbox:SetText(exportText or "")
	frame.scrollFrame:SetVerticalScroll(0)
	frame.statusText:SetText("")
	frame:Show()
	frame:Raise()
	frame.dataEditbox:SetFocus()
	if exportText then frame.dataEditbox:HighlightText() end
end

function module.ShowExport(config, text)
	Show(config, text)
end

function module.ShowImport(config)
	Show(config)
end
