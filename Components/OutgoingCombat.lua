local OutgoingCombat = {}
OutgoingCombat.__index = OutgoingCombat

function OutgoingCombat:New(config)
	return setmetatable({
		config = config,
		lastSpellID = nil,
		lastSpellTime = 0,
		dotSpellID = nil,
		dotAuraIDs = nil,
		dotRequiresAura = true,
		dotExpires = 0,
		lastAutoAttackTime = 0,
	}, self)
end

function OutgoingCombat:GetLastSpell()
	return self.lastSpellID, self.lastSpellTime
end

function OutgoingCombat:Reset()
	self:ResetCombatState()
	self.config.batcher:Reset()
end

function OutgoingCombat:ResetCombatState()
	self.dotSpellID = nil
	self.dotAuraIDs = nil
	self.dotRequiresAura = true
	self.dotExpires = 0
	self.lastAutoAttackTime = 0
	if self.config.damageMeter then
		self.config.damageMeter:Reset()
	end
end

function OutgoingCombat:Start()
	if self.config.damageMeter then
		self.config.damageMeter:Start()
	end
end

function OutgoingCombat:Stop()
	if self.config.damageMeter then
		self.config.damageMeter:Stop()
	end
end

function OutgoingCombat:HandleSpellcastSucceeded(unitID, spellID)
	if unitID ~= "player" or not spellID then
		return false
	end

	self.lastSpellID = spellID
	self.lastSpellTime = self.config.getTime()
	local timedDuration = self.config.timedDotSpells[spellID]
	if timedDuration then
		self.dotSpellID = spellID
		self.dotAuraIDs = nil
		self.dotRequiresAura = false
		self.dotExpires = self.lastSpellTime + timedDuration
		return true
	end

	local auraIDs = self.config.dotSpells[spellID]
	if auraIDs then
		self.dotSpellID = spellID
		self.dotAuraIDs = auraIDs
		self.dotRequiresAura = true
		self.dotExpires = self.lastSpellTime + self.config.dotDuration
	end
	return true
end

function OutgoingCombat:IsDotFallbackActive(now)
	if not self.dotSpellID or now > self.dotExpires then
		return false
	end
	if not self.dotRequiresAura then
		return true
	end
	return self.config.hasPlayerDebuff(self.dotAuraIDs)
end

function OutgoingCombat:HasRecentSignal(now, schoolMask)
	if self.lastSpellID
		and now - self.lastSpellTime <= self.config.signalWindow then
		return true
	end
	if self:IsDotFallbackActive(now) then
		return true
	end
	if not self.config.isLikelySpellSchool(schoolMask) then
		return self.config.canUseAutoAttackFallback(
			now,
			self.lastAutoAttackTime
		)
	end
	return false
end

function OutgoingCombat:ResolveAttribution(now, isDamage)
	local spellID
	local texture
	if self.lastSpellID
		and now - self.lastSpellTime
			<= self.config.fallbackAttributionWindow then
		spellID = self.lastSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	if not texture and isDamage and self.lastSpellID
		and not self.config.isAutoAttack(self.lastSpellID)
		and now - self.lastSpellTime
			<= self.config.delayedAttributionWindow then
		spellID = self.lastSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	if not texture and isDamage and self:IsDotFallbackActive(now) then
		spellID = self.dotSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	if not texture then
		if not isDamage then
			return nil
		end
		if not self.config.canUseAutoAttackFallback(
			now,
			self.lastAutoAttackTime
		) then
			return nil
		end
		spellID = self.config.autoAttackSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	return spellID, texture
end

function OutgoingCombat:QueueDamage(
	spellID,
	amount,
	isCrit,
	texture,
	schoolMask
)
	local forceIsSpell = spellID == self.config.autoAttackSpellID
		and self.config.isLikelySpellSchool(schoolMask)
		or nil
	if spellID == self.config.autoAttackSpellID then
		self.lastAutoAttackTime = self.config.getTime()
	end
	self.config.batcher:Queue(
		spellID,
		amount,
		isCrit,
		texture,
		forceIsSpell
	)
end

function OutgoingCombat:HandleUnitCombat(
	unitTarget,
	action,
	flagText,
	amount,
	schoolMask
)
	if unitTarget ~= "target" then
		return false
	end
	if not self.config.inCombat() or not self.config.isTargetValid() then
		return true
	end

	local isDamage = action == "WOUND"
	local normalizedAmount = self.config.normalizeNumber(amount)
	local now = self.config.getTime()
	if isDamage and not self:HasRecentSignal(now, schoolMask) then
		return true
	end

	local spellID, texture = self:ResolveAttribution(now, isDamage)
	if not spellID then
		return true
	end
	if isDamage then
		if not normalizedAmount or normalizedAmount <= 0 then
			return true
		end
		if self.config.damageMeter and self.config.damageMeter:IsActive()
			and self.config.damageMeter:IsDeltaFresh(now)
			and spellID ~= self.dotSpellID then
			return true
		end
		self:QueueDamage(
			spellID,
			normalizedAmount,
			flagText == "CRITICAL",
			texture,
			schoolMask
		)
		return true
	end

	local profile = self.config.getProfile()
	local settings = profile.events["OUTGOING_" .. tostring(action or "")]
	if settings and not settings.disabled then
		local message = self.config.buildActionMessage(settings, normalizedAmount)
		if message and message ~= "" then
			self.config.display(settings, message, texture)
		end
	end
	return true
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.OutgoingCombat = OutgoingCombat

return OutgoingCombat
