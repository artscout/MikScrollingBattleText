local ItemCooldownTracker = {}
ItemCooldownTracker.__index = ItemCooldownTracker

function ItemCooldownTracker:New(config)
	return setmetatable({
		config = config,
		enabled = false,
		elapsed = 0,
		watchedItems = {},
		activeCooldowns = {},
	}, self)
end

function ItemCooldownTracker:Reset()
	self.elapsed = 0
	for itemID in pairs(self.watchedItems) do
		self.watchedItems[itemID] = nil
	end
	for itemID in pairs(self.activeCooldowns) do
		self.activeCooldowns[itemID] = nil
	end
end

function ItemCooldownTracker:SetEnabled(enabled)
	self.enabled = not not enabled
	if not self.enabled then
		self:Reset()
	end
end

function ItemCooldownTracker:RecordUse(itemID)
	if not self.enabled or not itemID then
		return false
	end
	local itemName = self.config.getItemInfo(itemID)
	local exclusions = self.config.getProfile().cooldownExclusions
	if exclusions[itemName] or exclusions[itemID] then
		return false
	end
	self.watchedItems[itemID] = self.config.getTime()
	return true
end

function ItemCooldownTracker:StartCooldown(itemID)
	local startTime, duration = self.config.getItemCooldown(itemID)
	startTime = self.config.normalizeNumber(startTime)
	duration = self.config.normalizeNumber(duration)
	if not startTime or not duration then
		return
	end

	local profile = self.config.getProfile()
	local itemName = self.config.getItemInfo(itemID)
	local ignoredThresholds = profile.ignoreCooldownThreshold
	if duration >= profile.cooldownThreshold
		or ignoredThresholds[itemName]
		or ignoredThresholds[itemID] then
		self.activeCooldowns[itemID] = duration
	end
end

function ItemCooldownTracker:DisplayCompletion(itemID)
	local itemName, _, _, _, _, _, _, _, _, texture =
		self.config.getItemInfo(itemID)
	itemName = itemName or self.config.unknown

	local settings = self.config.getProfile().events.NOTIFICATION_ITEM_COOLDOWN
	if not settings or settings.disabled then
		return
	end
	local coloredName = string.format(
		"|cFF%02x%02x%02x%s|r",
		settings.skillColorR * 255,
		settings.skillColorG * 255,
		settings.skillColorB * 255,
		string.gsub(itemName, "%(.+%)%(%)$", "")
	)
	local message = string.gsub(settings.message, "%%e", coloredName)
	self.config.display(settings, message, texture)
end

function ItemCooldownTracker:Tick(elapsed)
	if not self.enabled then
		return false
	end
	self.elapsed = self.elapsed + (elapsed or self.config.updateInterval)
	if self.elapsed < self.config.updateInterval then
		return next(self.watchedItems) ~= nil
			or next(self.activeCooldowns) ~= nil
	end
	self.elapsed = 0

	local now = self.config.getTime()
	for itemID, usedTime in pairs(self.watchedItems) do
		if now >= usedTime + self.config.watchDelay then
			self:StartCooldown(itemID)
			self.watchedItems[itemID] = nil
		end
	end

	for itemID, previousDuration in pairs(self.activeCooldowns) do
		local startTime, duration = self.config.getItemCooldown(itemID)
		startTime = self.config.normalizeNumber(startTime)
		duration = self.config.normalizeNumber(duration)
		local remaining
		if startTime and duration then
			remaining = startTime + duration - now
		else
			remaining = previousDuration
		end
		if remaining <= 0 then
			self.activeCooldowns[itemID] = nil
			self:DisplayCompletion(itemID)
		else
			self.activeCooldowns[itemID] = remaining
		end
	end

	return next(self.watchedItems) ~= nil
		or next(self.activeCooldowns) ~= nil
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.ItemCooldownTracker = ItemCooldownTracker

return ItemCooldownTracker
