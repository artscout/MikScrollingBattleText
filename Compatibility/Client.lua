local module = {}
MikSBT.Compatibility = MikSBT.Compatibility or {}
MikSBT.Compatibility.Client = module

local FOREVER_INTERFACE = 16001

local interfaceVersion = tonumber((select(4, GetBuildInfo())))

module.interfaceVersion = interfaceVersion
module.isForever = interfaceVersion == FOREVER_INTERFACE
module.isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
module.isCataClassic = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
module.isVanillaContent = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
		or module.isForever
module.isClassicContent = WOW_PROJECT_ID >= WOW_PROJECT_CLASSIC
		or module.isForever
module.hasModernAPI = module.isMainline or module.isForever
