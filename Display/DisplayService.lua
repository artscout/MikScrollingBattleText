local DisplayService = {
	config = {},
}

function DisplayService:Configure(config)
	self.config = config
end

function DisplayService:DisplayEvent(eventSettings, message, texturePath, muteSound)
	if eventSettings.disabled or self.config.isModDisabled() then return end
	local profile = self.config.getProfile()
	local scrollAreas = self.config.scrollAreas
	local areaKey = eventSettings.scrollArea or self.config.defaultArea
	local area = scrollAreas:Resolve(areaKey)
	if not area or area.disabled or scrollAreas:IsSuppressedInGroup(areaKey) then
		return
	end

	local fontSize
	local fontName
	local outlineIndex
	local fontAlpha
	local isSticky
	if eventSettings.isCrit then
		fontSize = eventSettings.fontSize or area.critFontSize
			or profile.critFontSize
		fontName = eventSettings.fontName or area.critFontName
			or profile.critFontName
		outlineIndex = eventSettings.outlineIndex or area.critOutlineIndex
			or profile.critOutlineIndex
		fontAlpha = eventSettings.fontAlpha or area.critFontAlpha
			or profile.critFontAlpha
		isSticky = not profile.stickyCritsDisabled
	else
		fontSize = eventSettings.fontSize or area.normalFontSize
			or profile.normalFontSize
		fontName = eventSettings.fontName or area.normalFontName
			or profile.normalFontName
		outlineIndex = eventSettings.outlineIndex or area.normalOutlineIndex
			or profile.normalOutlineIndex
		fontAlpha = eventSettings.fontAlpha or area.normalFontAlpha
			or profile.normalFontAlpha
	end

	isSticky = isSticky or eventSettings.alwaysSticky
	self.config.display(
		message,
		area,
		isSticky,
		eventSettings.colorR or 1,
		eventSettings.colorG or 1,
		eventSettings.colorB or 1,
		fontSize,
		self.config.fonts[fontName],
		outlineIndex,
		fontAlpha,
		texturePath
	)
	if not muteSound and not profile.soundsDisabled and eventSettings.soundFile
		and eventSettings.soundFile ~= "" and self.config.playSound then
		self.config.playSound(eventSettings.soundFile)
	end
end

local function NormalizeColor(value)
	if value == nil or value < 0 or value > 255 then
		return 255
	end

	return value
end

function DisplayService:DisplayMessage(
	message,
	scrollArea,
	isSticky,
	colorR,
	colorG,
	colorB,
	fontSize,
	fontName,
	outlineIndex,
	texturePath
)
	if not message or self.config.isModDisabled() then
		return
	end

	local scrollAreas = self.config.scrollAreas
	local area = scrollAreas:Resolve(scrollArea)
	if not area or area.disabled then
		return
	end

	local areaKey = scrollAreas.areas[scrollArea]
		and scrollArea or scrollAreas:ResolveKey(area)
	if scrollAreas:IsSuppressedInGroup(areaKey) then
		return
	end

	colorR = NormalizeColor(colorR)
	colorG = NormalizeColor(colorG)
	colorB = NormalizeColor(colorB)

	local profile = self.config.getProfile()
	if fontSize == nil or fontSize < 4 or fontSize > 38 then
		fontSize = area.normalFontSize or profile.normalFontSize
	end

	local fonts = self.config.fonts
	local fontPath = fonts[fontName]
		or fonts[area.normalFontName or profile.normalFontName]
	if not self.config.outlineMap[outlineIndex] then
		outlineIndex = area.normalOutlineIndex or profile.normalOutlineIndex
	end

	self.config.display(
		message,
		area,
		isSticky,
		colorR / 255,
		colorG / 255,
		colorB / 255,
		fontSize,
		fontPath,
		outlineIndex,
		area.normalFontAlpha or profile.normalFontAlpha,
		texturePath
	)
end

MikSBT.Display = MikSBT.Display or {}
MikSBT.Display.Service = DisplayService

return DisplayService
