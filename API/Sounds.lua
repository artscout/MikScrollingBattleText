local Sounds = {}
local RestrictedValue = MikSBT.API.RestrictedValue
local DEFAULT_SOUND_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\"

function Sounds:NormalizeFile(value)
	if not RestrictedValue:CanAccess(value) then return nil end
	if type(value) == "string" then
		value = value:match("^%s*(.-)%s*$")
		local fileID = tonumber(value)
		if fileID then value = fileID end
	end
	if type(value) == "number" then
		if value > 0 and value < math.huge and value % 1 == 0 then
			return value
		end
		return nil
	end
	if type(value) ~= "string" or value == "" then return nil end

	local path = value:gsub("/", "\\")
	local lower = path:lower()
	if not lower:match("%.ogg$") and not lower:match("%.mp3$") then
		return nil
	end
	if path:find("..", 1, true) or path:find("[%c:]") then return nil end
	if not path:find("\\", 1, true) then
		return DEFAULT_SOUND_PATH .. path
	end
	if lower:sub(1, 10) == "interface\\" then return path end
end

function Sounds:Play(file)
	file = self:NormalizeFile(file)
	if not file or type(PlaySoundFile) ~= "function" then return false end
	local ok, played = pcall(PlaySoundFile, file, "Master")
	return ok and RestrictedValue:Boolean(played) == true
end

MikSBT.API.Sounds = Sounds
return Sounds
