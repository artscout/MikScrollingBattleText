local module = {}
local moduleName = "Media"
MikSBT[moduleName] = module

local DEFAULT_SOUND_FILES = {
	["MSBT Cooldown"] = "Interface\\Addons\\MikScrollingBattleText\\Sounds\\Cooldown.ogg",
}

local registry = MikSBT.Configuration.MediaRegistry:New({
	sharedMedia = LibStub("LibSharedMedia-3.0"),
	defaultFonts = MikSBT.translations.FONT_FILES,
	defaultSounds = DEFAULT_SOUND_FILES,
})
registry:Initialize()

local function OnVariablesInitialized()
	registry:LoadSavedMedia(MikSBT.Profiles.savedMedia)
end

module.fonts = registry.fonts
module.sounds = registry.sounds
module.RegisterSound = function(name, file)
	return registry:RegisterSound(name, file)
end
module.IterateSounds = function()
	return registry:IterateSounds()
end
module.PlaySound = function(reference)
	return registry:PlaySound(reference)
end
module.RegisterFont = function(name, path)
	return registry:RegisterFont(name, path)
end
module.IterateFonts = function()
	return registry:IterateFonts()
end
module.OnVariablesInitialized = OnVariablesInitialized
