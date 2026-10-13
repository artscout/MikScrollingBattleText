local IncomingCombat = {}
IncomingCombat.__index = IncomingCombat

local damageSourceMap = {
	FALLING = "falling",
	DROWNING = "drowning",
	FIRE = "fire",
	LAVA = "lava",
	SLIME = "slime",
	EXHAUSTION = "fatigue",
}

local ignoredDamageFlags = {
	CRITICAL = true,
	CRUSHING = true,
	GLANCING = true,
	BLOCK = true,
	ABSORB = true,
	RESIST = true,
}

function IncomingCombat:New(config)
	return setmetatable({
		config = config,
		damageBatches = {},
		healBatches = {},
	}, self)
end

local function ClearTable(target)
	for key in pairs(target) do
		target[key] = nil
	end
end

function IncomingCombat:Reset()
	ClearTable(self.damageBatches)
	ClearTable(self.healBatches)
end

local function StripRealm(name, unknown)
	if not name then
		return unknown
	end
	if string.find(name, "-", 1, true) then
		return string.gsub(name, "(.-)%-.*", "%1")
	end
	return name
end

local function BuildHitSummary(hitCount, critCount)
	if not hitCount or hitCount <= 0 then
		return nil
	end
	if critCount and critCount > 0 then
		if hitCount == 1 and critCount == 1 then
			return " (Crit)"
		end
		local hitsWord = hitCount == 1 and "hit" or "hits"
		local critWord = critCount == 1 and "Crit" or "Crits"
		return string.format(
			" (%d %s, %d %s)",
			hitCount,
			hitsWord,
			critCount,
			critWord
		)
	end
	if hitCount > 1 then
		return string.format(" (%d hits)", hitCount)
	end
	return nil
end

local function BuildDamageLine(self, settings, batch, amount, hits, crits)
	local message = self.config.buildActionMessage(settings, amount)
	if not message or message == "" then
		return nil
	end

	local summary = BuildHitSummary(hits, crits)
	if summary then
		message = message .. summary
	end
	if batch.damageSource and batch.damageSource ~= "" then
		message = string.format("%s - %s", message, batch.damageSource)
	end
	return message
end

local function BuildHealLine(self, settings, batch, amount, hits, crits)
	local message = self.config.buildActionMessage(settings, amount)
	if not message or message == "" then
		return nil
	end

	local summary = BuildHitSummary(hits, crits)
	if summary then
		message = message .. summary
	end
	if batch.healSourceLabel and batch.healSourceLabel ~= "" then
		message = string.format("%s [%s]", message, batch.healSourceLabel)
	end
	return message
end

local function GetDamageSource(flagText, schoolMask)
	if flagText and damageSourceMap[flagText] then
		return damageSourceMap[flagText]
	end
	if flagText and not ignoredDamageFlags[flagText] then
		return string.lower(flagText)
	end
	if type(schoolMask) == "string" and schoolMask ~= "" then
		return string.lower(schoolMask)
	end
	return nil
end

local function GetHealSourceLabel(flagText, schoolMask)
	local flag = flagText and string.upper(tostring(flagText)) or ""
	local school = schoolMask and string.upper(tostring(schoolMask)) or ""
	if string.find(flag, "LEECH", 1, true)
		or string.find(school, "LEECH", 1, true) then
		return "Leech"
	end
	return nil
end

local function DisplayDamageBatch(self, batchKey)
	local batch = self.damageBatches[batchKey]
	if not batch then
		return
	end
	self.damageBatches[batchKey] = nil

	local profile = self.config.getProfile()
	local settings = profile.events.INCOMING_DAMAGE
	if not settings or settings.disabled then
		return
	end
	local critSettings = profile.events.INCOMING_DAMAGE_CRIT
	local critCount = batch.critCount or 0
	local critAmount = math.min(batch.critAmount or 0, batch.totalAmount)

	if self.config.shouldSplitCritBatch(settings, critSettings, critCount) then
		local normalCount = batch.hitCount - critCount
		local normalAmount = batch.totalAmount - critAmount
		if normalCount > 0 and normalAmount > 0 then
			local message = BuildDamageLine(
				self,
				settings,
				batch,
				normalAmount,
				normalCount,
				0
			)
			if message then
				self.config.display(settings, message)
			end
		end

		local message = BuildDamageLine(
			self,
			critSettings,
			batch,
			critAmount,
			critCount,
			critCount
		)
		if message then
			self.config.display(critSettings, message)
		end
		return
	end

	local message = BuildDamageLine(
		self,
		settings,
		batch,
		batch.totalAmount,
		batch.hitCount,
		critCount
	)
	if message then
		local displaySettings = self.config.resolveBatchDisplaySettings(
			settings,
			critSettings,
			batch.hitCount,
			critCount
		)
		self.config.display(displaySettings, message)
	end
end

function IncomingCombat:QueueDamage(amount, isCrit, damageSource)
	local batchKey = "incoming_damage"
	local batch = self.damageBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			critCount = 0,
			critAmount = 0,
			totalAmount = 0,
			damageSource = damageSource,
		}
		self.damageBatches[batchKey] = batch
		self.config.after(self.config.groupDelay, function()
			if self.damageBatches[batchKey] == batch then
				DisplayDamageBatch(self, batchKey)
			end
		end)
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + amount
	if isCrit then
		batch.critCount = batch.critCount + 1
		batch.critAmount = batch.critAmount + amount
	end
	if damageSource and damageSource ~= "" then
		if batch.damageSource and batch.damageSource ~= damageSource then
			batch.damageSource = "mixed"
		elseif not batch.damageSource then
			batch.damageSource = damageSource
		end
	end
end

local function DisplayHealBatch(self, batchKey)
	local batch = self.healBatches[batchKey]
	if not batch then
		return
	end
	self.healBatches[batchKey] = nil

	local profile = self.config.getProfile()
	local settings = profile.events[batch.baseEventKey]
	local critSettings = profile.events[batch.critEventKey]
	local normalEnabled = settings and not settings.disabled
	local critEnabled = critSettings and not critSettings.disabled
	if not normalEnabled and not critEnabled then
		return
	end

	local critCount = batch.critCount or 0
	local critAmount = math.min(batch.critAmount or 0, batch.totalAmount)
	if not normalEnabled then
		if critEnabled and critCount > 0 and critAmount > 0 then
			local message = BuildHealLine(
				self,
				critSettings,
				batch,
				critAmount,
				critCount,
				critCount
			)
			if message then
				self.config.display(critSettings, message, batch.effectTexture)
			end
		end
		return
	end

	if self.config.shouldSplitCritBatch(settings, critSettings, critCount) then
		local normalCount = batch.hitCount - critCount
		local normalAmount = batch.totalAmount - critAmount
		if normalCount > 0 and normalAmount > 0 then
			local message = BuildHealLine(
				self,
				settings,
				batch,
				normalAmount,
				normalCount,
				0
			)
			if message then
				self.config.display(settings, message, batch.effectTexture)
			end
		end

		local message = BuildHealLine(
			self,
			critSettings,
			batch,
			critAmount,
			critCount,
			critCount
		)
		if message then
			self.config.display(critSettings, message, batch.effectTexture)
		end
		return
	end

	local message = BuildHealLine(
		self,
		settings,
		batch,
		batch.totalAmount,
		batch.hitCount,
		critCount
	)
	if message then
		local displaySettings = self.config.resolveBatchDisplaySettings(
			settings,
			critSettings,
			batch.hitCount,
			critCount
		)
		self.config.display(displaySettings, message, batch.effectTexture)
	end
end

function IncomingCombat:QueueHeal(
	amount,
	isCrit,
	effectTexture,
	sourceName,
	healSourceLabel,
	baseEventKey,
	critEventKey
)
	baseEventKey = baseEventKey or "INCOMING_HEAL"
	critEventKey = critEventKey or baseEventKey .. "_CRIT"
	local batchKey = "incoming_heal:" .. baseEventKey
	local batch = self.healBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			critCount = 0,
			critAmount = 0,
			totalAmount = 0,
			effectTexture = effectTexture,
			sourceName = sourceName,
			healSourceLabel = healSourceLabel,
			baseEventKey = baseEventKey,
			critEventKey = critEventKey,
		}
		self.healBatches[batchKey] = batch
		self.config.after(self.config.groupDelay, function()
			if self.healBatches[batchKey] == batch then
				DisplayHealBatch(self, batchKey)
			end
		end)
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + amount
	if isCrit then
		batch.critCount = batch.critCount + 1
		batch.critAmount = batch.critAmount + amount
	end
	if effectTexture and not batch.effectTexture then
		batch.effectTexture = effectTexture
	end
	if healSourceLabel and healSourceLabel ~= "" then
		batch.healSourceLabel = healSourceLabel
	end
end

local function GetLikelyHealSource(self)
	local config = self.config
	if config.unitCastingInfo("player") or config.unitChannelInfo("player") then
		return config.unitName("player") or config.unknown
	end
	if not config.safeUnitBoolean(UnitExists, "target") then
		return config.unitName("player") or config.unknown
	end
	if config.safeUnitBoolean(UnitCanAssist, "player", "target")
		and config.safeUnitBoolean(UnitExists, "targettarget")
		and config.safeUnitBoolean(UnitIsUnit, "targettarget", "player") then
		return config.unitName("target") or config.unknown
	end
	if config.safeUnitBoolean(UnitExists, "focus")
		and config.safeUnitBoolean(UnitCanAssist, "player", "focus")
		and config.safeUnitBoolean(UnitExists, "focustarget")
		and config.safeUnitBoolean(UnitIsUnit, "focustarget", "player") then
		return config.unitName("focus") or config.unknown
	end
	return config.unknown
end

function IncomingCombat:HandleUnitCombat(
	unitTarget,
	action,
	flagText,
	amount,
	schoolMask
)
	if unitTarget ~= "player" then
		return false
	end

	local normalizedAmount = self.config.normalizeNumber(amount)
	local isCrit = flagText == "CRITICAL"
	local profile = self.config.getProfile()
	if action == "WOUND" then
		if not normalizedAmount or normalizedAmount <= 0 then
			return true
		end
		local settings = profile.events.INCOMING_DAMAGE
		if not settings or settings.disabled then
			return true
		end
		self:QueueDamage(
			normalizedAmount,
			isCrit,
			GetDamageSource(flagText, schoolMask)
		)
		return true
	end

	if action == "HEAL" then
		if not normalizedAmount or normalizedAmount <= 0 then
			return true
		end
		local now = self.config.getTime()
		local sourceName = StripRealm(
			GetLikelyHealSource(self),
			self.config.unknown
		)
		local playerName = StripRealm(
			self.config.unitName("player"),
			self.config.unknown
		)
		local isSelfHeal = sourceName == playerName
		local baseKey = isSelfHeal and "SELF_HEAL" or "INCOMING_HEAL"
		local critKey = isSelfHeal and "SELF_HEAL_CRIT" or "INCOMING_HEAL_CRIT"
		local settings = profile.events[baseKey]
		local critSettings = profile.events[critKey]
		local normalEnabled = settings and not settings.disabled
		local critEnabled = critSettings and not critSettings.disabled
		if not normalEnabled and not (isCrit and critEnabled) then
			return true
		end

		local attributionWindow = isSelfHeal
			and self.config.selfHealIconWindow
			or 1.5
		local spellID, spellTime = self.config.getLastPlayerSpell()
		local texture
		if spellID and not self.config.isAutoAttackSpellID(spellID)
			and now - spellTime <= attributionWindow then
			_, _, texture = self.config.getSpellInfo(spellID)
		end
		self:QueueHeal(
			normalizedAmount,
			isCrit,
			texture,
			sourceName,
			GetHealSourceLabel(flagText, schoolMask),
			baseKey,
			critKey
		)
		return true
	end

	local settings = profile.events["INCOMING_" .. tostring(action or "")]
	if settings and not settings.disabled then
		local message = self.config.buildActionMessage(settings, normalizedAmount)
		if message and message ~= "" then
			self.config.display(settings, message)
		end
	end
	return true
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.IncomingCombat = IncomingCombat

return IncomingCombat
