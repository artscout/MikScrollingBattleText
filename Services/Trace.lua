local Trace = {
	counts = {},
	errors = {},
	notes = {},
	lastTime = {},
}

function Trace:Inc(key)
	self.counts[key] = (self.counts[key] or 0) + 1
	self.lastTime[key] = GetTime()
end

function Trace:Error(where, err)
	self:Inc("error:" .. where)
	local text = tostring(err)
	if issecretvalue and issecretvalue(err) then
		text = "<secret>"
	end
	self.errors[where] = { text = text, time = GetTime() }
end

function Trace:Note(key, text)
	self:Inc(key)
	self.notes[key] = { text = tostring(text), time = GetTime() }
end

function Trace:Reset()
	self.counts = {}
	self.errors = {}
	self.notes = {}
	self.lastTime = {}
end

MikSBT.Trace = Trace

return Trace
