local UtilityNotifications = {}
UtilityNotifications.__index = UtilityNotifications

function UtilityNotifications:New(config)
	return setmetatable({
		config = config,
		lastPowerAmounts = {},
		recentEmotes = {},
	}, self)
end

function UtilityNotifications:DisplayAmount(eventKey, amount, powerType)
	local settings = self.config.getProfile().events[eventKey]
	if not settings or settings.disabled or not amount or amount <= 0 then
		return
	end
	self.config.display(
		settings,
		self.config.format(
			settings.message,
			amount,
			nil,
			nil,
			nil,
			powerType
		)
	)
end

function UtilityNotifications:DisplayResource(
	amount,
	powerType,
	changeEvent,
	fullEvent
)
	local eventKey = amount == self.config.unitPowerMax("player", powerType)
		and fullEvent
		or changeEvent
	self:DisplayAmount(eventKey, amount, powerType)
end

function UtilityNotifications:DetectPowerGain(amount, powerType)
	local profile = self.config.getProfile()
	local settings = profile.events.NOTIFICATION_POWER_GAIN
	if not settings or settings.disabled or not powerType then
		return
	end
	local previousAmount = self.lastPowerAmounts[powerType] or 65535
	if amount > previousAmount then
		self.config.display(
			settings,
			self.config.format(
				settings.message,
				amount - previousAmount,
				nil,
				nil,
				nil,
				powerType,
				nil,
				nil,
				self.config.unknown
			)
		)
	end
end

function UtilityNotifications:HandlePowerUpdate(unitID, powerToken)
	if unitID ~= "player" then
		return
	end
	local powerType = self.config.powerTypes[powerToken]
	if not powerType then
		return
	end

	local amount = self.config.unitPower("player", powerType)
	local previousAmount = self.lastPowerAmounts[powerType]
	local playerClass = self.config.getPlayerClass()
	local handled = true
	if powerToken == "CHI" and playerClass == "MONK" then
		if amount ~= previousAmount then
			self:DisplayResource(
				amount,
				powerType,
				"NOTIFICATION_CHI_CHANGE",
				"NOTIFICATION_CHI_FULL"
			)
		end
	elseif powerToken == "HOLY_POWER" and playerClass == "PALADIN" then
		if amount ~= previousAmount then
			self:DisplayResource(
				amount,
				powerType,
				"NOTIFICATION_HOLY_POWER_CHANGE",
				"NOTIFICATION_HOLY_POWER_FULL"
			)
		end
	elseif powerToken == "COMBO_POINTS"
		and (playerClass == "ROGUE" or playerClass == "DRUID") then
		if amount ~= previousAmount then
			self:DisplayResource(
				amount,
				powerType,
				"NOTIFICATION_CP_GAIN",
				"NOTIFICATION_CP_FULL"
			)
		end
	elseif powerToken == "ARCANE_CHARGES" and playerClass == "MAGE" then
		if amount ~= previousAmount then
			self:DisplayResource(
				amount,
				powerType,
				"NOTIFICATION_AC_CHANGE",
				"NOTIFICATION_AC_FULL"
			)
		end
	elseif powerToken == "ESSENCE" and playerClass == "EVOKER" then
		if amount ~= previousAmount then
			self:DisplayResource(
				amount,
				powerType,
				"NOTIFICATION_ESSENCE_CHANGE",
				"NOTIFICATION_ESSENCE_FULL"
			)
		end
	else
		handled = false
	end

	if not handled and self.config.getProfile().showAllPowerGains then
		self:DetectPowerGain(amount, powerType)
	end
	self.lastPowerAmounts[powerType] = amount
end

function UtilityNotifications:DisplayStatic(eventKey)
	local settings = self.config.getProfile().events[eventKey]
	if settings and not settings.disabled then
		self.config.display(settings, settings.message)
	end
end

function UtilityNotifications:HandleCombatEnter()
	self:DisplayStatic("NOTIFICATION_COMBAT_ENTER")
end

function UtilityNotifications:HandleCombatLeave()
	self:DisplayStatic("NOTIFICATION_COMBAT_LEAVE")
end

function UtilityNotifications:HandleMonsterEmote(message, sourceName)
	local targetName = self.config.unitName("target")
	local compareSucceeded, isTarget = pcall(function()
		return sourceName == targetName
	end)
	if not compareSucceeded or not isTarget then
		return
	end

	local formatSucceeded, emote = pcall(
		string.gsub,
		message,
		"%%s",
		sourceName
	)
	if not formatSucceeded then
		return
	end
	local settings = self.config.getProfile().events.NOTIFICATION_MONSTER_EMOTE
	if not settings or settings.disabled then
		return
	end

	local now = self.config.getTime()
	for recentEmote, expires in pairs(self.recentEmotes) do
		if now >= expires then
			self.recentEmotes[recentEmote] = nil
		end
	end
	if self.recentEmotes[emote] then
		return
	end

	self.config.display(
		settings,
		self.config.format(
			settings.message,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			emote
		)
	)
	self.recentEmotes[emote] = now + self.config.emoteHoldTime
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.UtilityNotifications = UtilityNotifications

return UtilityNotifications
