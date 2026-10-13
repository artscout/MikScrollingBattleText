local RestrictedValue = MikSBT.API.RestrictedValue
local Units = {}

local function IsUnitToken(unit)
	return RestrictedValue:String(unit) ~= nil
end

local function IsAccessibleAuraResult(value)
	if type(value) == "table" then
		return RestrictedValue:Table(value) ~= nil
	end

	return RestrictedValue:Value(value) ~= nil
end

function Units:HasAura(unit, aura, filter)
	if not IsUnitToken(unit) then
		return false
	end

	local auraType = type(aura)
	if auraType ~= "number" and auraType ~= "string" then
		return false
	end

	local getter
	if C_UnitAuras then
		if auraType == "number" then
			getter = C_UnitAuras.GetAuraDataBySpellID
		else
			getter = C_UnitAuras.GetAuraDataBySpellName
		end
	end

	if type(getter) == "function" then
		local success, auraData = pcall(getter, unit, aura, filter)
		return success and RestrictedValue:Table(auraData) ~= nil
	end
	if AuraUtil then
		local auraGetter = auraType == "number" and AuraUtil.FindAuraBySpellID
			or AuraUtil.FindAuraByName
		if type(auraGetter) == "function" then
			local success, auraData = pcall(auraGetter, aura, unit, filter)
			if success and IsAccessibleAuraResult(auraData) then
				return true
			end
		end
	end
	if type(UnitBuff) == "function" and filter ~= "HARMFUL" then
		local success, auraData = pcall(UnitBuff, unit, aura)
		if success and IsAccessibleAuraResult(auraData) then
			return true
		end
	end
	if type(UnitAura) == "function" then
		local success, auraData = pcall(UnitAura, unit, aura, filter or "HELPFUL")
		if success and IsAccessibleAuraResult(auraData) then
			return true
		end
	end

	return false
end

MikSBT.API.Units = Units

return Units
