
local math_floor = math.floor
local math_ceil = math.ceil
local math_random = math.random
local math_max = math.max
local math_abs = math.abs
local math_sqrt = math.sqrt

local POW_FADE_IN_TIME = 0.17
local POW_DISPLAY_TIME = 1.5
local POW_FADE_OUT_TIME = 0.5
local POW_TEXT_DELTA = 0.7
local JIGGLE_DELAY_TIME = 0.05

local STATIC_DISPLAY_TIME = 3.15

local ANGLED_HORIZONTAL_PHASE_TIME = 1
local ANGLED_FADE_OUT_TIME = 0.5
local ANGLED_WIDTH_PERCENT = 0.85

local MOVEMENT_SPEED = (3 / 260)

local MIN_VERTICAL_SPACING = 8
local MIN_HORIZONTAL_SPACING = 10

local _

local lastAngledFinishPositionY = {}
local lastAngledDirection = {}
local lastHorizontalPositionY = {}
local lastHorizontalDirection = {}

local function AnimatePowNormal(displayEvent, animationProgress)
	local fadeInPercent = POW_FADE_IN_TIME / displayEvent.scrollTime

	if animationProgress <= fadeInPercent then
		displayEvent.fontString:SetTextHeight(displayEvent.fontSize * (1 + ((1 - animationProgress / fadeInPercent) * POW_TEXT_DELTA)))

	else
		local fontPath, _, fontOutline = displayEvent.fontString:GetFont()
		displayEvent.fontString:SetFont(fontPath, displayEvent.fontSize, fontOutline)
	end
end

local function AnimatePowJiggle(displayEvent, animationProgress)
	local fadeInPercent = POW_FADE_IN_TIME / displayEvent.scrollTime

	if animationProgress <= fadeInPercent then
		displayEvent.fontString:SetTextHeight(displayEvent.fontSize * (1 + ((1 - animationProgress / fadeInPercent) * POW_TEXT_DELTA)))
		return

	elseif animationProgress <= displayEvent.fadePercent then
		local elapsedTime = displayEvent.elapsedTime
		if elapsedTime - displayEvent.timeLastJiggled > JIGGLE_DELAY_TIME then
			displayEvent.positionX = displayEvent.originalPositionX + math_random(-1, 1)
			displayEvent.positionY = displayEvent.originalPositionY + math_random(-1, 1)
			displayEvent.timeLastJiggled = elapsedTime
		end

		local fontPath, _, fontOutline = displayEvent.fontString:GetFont()
		displayEvent.fontString:SetFont(fontPath, displayEvent.fontSize, fontOutline)
	end
end

local function InitPow(newDisplayEvent, activeDisplayEvents, direction, behavior)

	local animationSpeed = newDisplayEvent.animationSpeed
	local scrollTime = POW_FADE_IN_TIME + (POW_DISPLAY_TIME / animationSpeed) + POW_FADE_OUT_TIME
	newDisplayEvent.scrollTime = scrollTime * animationSpeed
	newDisplayEvent.fadePercent = (POW_FADE_IN_TIME + (POW_DISPLAY_TIME / animationSpeed)) / scrollTime

	newDisplayEvent.animationHandler = (behavior == "Jiggle") and AnimatePowJiggle or AnimatePowNormal

	local anchorPoint = newDisplayEvent.anchorPoint
	if anchorPoint == "BOTTOMLEFT" then
		newDisplayEvent.positionX = 0
	elseif anchorPoint == "BOTTOM" then
		newDisplayEvent.positionX = newDisplayEvent.scrollWidth / 2
	elseif anchorPoint == "BOTTOMRIGHT" then
		newDisplayEvent.positionX = newDisplayEvent.scrollWidth
	end
	newDisplayEvent.positionY = newDisplayEvent.scrollHeight / 2

	newDisplayEvent.originalPositionX = newDisplayEvent.positionX
	newDisplayEvent.originalPositionY = newDisplayEvent.positionY
	newDisplayEvent.timeLastJiggled = 0

	local numActiveAnimations = #activeDisplayEvents

	if (numActiveAnimations == 0) then return end

	if direction == "Down" then

		local middleSticky = math_floor((numActiveAnimations + 2) / 2)

		activeDisplayEvents[middleSticky].originalPositionY = newDisplayEvent.scrollHeight / 2
		activeDisplayEvents[middleSticky].positionY = activeDisplayEvents[middleSticky].originalPositionY

		for x = middleSticky - 1, 1, -1 do
			activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x + 1].originalPositionY - activeDisplayEvents[x].fontSize - MIN_VERTICAL_SPACING
			activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
		end

		for x = middleSticky + 1, numActiveAnimations do
			activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x - 1].originalPositionY + activeDisplayEvents[x - 1].fontSize + MIN_VERTICAL_SPACING
			activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
		end

		newDisplayEvent.originalPositionY = activeDisplayEvents[numActiveAnimations].originalPositionY + activeDisplayEvents[numActiveAnimations].fontSize + MIN_VERTICAL_SPACING
		newDisplayEvent.positionY = newDisplayEvent.originalPositionY

	else

		local middleSticky = math_ceil(numActiveAnimations / 2)

		activeDisplayEvents[middleSticky].originalPositionY = newDisplayEvent.scrollHeight / 2
		activeDisplayEvents[middleSticky].positionY = activeDisplayEvents[middleSticky].originalPositionY

		for x = middleSticky - 1, 1, -1 do
			activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x + 1].originalPositionY + activeDisplayEvents[x + 1].fontSize + MIN_VERTICAL_SPACING
			activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
		end

		for x = middleSticky + 1, numActiveAnimations do
			activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x - 1].originalPositionY - activeDisplayEvents[x].fontSize - MIN_VERTICAL_SPACING
			activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
		end

		newDisplayEvent.originalPositionY = activeDisplayEvents[numActiveAnimations].originalPositionY - activeDisplayEvents[numActiveAnimations].fontSize - MIN_VERTICAL_SPACING
		newDisplayEvent.positionY = newDisplayEvent.originalPositionY
	end
end

local function ScrollLeftAngledUp(displayEvent, animationProgress)
	local linePhasePercent = displayEvent.linePhasePercent
	local horizontalPhasePercent = displayEvent.horizontalPhasePercent

	if animationProgress <= linePhasePercent then

		local phaseProgress = animationProgress / linePhasePercent
		displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress)
		displayEvent.positionY = displayEvent.finishPositionY * phaseProgress

	elseif animationProgress <= horizontalPhasePercent then
		displayEvent.positionX = displayEvent.scrollWidth - displayEvent.finishPositionX
		displayEvent.positionY = displayEvent.finishPositionY

	else

		local phaseProgress = (animationProgress - horizontalPhasePercent) / (1 - horizontalPhasePercent)
		displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress))
	end
end

local function ScrollLeftAngledDown(displayEvent, animationProgress)
	local linePhasePercent = displayEvent.linePhasePercent
	local horizontalPhasePercent = displayEvent.horizontalPhasePercent

	if animationProgress <= linePhasePercent then

		local phaseProgress = animationProgress / linePhasePercent
		displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress)
		displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY * phaseProgress

	elseif animationProgress <= horizontalPhasePercent then
		displayEvent.positionX = displayEvent.scrollWidth - displayEvent.finishPositionX
		displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY

	else

		local phaseProgress = (animationProgress - horizontalPhasePercent) / (1 - horizontalPhasePercent)
		displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress))
	end
end

local function ScrollRightAngledUp(displayEvent, animationProgress)
	local linePhasePercent = displayEvent.linePhasePercent
	local horizontalPhasePercent = displayEvent.horizontalPhasePercent

	if animationProgress <= linePhasePercent then

		local phaseProgress = animationProgress / linePhasePercent
		displayEvent.positionX = displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress
		displayEvent.positionY = displayEvent.finishPositionY * phaseProgress

	elseif animationProgress <= horizontalPhasePercent then
		displayEvent.positionX = displayEvent.finishPositionX
		displayEvent.positionY = displayEvent.finishPositionY

	else

		local phaseProgress = (animationProgress - horizontalPhasePercent) / (1 - horizontalPhasePercent)
		displayEvent.positionX = displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress)
	end
end

local function ScrollRightAngledDown(displayEvent, animationProgress)
	local linePhasePercent = displayEvent.linePhasePercent
	local horizontalPhasePercent = displayEvent.horizontalPhasePercent

	if animationProgress <= linePhasePercent then

		local phaseProgress = animationProgress / linePhasePercent
		displayEvent.positionX = displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress
		displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY * phaseProgress

	elseif animationProgress <= horizontalPhasePercent then
		displayEvent.positionX = displayEvent.finishPositionX
		displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY

	else

		local phaseProgress = (animationProgress - horizontalPhasePercent) / (1 - horizontalPhasePercent)
		displayEvent.positionX = displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress)
	end
end

local function InitAngled(newDisplayEvent, activeDisplayEvents, direction, behavior)

	local startPositionX = 0
	local anchorPoint = newDisplayEvent.anchorPoint
	if direction ~= "Left" and direction ~= "Right" then

		direction = (lastAngledDirection[activeDisplayEvents] == "Left") and "Right" or "Left"
		lastAngledDirection[activeDisplayEvents] = direction
		anchorPoint = (direction == "Left") and "BOTTOMRIGHT" or "BOTTOMLEFT"
		newDisplayEvent.anchorPoint = anchorPoint

		startPositionX = newDisplayEvent.scrollWidth / 2
	end

	if direction == "Right" then
		newDisplayEvent.animationHandler = (behavior == "AngleDown") and ScrollRightAngledDown or ScrollRightAngledUp
	else
		newDisplayEvent.animationHandler = (behavior == "AngleDown") and ScrollLeftAngledDown or ScrollLeftAngledUp
	end

	local finishPositionY
	finishPositionY = lastAngledFinishPositionY[activeDisplayEvents] or newDisplayEvent.scrollHeight
	finishPositionY = finishPositionY - newDisplayEvent.fontSize - MIN_VERTICAL_SPACING
	if finishPositionY < 0 then
		finishPositionY = newDisplayEvent.scrollHeight
	end

	local animationSpeed = newDisplayEvent.animationSpeed
	local finishPositionX = newDisplayEvent.scrollWidth * ANGLED_WIDTH_PERCENT
	local linePhaseTime = math_sqrt((finishPositionX - startPositionX) * (finishPositionX - startPositionX) + finishPositionY * finishPositionY) * MOVEMENT_SPEED
	local scrollTime = ((linePhaseTime + ANGLED_HORIZONTAL_PHASE_TIME) / animationSpeed) + ANGLED_FADE_OUT_TIME
	newDisplayEvent.scrollTime = scrollTime * animationSpeed
	newDisplayEvent.linePhasePercent = linePhaseTime / animationSpeed / scrollTime
	newDisplayEvent.horizontalPhasePercent = ((linePhaseTime + ANGLED_HORIZONTAL_PHASE_TIME) / animationSpeed) / scrollTime
	newDisplayEvent.fadePercent = 1 - (ANGLED_FADE_OUT_TIME / scrollTime)

	newDisplayEvent.positionX = startPositionX
	newDisplayEvent.positionY = 0
	newDisplayEvent.startPositionX = startPositionX
	newDisplayEvent.finishPositionX = newDisplayEvent.scrollWidth * ANGLED_WIDTH_PERCENT
	newDisplayEvent.finishPositionY = finishPositionY

	lastAngledFinishPositionY[activeDisplayEvents] = finishPositionY
end

local function ScrollUp(displayEvent, animationProgress)

	displayEvent.positionY = displayEvent.scrollHeight * animationProgress
end

local function ScrollDown(displayEvent, animationProgress)

	displayEvent.positionY = displayEvent.scrollHeight - displayEvent.scrollHeight * animationProgress
end

local function InitStraight(newDisplayEvent, activeDisplayEvents, direction, behavior)

	newDisplayEvent.scrollTime = newDisplayEvent.scrollHeight * MOVEMENT_SPEED

	local anchorPoint = newDisplayEvent.anchorPoint
	if anchorPoint == "BOTTOMLEFT" then
		newDisplayEvent.positionX = 0
	elseif anchorPoint == "BOTTOM" then
		newDisplayEvent.positionX = newDisplayEvent.scrollWidth / 2
	elseif anchorPoint == "BOTTOMRIGHT" then
		newDisplayEvent.positionX = newDisplayEvent.scrollWidth
	end

	local numActiveAnimations = #activeDisplayEvents

	if direction == "Down" then

		newDisplayEvent.animationHandler = ScrollDown

		if numActiveAnimations == 0 then
			return
		end

		local perPixelTime = MOVEMENT_SPEED / newDisplayEvent.animationSpeed
		local currentDisplayEvent = newDisplayEvent
		local prevDisplayEvent, topTimeCurrent

		for x = numActiveAnimations, 1, -1 do
			prevDisplayEvent = activeDisplayEvents[x]

			topTimeCurrent = currentDisplayEvent.elapsedTime + (currentDisplayEvent.fontSize + MIN_VERTICAL_SPACING) * perPixelTime

			if prevDisplayEvent.elapsedTime < topTimeCurrent then
				prevDisplayEvent.elapsedTime = topTimeCurrent
			else

				break
			end

			currentDisplayEvent = prevDisplayEvent
		end

	else

		newDisplayEvent.animationHandler = ScrollUp

		if numActiveAnimations == 0 then
			return
		end

		local perPixelTime = MOVEMENT_SPEED / newDisplayEvent.animationSpeed
		local currentDisplayEvent = newDisplayEvent
		local prevDisplayEvent, topTimePrev

		for x = numActiveAnimations, 1, -1 do
			prevDisplayEvent = activeDisplayEvents[x]

			topTimePrev = prevDisplayEvent.elapsedTime - (prevDisplayEvent.fontSize + MIN_VERTICAL_SPACING) * perPixelTime

			if topTimePrev < currentDisplayEvent.elapsedTime then
				prevDisplayEvent.elapsedTime = currentDisplayEvent.elapsedTime + (prevDisplayEvent.fontSize + MIN_VERTICAL_SPACING) * perPixelTime
			else

				return
			end

			currentDisplayEvent = prevDisplayEvent
		end
	end
end

local function ScrollLeftParabolaUp(displayEvent, animationProgress)

	ScrollUp(displayEvent, animationProgress)

	local y = displayEvent.positionY - displayEvent.midPoint
	displayEvent.positionX = (y * y) / displayEvent.fourA
end

local function ScrollLeftParabolaDown(displayEvent, animationProgress)

	ScrollDown(displayEvent, animationProgress)

	local y = displayEvent.positionY - displayEvent.midPoint
	displayEvent.positionX = (y * y) / displayEvent.fourA
end

local function ScrollRightParabolaUp(displayEvent, animationProgress)

	ScrollUp(displayEvent, animationProgress)

	local y = displayEvent.positionY - displayEvent.midPoint
	displayEvent.positionX = displayEvent.scrollWidth - ((y * y) / displayEvent.fourA)
end

local function ScrollRightParabolaDown(displayEvent, animationProgress)

	ScrollDown(displayEvent, animationProgress)

	local y = displayEvent.positionY - displayEvent.midPoint
	displayEvent.positionX = displayEvent.scrollWidth - ((y * y) / displayEvent.fourA)
end

local function InitParabola(newDisplayEvent, activeDisplayEvents, direction, behavior)

	InitStraight(newDisplayEvent, activeDisplayEvents, direction, behavior)

	if direction == "Down" then
		newDisplayEvent.animationHandler = (behavior == "CurvedRight") and ScrollRightParabolaDown or ScrollLeftParabolaDown
	else
		newDisplayEvent.animationHandler = (behavior == "CurvedRight") and ScrollRightParabolaUp or ScrollLeftParabolaUp
	end

	local midPoint = newDisplayEvent.scrollHeight / 2
	newDisplayEvent.midPoint = midPoint

	newDisplayEvent.fourA = (midPoint * midPoint) / newDisplayEvent.scrollWidth
end

local function ScrollLeft(displayEvent, animationProgress)

	displayEvent.positionX = displayEvent.scrollWidth - displayEvent.scrollWidth * animationProgress
end

local function ScrollRight(displayEvent, animationProgress)

	displayEvent.positionX = displayEvent.scrollWidth * animationProgress
end

local function RepositionHorizontalRight(currentDisplayEvent, activeDisplayEvents, startEvent)

	local perPixelTime = MOVEMENT_SPEED / currentDisplayEvent.animationSpeed

	local topCurrent = currentDisplayEvent.positionY + currentDisplayEvent.fontSize
	local bottomCurrent = currentDisplayEvent.positionY

	local prevDisplayEvent, topPrev, bottomPrev
	local leftTimePrev, rightTimeCurrent
	for x = startEvent, 1, -1 do

		prevDisplayEvent = activeDisplayEvents[x]
		topPrev = prevDisplayEvent.positionY + prevDisplayEvent.fontSize
		bottomPrev = prevDisplayEvent.positionY

		if (topCurrent >= bottomPrev and topCurrent <= topPrev) or (bottomCurrent >= bottomPrev and bottomCurrent <= topPrev) then

			leftTimePrev = prevDisplayEvent.elapsedTime + (prevDisplayEvent.offsetLeft or 0) * perPixelTime
			rightTimeCurrent = currentDisplayEvent.elapsedTime + ((currentDisplayEvent.offsetRight or 0) + MIN_HORIZONTAL_SPACING) * perPixelTime

			if leftTimePrev <= rightTimeCurrent then
				prevDisplayEvent.elapsedTime = rightTimeCurrent + math_abs((prevDisplayEvent.offsetLeft or 0) * perPixelTime)

				RepositionHorizontalRight(prevDisplayEvent, activeDisplayEvents, x - 1)
			end
		end
	end
end

local function RepositionHorizontalLeft(currentDisplayEvent, activeDisplayEvents, startEvent)

	local perPixelTime = MOVEMENT_SPEED / currentDisplayEvent.animationSpeed

	local topCurrent = currentDisplayEvent.positionY + currentDisplayEvent.fontSize
	local bottomCurrent = currentDisplayEvent.positionY

	local prevDisplayEvent, topPrev, bottomPrev
	local rightTimePrev, leftTimeCurrent
	for x = startEvent, 1, -1 do

		prevDisplayEvent = activeDisplayEvents[x]
		topPrev = prevDisplayEvent.positionY + prevDisplayEvent.fontSize
		bottomPrev = prevDisplayEvent.positionY

		if (topCurrent >= bottomPrev and topCurrent <= topPrev) or (bottomCurrent >= bottomPrev and bottomCurrent <= topPrev) then

			rightTimePrev = prevDisplayEvent.elapsedTime - ((prevDisplayEvent.offsetRight or 0) + MIN_HORIZONTAL_SPACING) * perPixelTime
			leftTimeCurrent = currentDisplayEvent.elapsedTime - (currentDisplayEvent.offsetLeft or 0) * perPixelTime

			if rightTimePrev <= leftTimeCurrent then
				prevDisplayEvent.elapsedTime = leftTimeCurrent + ((prevDisplayEvent.offsetRight or 0) + MIN_HORIZONTAL_SPACING) * perPixelTime

				RepositionHorizontalLeft(prevDisplayEvent, activeDisplayEvents, x - 1)
			end
		end
	end
end

local function InitHorizontal(newDisplayEvent, activeDisplayEvents, direction, behavior)

	newDisplayEvent.scrollTime = newDisplayEvent.scrollWidth * MOVEMENT_SPEED

	local anchorPoint = newDisplayEvent.anchorPoint
	if direction ~= "Left" and direction ~= "Right" then

		direction = (lastHorizontalDirection[activeDisplayEvents] == "Left") and "Right" or "Left"
		lastHorizontalDirection[activeDisplayEvents] = direction
		anchorPoint = (direction == "Left") and "BOTTOMRIGHT" or "BOTTOMLEFT"
		newDisplayEvent.anchorPoint = anchorPoint

		newDisplayEvent.elapsedTime = newDisplayEvent.scrollTime / 2
	end

	local fontStringWidth = newDisplayEvent.fontString:GetStringWidth()
	if issecretvalue and issecretvalue(fontStringWidth) then
		fontStringWidth = newDisplayEvent.fontSize * 6
	end
	if anchorPoint == "BOTTOMLEFT" then
		newDisplayEvent.offsetLeft = 0
		newDisplayEvent.offsetRight = fontStringWidth
	elseif anchorPoint == "BOTTOM" then
		local halfWidth = fontStringWidth / 2
		newDisplayEvent.offsetLeft = -halfWidth
		newDisplayEvent.offsetRight = halfWidth
	elseif anchorPoint == "BOTTOMRIGHT" then
		newDisplayEvent.offsetLeft = -fontStringWidth
		newDisplayEvent.offsetRight = 0
	end

	local positionY
	if behavior == "GrowDown" then

		positionY = lastHorizontalPositionY[activeDisplayEvents] or newDisplayEvent.scrollHeight
		positionY = positionY - newDisplayEvent.fontSize - MIN_VERTICAL_SPACING
		if positionY < 0 then
			positionY = newDisplayEvent.scrollHeight
		end

	else

		positionY = lastHorizontalPositionY[activeDisplayEvents] or 0
		positionY = positionY + newDisplayEvent.fontSize + MIN_VERTICAL_SPACING
		if positionY > newDisplayEvent.scrollHeight then
			positionY = 0
		end
	end

	newDisplayEvent.positionY = positionY
	lastHorizontalPositionY[activeDisplayEvents] = positionY

	local numActiveAnimations = #activeDisplayEvents

	if direction == "Right" then

		newDisplayEvent.animationHandler = ScrollRight

		if numActiveAnimations == 0 then
			return
		end

		RepositionHorizontalRight(newDisplayEvent, activeDisplayEvents, numActiveAnimations)

	else

		newDisplayEvent.animationHandler = ScrollLeft

		if numActiveAnimations == 0 then
			return
		end

		RepositionHorizontalLeft(newDisplayEvent, activeDisplayEvents, numActiveAnimations)
	end
end

local function ScrollStatic(displayEvent, animationProgress)

end

local function InitStatic(newDisplayEvent, activeDisplayEvents, direction, behavior)

	newDisplayEvent.scrollTime = STATIC_DISPLAY_TIME

	newDisplayEvent.animationHandler = ScrollStatic

	local anchorPoint = newDisplayEvent.anchorPoint
	if anchorPoint == "BOTTOMLEFT" then
		newDisplayEvent.positionX = 0
	elseif anchorPoint == "BOTTOM" then
		newDisplayEvent.positionX = newDisplayEvent.scrollWidth / 2
	elseif anchorPoint == "BOTTOMRIGHT" then
		newDisplayEvent.positionX = newDisplayEvent.scrollWidth
	end

	local numActiveAnimations = #activeDisplayEvents
	local positionY

	if direction == "Down" then
		positionY = newDisplayEvent.scrollHeight

		if numActiveAnimations > 0 then

			positionY = activeDisplayEvents[numActiveAnimations].positionY - newDisplayEvent.fontSize - MIN_VERTICAL_SPACING

			if positionY < 0 then
				positionY = newDisplayEvent.scrollHeight
			end
		end

	else
		positionY = 0

		if numActiveAnimations > 0 then

			positionY = activeDisplayEvents[numActiveAnimations].positionY + newDisplayEvent.fontSize + MIN_VERTICAL_SPACING

			if positionY > newDisplayEvent.scrollHeight then
				positionY = 0
			end
		end
	end

	if numActiveAnimations > 0 then

		local topNew = positionY + newDisplayEvent.fontSize
		local bottomNew = positionY

		local oldDisplayEvent, topOld, bottomOld
		for x = 1, numActiveAnimations - 1 do

			oldDisplayEvent = activeDisplayEvents[x]
			bottomOld = oldDisplayEvent.positionY
			topOld = bottomOld + oldDisplayEvent.fontSize

			if (topNew >= bottomOld and topNew <= topOld) or (bottomNew >= bottomOld and bottomNew <= topOld) then
				oldDisplayEvent.elapsedTime = oldDisplayEvent.scrollTime
			end
		end
	end

	newDisplayEvent.positionY = positionY
end

MikSBT.RegisterAnimationStyle("Angled", InitAngled, "Alternate;Left;Right", "AngleUp;AngleDown")
MikSBT.RegisterAnimationStyle("Straight", InitStraight, "Up;Down", nil)
MikSBT.RegisterAnimationStyle("Parabola", InitParabola, "Up;Down", "CurvedLeft;CurvedRight")
MikSBT.RegisterAnimationStyle("Horizontal", InitHorizontal, "Alternate;Left;Right", "GrowUp;GrowDown")
MikSBT.RegisterAnimationStyle("Static", InitStatic, "Up;Down", nil)

MikSBT.RegisterStickyAnimationStyle("Pow", InitPow, "Up;Down", "Normal;Jiggle")
MikSBT.RegisterStickyAnimationStyle("Static", InitStatic, "Up;Down", nil)

