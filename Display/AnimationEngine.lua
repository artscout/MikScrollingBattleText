
local module = {}
local moduleName = "Animations"
MikSBT[moduleName] = module

local MSBTMedia = MikSBT.Media
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations
local ScrollAreas = MikSBT.Display.ScrollAreas
local DisplayService = MikSBT.Display.Service

local table_remove = table.remove
local string_find = string.find

local IsModDisabled = MSBTProfiles.IsModDisabled

local fonts = MSBTMedia.fonts

local MAX_ANIMATIONS_PER_AREA = 15
local DEFAULT_SCROLL_TIME = 3
local DEFAULT_FADE_PERCENT = 0.8

local ANIMATION_DELAY = 0.015

local TEXT_ALIGN_MAP = {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROME,OUTLINE", "MONOCHROME,THICKOUTLINE"}

local DEFAULT_FONT_SIZE = 18
local DEFAULT_FONT_PATH = L.FONT_FILES[L.DEFAULT_FONT_NAME]
local DEFAULT_TEXT_ALIGN = TEXT_ALIGN_MAP[2]
local DEFAULT_OUTLINE = OUTLINE_MAP[1]
local DEFAULT_SCROLL_AREA = "Notification"
local DEFAULT_SCROLL_HEIGHT = 260
local DEFAULT_SCROLL_WIDTH = 40
local DEFAULT_ANIMATION_STYLE = "Straight"
local DEFAULT_STICKY_ANIMATION_STYLE = "Pow"

local DEFAULT_SOUND_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\"

local TEMP_TEXTURE_PATH = "Interface\\Icons\\Temp"

local _

local animationFrame

local displayEventCache = {}
local textureCache = {}

local animationData = {normal = {}, sticky = {}}

local animationStyles = {}
local stickyAnimationStyles = {}
local scrollAreas = ScrollAreas.areas

local fontLoaderFrame
local loadedFontStrings = {}

ScrollAreas:Configure({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	getMasterProfile = function()
		return MSBTProfiles.masterProfile
	end,
	isInGroup = IsInGroup,
	isInRaid = IsInRaid,
	defaultArea = DEFAULT_SCROLL_AREA,
})

local function RegisterAnimationStyle(styleID, initHandler, availableDirections, availableBehaviors, localizationTable)

	if not animationStyles[styleID] and initHandler then

		local animStyleSettings = {}
		animStyleSettings.initHandler = initHandler
		animStyleSettings.availableDirections = availableDirections
		animStyleSettings.availableBehaviors = availableBehaviors
		animStyleSettings.localizationTable = localizationTable

		animationStyles[styleID] = animStyleSettings
	end
end

local function RegisterStickyAnimationStyle(styleID, initHandler, availableDirections, availableBehaviors, localizationTable)

	if not stickyAnimationStyles[styleID] and initHandler then

		local animStyleSettings = {}
		animStyleSettings.initHandler = initHandler
		animStyleSettings.availableDirections = availableDirections
		animStyleSettings.availableBehaviors = availableBehaviors
		animStyleSettings.localizationTable = localizationTable

		stickyAnimationStyles[styleID] = animStyleSettings
	end
end

local function LoadFont(fontName)
	local fontPath = MikSBT.Media.fonts[fontName]
	if fontPath == nil then
		return
	end

	local fontString = loadedFontStrings[fontName]
	if fontString ~= nil then
		return
	end

	fontLoaderFrame:Show()
	fontString = fontLoaderFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontString:SetPoint("BOTTOM")

	fontString:SetText("Font Loader")
	fontString:SetFont(fontPath, DEFAULT_FONT_SIZE, DEFAULT_FONT_OUTLINE)
	fontString:SetText("")
	fontString:SetAlpha(0)
	loadedFontStrings[fontName] = fontString
	fontLoaderFrame:Hide()
end

local function Display(message, saSettings, isSticky, colorR, colorG, colorB, fontSize, fontPath, outlineIndex, fontAlpha, texturePath)

	local animStyleSettings, direction, behavior, textAlignIndex
	if isSticky then
		animStyleSettings = stickyAnimationStyles[saSettings.stickyAnimationStyle] or stickyAnimationStyles[DEFAULT_STICKY_ANIMATION_STYLE]
		direction = saSettings.stickyDirection
		behavior = saSettings.stickyBehavior
		textAlignIndex = saSettings.stickyTextAlignIndex
	else
		animStyleSettings = animationStyles[saSettings.animationStyle] or animationStyles[DEFAULT_ANIMATION_STYLE]
		direction = saSettings.direction
		behavior = saSettings.behavior
		textAlignIndex = saSettings.textAlignIndex
	end

	if not animStyleSettings then
		return
	end

	if not animationData.normal[saSettings] then
		animationData.normal[saSettings] = {}
	end
	if isSticky and not animationData.sticky[saSettings] then
		animationData.sticky[saSettings] = {}
	end

	local animationArray = isSticky and animationData.sticky[saSettings] or animationData.normal[saSettings]

	local displayEvent
	if #animationArray >= MAX_ANIMATIONS_PER_AREA then
		displayEvent = table_remove(animationArray, 1)
		displayEvent.fontString:SetAlpha(0)
		if displayEvent.texture then
			displayEvent.texture:SetAlpha(0)
		end
	else
		displayEvent = table_remove(displayEventCache) or { fontString = animationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal") }
	end

	local currentProfile = MSBTProfiles.currentProfile

	displayEvent.offsetX = saSettings.offsetX or 0
	displayEvent.offsetY = saSettings.offsetY or 0
	displayEvent.anchorPoint = TEXT_ALIGN_MAP[textAlignIndex] or DEFAULT_TEXT_ALIGN
	displayEvent.scrollHeight = saSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT
	displayEvent.scrollWidth = saSettings.scrollWidth or DEFAULT_SCROLL_WIDTH
	displayEvent.animationSpeed = (saSettings.animationSpeed or currentProfile.animationSpeed) / 100
	displayEvent.masterAlpha = fontAlpha / 100

	displayEvent.alpha = 1
	displayEvent.positionX = 0
	displayEvent.positionY = 0
	displayEvent.fontSize = fontSize

	local fontString = displayEvent.fontString
	local fontOutline = OUTLINE_MAP[outlineIndex] or DEFAULT_OUTLINE
	if not fontPath then
		fontPath = DEFAULT_FONT_PATH
	end
	fontString:ClearAllPoints()
	if fontPath == DEFAULT_FONT_PATH then
		fontString:SetFont(DEFAULT_FONT_PATH, fontSize, fontOutline)
	end
	fontString:SetFont(fontPath, fontSize, fontOutline)
	fontString:SetTextColor(colorR, colorG, colorB)
	fontString:SetDrawLayer(isSticky and "OVERLAY" or "ARTWORK")
	fontString:SetShadowColor(0, 0, 0, 1)
	fontString:SetShadowOffset(1, -1)
	fontString:SetAlpha(0)
	fontString:SetText(message)

	if texturePath and texturePath ~= TEMP_TEXTURE_PATH and not saSettings.skillIconsDisabled and not currentProfile.skillIconsDisabled then

		local texture = displayEvent.texture

		if not texture then
			texture = table_remove(textureCache) or animationFrame:CreateTexture(nil, "ARTWORK")
		end

		texture:ClearAllPoints()
		texture:SetTexture(texturePath)
		texture:SetWidth(fontSize)
		texture:SetHeight(fontSize)
		texture:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		if saSettings.iconAlign == "Right" then
			texture:SetPoint("LEFT", fontString, "RIGHT", 4, 0)
		else
			texture:SetPoint("RIGHT", fontString, "LEFT", -4, 0)
		end
		texture:SetDrawLayer(isSticky and "OVERLAY" or "ARTWORK")
		texture:SetAlpha(0)
		displayEvent.texture = texture
	end

	displayEvent.elapsedTime = 0
	displayEvent.timeSinceLastUpdate = 0
	displayEvent.scrollTime = DEFAULT_SCROLL_TIME
	displayEvent.fadePercent = DEFAULT_FADE_PERCENT

	animStyleSettings.initHandler(displayEvent, animationArray, direction, behavior)
	fontString:SetPoint(displayEvent.anchorPoint, displayEvent.offsetX + displayEvent.positionX, displayEvent.offsetY + displayEvent.positionY)
	displayEvent.scrollTime = displayEvent.scrollTime / displayEvent.animationSpeed

	animationArray[#animationArray + 1] = displayEvent

	if not animationFrame:IsVisible() then
		animationFrame:Show()
	end
end

DisplayService:Configure({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	scrollAreas = ScrollAreas,
	fonts = fonts,
	isModDisabled = IsModDisabled,
	display = Display,
	playSound = MikSBT.Media.PlaySound,
	outlineMap = OUTLINE_MAP,
	defaultArea = DEFAULT_SCROLL_AREA,
})
local function AnimateEvent(displayEvent)
	local fontString = displayEvent.fontString
	local texture = displayEvent.texture
	local percentDone = displayEvent.elapsedTime / displayEvent.scrollTime

	if percentDone <= 1 then

		displayEvent.animationHandler(displayEvent, percentDone)

		local fadePercent = displayEvent.fadePercent
		if percentDone >= fadePercent then
			displayEvent.alpha = (1 - percentDone) / (1 - fadePercent)
		end

		fontString:SetPoint(displayEvent.anchorPoint, displayEvent.offsetX + displayEvent.positionX, displayEvent.offsetY + displayEvent.positionY)
		fontString:SetAlpha(displayEvent.masterAlpha * displayEvent.alpha)
		if texture then
			texture:SetAlpha(displayEvent.masterAlpha * displayEvent.alpha)
		end
	else

		fontString:SetAlpha(0)
		if texture then
			texture:SetAlpha(0)
		end
		displayEvent.animationComplete = true
	end
end

local function OnUpdateAnimationFrame(this, elapsed)

	local allInactive = true

	local numEvents, displayEvent, texture

	for _, animationArray in pairs(animationData) do

		for areaSettings, displayEvents in pairs(animationArray) do
			numEvents = #displayEvents

			for i = 1, numEvents do
				displayEvent = displayEvents[i]
				displayEvent.timeSinceLastUpdate = displayEvent.timeSinceLastUpdate + elapsed

				if displayEvent.timeSinceLastUpdate >= ANIMATION_DELAY then
					displayEvent.elapsedTime = displayEvent.elapsedTime + displayEvent.timeSinceLastUpdate
					AnimateEvent(displayEvent)
					displayEvent.timeSinceLastUpdate = 0
				end

				allInactive = false
			end

			for i = numEvents, 1, -1 do
				displayEvent = displayEvents[i]
				if displayEvent.animationComplete then
					table_remove(displayEvents, i)

					texture = displayEvent.texture
					if texture then
						textureCache[#textureCache + 1] = texture
						texture:SetTexture(nil)
						displayEvent.texture = nil
					end

					displayEventCache[#displayEventCache + 1] = displayEvent
					displayEvent.animationComplete = false
				end
			end
			if #displayEvents == 0 then
				animationArray[areaSettings] = nil
			end
		end
	end

	if allInactive then
		this:Hide()
	end
end

animationFrame = CreateFrame("Frame", "MSBTAnimationFrame", UIParent)
animationFrame:SetFrameStrata("HIGH")
animationFrame:SetPoint("BOTTOM", UIParent, "CENTER")
animationFrame:SetWidth(0.0001)
animationFrame:SetHeight(0.0001)
animationFrame:Hide()
animationFrame:SetScript("OnUpdate", OnUpdateAnimationFrame)

fontLoaderFrame = CreateFrame("Frame", nil, UIParent)
fontLoaderFrame:SetPoint("BOTTOM")
fontLoaderFrame:SetWidth(0.0001)
fontLoaderFrame:SetHeight(0.0001)
fontLoaderFrame:Hide()

module.scrollAreas					= scrollAreas
module.animationStyles				= animationStyles
module.stickyAnimationStyles		= stickyAnimationStyles

module.IsScrollAreaActive			= function(scrollArea)
	return ScrollAreas:IsActive(scrollArea)
end
module.IsScrollAreaIconShown		= function(scrollArea)
	return ScrollAreas:IsIconShown(scrollArea)
end
module.UpdateScrollAreas			= function()
	ScrollAreas:Update()
end
module.RegisterAnimationStyle		= RegisterAnimationStyle
module.RegisterStickyAnimationStyle = RegisterStickyAnimationStyle
module.IterateScrollAreas			= function()
	return ScrollAreas:Iterate()
end
module.LoadFont						= LoadFont
module.DisplayMessage				= function(...)
	return DisplayService:DisplayMessage(...)
end
module.DisplayEvent					= function(...)
	return DisplayService:DisplayEvent(...)
end

