local DamageMeterSource = {}
DamageMeterSource.__index = DamageMeterSource

local METER_EVENTS = {
	"DAMAGE_METER_CURRENT_SESSION_UPDATED",
	"DAMAGE_METER_COMBAT_SESSION_UPDATED",
	"DAMAGE_METER_RESET",
}

local function MeterLog(self, ...)
	if not MikSBT.meterLog then
		return
	end
	local parts = { string.format("%.2f", GetTime()), InCombatLockdown() and "[combat]" or "[idle]",
		tostring(self.config.label or "?") }
	for index = 1, select("#", ...) do
		parts[#parts + 1] = tostring((select(index, ...)))
	end
	print("|cff88ccffMSBT meter|r " .. table.concat(parts, " "))
end

function DamageMeterSource:New(config)
	return setmetatable({
		config = config,
		lastTotals = {},
		lastPollTime = 0,
		lastDeltaTime = 0,
		isBlind = false,
		failureCount = 0,
		assumeZero = false,
		wantsRunning = false,
		ticker = nil,
		frame = nil,
	}, self)
end

function DamageMeterSource:IsAvailable()
	local ok, isAvailable = pcall(self.config.isAvailable)
	return ok and isAvailable == true
end

function DamageMeterSource:IsActive()
	return not self.isBlind and self:IsAvailable()
end

function DamageMeterSource:IsDeltaFresh(now)
	if self.lastDeltaTime <= 0 then
		return false
	end
	return now - self.lastDeltaTime <= self.config.freshDuration
end

function DamageMeterSource:ClearTotals()
	for key in pairs(self.lastTotals) do
		self.lastTotals[key] = nil
	end
	self.lastPollTime = 0
	self.lastDeltaTime = 0
	self.primedSources = nil
end

function DamageMeterSource:Reset(isSessionBoundary)
	self:ClearTotals()
	self.sessionID = nil

	-- At a combat boundary the current session starts from zero, so the first
	-- total seen afterwards is a real hit rather than a running sum.
	self.assumeZero = isSessionBoundary == true

	if self.assumeZero and self.isBlind and self.wantsRunning then
		self.isBlind = false
		self:Start()
	end
end

function DamageMeterSource:SetBlind()
	if self.isBlind then
		return
	end

	-- Session data is flagged SecretWhenInCombat, so inside restricted content
	-- the amounts come back as secret values. They cannot be compared, summed
	-- or formatted, which makes the meter useless as a source there.
	self.isBlind = true
	self:ClearTotals()
	self:Stop()
end

function DamageMeterSource:CollectSourceGUIDs(target)
	for index = #target, 1, -1 do
		target[index] = nil
	end

	local playerGUID = self.config.unitGUID("player")
		or self.config.getPlayerGUID()
	if not playerGUID then
		return target
	end

	target[1] = playerGUID

	for _, unitID in ipairs(self.config.extraUnits) do
		local guid = self.config.unitGUID(unitID)
		if guid then
			local isKnown = false
			for index = 1, #target do
				local ok, isSame = pcall(function()
					return target[index] == guid
				end)
				if ok and isSame then
					isKnown = true
					break
				end
			end
			if not isKnown then
				target[#target + 1] = guid
			end
		end
	end

	return target
end

function DamageMeterSource:ProcessSpell(sourceKey, damageSpell)
	local spellID = self.config.normalizeNumber(damageSpell.spellID)
	local totalAmount = damageSpell.totalAmount
	if not spellID or totalAmount == nil then
		return
	end

	if self.config.isSecret(totalAmount) then
		MeterLog(self, "secret amount -> blind")
		self:SetBlind()
		return
	end

	local normalizedTotal = self.config.normalizeNumber(totalAmount)
	if not normalizedTotal or normalizedTotal <= 0 then
		return
	end

	local key = sourceKey .. ":" .. tostring(spellID)
	local previousAmount = self.lastTotals[key]
	self.lastTotals[key] = normalizedTotal
	if previousAmount ~= normalizedTotal then
		MeterLog(self, "spell", spellID, "src", sourceKey, "session", self.sessionID or "current",
			"prev", previousAmount, "total", normalizedTotal)
	end

	if not previousAmount then
		if not self.assumeZero
			and not (self.primedSources and self.primedSources[sourceKey]) then
			-- First sighting without a known baseline: the running total would
			-- be shown as one huge hit, so only record it.
			return
		end
		previousAmount = 0
	end

	local delta = normalizedTotal - previousAmount
	if delta <= 0 then
		return
	end

	if self.config.isSuppressed and self.config.isSuppressed() then
		return
	end

	local isCrit = false
	if self.config.consumeCrit then
		isCrit = self.config.consumeCrit(delta) == true
	end

	self.config.queue(spellID, delta, isCrit, sourceKey, damageSpell)
	self.lastDeltaTime = self.config.getTime()
end

function DamageMeterSource:ProcessSource(sourceKey, sourceGUID)
	local ok, source
	if self.sessionID and self.config.getSessionSourceByID then
		ok, source = pcall(
			self.config.getSessionSourceByID,
			self.sessionID,
			self.config.damageType(),
			sourceGUID
		)
	else
		ok, source = pcall(
			self.config.getSessionSource,
			self.config.sessionType(),
			self.config.damageType(),
			sourceGUID
		)
	end
	if not ok or not source then
		return
	end

	local combatSpells = source.combatSpells
	if type(combatSpells) ~= "table" then
		if self.config.isSecret(combatSpells) then
			MeterLog(self, "secret spell table -> blind")
			self:SetBlind()
		end
		return
	end

	for _, damageSpell in ipairs(combatSpells) do
		if type(damageSpell) == "table" then
			self:ProcessSpell(sourceKey, damageSpell)
		end
	end

	if self.config.primeBaseline then
		self.primedSources = self.primedSources or {}
		self.primedSources[sourceKey] = true
	end
end

function DamageMeterSource:SafeProcessSource(sourceKey, sourceGUID)
	-- Anything read out of the session can be a secret value, and touching one
	-- raises rather than returning a flag. Treat a run of failures the same as
	-- a secret amount and step aside for the UNIT_COMBAT fallback.
	if pcall(self.ProcessSource, self, sourceKey, sourceGUID) then
		self.failureCount = 0
		return
	end

	self.failureCount = (self.failureCount or 0) + 1
	if self.failureCount >= 3 then
		self:SetBlind()
	end
end

function DamageMeterSource:Poll()
	if not self:IsActive() then
		return
	end

	self.lastPollTime = self.config.getTime()

	local sourceGUIDs = self:CollectSourceGUIDs(self.sourceGUIDs or {})
	self.sourceGUIDs = sourceGUIDs

	for index = 1, #sourceGUIDs do
		self:SafeProcessSource(tostring(index), sourceGUIDs[index])
	end
end

function DamageMeterSource:TrackSession(meterType, sessionID)
	if meterType == nil or sessionID == nil
		or self.config.isSecret(meterType) or self.config.isSecret(sessionID) then
		return
	end
	if meterType ~= self.config.damageType() or sessionID == 0 then
		return
	end
	if self.sessionID == sessionID then
		return
	end

	-- The in-progress combat session is only reachable by its ID: the
	-- "Current" session type keeps returning the previous one until combat
	-- ends. A new ID means a fresh session whose totals start at zero.
	MeterLog(self, "session", self.sessionID, "->", sessionID)
	self:ClearTotals()
	self.sessionID = sessionID
	self.assumeZero = true
end

function DamageMeterSource:OnEvent(event, meterType, sessionID)
	if event == "DAMAGE_METER_RESET" then
		MeterLog(self, "event", event)
		self:Reset(true)
		return
	end

	if event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
		self:TrackSession(meterType, sessionID)
	end

	self:Poll()
end

function DamageMeterSource:Start()
	self.wantsRunning = true

	if not self:IsActive() then
		return
	end

	if not self.frame then
		local frame = self.config.createFrame()
		frame:SetScript("OnEvent", function(_, event, meterType, sessionID)
			self:OnEvent(event, meterType, sessionID)
		end)
		self.frame = frame
	end

	for _, event in ipairs(METER_EVENTS) do
		pcall(self.frame.RegisterEvent, self.frame, event)
	end

	if not self.ticker then
		self.ticker = self.config.newTicker(
			self.config.pollInterval,
			function()
				self:Poll()
			end
		)
	end
end

function DamageMeterSource:Stop(isShutdown)
	if isShutdown then
		self.wantsRunning = false
	end

	if self.frame then
		pcall(self.frame.UnregisterAllEvents, self.frame)
	end

	if self.ticker then
		self.ticker:Cancel()
		self.ticker = nil
	end
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.DamageMeterSource = DamageMeterSource

return DamageMeterSource
