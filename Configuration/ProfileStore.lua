local ProfileStore = {}
ProfileStore.__index = ProfileStore

local SAVED_VARIABLES_NAME = "MSBTProfiles_SavedVars"
local CHARACTER_VARIABLES_NAME = "MSBTProfiles_SavedVarsPerChar"
local SAVED_MEDIA_NAME = "MSBT_SavedMedia"

function ProfileStore:New(options)
	local store = setmetatable({}, self)

	store.globals = options.globals or _G
	store.version = options.version
	store.defaultProfileName = options.defaultProfileName or "Default"
	store.migrateProfiles = options.migrateProfiles

	return store
end

function ProfileStore:Initialize()
	local globals = self.globals
	local savedVariables = globals[SAVED_VARIABLES_NAME]
	local isFirstLoad = not savedVariables

	if not savedVariables then
		savedVariables = {
			profiles = {
				[self.defaultProfileName] = {
					creationVersion = self.version,
				},
			},
		}
		globals[SAVED_VARIABLES_NAME] = savedVariables
	else
		savedVariables.profiles = savedVariables.profiles or {}
		savedVariables.profiles[self.defaultProfileName] =
			savedVariables.profiles[self.defaultProfileName] or {}
		if self.migrateProfiles then
			self.migrateProfiles(savedVariables.profiles)
		end
	end

	local perCharacter = globals[CHARACTER_VARIABLES_NAME]
	if not perCharacter then
		perCharacter = {}
		globals[CHARACTER_VARIABLES_NAME] = perCharacter
	end

	local selectedName = perCharacter.currentProfileName
	if not selectedName or not savedVariables.profiles[selectedName] then
		selectedName = self.defaultProfileName
		perCharacter.currentProfileName = selectedName
	end

	local savedMedia = globals[SAVED_MEDIA_NAME]
	if not savedMedia then
		savedMedia = {}
		globals[SAVED_MEDIA_NAME] = savedMedia
	end
	savedMedia.fonts = savedMedia.fonts or {}
	savedMedia.sounds = savedMedia.sounds or {}

	return {
		savedVariables = savedVariables,
		savedVariablesPerChar = perCharacter,
		savedMedia = savedMedia,
		currentProfileName = selectedName,
		isFirstLoad = isFirstLoad,
	}
end

MikSBT.Configuration.ProfileStore = ProfileStore

return ProfileStore
