--[[
Name: Banzai-1.1
Revision: $Rev: 55700 $
Author(s): Rabbit (rabbit.magtheridon@gmail.com), maia
Documentation: http://www.wowace.com/index.php/Banzai-1.1_API_Documentation
SVN: http://svn.wowace.com/wowace/trunk/BanzaiLib/Banzai-1.1
Description: Aggro notification library.
Dependencies: AceLibrary, AceEvent-2.0, Roster-2.1
]]

--[[
BanzaiLib is copyrighted 2006 by Rabbit.

This addon is distributed under the terms of the Creative Commons
Attribution-NonCommercial-ShareAlike 2.0 license.

http://creativecommons.org/licenses/by-nc-sa/2.5/

You may distribute and use these libraries without making your mod adhere to the
same license, as long as you preserve the license text embedded in the
libraries.

Any and all questions regarding our stance and licensing should be
directed to the #wowace IRC channel on irc.freenode.net.
]]

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local MAJOR_VERSION = "Banzai-1.1"
local MINOR_VERSION = "$Revision: 55700 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if AceLibrary:HasInstance("Banzai-1.0") then error(MAJOR_VERSION .. " can't run alongside Banzai-1.0.") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0.") end
if not AceLibrary:HasInstance("Roster-2.1") then error(MAJOR_VERSION .. " requires Roster-2.1.") end

local lib = {}
local aceEvent = AceLibrary("AceEvent-2.0")

aceEvent:embed(lib)

local RL = nil
local roster = nil
local playerName = nil
local UpdateAggroList = nil

local events = {
	["Banzai_UnitGainedAggro"] = true,
	["Banzai_UnitLostAggro"] = true,
	["Banzai_PlayerGainedAggro"] = true,
	["Banzai_PlayerLostAggro"] = true,
	["Banzai_Run"] = true,
}

-------------------------------------------------------------------------------
-- Local heap
-------------------------------------------------------------------------------

local new, del
do
	local cache = setmetatable({},{__mode='k'})
	function new()
		local t = next(cache)
		if t then
			cache[t] = nil
			return t
		else
			return {}
		end
	end
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Activate a new instance of this library
local function activate(self, oldLib, oldDeactivate)
	if oldLib then
		self.vars = oldLib.vars
		self.vars.running = nil
		if oldLib:IsEventScheduled("UpdateAggroList") then
			oldLib:CancelScheduledEvent("UpdateAggroList")
			self:Start()
		end
	else
		self.vars = {}
	end

	RL = AceLibrary("Roster-2.1")
	roster = RL.roster
	playerName = UnitName("player")

	if not self.vars then self.vars = {} end

	if not self.vars.running then
		for k in pairs(events) do
			if aceEvent:IsEventRegistered(k) then
				self:ScheduleRepeatingEvent("UpdateAggroList", UpdateAggroList, 0.2)
				self.vars.running = true
				self:TriggerEvent("Banzai_Enabled")

				break
			end
		end
	end

	self:RegisterEvent("AceEvent_EventRegistered", "Start")
	self:RegisterEvent("AceEvent_EventUnregistered", "Stop")

	lib = self

	if oldDeactivate then oldDeactivate(oldLib) end
end

-------------------------------------------------------------------------------
-- Library
-------------------------------------------------------------------------------

local table_insert = table.insert
local math_max = math.max
local math_min = math.min
local UnitExists = UnitExists
local UnitName = UnitName
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local getTargetId = setmetatable({}, {__index =
	function(self, key)
		self[key] = key .. "target"
		return self[key]
	end
})

local banzaiModifier = setmetatable({}, {__index =
	function(self, key)
		self[key] = 0
		return self[key]
	end
})

function UpdateAggroList()
	local oldBanzai = nil

	for name, unit in pairs(roster) do
		local unitId = unit.unitid
		if unit.online and UnitExists(unitId) and not UnitIsDeadOrGhost(unitId) then
			if not oldBanzai then oldBanzai = new() end
			oldBanzai[name] = unit.banzai

			-- check for aggro
			local targetId = getTargetId[unitId]
			if UnitExists(targetId) then
				local ttId = getTargetId[targetId]
				if UnitExists(ttId) then
					if UnitCanAttack(ttId, targetId) then
						local targetName = UnitName(ttId)
						if roster[targetName] then
							banzaiModifier[targetName] = banzaiModifier[targetName] + 10
							if not roster[targetName].banzaiTarget then roster[targetName].banzaiTarget = new() end
							table_insert(roster[targetName].banzaiTarget, targetId)
						end
					end
				end
			end

			-- cleanup
			banzaiModifier[name] = math_max(0, banzaiModifier[name] - 5)
			banzaiModifier[name] = math_min(25, banzaiModifier[name])

			-- set aggro
			unit.banzai = (banzaiModifier[name] > 15)
		elseif unit.banzai then
			if not oldBanzai then oldBanzai = new() end
			oldBanzai[name] = unit.banzai
			unit.banzai = false
			banzaiModifier[name] = 0
		end
	end

	if oldBanzai then
		for name, unit in pairs(roster) do
			if oldBanzai[name] ~= nil and oldBanzai[name] ~= unit.banzai then
				-- Aggro status has changed.
				if unit.banzai == true and unit.banzaiTarget then
					-- Unit has aggro
					lib:TriggerEvent("Banzai_UnitGainedAggro", unit.unitid, unit.banzaiTarget)
					if name == playerName then
						lib:TriggerEvent("Banzai_PlayerGainedAggro", unit.banzaiTarget)
					end
				elseif unit.banzai == false then
					-- Unit lost aggro
					lib:TriggerEvent("Banzai_UnitLostAggro", unit.unitid)
					if name == playerName then
						lib:TriggerEvent("Banzai_PlayerLostAggro", unit.unitid)
					end
				end
			end
			if unit.banzaiTarget then
				unit.banzaiTarget = del(unit.banzaiTarget)
			end
		end
		oldBanzai = del(oldBanzai)
	end
end

-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------

function lib:Stop(addon, event)
	if not self.vars.running then return end

	local shouldDisable = true
	for k in pairs(events) do
		if aceEvent:IsEventRegistered(k) then
			shouldDisable = nil
			break
		end
	end

	if shouldDisable then
		self:CancelScheduledEvent("UpdateAggroList")
		for name, unit in pairs(roster) do
			unit.banzai = nil
			banzaiModifier[name] = 0
		end
		self.vars.running = nil
		self:TriggerEvent("Banzai_Disabled")
	else
		self:Start(nil, event)
	end
end

function lib:Start(addon, event)
	if self.vars.running then return end
	if events[event] or event == 'all' then
		self:ScheduleRepeatingEvent("UpdateAggroList", UpdateAggroList, 0.2)
		self.vars.running = true
		self:TriggerEvent("Banzai_Enabled")
	end
end

-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------

function lib:GetUnitAggroByUnitId( unitId )
	if not self.vars.running then error(MAJOR_VERSION.." is not running. You must register for one of the events.", 2) end
	local rosterUnit = RL:GetUnitObjectFromUnit(unitId)
	if not rosterUnit then return nil end
	return rosterUnit.banzai
end

function lib:GetUnitAggroByUnitName( unitName )
	if not self.vars.running then error(MAJOR_VERSION.." is not running. You must register for one of the events.", 2) end
	local rosterUnit = RL:GetUnitObjectFromName(unitName)
	if not rosterUnit then return nil end
	return rosterUnit.banzai
end

function lib:IsRunning()
	return self:IsEventScheduled("UpdateAggroList")
end

-------------------------------------------------------------------------------
-- Register
-------------------------------------------------------------------------------
AceLibrary:Register(lib, MAJOR_VERSION, MINOR_VERSION, activate)

