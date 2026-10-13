local ParserNotifications = {}
ParserNotifications.__index = ParserNotifications

function ParserNotifications:New()
	return setmetatable({
	}, self)
end

function ParserNotifications:HandleHonor(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_HONOR_GAIN"
	end
	return nil
end

function ParserNotifications:HandleReputation(event)
	if event.recipientUnit ~= "player" then
		return nil
	end
	return "NOTIFICATION_REP_" .. (event.isLoss and "LOSS" or "GAIN"),
		event.factionName
end

function ParserNotifications:HandleProficiency(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_SKILL_GAIN", event.skillName
	end
	return nil
end

function ParserNotifications:HandleExperience(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_EXPERIENCE_GAIN"
	end
	return nil
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.ParserNotifications = ParserNotifications

return ParserNotifications
