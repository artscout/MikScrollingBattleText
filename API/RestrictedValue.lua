local RestrictedValue = {}

local function CallPredicate(predicate, value)
	local success, result = pcall(predicate, value)
	if not success then
		return nil
	end

	return result == true
end

function RestrictedValue:CanAccess(value)
	if type(canaccessvalue) == "function" then
		return CallPredicate(canaccessvalue, value) == true
	end

	if type(issecretvalue) == "function" then
		return CallPredicate(issecretvalue, value) == false
	end

	return true
end

function RestrictedValue:CanAccessTable(value)
	if type(value) ~= "table" or not self:CanAccess(value) then
		return false
	end

	if type(canaccesstable) == "function" then
		return CallPredicate(canaccesstable, value) == true
	end

	if type(issecrettable) == "function" then
		return CallPredicate(issecrettable, value) == false
	end

	return true
end

function RestrictedValue:Value(value)
	if self:CanAccess(value) then
		return value
	end
end

function RestrictedValue:Number(value)
	if self:CanAccess(value) and type(value) == "number" then
		return value
	end
end

function RestrictedValue:String(value)
	if self:CanAccess(value) and type(value) == "string" then
		return value
	end
end

function RestrictedValue:Boolean(value)
	if self:CanAccess(value) and type(value) == "boolean" then
		return value
	end
end

function RestrictedValue:Table(value)
	if self:CanAccessTable(value) then
		return value
	end
end

MikSBT.API = MikSBT.API or {}
MikSBT.API.RestrictedValue = RestrictedValue

return RestrictedValue
