local CombatLogFilterButton = {}
CombatLogFilterButton.__index = CombatLogFilterButton

local QUICK_BUTTON_PREFIX = "CombatLogQuickButtonFrameButton"

function CombatLogFilterButton:New(config)
	local helper = setmetatable({
		config = config,
		eventFrame = CreateFrame("Frame"),
	}, self)
	helper.eventFrame:SetScript("OnEvent", function(_, event, arg1)
		if event == "ADDON_LOADED" and arg1 ~= "Blizzard_CombatLog" then
			return
		end
		if event == "ADDON_LOADED" or event == "PLAYER_ENTERING_WORLD" then
			helper:HookBlizzard()
		end
		helper:Update()
	end)
	return helper
end

local function FindOwnFilterIndex()
	local settings = Blizzard_CombatLog_Filters
	if type(settings) ~= "table" or type(settings.filters) ~= "table" or COMBATLOG_FILTER_MINE == nil then
		return nil
	end
	for index, filter in ipairs(settings.filters) do
		if type(filter) == "table" and type(filter.filters) == "table" then
			for _, entry in pairs(filter.filters) do
				if type(entry) == "table" and type(entry.sourceFlags) == "table"
					and entry.sourceFlags[COMBATLOG_FILTER_MINE] == true then
					return index, filter.name
				end
			end
		end
	end
end

local function FindQuickButton(filterIndex)
	local index = 1
	while true do
		local button = _G[QUICK_BUTTON_PREFIX .. index]
		if not button then
			return nil
		end
		if button:IsShown() and button:GetID() == filterIndex then
			return button:GetName()
		end
		index = index + 1
	end
end

local function GetSelectedTabName()
	local frame = SELECTED_CHAT_FRAME
	if frame and frame ~= COMBATLOG and frame.GetName and frame:GetName() then
		local tab = _G[frame:GetName() .. "Tab"]
		if tab then
			return tab:GetName()
		end
	end
end

function CombatLogFilterButton:BuildMacro()
	if not COMBATLOG or not COMBATLOG.GetName then
		return nil
	end
	local filterIndex = FindOwnFilterIndex()
	if not filterIndex then
		return nil
	end
	local combatLogTab = _G[COMBATLOG:GetName() .. "Tab"]
	local quickButton = FindQuickButton(filterIndex)
	if not combatLogTab or not quickButton then
		return nil
	end
	local lines = { "/click " .. combatLogTab:GetName(), "/click " .. quickButton }
	local back = GetSelectedTabName()
	if back then
		lines[#lines + 1] = "/click " .. back
	end
	return table.concat(lines, "\n")
end

function CombatLogFilterButton:CreateButton()
	if self.button or InCombatLockdown() then
		return self.button
	end
	local button = CreateFrame("Button", "MSBTCombatLogFilterButton", UIParent,
		"SecureActionButtonTemplate, UIPanelButtonTemplate")
	button:SetFrameStrata("HIGH")
	button:SetText(self.config.label())
	button:SetWidth(button:GetTextWidth() + 30)
	button:SetHeight(24)
	if ChatFrame1 then
		button:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 34)
	else
		button:SetPoint("TOP", UIParent, "TOP", 0, -120)
	end
	button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
	button:SetAttribute("type", "macro")
	button:SetScript("PreClick", function()
		if not InCombatLockdown() then
			local macro = self:BuildMacro()
			if macro then
				button:SetAttribute("macrotext", macro)
			end
		end
	end)
	button:SetScript("PostClick", function()
		C_Timer.After(0.2, function()
			self:Update()
		end)
	end)
	button:Hide()
	self.button = button
	return button
end

function CombatLogFilterButton:HookBlizzard()
	if self.hooked or type(Blizzard_CombatLog_QuickButton_OnClick) ~= "function" then
		return
	end
	self.hooked = true
	hooksecurefunc("Blizzard_CombatLog_QuickButton_OnClick", function()
		C_Timer.After(0, function()
			self:Update()
		end)
	end)
end

function CombatLogFilterButton:Update()
	if InCombatLockdown() then
		return
	end
	local wanted = self.active and self.config.isWanted()
	local macro = wanted and self:BuildMacro()
	if not macro then
		if self.button then
			self.button:Hide()
		end
		return
	end
	local button = self:CreateButton()
	if button then
		button:SetAttribute("macrotext", macro)
		button:Show()
	end
end

function CombatLogFilterButton:Start()
	self.active = true
	self.eventFrame:RegisterEvent("ADDON_LOADED")
	self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:HookBlizzard()
	self:Update()
end

function CombatLogFilterButton:Stop()
	self.active = false
	self.eventFrame:UnregisterAllEvents()
	self:Update()
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.CombatLogFilterButton = CombatLogFilterButton

return CombatLogFilterButton
