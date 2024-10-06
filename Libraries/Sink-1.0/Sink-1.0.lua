--[[
Name: Sink-1.0
Revision: $Rev: 66007 $
Author(s): Rabbit (rabbit.magtheridon@gmail.com
Website: http://rabbit.nihilum.eu
Documentation: http://wiki.wowace.com/index.php/Sink-1.0
SVN: http://svn.wowace.com/wowace/trunk/SinkLib/Sink-1.0
Description: Library that handles chat output.
Dependencies: AceLibrary, AceOO-2.0, SharedMedia-1.0 (optional)
License: GPL v2 or later.
]]

--[[
Copyright (C) 2007 Rabbit

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

-----------------------------------------------------------------------
-- Sink-1.0

local SINK10 = "Sink-1.0"
local SINK10_MINOR = string.match("$Revision: 66007 $", "[0-9]+")

assert(AceLibrary, SINK10 .. " requires AceLibrary.")
if not AceLibrary:IsNewVersion(SINK10, SINK10_MINOR) then return end
if not AceLibrary:HasInstance("AceOO-2.0") then error(SINK10 .. " requires AceOO-2.0") end

local L_DEFAULT = "Default"
local L_DEFAULT_DESC = "Route output from this addon through the first available handler, preferring scrolling combat text addons if available."
local L_ROUTE = "Route output from this addon through %s."
local L_SCT = "Scrolling Combat Text"
local L_MSBT = "MikSBT"
local L_BIGWIGS = "BigWigs"
local L_BCF = "BlinkCombatFeedback"
local L_UIERROR = "Blizzard Error Frame"
local L_CHAT = "Chat"
local L_BLIZZARD = "Blizzard FCT"
local L_RW = "Raid Warning"
local L_PARROT = "Parrot"
local L_OUTPUT = "Output"
local L_OUTPUT_DESC = "Where to route the output from this addon."
local L_SCROLL = "Scroll area"
local L_SCROLL_DESC = "Set the scrollarea where messages should appear.\n\nOnly available for Parrot, SCT or MikSBT."
local L_STICKY = "Sticky"
local L_STICKY_DESC = "Set messages from this addon to appear as sticky.\n\nOnly available for Blizzard FCT, Parrot, SCT or MikSBT."
local L_NONE = "None"
local L_NONE_DESC = "Hide all messages from this addon."

local l = GetLocale()
if l == "koKR" then
	L_DEFAULT = "기본"
	L_DEFAULT_DESC = "처음으로 사용 가능한 트레이너를 통해 이 애드온으로부터 출력을 보냅니다."
	L_ROUTE = "%s|1을;를; 통해 이 애드온의 메시지를 출력합니다."
	L_SCT = "Scrolling Combat Text"
	L_MSBT = "MikSBT"
	L_BIGWIGS = "BigWigs"
	L_BCF = "블링크의 전투 메세지"
	L_UIERROR = "블리자드 오류 창"
	L_CHAT = "대화창"
	L_BLIZZARD = "블리자드 FCT"
	L_RW = "공격대 경보"
	L_PARROT = "Parrot"
	L_OUTPUT = "출력"
	L_OUTPUT_DESC = "어디에 이 애드온의 메시지를 출력할지 선택합니다."
	L_SCROLL = "스크롤 영역"
	L_SCROLL_DESC = "메시지를 출력할 스크룰 영역을 설정합니다.\n\nParrot, SCT나 MikSBT만 사용 가능합니다."
	L_STICKY = "점착"
	L_STICKY_DESC = "달라붙는 것처럼 보일 이 애드온의 메시지를 설정합니다.\n\n블리자드 FCT, Parrot, SCT나 MikSBT만 사용 가능합니다."
	L_NONE = "없음"
	L_NONE_DESC = "이 애드온의 모든 메시지를 숨김니다."
elseif l == "frFR" then
	L_DEFAULT = "Par défaut"
	L_DEFAULT_DESC = "Transmet la sortie de cet addon via le premier handler disponible, de préférence les textes de combat défilants s'il y en a."
	L_ROUTE = "Transmet la sortie de cet addon via %s."
	L_SCT = "Scrolling Combat Text"
	L_MSBT = "MikSBT"
	L_BIGWIGS = "BigWigs"
	L_BCF = "BlinkCombatFeedback"
	L_UIERROR = "Cadre des erreurs Blizzard"
	L_CHAT = "Fenêtre de discussion"
	L_BLIZZARD = "TCF de Blizzard"
	L_RW = "Avertissement raid"
	L_PARROT = "Parrot"
	L_OUTPUT = "Sortie"
	L_OUTPUT_DESC = "Destination de la sortie de cet addon."
	L_SCROLL = "Zone de défilement"
	L_SCROLL_DESC = "Définie la zone de défilement où les messages doivent apparaitre."
	L_STICKY = "En évidence"
	L_STICKY_DESC = "Fait en sortie que les messages de cet addon apparaissent en évidence.\n\nDisponible uniquement pour le TCF de Blizzard, Parrot, SCT et MikSBT."
	L_NONE = "Aucun"
	L_NONE_DESC = "Masque tous les messages de cet addon."
elseif l == "deDE" then
	L_DEFAULT = "Voreinstellung"
	L_ROUTE = "Schickt die Meldungen dieses Addons an %s."
	L_SCT = "Scrolling Combat Text(SCT)"
	L_MSBT = "MikSBT"
	L_BIGWIGS = "BigWigs"
	--L_UIERROR = "Blizzard Error Frame"
	L_CHAT = "den Chat"
	L_BLIZZARD = "Blizzard's schwebenden Kampftext"
	L_RW = "die Schlachtzug Warnung"
	L_PARROT = "Parrot"
	L_OUTPUT = "Ausgabe"
	L_OUTPUT_DESC = "Wohin die Meldungen des Addons gesendet werden soll."
	L_SCROLL = "Scroll Area"
	L_SCROLL_DESC = "Setzt die Scroll Area, wo die Meldungen erscheinen sollen."
	L_NONE = "Nirgends"
	L_NONE_DESC = "Versteckt alle Meldungen von diesem Addon."
elseif l == "zhCN" then
	L_DEFAULT = "默认"
	L_DEFAULT_DESC = "插件的输出方式取决于第一个可用插件.例如有SCT插件,则优先使用."
	L_ROUTE = "经由%s显示信息"
	L_SCT = "SCT"
	L_MSBT = "MikSBT"
	L_BIGWIGS = "BigWigs"
	L_BCF = "BlinkCombatFeedback"
	--L_UIERROR = "Blizzard Error Frame"
	L_CHAT = "聊天框架"
	L_BLIZZARD = "系统自带滚动战斗信息"
	L_RW = "团队警告"
	L_PARROT = "Parrot"
	L_OUTPUT = "输出模式"
	L_OUTPUT_DESC = "设置显示位置"
	L_SCROLL = "滚动区域"
	L_SCROLL_DESC = "设置滚动信息显示位置. \n\n只有Parrot, SCT及MikSBT支持"
	L_STICKY = "固定"
	L_STICKY_DESC = "设置信息固定显示位置.\n\n只有系统自带鼓动战斗信息, Parrot, SCT及MikSBT支持"
	L_NONE = "隐藏"
	L_NONE_DESC = "隐藏所有来自插件的信息. "
elseif l == "zhTW" then
	L_DEFAULT = "預設"
	L_DEFAULT_DESC = "插件輸出經由第一個可使用的處理器顯示，如果有 SCT 的話，則優先使用。"
	L_ROUTE = "插件輸出經由%s顯示。"
	L_SCT = "SCT"
	L_MSBT = "MikSBT"
	L_BIGWIGS = "BigWigs"
	L_BCF = "BlinkCombatFeedback"
	L_UIERROR = "Blizzard 錯誤訊息框架"
	L_CHAT = "聊天視窗"
	L_BLIZZARD = "Blizzard 浮動戰鬥文字"
	L_RW = "團隊警告"
	L_PARROT = "Parrot"
	L_OUTPUT = "顯示模式"
	L_OUTPUT_DESC = "插件輸出經由哪裡顯示。"
	L_SCROLL = "滾動區域"
	L_SCROLL_DESC = "設定滾動訊息出現位置。\n\n只有 Parrot，SCT 及 MikSBT 有支援。"
	L_STICKY = "固定"
	L_STICKY_DESC = "設定使用固定訊息。\n\n只有 Blizzard 浮動戰鬥文字，Parrot，SCT 及 MikSBT 有支援。"
	L_NONE = "隱藏"
	L_NONE_DESC = "隱藏所有插件輸出。"
end

local SML = AceLibrary:HasInstance("SharedMedia-1.0") and AceLibrary("SharedMedia-1.0") or nil

local AceOO = AceLibrary("AceOO-2.0")
local sink = AceOO.Mixin {
	"Pour",
	"RegisterSink",
	"SetSinkStorage",
}

local _G = getfenv(0)

local function getSticky(addon)
	return sink.storageForAddon[addon] and sink.storageForAddon[addon].sink10Sticky or nil
end

-- Thanks to Antiarc and his Soar-1.0 library for most of the 'meat' of the
-- sink-specific functions.

local function parrot(addon, text, r, g, b, font, size, outline, sticky, loc, icon)
	local location = sink.storageForAddon[addon] and sink.storageForAddon[addon].sink10ScrollArea or "Notification"
	local s = getSticky(addon) or sticky
	Parrot:ShowMessage(text, location, s, r, g, b, font, size, outline, icon)
end

local sct_color = {}
local function sct(addon, text, r, g, b, font, size, outline, sticky)
	sct_color.r, sct_color.g, sct_color.b = r, g, b
	local loc = sink.storageForAddon[addon] and sink.storageForAddon[addon].sink10ScrollArea or "Messages"
	local location = (loc == "Outgoing" and SCT.FRAME1) or (loc == "Incoming" and SCT.FRAME2) or SCT.MSG
	local s = getSticky(addon) or sticky
	SCT:DisplayCustomEvent(text, sct_color, s, location)
end

local msbt_outlines = {["NORMAL"] = 1, ["OUTLINE"] = 2, ["THICKOUTLINE"] = 3}
local function msbt(addon, text, r, g, b, font, size, outline, sticky)
	if font and SML and not sink.msbt_registered_fonts[font] then
		MikSBT.RegisterFont(font, SML:Fetch("font", font))
		sink.msbt_registered_fonts[font] = true
	end
	local location = sink.storageForAddon[addon] and sink.storageForAddon[addon].sink10ScrollArea or MikSBT.DISPLAYTYPE_NOTIFICATION
	local s = getSticky(addon) or sticky
	MikSBT.DisplayMessage(text, location, s, r * 255, g * 255, b * 255, size, font, msbt_outlines[outline])
end

local function bcf(addon, text, r, g, b, font, size, outline, sticky)
	local loc = sink.storageForAddon[addon] and sink.storageForAddon[addon].sink10ScrollArea or "BCF_Message_Knob"
	BCF_DisplayMessage({text = text, rgb = {r = r, g = g, b = b}, font = font, fontsize = size, paneltype = "standard", outline = outline, anchor = loc})
end

local function blizzard(addon, text, r, g, b, font, size, outline, sticky)
	if tostring(SHOW_COMBAT_TEXT) ~= "0" then
		local s = getSticky(addon) or sticky
		CombatText_AddMessage(text, CombatText_StandardScroll, r, g, b, s and "crit" or nil, false)
	else
		UIErrorsFrame:AddMessage(text, r, g, b, 1, UIERRORS_HOLD_TIME)
	end
end

local function chat(addon, text, r, g, b)
	DEFAULT_CHAT_FRAME:AddMessage(text, r, g, b)
end

local function uierror(addon, text, r, g, b)
	UIErrorsFrame:AddMessage(text, r, g, b, 1, UIERRORS_HOLD_TIME)
end

-- XXX: 2.3.0 compat
local rw
do
	local c = {}
	function rw(addon, text, r, g, b, _, _, _, _, _, icon)
		if not c[r] then c[r] = {} end
		if not c[r][g] then c[r][g] = {} end
		if not c[r][g][b] then c[r][g][b] = {r = r, g = g, b = b} end
		if icon then text = "|T"..icon..":27:27:-10:-10|t"..text end
		RaidNotice_AddMessage(RaidWarningFrame, text, c[r][g][b])
	end
end

local function noop() --[[ noop! ]] end

local handlerPriority = { "Parrot", "SCT", "MikSBT", "BCF" }
-- Thanks to ckk for these
local customHandlersEnabled = {
	Parrot = function()
		return _G.Parrot and _G.Parrot:IsActive()
	end,
	SCT = function()
		return _G.SCT and _G.SCT:IsEnabled()
	end,
	BCF = function()
		return _G.BlinkCombatFeedbackFrame and BlinkCombatFeed_Data["ENABLE"]
	end,
}

local msbtVersion = tonumber(GetAddOnMetadata("MikScrollingBattleText", "Version")) or 0
local isMSBTFive = math.floor(msbtVersion) == 5 and true or nil
if isMSBTFive then
	customHandlersEnabled.MikSBT = function()
		return _G.MikSBT and not _G.MikSBT.IsModDisabled()
	end
else
	customHandlersEnabled.MikSBT = function()
		return _G.MikSBT and _G.MSBTProfiles and _G.MSBTProfiles.GetSavedVariables() and not MSBTProfiles.GetSavedVariables().UserDisabled
	end
end

local currentHandler = nil
local function getPrioritizedSink()
	if currentHandler then
		local check = customHandlersEnabled[currentHandler]
		if check and check() then
			return sink.handlers[currentHandler]
		end
	end
	for i, v in ipairs(handlerPriority) do
		local check = customHandlersEnabled[v]
		if check and check() then
			currentHandler = v
			return sink.handlers[v]
		end
	end
	if SHOW_COMBAT_TEXT and tostring(SHOW_COMBAT_TEXT) ~= "0" then
		return blizzard
	end
	return chat
end

local function pour(addon, text, r, g, b, ...)
	local func = sink.override and sink.handlers[sink.override] or nil
	if not func and sink.storageForAddon[addon] and sink.storageForAddon[addon].sink10OutputSink then
		local h = sink.storageForAddon[addon].sink10OutputSink
		func = sink.handlers[h]
		-- If this sink is not available now, find one manually.
		if customHandlersEnabled[h] and not customHandlersEnabled[h]() then
			func = nil
		end
	end
	if not func then
		func = getPrioritizedSink()
	end
	if not func then func = chat end
	func(addon, text, r or 1, g or 1, b or 1, ...)
end

function sink:Pour(textOrAddon, ...)
	local t = type(textOrAddon)
	if t == "string" then
		pour(self, textOrAddon, ...)
	elseif t == "table" then
		pour(textOrAddon, ...)
	else
		sink:error("Invalid argument 2 to :Pour, must be either a string or a table.")
	end
end

local sinks
do
	local options = {}
	-- Maybe we want to hide them instead of disable
	local function shouldDisableSCT()
		return not _G.SCT
	end
	local function shouldDisableMSBT()
		return not _G.MikSBT
	end
	local function shouldDisableBCF()
		return not _G.BlinkCombatFeedbackFrame
	end
	local function shouldDisableParrot()
		return not _G.Parrot
	end
	local function shouldDisableFCT()
		return not SHOW_COMBAT_TEXT or tostring(SHOW_COMBAT_TEXT) == "0"
	end

	local emptyTable = {}
	sinks = {
		Default = {
			type = "toggle",
			name = L_DEFAULT,
			desc = L_DEFAULT_DESC,
			isRadio = true,
		},
		SCT = {
			type = "toggle",
			name = L_SCT,
			desc = L_ROUTE:format(L_SCT),
			isRadio = true,
			hidden = shouldDisableSCT,
		},
		MikSBT = {
			type = "toggle",
			name = L_MSBT,
			desc = L_ROUTE:format(L_MSBT),
			isRadio = true,
			hidden = shouldDisableMSBT,
		},
		BCF = {
			type = "toggle",
			name = L_BCF,
			desc = L_ROUTE:format(L_BCF),
			isRadio = true,
			hidden = shouldDisableBCF,
		},
		Parrot = {
			type = "toggle",
			name = L_PARROT,
			desc = L_ROUTE:format(L_PARROT),
			isRadio = true,
			hidden = shouldDisableParrot,
		},
		Blizzard = {
			type = "toggle",
			name = L_BLIZZARD,
			desc = L_ROUTE:format(L_BLIZZARD),
			isRadio = true,
			hidden = shouldDisableFCT,
		},
		RaidWarning = {
			type = "toggle",
			name = L_RW,
			desc = L_ROUTE:format(L_RW),
			isRadio = true,
		},
		ChatFrame = {
			type = "toggle",
			name = L_CHAT,
			desc = L_ROUTE:format(L_CHAT),
			isRadio = true,
		},
		UIErrorsFrame = {
			type = "toggle",
			name = L_UIERROR,
			desc = L_ROUTE:format(L_UIERROR),
			isRadio = true,
		},
		None = {
			type = "toggle",
			name = L_NONE,
			desc = L_NONE_DESC,
			isRadio = true,
		},
		ScrollArea = {
			type = "text",
			name = L_SCROLL,
			desc = L_SCROLL_DESC,
			validate = emptyTable,
			order = -1,
			disabled = true,
		},
		Sticky = {
			type = "toggle",
			name = L_STICKY,
			desc = L_STICKY_DESC,
			order = -2,
			disabled = true,
		},
	}

	local bcfGeneral = {"BCF_Message_Knob", "BCFG_Message_Knob"}
	local bcfNoGeneral = {"BCF_Message_Knob"}
	local sctFrames = {"Incoming", "Outgoing", "Messages"}
	local msbtFrames = nil
	local function getScrollAreasForAddon(addon)
		if type(addon) ~= "string" then return nil end
		if addon == "Parrot" then
			if Parrot.GetScrollAreasChoices then
				return Parrot:GetScrollAreasChoices()
			else
				return Parrot:GetScrollAreasValidate()
			end
		elseif addon == "MikSBT" then
			if isMSBTFive then
				if not msbtFrames then
					msbtFrames = {}
					for key, name in MikSBT.IterateScrollAreas() do
						table.insert(msbtFrames, name)
					end
				end
				return msbtFrames
			else
				return MikSBT.GetScrollAreaList()
			end
		elseif addon == "BCF" then
			return _G.BlinkCombatFeedback_General and bcfGeneral or bcfNoGeneral
		elseif addon == "SCT" then
			return sctFrames
		elseif sink.registeredScrollAreaFunctions[addon] then
			return sink.registeredScrollAreaFunctions[addon]()
		end
		return nil
	end

	function sink:RegisterSink(shortName, name, desc, func, scrollAreaFunc, hasSticky)
		sink:argCheck(shortName, 2, "string")
		sink:argCheck(name, 3, "string")
		sink:argCheck(desc, 4, "string", "nil")
		sink:argCheck(func, 5, "string", "function")
		sink:argCheck(scrollAreas, 6, "function", "nil")
		sink:argCheck(hasSticky, 7, "boolean", "nil")
		if sinks[shortName] or sink.handlers[shortName] then
			sink:error("There's already a sink by the short name %q.", shortName)
		end
		sinks[shortName] = {
			type = "toggle",
			name = name,
			desc = desc or L_ROUTE:format(name),
			isRadio = true,
		}
		-- Save it for library upgrades.
		if not sink.registeredSinks then sink.registeredSinks = {} end
		sink.registeredSinks[shortName] = sinks[shortName]

		if type(func) == "function" then
			sink.handlers[shortName] = func
		else
			sink.handlers[shortName] = function(...)
				self[func](self, ...)
			end
		end
		if type(scrollAreaFunc) == "function" then
			sink.registeredScrollAreaFunctions[shortName] = scrollAreaFunc
		elseif type(scrollAreaFunc) == "string" then
			sink.registeredScrollAreaFunctions[shortName] = function(...)
				return self[scrollAreaFunc](self, ...)
			end
		end
		sink.stickyAddons[shortName] = hasSticky and true or nil
	end

	function sink:GetAceOptionsDataTable(addon)
		if not options[addon] then
			options[addon] = {
				output = {
					type = "group",
					name = L_OUTPUT,
					desc = L_OUTPUT_DESC,
					pass = true,
					get = function(key)
						if not sink.storageForAddon[addon] then
							return "Default"
						end
						if tostring(key) == "nil" then
							-- Means AceConsole wants to list the output option,
							-- so we should show which sink is currently used.
							return sink.storageForAddon[addon].sink10OutputSink or L_DEFAULT
						end
						if key == "ScrollArea" then
							return sink.storageForAddon[addon].sink10ScrollArea
						elseif key == "Sticky" then
							return sink.storageForAddon[addon].sink10Sticky
						else
							if sink.storageForAddon[addon].sink10OutputSink == key then
								local sa = getScrollAreasForAddon(key)
								options[addon].output.args.ScrollArea.validate = sa or emptyTable
								options[addon].output.args.ScrollArea.disabled = not sa
								options[addon].output.args.Sticky.disabled = not sink.stickyAddons[key]
							end
							return sink.storageForAddon[addon].sink10OutputSink and sink.storageForAddon[addon].sink10OutputSink == key or nil
						end
					end,
					set = function(key, value)
						if not sink.storageForAddon[addon] then return end
						if key == "ScrollArea" then
							sink.storageForAddon[addon].sink10ScrollArea = value
						elseif key == "Sticky" then
							sink.storageForAddon[addon].sink10Sticky = value
						elseif value then
							local sa = getScrollAreasForAddon(key)
							options[addon].output.args.ScrollArea.validate = sa or emptyTable
							options[addon].output.args.ScrollArea.disabled = not sa
							options[addon].output.args.Sticky.disabled = not sink.stickyAddons[key]
							sink.storageForAddon[addon].sink10OutputSink = key
						end
					end,
					args = sinks,
					disabled = function()
						return (type(addon.IsActive) == "function" and not addon:IsActive()) or nil
					end,
				},
			}
		end
		return options[addon]
	end
end

do
	local prioritizedStorageTypes = {"profile", "char", "realm", "server", "class", "account"}
	function sink:OnEmbedEnable(addon, name)
		if sink.storageForAddon[addon] then return end

		local found = addon.db and true or nil
		if not found and addon.class and addon.class.mixins then
			for mixin in pairs(addon.class.mixins) do
				if tostring(mixin) == "AceDB-2.0" then
					found = true
					break
				end
			end
		end
		if found then
			for i, v in ipairs(prioritizedStorageTypes) do
				if addon.db[v] then
					sink.storageForAddon[addon] = addon.db[v]
					break
				end
			end
		end
	end
end

function sink:SetSinkStorage(addon, storage)
	sink:argCheck(addon, 2, "table")
	sink:argCheck(storage, 3, "table")
	sink.storageForAddon[addon] = storage
end

-- Sets a sink override for -all- addons, librarywide.
function sink:SetSinkOverride(override)
	sink:argCheck(override, 2, "string", "nil")
	if not sink.handlers[override] then
		sink:error("There's no %q sink.", override)
	end
	sink.override = override
end

local function activate(self, oldLib, oldDeactivate)
	sink = self
	if oldLib then
		self.storageForAddon = oldLib.storageForAddon
		self.override = oldLib.override
		self.msbt_registered_fonts = oldLib.msbt_registered_fonts
		self.registeredScrollAreaFunctions = oldLib.registeredScrollAreaFunctions
		self.stickyAddons = oldLib.stickyAddons
		self.handlers = oldLib.handlers
		if oldLib.registeredSinks then
			for k, v in pairs(oldLib.registeredSinks) do
				sinks[k] = v
			end
		end
	end
	if not self.storageForAddon then self.storageForAddon = {} end
	if not self.msbt_registered_fonts then self.msbt_registered_fonts = {} end
	if not self.registeredScrollAreaFunctions then self.registeredScrollAreaFunctions = {} end
	if not self.stickyAddons then
		self.stickyAddons = {
			Blizzard = true,
			MikSBT = true,
			SCT = true,
			Parrot = true,
		}
	end
	if not self.handlers then
		self.handlers = {
			Parrot = parrot,
			SCT = sct,
			MikSBT = msbt,
			BCF = bcf,
			ChatFrame = chat,
			UIErrorsFrame = uierror,
			Blizzard = blizzard,
			RaidWarning = rw,
			None = noop,
		}
	end
	if oldLib and oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(sink, SINK10, SINK10_MINOR, activate)

