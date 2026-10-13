local CombatRoutes = {}

local function IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value) == true
end

local function BelowThreshold(amount, threshold)
	if amount == nil or IsSecret(amount) or not threshold or threshold <= 0 then
		return false
	end
	return amount < threshold
end

local function GetInOutEventData(parserEvent)
	if parserEvent.recipientUnit == "player" then
		return "INCOMING", parserEvent.sourceName
	elseif parserEvent.sourceUnit == "player" then
		return "OUTGOING", parserEvent.recipientName
	elseif parserEvent.recipientUnit == "pet" then
		return "PET_INCOMING", parserEvent.sourceName
	elseif parserEvent.sourceUnit == "pet" then
		return "PET_OUTGOING", parserEvent.recipientName
	end
end

function CombatRoutes:Register(router, config)
	local autoAttackSpellID = config.autoAttackSpellID

	local function SpellPrefix(parserEvent)
		local skillID = parserEvent.skillID
		if skillID and skillID ~= autoAttackSpellID then
			return "_SPELL"
		end
		return ""
	end

	router:Register("damage", function(parserEvent, profile)
		local prefix, name = GetInOutEventData(parserEvent)
		if not prefix or BelowThreshold(parserEvent.amount, profile.damageThreshold) then
			return
		end
		local suffix = parserEvent.isDoT and "_DOT"
			or parserEvent.isDamageShield and "_DAMAGE_SHIELD"
			or "_DAMAGE"
		return prefix .. SpellPrefix(parserEvent) .. suffix, parserEvent.skillName, name
	end)

	router:Register("miss", function(parserEvent)
		local prefix, name = GetInOutEventData(parserEvent)
		if not prefix or not parserEvent.missType then
			return
		end
		return prefix .. SpellPrefix(parserEvent) .. "_" .. parserEvent.missType,
			parserEvent.skillName, name
	end)

	router:Register("heal", function(parserEvent, profile)
		local prefix, name = GetInOutEventData(parserEvent)
		if not prefix or BelowThreshold(parserEvent.amount, profile.healThreshold) then
			return
		end
		if parserEvent.isSelf then
			prefix = "SELF"
		end
		return prefix .. (parserEvent.isHoT and "_HOT" or "_HEAL"), parserEvent.skillName, name
	end)

	router:Register("interrupt", function(parserEvent)
		local prefix, name = GetInOutEventData(parserEvent)
		if not prefix then
			return
		end
		return prefix .. "_SPELL_INTERRUPT", parserEvent.extraSkillName, name
	end)

	router:Register("dispel", function(parserEvent)
		if parserEvent.sourceUnit == "player" then
			return "OUTGOING_DISPEL", parserEvent.extraSkillName, parserEvent.recipientName
		elseif parserEvent.sourceUnit == "pet" then
			return "PET_OUTGOING_DISPEL", parserEvent.extraSkillName, parserEvent.recipientName
		end
	end)

	router:Register("aura", function(parserEvent)
		if parserEvent.recipientUnit ~= "player" or not parserEvent.auraType then
			return
		end
		local eventTypeString = "NOTIFICATION_" .. parserEvent.auraType
		if parserEvent.isFade then
			eventTypeString = eventTypeString .. "_FADE"
		elseif parserEvent.isDose then
			eventTypeString = eventTypeString .. "_STACK"
		end
		return eventTypeString, parserEvent.skillName
	end)
end

MikSBT.Services = MikSBT.Services or {}
MikSBT.Services.CombatRoutes = CombatRoutes

return CombatRoutes
