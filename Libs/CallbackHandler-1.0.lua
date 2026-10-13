
local MAJOR, MINOR = "CallbackHandler-1.0", 7
local CallbackHandler = LibStub:NewLibrary(MAJOR, MINOR)

if not CallbackHandler then return end

local meta = {__index = function(tbl, key) tbl[key] = {} return tbl[key] end}

local error = error
local setmetatable, rawget = setmetatable, rawget
local next, select, pairs, type, tostring = next, select, pairs, type, tostring

local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function Dispatch(handlers, ...)
	local index, method = next(handlers)
	if not method then return end
	repeat
		xpcall(method, errorhandler, ...)
		index, method = next(handlers, index)
	until not method
end

function CallbackHandler.New(_self, target, RegisterName, UnregisterName, UnregisterAllName)

	RegisterName = RegisterName or "RegisterCallback"
	UnregisterName = UnregisterName or "UnregisterCallback"
	if UnregisterAllName==nil then
		UnregisterAllName = "UnregisterAllCallbacks"
	end

	local events = setmetatable({}, meta)
	local registry = { recurse=0, events=events }

	function registry:Fire(eventname, ...)
		if not rawget(events, eventname) or not next(events[eventname]) then return end
		local oldrecurse = registry.recurse
		registry.recurse = oldrecurse + 1

		Dispatch(events[eventname], eventname, ...)

		registry.recurse = oldrecurse

		if registry.insertQueue and oldrecurse==0 then

			for event,callbacks in pairs(registry.insertQueue) do
				local first = not rawget(events, event) or not next(events[event])
				for object,func in pairs(callbacks) do
					events[event][object] = func

					if first and registry.OnUsed then
						registry.OnUsed(registry, target, event)
						first = nil
					end
				end
			end
			registry.insertQueue = nil
		end
	end

	target[RegisterName] = function(self, eventname, method, ... )
		if type(eventname) ~= "string" then
			error("Usage: "..RegisterName.."(eventname, method[, arg]): 'eventname' - string expected.", 2)
		end

		method = method or eventname

		local first = not rawget(events, eventname) or not next(events[eventname])

		if type(method) ~= "string" and type(method) ~= "function" then
			error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): 'methodname' - string or function expected.", 2)
		end

		local regfunc

		if type(method) == "string" then

			if type(self) ~= "table" then
				error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): self was not a table?", 2)
			elseif self==target then
				error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): do not use Library:"..RegisterName.."(), use your own 'self'", 2)
			elseif type(self[method]) ~= "function" then
				error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): 'methodname' - method '"..tostring(method).."' not found on self.", 2)
			end

			if select("#",...)>=1 then
				local arg=select(1,...)
				regfunc = function(...) self[method](self,arg,...) end
			else
				regfunc = function(...) self[method](self,...) end
			end
		else

			if type(self)~="table" and type(self)~="string" and type(self)~="thread" then
				error("Usage: "..RegisterName.."(self or \"addonId\", eventname, method): 'self or addonId': table or string or thread expected.", 2)
			end

			if select("#",...)>=1 then
				local arg=select(1,...)
				regfunc = function(...) method(arg,...) end
			else
				regfunc = method
			end
		end

		if events[eventname][self] or registry.recurse<1 then

			events[eventname][self] = regfunc

			if registry.OnUsed and first then
				registry.OnUsed(registry, target, eventname)
			end
		else

			registry.insertQueue = registry.insertQueue or setmetatable({},meta)
			registry.insertQueue[eventname][self] = regfunc
		end
	end

	target[UnregisterName] = function(self, eventname)
		if not self or self==target then
			error("Usage: "..UnregisterName.."(eventname): bad 'self'", 2)
		end
		if type(eventname) ~= "string" then
			error("Usage: "..UnregisterName.."(eventname): 'eventname' - string expected.", 2)
		end
		if rawget(events, eventname) and events[eventname][self] then
			events[eventname][self] = nil

			if registry.OnUnused and not next(events[eventname]) then
				registry.OnUnused(registry, target, eventname)
			end
		end
		if registry.insertQueue and rawget(registry.insertQueue, eventname) and registry.insertQueue[eventname][self] then
			registry.insertQueue[eventname][self] = nil
		end
	end

	if UnregisterAllName then
		target[UnregisterAllName] = function(...)
			if select("#",...)<1 then
				error("Usage: "..UnregisterAllName.."([whatFor]): missing 'self' or \"addonId\" to unregister events for.", 2)
			end
			if select("#",...)==1 and ...==target then
				error("Usage: "..UnregisterAllName.."([whatFor]): supply a meaningful 'self' or \"addonId\"", 2)
			end

			for i=1,select("#",...) do
				local self = select(i,...)
				if registry.insertQueue then
					for eventname, callbacks in pairs(registry.insertQueue) do
						if callbacks[self] then
							callbacks[self] = nil
						end
					end
				end
				for eventname, callbacks in pairs(events) do
					if callbacks[self] then
						callbacks[self] = nil

						if registry.OnUnused and not next(callbacks) then
							registry.OnUnused(registry, target, eventname)
						end
					end
				end
			end
		end
	end

	return registry
end

