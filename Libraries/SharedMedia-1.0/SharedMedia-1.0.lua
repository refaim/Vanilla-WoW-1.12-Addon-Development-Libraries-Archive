--[[
Name: SharedMedia-1.0
Revision: $Revision: 54781 $
Author: Elkano (elkano@gmx.de)
Inspired By: SurfaceLib by Haste/Otravi (troeks@gmail.com)
Website: http://
Documentation: http://www.wowace.com/wiki/SharedMedia-1.0
SVN: http://svn.wowace.com/wowace/trunk/SharedMediaLib/SharedMedia-1.0/
Description: Shared handling of media data (fonts, sounds, textures, ...) between addons.
Dependencies: AceLibrary, AceEvent-2.0
License: LGPL v2.1
]]

local vmajor, vminor = "SharedMedia-1.0", "$Revision: 54781 $"

if not AceLibrary then error(vmajor .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(vmajor, vminor) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(vmajor .. " requires AceEvent-2.0.") end

local _G = getfenv(0)

local lib = {}

lib.MediaType = {
	BACKGROUND  = "background",			-- background textures
	BORDER      = "border",				-- border textures
	FONT		= "font",				-- fonts
	STATUSBAR	= "statusbar",			-- statusbar textures
	SOUND		= "sound",				-- sound files
}


local mediaTable = nil
local mediaList = nil
local overrideMedia = nil
local defaultMedia = nil

local function rebuildMediaList(type)
	if type then
		local mtable = mediaTable[type]
		if not mtable then return end
		if _G.type(mediaList[type]) ~= "table" then mediaList[type] = {} end
		local mlist = mediaList[type]
		for k in pairs(mlist) do mlist[k] = nil end
		for k in pairs(mtable) do
			rawset(mlist, #mlist + 1, k)
		end
		table.sort(mlist)
	else
		for k in pairs(mediaTable) do
			rebuildMediaList(k)
		end
	end
end

local function filename(file)
	local filename = select(3, file:find("^.+\\(.+)$"))
	if _G.type(filename) ~= "string" then error("Provided path does not contain a valid filename.") end
	local ext = filename:sub(-4)
	if ext == ".tga" or ext == ".blp" then filename = filename:sub(1, filename:len() - 4) end
	return filename:lower()
end

function lib:Register(m, n, t)
	self:argCheck(m, 2, "string")
	self:argCheck(n, 3, "string")
	self:argCheck(t, 4, "string")

	m = m:lower()
	n = n:trim()
	if not mediaTable[m] then
		mediaTable[m] = {}
	end
	local mtable = mediaTable[m]
	if not mtable or mtable[n] or mtable[n:lower()] or mtable[n:upper()] then return end

	for _, v in pairs(mtable) do
		if filename(t) == filename(v) then return end
	end

	mtable[n] = t
	rebuildMediaList(m)
	
	self:TriggerEvent("SharedMedia_Registered", m, n)
end

function lib:Fetch(m, n, noDefault)
	self:argCheck(m, 2, "string")
	self:argCheck(n, 3, "string")

	local result = mediaTable[m] and ((not overrideMedia[m] and mediaTable[m][n]) or (overrideMedia[m] and mediaTable[m][overrideMedia[m]]) or (not noDefault and mediaTable[m][defaultMedia[m]])) or nil

	local locale = GetLocale()
	if locale == "zhTW" then
		-- Because all the 4 default fonts and almost ALL custom fonts don't display traditional chinese, we just map them to bLEI00D.ttf.
		if m == "font" and result and result ~= "Fonts\\bHEI00M.ttf" and result ~= "Fonts\\bHEI01B.ttf" and result ~= "Fonts\\bKAI00M.ttf" and result ~= "Fonts\\bLEI00D.ttf" then
			result = "Fonts\\bLEI00D.ttf"
		end
	elseif locale == "zhCN" then
		if m == "font" and result and result ~= "Fonts\\ZYKai_T.TTF" and result ~= "Fonts\\ZYKai_C.TTF" and result ~= "Fonts\\ZYHei.TTF" then
			result = "Fonts\\ZYKai_T.TTF"
		end
	elseif locale == "koKR" then
		if m == "font" and result and result ~= "Fonts\\2002B.TTF" and result ~= "Fonts\\2002.TTF" and result ~= "Fonts\\K_Damage.TTF" and result ~= "Fonts\\K_Pagetext.TTF" then
			result = "Fonts\\2002.TTF"
		end
	end

	return result
end

function lib:HashTable(m)
	self:argCheck(m, 2, "string")
	if not mediaTable[m] then
		mediaTable[m] = {}
	end
	return mediaTable[m]
end

function lib:List(m)
	self:argCheck(m, 2, "string")
	if not mediaTable[m] then
		mediaTable[m] = {}
	end
	if not(mediaList[m]) then
		rebuildMediaList(m)
	end
	return mediaList[m]
end

function lib:GetGlobal(m)
	self:argCheck(m, 2, "string")
	return overrideMedia[m]
end

function lib:SetGlobal(m, n)
	self:argCheck(m, 2, "string")
	overrideMedia[m] = mediaTable[m] and mediaTable[m][n] and n or nil
	self:TriggerEvent("SharedMedia_SetGlobal", m, overrideMedia[m])
end

function lib:Usage(m)
	self:argCheck(m, 2, "string")
	if not(mediaList[m]) then
		rebuildMediaList(m)
	end
	return "{" .. table.concat(mediaList[m], " || ") .. "}"
end

function lib:IsValid(m, n)
	return mediaTable[m] and (not n or mediaTable[m][n]) and true or false
end

function lib:SetDefault(m, n)
	if mediaTable[m] and mediaTable[m][n] and not defaultMedia[m] then
		defaultMedia[m] = n
	end
end

function lib:GetData()
	return mediaTable, overrideMedia, defaultMedia
end

local Surface
function lib:Surface_Registered(name)
	if Surface and name then
		self:Register('statusbar', name, Surface:Iterate()[name])
	end
end

local LSM2
function lib.LSM2_Register(m, n)
	lib:Register(m, n, LSM2:Fetch(m, n))
end

local function activate(self, oldLib, oldDeactivate)
	if oldLib then
		mediaTable, overrideMedia, defaultMedia = oldLib:GetData()
	end

	if not mediaTable then
		mediaTable = {
			background = {
				["Blizzard Low Health"] = "Interface\\FullScreenTextures\\LowHealth",
				["Blizzard Out of Control"] = "Interface\\FullScreenTextures\\OutOfControl",
				["Blizzard Tabard Background"] = "Interface\\TabardFrame\\TabardFrameBackground",
				["Solid"] = "Interface\\Buttons\\WHITE8X8",
				["Blizzard Tooltip"] = "Interface\\Tooltips\\UI-Tooltip-Background",
			},

			border = {
				["None"] = "Interface\\None",
				["Blizzard Dialog"]  = "Interface\\DialogFrame\\UI-DialogBox-Border",
				["Blizzard Tooltip"] = "Interface\\Tooltips\\UI-Tooltip-Border",
			},

			font = {
				["Arial Narrow"] = "Fonts\\ARIALN.TTF",
				["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF",
				["Morpheus"] = "Fonts\\MORPHEUS.TTF",
				["Skurri"] = "Fonts\\SKURRI.TTF",
			},

			sound = {
				-- Relies on the fact that PlaySound[File] doesn't error on non-existing input.
				["None"] = "Interface\\Quiet.mp3",
			},

			statusbar = {
				["Blizzard"] = "Interface\\TargetingFrame\\UI-StatusBar",
			},
		}
	end

	local locale = GetLocale()
	if locale == "koKR" then
		mediaTable["font"]["굵은 글꼴"] = "Fonts\\2002B.TTF"
		mediaTable["font"]["기본 글꼴"] = "Fonts\\2002.TTF"
		mediaTable["font"]["데미지 글꼴"] = "Fonts\\K_Damage.TTF"
		mediaTable["font"]["퀘스트 글꼴"] = "Fonts\\K_Pagetext.TTF"
	elseif locale == "zhTW" then
		-- Add 4 more system fonts which can display chinese to mediaTable.
		mediaTable["font"]["提示訊息"] = "Fonts\\bHEI00M.ttf"
		mediaTable["font"]["聊天"] = "Fonts\\bHEI01B.ttf"
		mediaTable["font"]["傷害數字"] = "Fonts\\bKAI00M.ttf"
		mediaTable["font"]["預設"] = "Fonts\\bLEI00D.ttf"
	elseif locale == "zhCN" then
		mediaTable["font"]["任务"] = "Fonts\\ZYKai_T.TTF"
		mediaTable["font"]["伤害数字"] = "Fonts\\ZYKai_C.TTF"
		mediaTable["font"]["默认"] = "Fonts\\ZYKai_T.TTF"
		mediaTable["font"]["提示信息"] = "Fonts\\ZYHei.TTF"
		mediaTable["font"]["聊天"] = "Fonts\\ZYHei.TTF"
	end

	if not mediaList then mediaList = {} end
	if not overrideMedia then overrideMedia = {} end
	if not defaultMedia then
		defaultMedia = {
			font = "Friz Quadrata TT",
			statusbar = "Blizzard",
		}

		if locale == "zhTW" then
			defaultMedia["font"] = "預設"
		elseif locale == "koKR" then
			defaultMedia["font"] = "기본 글꼴"
		elseif locale == "zhCN" then
			defaultMedia["font"] = "默认"
		end
	end

	if _G.type(oldDeactivate) == "function" then oldDeactivate(oldLib) end
end

local function deactivate(self)
	mediaTable = nil
	mediaList = nil
	overrideMedia = nil
	defaultMedia = nil
end

local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		instance:embed(self)

		if Surface then -- SurfaceLib fired first
			for k,v in pairs(Surface:Iterate()) do
				self:Register('statusbar', k, v)
			end
		end
		if LSM2 then -- LibSharedMedia-2.0 fired first
			for _,u in pairs(self.MediaType) do
				for k,v in pairs(LSM2:HashTable(u)) do
					self:Register(u, k, v)
				end
			end
		end

		self:RegisterEvent("Surface_Registered")
	elseif major == "Surface-1.0" then
		Surface = instance

		if self.TriggerEvent then -- AceEvent fired first
			for k,v in pairs(Surface:Iterate()) do
				self:Register('statusbar', k, v)
			end
		end
	elseif major == "LibSharedMedia-2.0" then
		LSM2 = instance
		if LSM2.RegisterCallback then -- REMOVE CHECK LATER
			LSM2:RegisterCallback(self.LSM2_Register)
		end
		
		if self.TriggerEvent then -- AceEvent fired first
			for _,u in pairs(self.MediaType) do
				for k,v in pairs(LSM2:HashTable(u)) do
					self:Register(u, k, v)
				end
			end
		end
	end
end

AceLibrary:Register(lib, vmajor, vminor, activate, deactivate, external)
lib = AceLibrary(vmajor)

