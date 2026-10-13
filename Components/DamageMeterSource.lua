local DamageMeterSource = {}
DamageMeterSource.__index = DamageMeterSource

function DamageMeterSource:New(config)
	return setmetatable({
		config = config,
		lastTotals = {},
		lastPollTime = 0,
		lastDeltaTime = 0,
		ticker = nil,
	}, self)
end

function DamageMeterSource:IsActive()
	return self.config.isAvailable()
end

function DamageMeterSource:IsDeltaFresh(now)
	if self.lastDeltaTime <= 0 then
		return false
	end
	return now - self.lastDeltaTime <= self.config.freshDuration
end

function DamageMeterSource:Reset()
	for key in pairs(self.lastTotals) do
		self.lastTotals[key] = nil
	end
	self.lastPollTime = 0
	self.lastDeltaTime = 0
end

local function WasGUIDProcessed(processedGUIDs, sourceGUID)
	for index = 1, #processedGUIDs do
		local success, isSame = pcall(function()
			return processedGUIDs[index] == sourceGUID
		end)
		if success and isSame then
			return true
		end
	end
	return false
end

function DamageMeterSource:ProcessSpell(sourceIndex, damageSpell)
	pcall(function()
		local spellID = self.config.normalizeNumber(damageSpell.spellID)
		local totalAmount = damageSpell.totalAmount
		if not spellID or totalAmount == nil then
			return
		end

		local key = tostring(sourceIndex) .. ":" .. tostring(spellID)
		local previousAmount = self.lastTotals[key] or 0
		local normalizedTotal = tonumber(totalAmount)
		if not normalizedTotal or normalizedTotal <= 0 then
			return
		end

		local delta = normalizedTotal - previousAmount
		if delta < 0 then
			delta = normalizedTotal
		end
		if delta > 0 then
			self.config.queue(spellID, delta, false)
			self.lastDeltaTime = self.lastPollTime
		end
		self.lastTotals[key] = normalizedTotal
	end)
end

function DamageMeterSource:Poll()
	if not self:IsActive() or not self.config.inCombat() then
		return
	end

	self.lastPollTime = self.config.getTime()
	local playerGUID = self.config.unitGUID("player")
		or self.config.getPlayerGUID()
	if not playerGUID then
		return
	end

	local sourceGUIDs = {
		playerGUID,
		self.config.unitGUID("pet"),
		self.config.unitGUID("vehicle"),
	}
	local processedGUIDs = {}
	for sourceIndex = 1, 3 do
		local sourceGUID = sourceGUIDs[sourceIndex]
		if sourceGUID and not WasGUIDProcessed(processedGUIDs, sourceGUID) then
			processedGUIDs[#processedGUIDs + 1] = sourceGUID
			local success, source = pcall(
				self.config.getSessionSource,
				sourceGUID,
				self.config.damageType
			)
			if success and source then
				pcall(function()
					local combatSpells = source.combatSpells
					if type(combatSpells) ~= "table" then
						return
					end
					for _, damageSpell in ipairs(combatSpells) do
						self:ProcessSpell(sourceIndex, damageSpell)
					end
				end)
			end
		end
	end
end

function DamageMeterSource:Start()
	if self.ticker or not self:IsActive() then
		return
	end
	self.ticker = self.config.newTicker(
		self.config.pollInterval,
		function()
			self:Poll()
		end
	)
end

function DamageMeterSource:Stop()
	if not self.ticker then
		return
	end
	self.ticker:Cancel()
	self.ticker = nil
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.DamageMeterSource = DamageMeterSource

return DamageMeterSource
