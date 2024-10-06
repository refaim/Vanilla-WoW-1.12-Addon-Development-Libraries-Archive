--[[
	Name: SpecialEvents-Mail-2.0
	Revision: $Rev: 14864 $
	Author: Tekkub Stoutwrithe (tekkub@gmail.com)
	Website: http://www.wowace.com/
	Description: Special events for mail (received, auction notices, etc)
	Dependencies: AceLibrary, AceEvent-2.0
	-14864
	--fix for ruRU 82-105 lines
]]


local vmajor, vminor = "SpecialEvents-Mail-2.0", "$Revision: 14864 $"

if not AceLibrary then error(vmajor .. " requires AceLibrary.") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(vmajor .. " requires AceEvent-2.0.") end
if not AceLibrary:IsNewVersion(vmajor, vminor) then return end

local lib = {}
AceLibrary("AceEvent-2.0"):embed(lib)

local closedelay = 5


-- Activate a new instance of this library
function activate(self, oldLib, oldDeactivate)
	if oldLib then self.vars = oldLib.vars
else self.vars = {} end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("UPDATE_PENDING_MAIL")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	
	if oldDeactivate then oldDeactivate(oldLib) end
end


--------------------------------
--      Tracking methods      --
--------------------------------

function lib:PLAYER_ENTERING_WORLD()
	self.vars.zoneevent = true
end


function lib:MAIL_CLOSED()
	self.vars.lastclose = GetTime()
end


function lib:UPDATE_PENDING_MAIL()
	if self.vars.lastclose and (self.vars.lastclose + closedelay) > GetTime() then self.vars.ignorenext = true end
	
	if self.vars.zoneevent then
		self.vars.zoneevent = nil
		self:TriggerEvent("SpecialEvents_MailInit")
		return
	end
	
	if self.vars.ignorenext then
		self.vars.ignorenext = nil
		return
	end
	
	self:TriggerEvent("SpecialEvents_MailReceived")
end


-- Events that don't fire UPDATE_PENDING_MAIL like they should
local brokenevents = {
	[ERR_AUCTION_WON_S]     = false,
	[ERR_AUCTION_SOLD_S]    = false,
	[ERR_AUCTION_OUTBID_S]  = true,
	[ERR_AUCTION_EXPIRED_S] = false,
	[ERR_AUCTION_REMOVED_S] = false,
}
local eventnames = {
	[ERR_AUCTION_WON_S]     = "WON",
	[ERR_AUCTION_SOLD_S]    = "SOLD",
	[ERR_AUCTION_OUTBID_S]  = "OUTBID",
	[ERR_AUCTION_EXPIRED_S] = "EXPIRED",
	[ERR_AUCTION_REMOVED_S] = "REMOVED",
}
local ru=GetLocale()=="ruRU" --by CFM
local aucstr = {}
for i in pairs(brokenevents) do
	if ru and i==ERR_AUCTION_EXPIRED_S then  --by CFM
		aucstr[i] = string.gsub(i,"%%[^%s]+",".+)")  --by CFM
	elseif ru and (i==ERR_AUCTION_SOLD_S or i==ERR_AUCTION_REMOVED_S) then  --by CFM
		aucstr[i] = string.gsub(i,"\"%%[^%s]+","\"(.+)\"")  --by CFM
	elseif ru and i==ERR_AUCTION_WON_S then  --by CFM
		aucstr[i] = string.gsub(i,"%%[^%s]","(.+)")  --by CFM
	else  --by CFM
		aucstr[i] = string.gsub(i,"%%[^%s]+","(.+)")
	end  --by CFM
	
end

function lib:CHAT_MSG_SYSTEM(msg)
	if not msg then return end

	for i,searchstr in pairs(aucstr) do
		if not searchstr then return end --by CFM
		local _, _, item = string.find(msg, searchstr)
		if item then
			if ru and string.find(item,"%(") then  --by CFM
				item = string.sub(item,2,string.len(item)-1)  --by CFM
			end  --by CFM
			self:TriggerEvent("SpecialEvents_AHAlert", eventnames[i], item)
			if brokenevents[i] then
				self:TriggerEvent("SpecialEvents_MailReceived")
				return
			end
		end
	end
end


--------------------------------
--      Load this bitch!      --
--------------------------------
AceLibrary:Register(lib, vmajor, vminor, activate)
