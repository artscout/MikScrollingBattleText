local ScrollAreas = {
	config = {},
	areas = {},
	names = {},
}

local GROUP_SETTING_BY_AREA = {
	Outgoing = "disableOutgoingInGroup",
	Incoming = "disableIncomingInGroup",
	Notification = "disableNotificationInGroup",
	Static = "disableStaticInGroup",
}

local function Clear(values)
	for key in pairs(values) do
		values[key] = nil
	end
end

function ScrollAreas:Configure(config)
	self.config = config
end

function ScrollAreas:Update()
	Clear(self.areas)
	Clear(self.names)

	local profile = self.config.getProfile()
	local profileAreas = profile and rawget(profile, "scrollAreas")
	if profileAreas then
		for key, settings in pairs(profileAreas) do
			self.areas[key] = settings
			self.names[key] = settings.name
		end
	end

	local masterProfile = self.config.getMasterProfile()
	for key, settings in pairs(masterProfile.scrollAreas) do
		if not self.areas[key] then
			self.areas[key] = settings
			self.names[key] = settings.name
		end
	end
end

function ScrollAreas:Resolve(identifier)
	local settings = self.areas[identifier]
	if settings then
		return settings
	end

	for key, areaName in pairs(self.names) do
		if identifier == areaName then
			return self.areas[key]
		end
	end

	return self.areas[self.config.defaultArea]
end

function ScrollAreas:ResolveKey(settings)
	for key, areaSettings in pairs(self.areas) do
		if areaSettings == settings then
			return key
		end
	end

	return self.config.defaultArea
end

function ScrollAreas:IsActive(identifier)
	local settings = self:Resolve(identifier)
	return settings ~= nil and not settings.disabled
end

function ScrollAreas:IsIconShown(identifier)
	local settings = self:Resolve(identifier)
	return settings ~= nil and not settings.skillIconsDisabled
end

function ScrollAreas:IsSuppressedInGroup(areaKey)
	if not self.config.isInGroup() and not self.config.isInRaid() then
		return false
	end

	local profile = self.config.getProfile()
	local setting = GROUP_SETTING_BY_AREA[areaKey]
	return setting ~= nil and profile ~= nil and not not profile[setting]
end

function ScrollAreas:Iterate()
	return pairs(self.names)
end

MikSBT.Display = MikSBT.Display or {}
MikSBT.Display.ScrollAreas = ScrollAreas

return ScrollAreas
