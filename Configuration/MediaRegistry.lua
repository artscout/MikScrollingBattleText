local MediaRegistry = {}
MediaRegistry.__index = MediaRegistry

local ALL_LANGUAGES = 255

function MediaRegistry:New(options)
	local registry = setmetatable({}, self)

	registry.sharedMedia = options.sharedMedia
	registry.defaultFonts = options.defaultFonts or {}
	registry.defaultSounds = options.defaultSounds or {}
	registry.fonts = {}
	registry.sounds = {}

	return registry
end

function MediaRegistry:RegisterFont(name, path)
	if type(name) ~= "string" or name == "" then
		return false
	end
	if type(path) ~= "string" or path == "" then
		return false
	end

	self.fonts[name] = path
	self.sharedMedia:Register("font", name, path, ALL_LANGUAGES)

	return true
end

function MediaRegistry:ImportSharedMedia(mediaType, name)
	if mediaType == "font" then
		self.fonts[name] = self.sharedMedia:Fetch(mediaType, name)
	elseif mediaType == "sound" and name ~= "None" then
		local file = self.sharedMedia:Fetch(mediaType, name)
		file = MikSBT.API.Sounds:NormalizeFile(file)
		if file then self.sounds[name] = file end
	end
end

function MediaRegistry:RegisterSound(name, file)
	local access = MikSBT.API.RestrictedValue
	if not access:CanAccess(name) or type(name) ~= "string" then
		return false
	end
	if name:match("^%s*$") or name == "None" or self.sounds[name] then
		return false
	end
	file = MikSBT.API.Sounds:NormalizeFile(file)
	if not file then return false end
	if not self.sharedMedia:Register("sound", name, file) then return false end
	self.sounds[name] = file
	return true
end

function MediaRegistry:PlaySound(reference)
	if not MikSBT.API.RestrictedValue:CanAccess(reference) then return false end
	local file = reference
	if type(reference) == "string" then
		file = self.sounds[reference] or reference
	end
	return MikSBT.API.Sounds:Play(file)
end

function MediaRegistry:LoadSavedMedia(savedMedia)
	for name, path in pairs(savedMedia and savedMedia.fonts or {}) do
		self:RegisterFont(name, path)
	end
	local sounds = savedMedia and savedMedia.sounds
	if type(sounds) == "table" then
		for name, file in pairs(sounds) do self:RegisterSound(name, file) end
	end
end

function MediaRegistry:Initialize()
	for name, path in pairs(self.defaultFonts) do
		self:RegisterFont(name, path)
	end
	for name, path in pairs(self.defaultSounds) do
		self:RegisterSound(name, path)
	end
	for _, name in pairs(self.sharedMedia:List("font")) do
		self:ImportSharedMedia("font", name)
	end
	for _, name in pairs(self.sharedMedia:List("sound")) do
		self:ImportSharedMedia("sound", name)
	end

	self.sharedMedia.RegisterCallback(
		self,
		"LibSharedMedia_Registered",
		function(event, mediaType, name)
			self:ImportSharedMedia(mediaType, name)
		end
	)
end

function MediaRegistry:IterateFonts()
	return pairs(self.fonts)
end

function MediaRegistry:IterateSounds()
	return pairs(self.sounds)
end

MikSBT.Configuration.MediaRegistry = MediaRegistry

return MediaRegistry
