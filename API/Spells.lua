local RestrictedValue = MikSBT.API.RestrictedValue
local Spells = {}

local function IsSpellIdentifier(value)
	return RestrictedValue:Number(value) ~= nil
		or RestrictedValue:String(value) ~= nil
end

local function BuildInfo(
	name,
	iconID,
	castTime,
	minRange,
	maxRange,
	spellID,
	originalIconID
)
	name = RestrictedValue:String(name)
	if not name then
		return nil
	end

	return {
		name = name,
		iconID = RestrictedValue:Number(iconID),
		castTime = RestrictedValue:Number(castTime),
		minRange = RestrictedValue:Number(minRange),
		maxRange = RestrictedValue:Number(maxRange),
		spellID = RestrictedValue:Number(spellID),
		originalIconID = RestrictedValue:Number(originalIconID),
	}
end

function Spells:GetInfo(identifier)
	if not IsSpellIdentifier(identifier) then
		return nil
	end

	if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
		local success, rawInfo = pcall(C_Spell.GetSpellInfo, identifier)
		local info = success and RestrictedValue:Table(rawInfo) or nil
		if not info then
			return nil
		end

		return BuildInfo(
			info.name,
			info.iconID,
			info.castTime,
			info.minRange,
			info.maxRange,
			info.spellID,
			info.originalIconID
		)
	end

	if type(GetSpellInfo) ~= "function" then
		return nil
	end

	local success, name, _, iconID, castTime, minRange, maxRange, spellID,
		originalIconID = pcall(GetSpellInfo, identifier)
	if not success then
		return nil
	end

	return BuildInfo(name, iconID, castTime, minRange, maxRange, spellID,
		originalIconID)
end

function Spells:GetLegacyInfo(identifier)
	local info = self:GetInfo(identifier)
	if not info then
		return nil
	end

	return info.name, nil, info.iconID, info.castTime, info.minRange,
		info.maxRange, info.spellID, info.originalIconID
end

function Spells:GetTexture(identifier)
	if not IsSpellIdentifier(identifier) then
		return nil
	end

	if C_Spell and type(C_Spell.GetSpellTexture) == "function" then
		local success, texture = pcall(C_Spell.GetSpellTexture, identifier)
		if success then
			return RestrictedValue:Number(texture)
		end
	end
	if type(GetSpellTexture) == "function" then
		local success, texture = pcall(GetSpellTexture, identifier)
		if success then
			return RestrictedValue:Number(texture)
		end
	end

	local info = self:GetInfo(identifier)
	return info and info.iconID or nil
end

MikSBT.API.Spells = Spells

return Spells
