local CombatTextSource = {}
CombatTextSource.__index = CombatTextSource

local AURA_EVENTS = {
	SPELL_AURA_START = { auraType = "BUFF" },
	SPELL_AURA_START_HARMFUL = { auraType = "DEBUFF" },
	SPELL_AURA_END = { auraType = "BUFF", isFade = true },
	SPELL_AURA_END_HARMFUL = { auraType = "DEBUFF", isFade = true },
}

local function IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value) == true
end

function CombatTextSource:New(config)
	local source = setmetatable({
		config = config,
		frame = CreateFrame("Frame"),
	}, self)
	source.frame:SetScript("OnEvent", function(_, _, combatTextType)
		source:HandleEvent(combatTextType)
	end)
	return source
end

function CombatTextSource:IsAvailable()
	return C_CombatText ~= nil and C_CombatText.GetCurrentEventInfo ~= nil
end

function CombatTextSource:Start()
	if self:IsAvailable() then
		pcall(self.frame.RegisterEvent, self.frame, "COMBAT_TEXT_UPDATE")
	end
end

function CombatTextSource:Stop()
	self.frame:UnregisterAllEvents()
end

function CombatTextSource:HandleEvent(combatTextType)
	if combatTextType == nil or IsSecret(combatTextType) then
		return
	end
	local aura = AURA_EVENTS[combatTextType]
	if not aura then
		return
	end
	local ok, auraName = pcall(C_CombatText.GetCurrentEventInfo)
	if not ok or auraName == nil then
		return
	end
	self.config.emit({
		eventType = "aura",
		recipientUnit = "player",
		auraType = aura.auraType,
		isFade = aura.isFade,
		skillName = auraName,
	})
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.CombatTextSource = CombatTextSource

return CombatTextSource
