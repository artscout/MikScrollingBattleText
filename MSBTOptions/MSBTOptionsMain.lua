local module = {}
local moduleName = "Main"
MSBTOptions[moduleName] = module

local Client = MikSBT.Compatibility.Client
local HasModernAPI = Client.hasModernAPI



local MSBTControls = MSBTOptions.Controls
local L = MikSBT.translations



local WINDOW_TITLE = "Mik's Scrolling Battle Text " .. MikSBT.VERSION_STRING



local _

local mainFrame

local popupFrames = {}

local tabData = {}
local tabListbox
local resetTabListbox
local languageTabListbox
local BOTTOM_TAB_ORDER = 9000
local LANGUAGE_TAB_ORDER = 9500

local waitTable = {}
local waitFrame = nil



	local function InitTab(tabInfo)
		local frame = tabInfo.frame
		frame:SetParent(mainFrame)
		frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 235, -78)
		frame:SetWidth(535)
		frame:SetHeight(400)
	end


local function AddTab(frame, text, tooltip, order)
	local tabInfo = {}
	tabInfo.text = text
	tabInfo.frame = frame
	tabInfo.tooltip = tooltip
	tabInfo.order = order or (#tabData + 1)

	tabData[#tabData+1] = tabInfo
	table.sort(tabData, function(a, b) return a.order < b.order end)
	local tabIndex
	for index, info in ipairs(tabData) do
		if info == tabInfo then
			tabIndex = index
			break
		end
	end

	if (tabListbox) then
		InitTab(tabInfo)
		if tabInfo.order >= LANGUAGE_TAB_ORDER and languageTabListbox then
			languageTabListbox:AddItem(tabIndex)
		elseif tabInfo.order >= BOTTOM_TAB_ORDER and resetTabListbox then
			resetTabListbox:AddItem(tabIndex)
		else
			tabListbox:AddItem(tabIndex)
		end
	end
end


local function RefreshTabContainers()
	tabListbox:Refresh()
	if resetTabListbox then
		resetTabListbox:Refresh()
	end
	if languageTabListbox then
		languageTabListbox:Refresh()
	end
end


local function SelectTabContainerItem(tabIndex)
	local tabInfo = tabData[tabIndex]
	if not tabInfo then
		return
	end

	tabListbox:SetSelectedItem(0)
	if resetTabListbox then
		resetTabListbox:SetSelectedItem(0)
	end
	if languageTabListbox then
		languageTabListbox:SetSelectedItem(0)
	end

	if tabInfo.order >= LANGUAGE_TAB_ORDER then
		languageTabListbox:SetSelectedItem(tabIndex)
	elseif tabInfo.order >= BOTTOM_TAB_ORDER then
		resetTabListbox:SetSelectedItem(tabIndex)
	else
		tabListbox:SetSelectedItem(tabIndex)
	end
end


local function CreateTabLine(this)
	local frame = CreateFrame("Button", nil, this)

	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("LEFT", frame, "LEFT")
	fontString:SetPoint("RIGHT", frame, "RIGHT")

	frame.fontString = fontString
	frame.tooltipAnchor = "ANCHOR_LEFT"
	return frame
end


local function DisplayTabLine(this, line, key, isSelected)
	line.fontString:SetText(tabData[key].text)
	line.tooltip = tabData[key].tooltip
	local color = isSelected and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR
	line.fontString:SetTextColor(color.r, color.g, color.b)
end


local function OnClickTabLine(this, line, value)
	for _, info in ipairs(tabData) do
		info.frame:Hide()
	end

	for frame in pairs(popupFrames) do
		frame:Hide()
	end

	local frame = tabData[value].frame
	if (frame) then frame:Show() end

	SelectTabContainerItem(value)

	RefreshTabContainers()
end



local function OnHideMainFrame(this)
	PlaySound(799)
	for frame in pairs(popupFrames) do
		frame:Hide()
	end
end


local function CreateMainFrame()
	mainFrame = CreateFrame("Frame", "MSBTMainOptionsFrame", UIParent)
	mainFrame:EnableMouse(true)
	mainFrame:SetMovable(true)
	mainFrame:RegisterForDrag("LeftButton")
	mainFrame:SetClampedToScreen(true)
	mainFrame:SetFrameStrata("DIALOG")
	mainFrame:SetWidth(790)
	mainFrame:SetHeight(490)
	mainFrame:SetPoint("CENTER")
	mainFrame:SetHitRectInsets(0, 0, 0, 0)
	mainFrame:SetScript("OnHide", OnHideMainFrame)

	mainFrame:SetScript("OnShow", function(self)
			self:SetFrameLevel((self:GetParent() and self:GetParent():GetFrameLevel() or 0) + 50)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end)
	mainFrame:SetScript("OnDragStart", function(self)
			self:StartMoving()
	end)
	mainFrame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
	end)
	local texture = mainFrame:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture("Interface\\FriendsFrame\\FriendsFrameScrollIcon")
	texture:SetWidth(64)
	texture:SetHeight(64)
	texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, 1)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
	texture:SetWidth(256)
	texture:SetHeight(256)
	texture:SetPoint("TOPLEFT")

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
	texture:SetWidth(128)
	texture:SetHeight(256)
	texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 256, 0)
	texture:SetTexCoord(0.38, 0.88, 0, 1)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
	texture:SetHeight(256)
	texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 384, 0)
	texture:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -100, 0)
	texture:SetTexCoord(0.45, 0.95, 0, 1)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
	texture:SetWidth(100)
	texture:SetHeight(256)
	texture:SetPoint("TOPRIGHT")
	texture:SetTexCoord(0, 0.78125, 0, 1)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
	texture:SetWidth(256)
	texture:SetHeight(234)
	texture:SetPoint("BOTTOMLEFT")
	texture:SetTexCoord(0, 1, 0, 0.71875)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
	texture:SetWidth(128)
	texture:SetHeight(234)
	texture:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 256, 0)
	texture:SetTexCoord(0.5, 1, 0, 0.71875)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
	texture:SetHeight(234)
	texture:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 384, 0)
	texture:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -100, 0)
	texture:SetTexCoord(0.5, 1, 0, 0.71875)

	texture = mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	texture:SetWidth(100)
	texture:SetHeight(234)
	texture:SetPoint("BOTTOMRIGHT")
	texture:SetTexCoord(0, 0.78125, 0, 0.71875)

	texture = mainFrame:CreateTexture(nil, "OVERLAY")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
	texture:SetWidth(8)
	texture:SetHeight(184)
	texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 225, -72)
	texture:SetTexCoord(0.648437, 0.7109375, 0.28125, 1.0)

	texture = mainFrame:CreateTexture(nil, "OVERLAY")
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
	texture:SetWidth(8)
	texture:SetHeight(224)
	texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 225, -256)
	texture:SetTexCoord(0.648437, 0.7109375, 0.3203125, 1.0)

	local fontString = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fontString:SetText(WINDOW_TITLE)
	fontString:SetPoint("TOP", mainFrame, "TOP", 0, -18)

	local frame = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
	if not HasModernAPI then
		frame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -3, -8)
	else
		frame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -7, -12)
	end


	tabListbox = MSBTControls.CreateListbox(mainFrame)
	tabListbox:Configure(195, 365, 20)
	tabListbox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 30, -78)
	tabListbox:SetCreateLineHandler(CreateTabLine)
	tabListbox:SetDisplayHandler(DisplayTabLine)
	tabListbox:SetClickHandler(OnClickTabLine)

	resetTabListbox = MSBTControls.CreateListbox(mainFrame)
	resetTabListbox:Configure(195, 20, 20)
	resetTabListbox:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 30, 92)
	resetTabListbox:SetCreateLineHandler(CreateTabLine)
	resetTabListbox:SetDisplayHandler(DisplayTabLine)
	resetTabListbox:SetClickHandler(OnClickTabLine)

	languageTabListbox = MSBTControls.CreateListbox(mainFrame)
	languageTabListbox:Configure(195, 20, 20)
	languageTabListbox:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 30, 16)
	languageTabListbox:SetCreateLineHandler(CreateTabLine)
	languageTabListbox:SetDisplayHandler(DisplayTabLine)
	languageTabListbox:SetClickHandler(OnClickTabLine)

	for k, tabInfo in ipairs(tabData) do
		InitTab(tabInfo)
		if tabInfo.order >= LANGUAGE_TAB_ORDER then
			languageTabListbox:AddItem(k)
		elseif tabInfo.order >= BOTTOM_TAB_ORDER then
			resetTabListbox:AddItem(k)
		else
			tabListbox:AddItem(k)
		end
	end

	local defaultTabIndex = nil
	for index, info in ipairs(tabData) do
		if info.text == L.TABS.general.label then
			defaultTabIndex = index
			break
		end
	end
	if not defaultTabIndex then
		for index, info in ipairs(tabData) do
			if info.order < BOTTOM_TAB_ORDER then
				defaultTabIndex = index
				break
			end
		end
	end
	defaultTabIndex = defaultTabIndex or 1

	SelectTabContainerItem(defaultTabIndex)
	RefreshTabContainers()
	tabData[defaultTabIndex].frame:Show()

	local frameName = mainFrame:GetName()
	local isRegistered = false
	for _, name in ipairs(UISpecialFrames) do
		if name == frameName then
			isRegistered = true
			break
		end
	end
	if not isRegistered then
		table.insert(UISpecialFrames, frameName)
	end
end


local function ShowMainFrame()
	if (not mainFrame) then CreateMainFrame() end
	if (not MSBTScrollAreasConfigFrame or not MSBTScrollAreasConfigFrame:IsShown()) then
		mainFrame:Show()
	end
end


local function HideMainFrame()
	mainFrame:Hide()
end


local function RegisterPopupFrame(frame)
	if (not popupFrames[frame]) then popupFrames[frame] = true end
end



local function ScheduleCallback(delay, func, ...)
	if (waitFrame == nil) then
		waitFrame = CreateFrame("Frame", nil, UIParent)
		waitFrame:SetScript("OnUpdate",function (self, elapsed)
			local count = #waitTable
			local i = 1
			while (i <= count) do
				local waitRecord = tremove(waitTable, i)
				local duration = tremove(waitRecord, 1)
				local func = tremove(waitRecord, 1)
				local params = tremove(waitRecord, 1)
				if (duration > elapsed) then
					tinsert(waitTable, i, {duration - elapsed, func, params})
					i = i + 1
				else
					count = count - 1
					func(unpack(params))
				end
			end
		end)
	end
	tinsert(waitTable, {delay, func, {...}})
	return true
end




module.ShowMainFrame		= ShowMainFrame
module.HideMainFrame		= HideMainFrame
module.RegisterPopupFrame	= RegisterPopupFrame
module.AddTab				= AddTab
module.ScheduleCallback		= ScheduleCallback
