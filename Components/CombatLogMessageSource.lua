local CombatLogMessageSource = {}
CombatLogMessageSource.__index = CombatLogMessageSource

local NEWEST_ORDER = Enum and Enum.CombatLogMessageOrder and Enum.CombatLogMessageOrder.Newest or 0

function CombatLogMessageSource:New(config)
	local source = setmetatable({
		config = config,
		frame = CreateFrame("Frame"),
		lastMessageTime = 0,
		lastLiveTime = 0,
		recentMessages = {},
		expectedCasts = {},
		missedCasts = 0,
		suspect = false,
	}, self)
	source.frame:SetScript("OnEvent", function(_, _, message, colorR, colorG, colorB, order)
		source:HandleMessage(message, colorR, colorG, colorB, order)
	end)
	return source
end

local function SetFilteredEvents(enabled)
	if C_CombatLog and C_CombatLog.SetFilteredEventsEnabled then
		pcall(C_CombatLog.SetFilteredEventsEnabled, enabled)
	end
end

local function IsCombatLogTabShown()
	return COMBATLOG ~= nil and COMBATLOG.IsShown ~= nil and COMBATLOG:IsShown()
end

function CombatLogMessageSource:KeepLiveProcessing()
	if self.active and self:IsEnabled() then
		SetFilteredEvents(true)
	end
end

function CombatLogMessageSource:HookBlizzardToggle()
	if self.hooked or not (C_CombatLog and C_CombatLog.SetFilteredEventsEnabled) then
		return
	end
	self.hooked = true
	hooksecurefunc(C_CombatLog, "SetFilteredEventsEnabled", function(enabled)
		if enabled or not self.active or not self:IsEnabled() or self.restoring then
			return
		end
		C_Timer.After(0, function()
			self:KeepLiveProcessing()
		end)
	end)
end

function CombatLogMessageSource:Start()
	self.active = true
	pcall(self.frame.RegisterEvent, self.frame, "COMBAT_LOG_MESSAGE")
	self:HookBlizzardToggle()
	self:KeepLiveProcessing()
end

function CombatLogMessageSource:Stop()
	self.active = false
	self.frame:UnregisterAllEvents()
	self.lastMessageTime = 0
	self:RestoreBlizzardState()
end

function CombatLogMessageSource:RestoreBlizzardState()
	self.restoring = true
	SetFilteredEvents(IsCombatLogTabShown())
	self.restoring = false
end

function CombatLogMessageSource:ApplyOption()
	if not self.active then
		return
	end
	if self:IsEnabled() then
		self:KeepLiveProcessing()
	else
		self.lastMessageTime = 0
		self:RestoreBlizzardState()
	end
end

function CombatLogMessageSource:IsEnabled()
	local profile = self.config.getProfile()
	return profile ~= nil and profile.useCombatLogMessages ~= false
end

function CombatLogMessageSource:IsRawMode()
	local profile = self.config.getProfile()
	return profile ~= nil and profile.combatLogMessagesRaw == true
end

function CombatLogMessageSource:IsOwning()
	return self:IsEnabled() and self:IsRawMode() and self.lastMessageTime > 0
		and self.config.getTime() - self.lastMessageTime <= self.config.ownershipWindow
end

function CombatLogMessageSource:GetFilterState()
	local settings = Blizzard_CombatLog_Filters
	if type(settings) ~= "table" or type(settings.filters) ~= "table" then
		return nil
	end
	local current = settings.filters[settings.currentFilter]
	if type(current) ~= "table" or type(current.filters) ~= "table" then
		return nil
	end
	local mine = COMBATLOG_FILTER_MINE
	if mine == nil then
		return nil
	end
	for _, entry in pairs(current.filters) do
		if type(entry) == "table" and type(entry.sourceFlags) == "table"
			and entry.sourceFlags[mine] == true then
			return true, current.name
		end
	end
	return false, current.name
end

local function IsPlainNumber(value)
	return type(value) == "number" and not (issecretvalue and issecretvalue(value))
end

local function AddColor(list, color, highlight)
	if type(color) ~= "table" or not IsPlainNumber(color.r) or not IsPlainNumber(color.g)
		or not IsPlainNumber(color.b) then
		return
	end
	list[#list + 1] = { color.r, color.g, color.b }
	if highlight then
		list[#list + 1] = {
			math.min(color.r * 1.5, 1), math.min(color.g * 1.5, 1), math.min(color.b * 1.5, 1),
		}
	end
end

function CombatLogMessageSource:GetOwnerColors()
	local settings = Blizzard_CombatLog_Filters
	if type(settings) ~= "table" or type(settings.filters) ~= "table" then
		return nil, "nofilter"
	end
	local current = settings.filters[settings.currentFilter]
	if type(current) ~= "table" or type(current.settings) ~= "table" or type(current.colors) ~= "table"
		or type(current.colors.unitColoring) ~= "table" then
		return nil, "nosettings"
	end
	local lineSettings = current.settings
	if not lineSettings.lineColoring then
		return nil, "linecoloring off"
	end
	if lineSettings.lineColorPriority ~= nil and lineSettings.lineColorPriority ~= 1 then
		return nil, "priority " .. tostring(lineSettings.lineColorPriority)
	end
	local highlight = lineSettings.lineHighlighting and true or false
	local unitColoring = current.colors.unitColoring
	local mine, others = {}, {}
	for mask, color in pairs(unitColoring) do
		if mask == COMBATLOG_FILTER_MINE or mask == COMBATLOG_FILTER_MY_PET then
			AddColor(mine, color, highlight)
		else
			AddColor(others, color, highlight)
		end
	end
	local distinct = {}
	for _, own in ipairs(mine) do
		local collides = false
		for _, other in ipairs(others) do
			if math.abs(own[1] - other[1]) < 0.01 and math.abs(own[2] - other[2]) < 0.01
				and math.abs(own[3] - other[3]) < 0.01 then
				collides = true
				break
			end
		end
		own.ambiguous = collides
		if not collides then
			distinct[#distinct + 1] = own
		end
	end
	if #distinct == 0 then
		return nil, "ambiguous"
	end
	return mine
end

function CombatLogMessageSource:ClassifyColor(colorR, colorG, colorB)
	if not (IsPlainNumber(colorR) and IsPlainNumber(colorG) and IsPlainNumber(colorB)) then
		return nil, "secret"
	end
	local mine, reason = self:GetOwnerColors()
	if not mine then
		return nil, reason
	end
	for _, own in ipairs(mine) do
		if math.abs(own[1] - colorR) < 0.01 and math.abs(own[2] - colorG) < 0.01
			and math.abs(own[3] - colorB) < 0.01 then
			if own.ambiguous then
				return nil, "ambiguous color"
			end
			return "mine"
		end
	end
	return "other"
end

function CombatLogMessageSource:CoversOwnActions()
	return self:GetFilterState() ~= false
end

function CombatLogMessageSource:IsLive()
	return self:IsEnabled() and self.lastLiveTime > 0
		and self.config.getTime() - self.lastLiveTime <= self.config.liveWindow
		and self:CoversOwnActions()
end

function CombatLogMessageSource:TakeMessage(eventTime, lookback, owner)
	local best, bestDistance
	for _, entry in ipairs(self.recentMessages) do
		if not entry.used and (owner == nil or entry.owner == nil or entry.owner == owner) then
			local distance = eventTime - entry.time
			local fits = distance == 0 or (lookback and distance > 0 and distance <= lookback)
			if fits and (not bestDistance or distance < bestDistance) then
				best, bestDistance = entry, distance
			end
		end
	end
	if best then
		best.used = true
		return true
	end
	return false
end

function CombatLogMessageSource:CountLive(now, owner)
	self.lastLiveTime = now
	local messages = self.recentMessages
	for index = #messages, 1, -1 do
		if now - messages[index].time > 4 then
			table.remove(messages, index)
		end
	end
	messages[#messages + 1] = { time = now, owner = owner }
end

function CombatLogMessageSource:DescribeLinesNear(castTime)
	local parts = {}
	for _, entry in ipairs(self.recentMessages) do
		local offset = entry.time - castTime
		if offset >= -0.5 and offset <= self.config.expectWindow and #parts < 6 then
			parts[#parts + 1] = string.format("%+.2f%s%s", offset, entry.owner == "other" and "x" or "",
				entry.used and "" or "?")
		end
	end
	return #parts > 0 and table.concat(parts, " ") or "no lines"
end

function CombatLogMessageSource:NoteMissedCast(castTime)
	if self.lastMissedCast == castTime then
		return
	end
	self.lastMissedCast = castTime
	self.missedCasts = self.missedCasts + 1
	MikSBT.Trace:Note("own:castmiss", self:DescribeLinesNear(castTime))
	if not self.suspect and self.missedCasts >= self.config.missLimit then
		self.suspect = true
		MikSBT.Trace:Inc("own:suspect")
	end
end

function CombatLogMessageSource:CheckExpectedCasts(now)
	local casts = self.expectedCasts
	for index = #casts, 1, -1 do
		local castTime = casts[index]
		if now - castTime > self.config.expectWindow then
			table.remove(casts, index)
			self:NoteMissedCast(castTime)
		end
	end
end

function CombatLogMessageSource:ExpectOwnLine(now)
	self:CheckExpectedCasts(now)
	self.expectedCasts[#self.expectedCasts + 1] = now
end

function CombatLogMessageSource:ConfirmOwnLine()
	local casts = self.expectedCasts
	for index = #casts, 1, -1 do
		casts[index] = nil
	end
	self.missedCasts = 0
	if self.suspect then
		self.suspect = false
		MikSBT.Trace:Inc("own:revived")
	end
end

function CombatLogMessageSource:IsSuspect()
	return self.suspect == true
end

local function ToByte(value)
	if type(value) ~= "number" or (issecretvalue and issecretvalue(value)) then
		return 255
	end
	return math.floor(math.max(0, math.min(1, value)) * 255 + 0.5)
end

function CombatLogMessageSource:HandleMessage(message, colorR, colorG, colorB, order)
	local trace = MikSBT.Trace
	trace:Inc("clm:recv")
	if type(message) == "string" and not (issecretvalue and issecretvalue(message))
		and not string.find(message, "|K", 1, true) then
		trace:Error("clm:readable", string.sub(string.gsub(message, "|", "||"), 1, 160))
	end
	if order ~= nil and not (issecretvalue and issecretvalue(order)) and order ~= NEWEST_ORDER then
		trace:Inc("clm:replay")
		return
	end
	if message == nil or not self:IsEnabled() then
		return
	end
	local now = self.config.getTime()
	local owner, reason = self:ClassifyColor(colorR, colorG, colorB)
	if owner == "mine" then
		trace:Inc("clm:color:mine")
	elseif owner == "other" then
		trace:Note("clm:color:other", string.format("%.2f %.2f %.2f", colorR, colorG, colorB))
	else
		trace:Note("clm:color:none", reason)
	end
	self:CountLive(now, owner)
	trace:Inc("clm:live")
	if not self.filterWarned and self.config.warnFilter then
		local covers, filterName = self:GetFilterState()
		if covers == false then
			self.filterWarned = true
			self.config.warnFilter(filterName)
		end
	end
	if not self:IsRawMode() then
		return
	end
	self.lastMessageTime = now
	trace:Inc("clm:shown")
	self.config.display(message, self.config.getProfile().combatLogMessageArea or "Outgoing",
		ToByte(colorR), ToByte(colorG), ToByte(colorB))
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.CombatLogMessageSource = CombatLogMessageSource

return CombatLogMessageSource
