
if (GetLocale() ~= "zhCN") then return end

local L = MikSBT.translations

L.FONT_FILES["MSBT ARKai_C"] = "Fonts\\ARKai_C.TTF"

L.DEFAULT_FONT_NAME = "MSBT ARKai_C"

L.COMMAND_USAGE = {
	"使用方法: " .. MikSBT.COMMAND .. " <命令> [参数]",
	" 命令:",
	"  " .. L.COMMAND_RESET .. " - 重置",
	"  " .. L.COMMAND_DISABLE .. " - 禁用",
	"  " .. L.COMMAND_ENABLE .. " - 启用",
	"  " .. L.COMMAND_SHOWVER .. " - 显示当前版本",
	"  " .. L.COMMAND_HELP .. " - 帮助",
}

L.MSG_DISABLE				= "禁用插件."
L.MSG_ENABLE				= "启用插件."
L.MSG_PROFILE_RESET			= "重置配置"
L.MSG_HITS					= "击中"
L.MSG_CRIT					= "爆击"
L.MSG_CRITS					= "爆击"
L.MSG_MULTIPLE_TARGETS		= "多个目标"
L.MSG_READY_NOW				= "准备完毕"

L.MSG_INCOMING			= "承受伤害"
L.MSG_OUTGOING			= "输出伤害"
L.MSG_NOTIFICATION		= "通告信息"
L.MSG_STATIC			= "静态信息"

L.MSG_COMBAT					= "战斗"
L.MSG_DISPEL					= "驱散"

L.MSG_CP_FULL					= "终结技"
L.MSG_HOLY_POWER_FULL			= "满圣能"

L.MSG_KILLING_BLOW				= "击杀"
L.MSG_TRIGGER_LOW_HEALTH		= "生命值低"
L.MSG_TRIGGER_LOW_MANA			= "魔法值低"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "宠物生命值低"

