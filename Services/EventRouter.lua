local EventRouter = {}
EventRouter.__index = EventRouter

function EventRouter:New()
	return setmetatable({
		routes = {},
	}, self)
end

function EventRouter:Register(eventType, handler)
	assert(eventType, "event route must have an event type")
	assert(type(handler) == "function", "event route must have a handler")
	assert(not self.routes[eventType], "event route is already registered")

	self.routes[eventType] = handler
end

function EventRouter:Resolve(parserEvent, profile)
	local handler = self.routes[parserEvent.eventType]
	if not handler then
		return
	end

	return handler(parserEvent, profile)
end

MikSBT.Services = MikSBT.Services or {}
MikSBT.Services.EventRouter = EventRouter

return EventRouter
