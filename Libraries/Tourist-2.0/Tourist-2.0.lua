--[[
	Name: Tourist-2.0
	Revision: $Rev: 15758 $
	Author(s): ckknight (ckknight@gmail.com)
	Website: http://ckknight.wowinterface.com/
	Documentation: http://wiki.wowace.com/index.php/Tourist-2.0
	SVN: http://svn.wowace.com/root/trunk/TouristLib/Tourist-2.0
	Description: A library to provide information about zones and instances.
	Dependencies: AceLibrary, Babble-Zone-2.2, AceConsole-2.0 (optional)
]]

local MAJOR_VERSION = "Tourist-2.0"
local MINOR_VERSION = "$Revision: 15758 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("Babble-Zone-2.2") then error(MAJOR_VERSION .. " requires Babble-Zone-2.2.") end

local Tourist = {}

local Z = AceLibrary("Babble-Zone-2.2")

local playerLevel = 1
local _,race = UnitRace("player")
local isHorde = (race == "Orc" or race == "Troll" or race == "Tauren" or race == "Scourge" or race == "BloodElf")
local isWestern = GetLocale() == "enUS" or GetLocale() == "ruRU" or GetLocale() == "deDE" or GetLocale() == "frFR" or GetLocale() == "esES"
local math_mod = math.fmod or math.mod

local Kalimdor, Eastern_Kingdoms, Outland = GetMapContinents()
if not Outland then
	Outland = "Outland"
end

local X_Y_ZEPPELIN = "%s/%s Zeppelin"
local X_Y_BOAT = "%s/%s Boat"
local X_Y_PORTAL = "%s/%s Portal"

local recZones = {}
local recInstances = {}
local lows = setmetatable({}, {__index = function() return 0 end})
local highs = setmetatable({}, getmetatable(lows))
local continents = {}
local instances = {}
local paths = {}
local types = {}
local groupSizes = {}
local factions = {}

local cost = {}

local function PLAYER_LEVEL_UP(self)
	playerLevel = UnitLevel("player")
	for k in pairs(recZones) do
		recZones[k] = nil
	end
	for k in pairs(recInstances) do
		recInstances[k] = nil
	end
	for k in pairs(cost) do
		cost[k] = nil
	end
	for zone in pairs(lows) do
		if not self:IsHostile(zone) then
			local low, high = self:GetLevel(zone)
			if types[zone] == "Zone" then
				if low <= playerLevel and playerLevel <= high then
					recZones[zone] = true
				end
			elseif types[zone] == "Battleground" then
				local playerLevel = playerLevel
				if zone == Z["Alterac Valley"] then
					playerLevel = playerLevel - 1
				end
				if playerLevel >= low and (playerLevel == MAX_PLAYER_LEVEL or math_mod(playerLevel, 10) >= 6) then
					recInstances[zone] = true
				end
			elseif types[zone] == "Instance" then
				if low <= playerLevel and playerLevel <= high then
					recInstances[zone] = true
				end
			end
		end
	end
end

function Tourist:GetLevel(zone)
	self:argCheck(zone, 2, "string")
	if types[zone] == "Battleground" then
		if zone == Z["Alterac Valley"] then
			if playerLevel <= 60 then
				return 51, 60
			else
				return 61, 70
			end
		elseif playerLevel >= MAX_PLAYER_LEVEL then
			return MAX_PLAYER_LEVEL, MAX_PLAYER_LEVEL
		elseif playerLevel >= 60 then
			return 60, 69
		elseif playerLevel >= 50 then
			return 50, 59
		elseif playerLevel >= 40 then
			return 40, 49
		elseif playerLevel >= 30 then
			return 30, 39
		elseif playerLevel >= 20 or zone == Z["Arathi Basin"] then
			return 20, 29
		else
			return 10, 19
		end
	end
	return lows[zone], highs[zone]
end

function Tourist:GetLevelColor(zone)
	self:argCheck(zone, 2, "string")
	if types[zone] == "Battleground" then
		if (playerLevel < 51 and zone == Z["Alterac Valley"]) or (playerLevel < 20 and zone == Z["Arathi Basin"]) or (playerLevel < 10 and zone == Z["Warsong Gulch"]) then
			return 1, 0, 0
		end
		local playerLevel = playerLevel
		if zone == Z["Alterac Valley"] then
			playerLevel = playerLevel - 1
		end
		if playerLevel == MAX_PLAYER_LEVEL then
			return 1, 1, 0
		end
		playerLevel = math_mod(playerLevel, 10)
		if playerLevel <= 5 then
			return 1, playerLevel / 10, 0
		elseif playerLevel <= 7 then
			return 1, (playerLevel - 3) / 4, 0
		else
			return (9 - playerLevel) / 2, 1, 0
		end
	end
	local low, high = lows[zone], highs[zone]
	
	if low <= 0 and high <= 0 then
		-- City
		return 1, 1, 1
	elseif playerLevel == low and playerLevel == high then
		return 1, 1, 0
	elseif playerLevel <= low - 3 then
		return 1, 0, 0
	elseif playerLevel <= low then
		return 1, (playerLevel - low - 3) / -6, 0
	elseif playerLevel <= (low + high) / 2 then
		return 1, (playerLevel - low) / (high - low) + 0.5, 0
	elseif playerLevel <= high then
		return 2 * (playerLevel - high) / (low - high), 1, 0
	elseif playerLevel <= high + 3 then
		local num = (playerLevel - high) / 6
		return num, 1 - num, num
	else
		return 0.5, 0.5, 0.5
	end
end

function Tourist:GetFactionColor(zone)
	self:argCheck(zone, 2, "string")
	if factions[zone] == (isHorde and "Alliance" or "Horde") then
		return 1, 0, 0
	elseif factions[zone] == (isHorde and "Horde" or "Alliance") then
		return 0, 1, 0
	else
		return 1, 1, 0
	end
end

local function retNil() return nil end
local function retOne(object, state)
	if state == object then
		return nil
	else
		return object
	end
end

local function retNormal(t, position)
	return (next(t, position))
end

function Tourist:IterateZoneInstances(zone)
	self:argCheck(zone, 2, "string")
	
	local inst = instances[zone]
	
	if not inst then
		return retNil
	elseif type(inst) == "table" then
		return retNormal, inst, nil
	else
		return retOne, inst, nil
	end
end

function Tourist:GetInstanceZone(instance)
	self:argCheck(instance, 2, "string")
	for k, v in pairs(instances) do
		if v then
			if type(v) == "string" then
				if v == instance then
					return k
				end
			else -- table
				for l in pairs(v) do
					if l == instance then
						return k
					end
				end
			end
		end
	end
end

function Tourist:DoesZoneHaveInstances(zone)
	self:argCheck(zone, 2, "string")
	return instances[zone] and true or false
end

local zonesInstances
local function initZonesInstances()
	if not zonesInstances then
		zonesInstances = {}
		for zone, v in pairs(lows) do
			if types[zone] ~= "Transport" then
				zonesInstances[zone] = true
			end
		end
	end
	initZonesInstances = nil
end

function Tourist:IterateZonesAndInstances()
	if initZonesInstances then
		initZonesInstances()
	end
	return retNormal, zonesInstances, nil
end

local function zoneIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and (types[k] == "Instance" or types[k] == "Battleground") do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateZones()
	if initZonesInstances then
		initZonesInstances()
	end
	return zoneIter, nil, nil
end

local function instanceIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and (types[k] ~= "Instance" or types[k] ~= "Battleground") do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateInstances()
	if initZonesInstances then
		initZonesInstances()
	end
	return instanceIter, nil, nil
end

local function bgIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and types[k] ~= "Battleground" do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateBattlegrounds()
	if initZonesInstances then
		initZonesInstances()
	end
	return bgIter, nil, nil
end

local function allianceIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and factions[k] ~= "Alliance" do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateAlliance()
	if initZonesInstances then
		initZonesInstances()
	end
	return allianceIter, nil, nil
end

local function hordeIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and factions[k] ~= "Horde" do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateHorde()
	if initZonesInstances then
		initZonesInstances()
	end
	return hordeIter, nil, nil
end

if isHorde then
	Tourist.IterateFriendly = Tourist.IterateHorde
	Tourist.IterateHostile = Tourist.IterateAlliance
else
	Tourist.IterateFriendly = Tourist.IterateAlliance
	Tourist.IterateHostile = Tourist.IterateHorde
end

local function contestedIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and factions[k] do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateContested()
	if initZonesInstances then
		initZonesInstances()
	end
	return contestedIter, nil, nil
end

local function kalimdorIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and continents[k] ~= Kalimdor do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateKalimdor()
	if initZonesInstances then
		initZonesInstances()
	end
	return kalimdorIter, nil, nil
end

local function easternKingdomsIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and continents[k] ~= Eastern_Kingdoms do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateEasternKingdoms()
	if initZonesInstances then
		initZonesInstances()
	end
	return easternKingdomsIter, nil, nil
end

local function outlandIter(_, position)
	local k = next(zonesInstances, position)
	while k ~= nil and continents[k] ~= Outland do
		k = next(zonesInstances, k)
	end
	return k
end
function Tourist:IterateOutland()
	if initZonesInstances then
		initZonesInstances()
	end
	return outlandIter, nil, nil
end

function Tourist:IterateRecommendedZones()
	return retNormal, recZones, nil
end

function Tourist:IterateRecommendedInstances()
	return retNormal, recInstances, nil
end

function Tourist:HasRecommendedInstances()
	return next(recInstances) ~= nil
end

function Tourist:IsInstance(zone)
	self:argCheck(zone, 2, "string")
	local t = types[zone]
	return t == "Instance" or t == "Battleground"
end

function Tourist:IsZone(zone)
	self:argCheck(zone, 2, "string")
	local t = types[zone]
	return t ~= "Instance" and t ~= "Battleground" and t ~= "Transport"
end

function Tourist:IsZoneOrInstance(zone)
	self:argCheck(zone, 2, "string")
	local t = types[zone]
	return t and t ~= "Transport"
end

function Tourist:IsBattleground(zone)
	self:argCheck(zone, 2, "string")
	local t = types[zone]
	return t == "Battleground"
end

function Tourist:IsAlliance(zone)
	self:argCheck(zone, 2, "string")
	return factions[zone] == "Alliance"
end

function Tourist:IsHorde(zone)
	self:argCheck(zone, 2, "string")
	return factions[zone] == "Horde"
end

if isHorde then
	Tourist.IsFriendly = Tourist.IsHorde
	Tourist.IsHostile = Tourist.IsAlliance
else
	Tourist.IsFriendly = Tourist.IsAlliance
	Tourist.IsHostile = Tourist.IsHorde
end

function Tourist:IsContested(zone)
	self:argCheck(zone, 2, "string")
	return not factions[zone]
end

function Tourist:GetContinent(zone)
	self:argCheck(zone, 2, "string")
	
	return continents[zone] or UNKNOWN
end

function Tourist:IsInKalimdor(zone)
	self:argCheck(zone, 2, "string")
	
	return continents[zone] == Kalimdor
end

function Tourist:IsInEasternKingdoms(zone)
	self:argCheck(zone, 2, "string")
	
	return continents[zone] == Eastern_Kingdoms
end

function Tourist:IsInOutland(zone)
	self:argCheck(zone, 2, "string")
	
	return continents[zone] == Outland
end

function Tourist:GetInstanceGroupSize(instance)
	self:argCheck(instance, 2, "string")
	
	return groupSizes[instance] or 0
end

local inf = 1/0
local stack = setmetatable({}, {__mode='k'})
local function iterator(S)
	local position = S['#'] - 1
	S['#'] = position
	local x = S[position]
	if not x then
		for k in pairs(S) do
			S[k] = nil
		end
		stack[S] = true
		return nil
	end
	return x
end

setmetatable(cost, {
	__index = function(self, vertex)
		local price = 1
		
		if lows[vertex] > playerLevel then
			price = price * (1 + math.ceil((lows[vertex] - playerLevel) / 6))
		end
		
		if factions[vertex] == (isHorde and "Horde" or "Alliance") then
			price = price / 2
		elseif factions[vertex] == (isHorde and "Alliance" or "Horde") then
			if types[vertex] == "City" then
				price = price * 10
			else
				price = price * 3
			end
		end
		
		if types[x] == "Transport" then
			price = price * 2
		end
		
		self[vertex] = price
		return price
	end
})

function Tourist:IteratePath(alpha, bravo)
	self:argCheck(alpha, 2, "string")
	self:argCheck(bravo, 3, "string")
	
	if paths[alpha] == nil or paths[bravo] == nil then
		return retNil
	end
	
	local d = next(stack) or {}
	stack[d] = nil
	local Q = next(stack) or {}
	stack[Q] = nil
	local S = next(stack) or {}
	stack[S] = nil
	local pi = next(stack) or {}
	stack[pi] = nil
	
	for vertex, v in pairs(paths) do
		d[vertex] = inf
		Q[vertex] = v
	end
	d[alpha] = 0
	
	while next(Q) do
		local u
		local min = inf
		for z in pairs(Q) do
			local value = d[z]
			if value < min then
				min = value
				u = z
			end
		end
		if min == inf then
			return retNil
		end
		Q[u] = nil
		if u == bravo then
			break
		end
		
		local adj = paths[u]
		if type(adj) == "table" then
			local d_u = d[u]
			for v in pairs(adj) do
				local c = d_u + cost[v]
				if d[v] > c then
					d[v] = c
					pi[v] = u
				end
			end
		elseif adj ~= false then
			local c = d[u] + cost[adj]
			if d[adj] > c then
				d[adj] = c
				pi[adj] = u
			end
		end
	end
	
	local i = 1
	local last = bravo
	while last do
		S[i] = last
		i = i + 1
		last = pi[last]
	end
	
	for k in pairs(pi) do
		pi[k] = nil
	end
	for k in pairs(Q) do
		Q[k] = nil
	end
	for k in pairs(d) do
		d[k] = nil
	end
	stack[pi] = true
	stack[Q] = true
	stack[d] = true
	
	S['#'] = i
	
	return iterator, S
end

function Tourist:IterateBorderZones(zone)
	self:argCheck(zone, 2, "string")
	local path = paths[zone]
	if not path then
		return retNil
	elseif type(path) == "table" then
		return retNormal, path
	else
		return retOne, path
	end
end

local function activate(self, oldLib, oldDeactivate)
	Tourist = self
	self.frame = oldLib and oldLib.frame or CreateFrame("Frame", "TouristLibFrame", UIParent)
	self.frame:UnregisterAllEvents()
	self.frame:RegisterEvent("PLAYER_LEVEL_UP")
	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.frame:SetScript("OnEvent", function()
		PLAYER_LEVEL_UP(self)
	end)
	
	local BOOTYBAY_RATCHET_BOAT = string.format(X_Y_BOAT, Z["Booty Bay"], Z["Ratchet"])
	local MENETHIL_THERAMORE_BOAT = string.format(X_Y_BOAT, Z["Menethil Harbor"], Z["Theramore Isle"])
	local MENETHIL_AUBERDINE_BOAT = string.format(X_Y_BOAT, Z["Menethil Harbor"], Z["Auberdine"])
	local AUBERDINE_DARNASSUS_BOAT = string.format(X_Y_BOAT, Z["Auberdine"], Z["Darnassus"])
	local ORGRIMMAR_UNDERCITY_ZEPPELIN = string.format(X_Y_ZEPPELIN, Z["Orgrimmar"], Z["Undercity"])
	local ORGRIMMAR_GROMGOL_ZEPPELIN = string.format(X_Y_ZEPPELIN, Z["Orgrimmar"], Z["Grom'gol Base Camp"])
	local UNDERCITY_GROMGOL_ZEPPELIN = string.format(X_Y_ZEPPELIN, Z["Undercity"], Z["Grom'gol Base Camp"])
	
	local zones = {}
	
	zones[AUBERDINE_DARNASSUS_BOAT] = {
		paths = {
			[Z["Darkshore"]] = true,
			[Z["Darnassus"]] = true,
		},
		faction = "Alliance",
		type = "Transport",
	}
	
	zones[BOOTYBAY_RATCHET_BOAT] = {
		paths = {
			[Z["Stranglethorn Vale"]] = true,
			[Z["The Barrens"]] = true,
		},
		type = "Transport",
	}
	
	zones[MENETHIL_AUBERDINE_BOAT] = {
		paths = {
			[Z["Wetlands"]] = true,
			[Z["Darkshore"]] = true,
		},
		faction = "Alliance",
		type = "Transport",
	}
	
	zones[MENETHIL_THERAMORE_BOAT] = {
		paths = {
			[Z["Wetlands"]] = true,
			[Z["Dustwallow Marsh"]] = true,
		},
		faction = "Alliance",
		type = "Transport",
	}
	
	zones[ORGRIMMAR_GROMGOL_ZEPPELIN] = {
		paths = {
			[Z["Durotar"]] = true,
			[Z["Stranglethorn Vale"]] = true,
		},
		faction = "Horde",
		type = "Transport",
	}
	
	zones[ORGRIMMAR_UNDERCITY_ZEPPELIN] = {
		paths = {
			[Z["Durotar"]] = true,
			[Z["Tirisfal Glades"]] = true,
		},
		faction = "Horde",
		type = "Transport",
	}
	
	zones[UNDERCITY_GROMGOL_ZEPPELIN] = {
		paths = {
			[Z["Stranglethorn Vale"]] = true,
			[Z["Tirisfal Glades"]] = true,
		},
		faction = "Horde",
		type = "Transport",
	}
	
	zones[Z["Alterac Valley"]] = {
		continent = Eastern_Kingdoms,
		paths = Z["Alterac Mountains"],
		groupSize = 40,
		type = "Battleground",
	}
	
	zones[Z["Arathi Basin"]] = {
		continent = Eastern_Kingdoms,
		paths = Z["Arathi Highlands"],
		groupSize = 15,
		type = "Battleground",
	}
	
	zones[Z["Warsong Gulch"]] = {
		continent = Kalimdor,
		paths = isHorde and Z["The Barrens"] or Z["Ashenvale"],
		groupSize = 10,
		type = "Battleground",
	}
	
	zones[Z["Deeprun Tram"]] = {
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Stormwind City"]] = true,
			[Z["Ironforge"]] = true,
		},
		faction = "Alliance",
	}
	
	zones[Z["Ironforge"]] = {
		continent = Eastern_Kingdoms,
		instances = Z["Gnomeregan"],
		paths = {
			[Z["Dun Morogh"]] = true,
			[Z["Deeprun Tram"]] = true,
		},
		faction = "Alliance",
		type = "City",
	}
	
	zones[Z["Stormwind City"]] = {
		continent = Eastern_Kingdoms,
		instances = Z["The Stockade"],
		paths = {
			[Z["Deeprun Tram"]] = true,
			[Z["The Stockade"]] = true,
			[Z["Elwynn Forest"]] = true,
		},
		faction = "Alliance",
		type = "City",
	}
	
	zones[Z["Undercity"]] = {
		continent = Eastern_Kingdoms,
		instances = Z["Scarlet Monastery"],
		paths = {
			[Z["Tirisfal Glades"]] = true,
		},
		faction = "Horde",
		type = "City",
	}
	
	zones[Z["Dun Morogh"]] = {
		low = 1,
		high = 10,
		continent = Eastern_Kingdoms,
		instances = Z["Gnomeregan"],
		paths = {
			[Z["Wetlands"]] = true,
			[Z["Gnomeregan"]] = true,
			[Z["Ironforge"]] = true,
			[Z["Loch Modan"]] = true,
		},
		faction = "Alliance",
	}
	
	zones[Z["Elwynn Forest"]] = {
		low = 1,
		high = 10,
		continent = Eastern_Kingdoms,
		instances = Z["The Stockade"],
		paths = {
			[Z["Westfall"]] = true,
			[Z["Redridge Mountains"]] = true,
			[Z["Stormwind City"]] = true,
			[Z["Duskwood"]] = true,
		},
		faction = "Alliance",
	}

	zones[Z["Tirisfal Glades"]] = {
		low = 1,
		high = 10,
		continent = Eastern_Kingdoms,
		instances = Z["Scarlet Monastery"],
		paths = {
			[Z["Western Plaguelands"]] = true,
			[Z["Undercity"]] = true,
			[Z["Scarlet Monastery"]] = true,
			[UNDERCITY_GROMGOL_ZEPPELIN] = true,
			[ORGRIMMAR_UNDERCITY_ZEPPELIN] = true,
			[Z["Silverpine Forest"]] = true,
		},
		faction = "Horde",
	}

	zones[Z["Loch Modan"]] = {
		low = 10,
		high = 20,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Wetlands"]] = true,
			[Z["Badlands"]] = true,
			[Z["Dun Morogh"]] = true,
			[Z["Searing Gorge"]] = not isHorde and true or nil,
		},
		faction = "Alliance",
	}
	
	zones[Z["Silverpine Forest"]] = {
		low = 10,
		high = 20,
		continent = Eastern_Kingdoms,
		instances = Z["Shadowfang Keep"],
		paths = {
			[Z["Tirisfal Glades"]] = true,
			[Z["Hillsbrad Foothills"]] = true,
			[Z["Shadowfang Keep"]] = true,
		},
		faction = "Horde",
	}
	
	zones[Z["Westfall"]] = {
		low = 10,
		high = 20,
		continent = Eastern_Kingdoms,
		instances = Z["The Deadmines"],
		paths = {
			[Z["Duskwood"]] = true,
			[Z["Elwynn Forest"]] = true,
			[Z["The Deadmines"]] = true,
		},
		faction = "Alliance",
	}
	
	zones[Z["Redridge Mountains"]] = {
		low = 15,
		high = 25,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Burning Steppes"]] = true,
			[Z["Elwynn Forest"]] = true,
			[Z["Duskwood"]] = true,
		},
	}
	
	zones[Z["Duskwood"]] = {
		low = 18,
		high = 30,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Redridge Mountains"]] = true,
			[Z["Stranglethorn Vale"]] = true,
			[Z["Westfall"]] = true,
			[Z["Deadwind Pass"]] = true,
			[Z["Elwynn Forest"]] = true,
		},
	}
	
	zones[Z["Hillsbrad Foothills"]] = {
		low = 20,
		high = 30,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Alterac Mountains"]] = true,
			[Z["The Hinterlands"]] = true,
			[Z["Arathi Highlands"]] = true,
			[Z["Silverpine Forest"]] = true,
		},
	}
	
	zones[Z["Wetlands"]] = {
		low = 20,
		high = 30,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Arathi Highlands"]] = true,
			[MENETHIL_AUBERDINE_BOAT] = true,
			[MENETHIL_THERAMORE_BOAT] = true,
			[Z["Dun Morogh"]] = true,
			[Z["Loch Modan"]] = true,
		},
	}
	
	zones[Z["Alterac Mountains"]] = {
		low = 30,
		high = 40,
		continent = Eastern_Kingdoms,
		instances = Z["Alterac Valley"],
		paths = {
			[Z["Western Plaguelands"]] = true,
			[Z["Alterac Valley"]] = true,
			[Z["Hillsbrad Foothills"]] = true,
		},
	}
	
	zones[Z["Arathi Highlands"]] = {
		low = 30,
		high = 40,
		continent = Eastern_Kingdoms,
		instances = Z["Arathi Basin"],
		paths = {
			[Z["Wetlands"]] = true,
			[Z["Hillsbrad Foothills"]] = true,
			[Z["Arathi Basin"]] = true,
		},
	}
	
	zones[Z["Stranglethorn Vale"]] = {
		low = 30,
		high = 45,
		continent = Eastern_Kingdoms,
		instances = Z["Zul'Gurub"],
		paths = {
			[Z["Zul'Gurub"]] = true,
			[BOOTYBAY_RATCHET_BOAT] = true,
			[Z["Duskwood"]] = true,
			[ORGRIMMAR_GROMGOL_ZEPPELIN] = true,
			[UNDERCITY_GROMGOL_ZEPPELIN] = true,
		},
	}
	
	zones[Z["Badlands"]] = {
		low = 35,
		high = 45,
		continent = Eastern_Kingdoms,
		instances = Z["Uldaman"],
		paths = {
			[Z["Uldaman"]] = true,
			[Z["Searing Gorge"]] = true,
			[Z["Loch Modan"]] = true,
		},
	}
	
	zones[Z["Swamp of Sorrows"]] = {
		low = 35,
		high = 45,
		continent = Eastern_Kingdoms,
		instances = Z["The Temple of Atal'Hakkar"],
		paths = {
			[Z["Blasted Lands"]] = true,
			[Z["Deadwind Pass"]] = true,
			[Z["The Temple of Atal'Hakkar"]] = true,
		},
	}
	
	zones[Z["The Hinterlands"]] = {
		low = 40,
		high = 50,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Hillsbrad Foothills"]] = true,
			[Z["Western Plaguelands"]] = true,
		},
	}
	
	zones[Z["Searing Gorge"]] = {
		low = 43,
		high = 50,
		continent = Eastern_Kingdoms,
		instances = {
			[Z["Blackrock Depths"]] = true,
			[Z["Blackwing Lair"]] = true,
			[Z["Molten Core"]] = true,
			[Z["Blackrock Spire"]] = true,
		},
		paths = {
			[Z["Blackrock Mountain"]] = true,
			[Z["Badlands"]] = true,
			[Z["Loch Modan"]] = not isHorde and true or nil,
		},
	}
	
	zones[Z["Blackrock Mountain"]] = {
		low = 42,
		high = 54,
		continent = Eastern_Kingdoms,
		instances = {
			[Z["Blackrock Depths"]] = true,
			[Z["Blackwing Lair"]] = true,
			[Z["Molten Core"]] = true,
			[Z["Blackrock Spire"]] = true,
		},
		paths = {
			[Z["Burning Steppes"]] = true,
			[Z["Blackwing Lair"]] = true,
			[Z["Molten Core"]] = true,
			[Z["Blackrock Depths"]] = true,
			[Z["Searing Gorge"]] = true,
			[Z["Blackrock Spire"]] = true,
		},
	}
	
	zones[Z["Deadwind Pass"]] = {
		low = 55,
		high = 60,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Duskwood"]] = true,
			[Z["Swamp of Sorrows"]] = true
		},
	}
	
	zones[Z["Blasted Lands"]] = {
		low = 45,
		high = 55,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Swamp of Sorrows"]] = true,
		},
	}
	
	zones[Z["Burning Steppes"]] = {
		low = 50,
		high = 58,
		continent = Eastern_Kingdoms,
		instances = {
			[Z["Blackrock Depths"]] = true,
			[Z["Blackwing Lair"]] = true,
			[Z["Molten Core"]] = true,
			[Z["Blackrock Spire"]] = true,
		},
		paths = {
			[Z["Blackrock Mountain"]] = true,
			[Z["Redridge Mountains"]] = true,
		},
	}
	
	zones[Z["Western Plaguelands"]] = {
		low = 51,
		high = 58,
		continent = Eastern_Kingdoms,
		instances = Z["Scholomance"],
		paths = {
			[Z["The Hinterlands"]] = true,
			[Z["Eastern Plaguelands"]] = true,
			[Z["Tirisfal Glades"]] = true,
			[Z["Scholomance"]] = true,
			[Z["Alterac Mountains"]] = true,
		},
	}
	
	zones[Z["Eastern Plaguelands"]] = {
		low = 53,
		high = 60,
		continent = Eastern_Kingdoms,
		instances = {
			[Z["Stratholme"]] = true,
			[Z["Naxxramas"]] = true,
		},
		paths = {
			[Z["Western Plaguelands"]] = true,
			[Z["Naxxramas"]] = true,
			[Z["Stratholme"]] = true,
		},
	}
	
	zones[Z["The Deadmines"]] = {
		low = isWestern and 17 or 15,
		high = isWestern and 26 or 20,
		continent = Eastern_Kingdoms,
		paths = Z["Westfall"],
		groupSize = 5,
		faction = "Alliance",
		type = "Instance",
	}
	
	zones[Z["Shadowfang Keep"]] = {
		low = isWestern and 22 or 18,
		high = isWestern and 30 or 25,
		continent = Eastern_Kingdoms,
		paths = Z["Silverpine Forest"],
		groupSize = 5,
		faction = "Horde",
		type = "Instance",
	}
	
	zones[Z["The Stockade"]] = {
		low = isWestern and 24 or 23,
		high = isWestern and 32 or 26,
		continent = Eastern_Kingdoms,
		paths = Z["Stormwind City"],
		groupSize = 5,
		faction = "Alliance",
		type = "Instance",
	}
	
	zones[Z["Gnomeregan"]] = {
		low = isWestern and 29 or 24,
		high = isWestern and 38 or 33,
		continent = Eastern_Kingdoms,
		paths = Z["Dun Morogh"],
		groupSize = 5,
		faction = "Alliance",
		type = "Instance",
	}
	
	zones[Z["Scarlet Monastery"]] = {
		low = isWestern and 34 or 30,
		high = isWestern and 45 or 40,
		continent = Eastern_Kingdoms,
		paths = Z["Tirisfal Glades"],
		groupSize = 5,
		faction = "Horde",
		type = "Instance",
	}
	
	zones[Z["Uldaman"]] = {
		low = isWestern and 41 or 35,
		high = isWestern and 51 or 45,
		continent = Eastern_Kingdoms,
		paths = Z["Badlands"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["The Temple of Atal'Hakkar"]] = {
		low = isWestern and 50 or 44,
		high = isWestern and 60 or 50,
		continent = Eastern_Kingdoms,
		paths = Z["Swamp of Sorrows"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Blackrock Depths"]] = {
		low = isWestern and 52 or 48,
		high = isWestern and 60 or 56,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Molten Core"]] = true,
			[Z["Blackrock Mountain"]] = true,
		},
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Blackrock Spire"]] = {
		low = isWestern and 55 or 53,
		high = 60,
		continent = Eastern_Kingdoms,
		paths = {
			[Z["Blackrock Mountain"]] = true,
			[Z["Blackwing Lair"]] = true,
		},
		groupSize = 10,
		type = "Instance",
	}
	
	zones[Z["Scholomance"]] = {
		low = 58,
		high = 60,
		continent = Eastern_Kingdoms,
		paths = Z["Western Plaguelands"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Stratholme"]] = {
		low = isWestern and 58 or 55,
		high = 60,
		continent = Eastern_Kingdoms,
		paths = Z["Eastern Plaguelands"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Blackwing Lair"]] = {
		low = 60,
		high = 62,
		continent = Eastern_Kingdoms,
		paths = Z["Blackrock Mountain"],
		groupSize = 40,
		type = "Instance",
	}
	
	zones[Z["Molten Core"]] = {
		low = 60,
		high = 62,
		continent = Eastern_Kingdoms,
		paths = Z["Blackrock Mountain"],
		groupSize = 40,
		type = "Instance",
	}
	
	zones[Z["Zul'Gurub"]] = {
		low = 60,
		high = 62,
		continent = Eastern_Kingdoms,
		paths = Z["Stranglethorn Vale"],
		groupSize = 20,
		type = "Instance",
	}
	
	zones[Z["Naxxramas"]] = {
		low = 60,
		high = 70,
		continent = Eastern_Kingdoms,
		groupSize = 40,
		type = "Instance",
	}
	
	zones[Z["Darnassus"]] = {
		continent = Kalimdor,
		paths = {
			[Z["Teldrassil"]] = true,
			[AUBERDINE_DARNASSUS_BOAT] = true,
		},
		faction = "Alliance",
		type = "City",
	}
	
	zones[Z["Hyjal"]] = {
		continent = Kalimdor,
	}
	
	zones[Z["Moonglade"]] = {
		continent = Kalimdor,
		paths = {
			[Z["Felwood"]] = true,
			[Z["Winterspring"]] = true,
		},
	}
	
	zones[Z["Orgrimmar"]] = {
		continent = Kalimdor,
		instances = Z["Ragefire Chasm"],
		paths = {
			[Z["Durotar"]] = true,
			[Z["Ragefire Chasm"]] = true,
		},
		faction = "Horde",
		type = "City",
	}
	
	zones[Z["Thunder Bluff"]] = {
		continent = Kalimdor,
		paths = Z["Mulgore"],
		faction = "Horde",
		type = "City",
	}
	
	zones[Z["Durotar"]] = {
		low = 1,
		high = 10,
		continent = Kalimdor,
		instances = Z["Ragefire Chasm"],
		paths = {
			[ORGRIMMAR_UNDERCITY_ZEPPELIN] = true,
			[ORGRIMMAR_GROMGOL_ZEPPELIN] = true,
			[Z["The Barrens"]] = true,
			[Z["Orgrimmar"]] = true,
		},
		faction = "Horde",
	}
	
	zones[Z["Mulgore"]] = {
		low = 1,
		high = 10,
		continent = Kalimdor,
		paths = {
			[Z["Thunder Bluff"]] = true,
			[Z["The Barrens"]] = true,
		},
		faction = "Horde",
	}
	
	zones[Z["Teldrassil"]] = {
		low = 1,
		high = 10,
		continent = Kalimdor,
		paths = Z["Darnassus"],
		faction = "Alliance",
	}
	
	zones[Z["Darkshore"]] = {
		low = 10,
		high = 20,
		continent = Kalimdor,
		paths = {
			[MENETHIL_AUBERDINE_BOAT] = true,
			[AUBERDINE_DARNASSUS_BOAT] = true,
			[Z["Ashenvale"]] = true,
		},
		faction = "Alliance",
	}
	
	zones[Z["The Barrens"]] = {
		low = 10,
		high = 25,
		continent = Kalimdor,
		instances = {
			[Z["Razorfen Kraul"]] = true,
			[Z["Wailing Caverns"]] = true,
			[Z["Razorfen Downs"]] = true,
			[Z["Warsong Gulch"]] = isHorde and true or nil,
		},
		paths = {
			[Z["Thousand Needles"]] = true,
			[Z["Razorfen Kraul"]] = true,
			[Z["Ashenvale"]] = true,
			[Z["Durotar"]] = true,
			[Z["Wailing Caverns"]] = true,
			[BOOTYBAY_RATCHET_BOAT] = true,
			[Z["Dustwallow Marsh"]] = true,
			[Z["Razorfen Downs"]] = true,
			[Z["Stonetalon Mountains"]] = true,
			[Z["Mulgore"]] = true,
			[Z["Warsong Gulch"]] = isHorde and true or nil,
		},
		faction = "Horde",
	}
	
	zones[Z["Stonetalon Mountains"]] = {
		low = 15,
		high = 27,
		continent = Kalimdor,
		paths = {
			[Z["Desolace"]] = true,
			[Z["The Barrens"]] = true,
			[Z["Ashenvale"]] = true,
		},
	}
	
	zones[Z["Ashenvale"]] = {
		low = 18,
		high = 30,
		continent = Kalimdor,
		instances = {
			[Z["Blackfathom Deeps"]] = true,
			[Z["Warsong Gulch"]] = not isHorde and true or nil,
		},
		paths = {
			[Z["Azshara"]] = true,
			[Z["The Barrens"]] = true,
			[Z["Blackfathom Deeps"]] = true,
			[Z["Warsong Gulch"]] = not isHorde and true or nil,
			[Z["Felwood"]] = true,
			[Z["Darkshore"]] = true,
			[Z["Stonetalon Mountains"]] = true,
		},
	}
	
	zones[Z["Thousand Needles"]] = {
		low = 25,
		high = 35,
		continent = Kalimdor,
		paths = {
			[Z["Feralas"]] = true,
			[Z["The Barrens"]] = true,
			[Z["Tanaris"]] = true,
		},
	}
	
	zones[Z["Desolace"]] = {
		low = 30,
		high = 40,
		continent = Kalimdor,
		instances = Z["Maraudon"],
		paths = {
			[Z["Feralas"]] = true,
			[Z["Stonetalon Mountains"]] = true,
			[Z["Maraudon"]] = true,
		},
	}
	
	zones[Z["Dustwallow Marsh"]] = {
		low = 35,
		high = 45,
		continent = Kalimdor,
		instances = Z["Onyxia's Lair"],
		paths = {
			[Z["Onyxia's Lair"]] = true,
			[Z["The Barrens"]] = true,
			[MENETHIL_THERAMORE_BOAT] = true,
		},
	}
	
	zones[Z["Feralas"]] = {
		low = 40,
		high = 50,
		continent = Kalimdor,
		instances = Z["Dire Maul"],
		paths = {
			[Z["Thousand Needles"]] = true,
			[Z["Desolace"]] = true,
			[Z["Dire Maul"]] = true,
		},
	}
	
	zones[Z["Tanaris"]] = {
		low = 40,
		high = 50,
		continent = Kalimdor,
		instances = {
			[Z["Zul'Farrak"]] = true,
		},
		paths = {
			[Z["Thousand Needles"]] = true,
			[Z["Un'Goro Crater"]] = true,
			[Z["Zul'Farrak"]] = true,
		},
	}
	
	zones[Z["Azshara"]] = {
		low = 45,
		high = 55,
		continent = Kalimdor,
		paths = Z["Ashenvale"],
	}
	
	zones[Z["Felwood"]] = {
		low = 48,
		high = 55,
		continent = Kalimdor,
		paths = {
			[Z["Winterspring"]] = true,
			[Z["Moonglade"]] = true,
			[Z["Ashenvale"]] = true,
		},
	}
	
	zones[Z["Un'Goro Crater"]] = {
		low = 48,
		high = 55,
		continent = Kalimdor,
		paths = {
			[Z["Silithus"]] = true,
			[Z["Tanaris"]] = true,
		},
	}
	
	zones[Z["Silithus"]] = {
		low = 55,
		high = 60,
		continent = Kalimdor,
		instances = {
			[Z["Ahn'Qiraj"]] = true,
			[Z["Ruins of Ahn'Qiraj"]] = true,
		},
		paths = {
			[Z["Ruins of Ahn'Qiraj"]] = true,
			[Z["Un'Goro Crater"]] = true,
			[Z["Ahn'Qiraj"]] = true,
		},
	}
	
	zones[Z["Winterspring"]] = {
		low = 55,
		high = 60,
		continent = Kalimdor,
		paths = {
			[Z["Felwood"]] = true,
			[Z["Moonglade"]] = true,
		},
	}
	
	zones[Z["Ragefire Chasm"]] = {
		low = 13,
		high = isWestern and 18 or 15,
		continent = Kalimdor,
		paths = Z["Orgrimmar"],
		groupSize = 5,
		faction = "Horde",
		type = "Instance",
	}
	
	zones[Z["Wailing Caverns"]] = {
		low = isWestern and 17 or 15,
		high = isWestern and 24 or 21,
		continent = Kalimdor,
		paths = Z["The Barrens"],
		groupSize = 5,
		faction = "Horde",
		type = "Instance",
	}
	
	zones[Z["Blackfathom Deeps"]] = {
		low = isWestern and 24 or 20,
		high = isWestern and 32 or 27,
		continent = Kalimdor,
		paths = Z["Ashenvale"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Razorfen Kraul"]] = {
		low = isWestern and 29 or 25,
		high = isWestern and 38 or 35,
		continent = Kalimdor,
		paths = Z["The Barrens"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Razorfen Downs"]] = {
		low = isWestern and 37 or 35,
		high = isWestern and 46 or 40,
		continent = Kalimdor,
		paths = Z["The Barrens"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Zul'Farrak"]] = {
		low = isWestern and 44 or 43,
		high = isWestern and 54 or 47,
		continent = Kalimdor,
		paths = Z["Tanaris"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Maraudon"]] = {
		low = isWestern and 46 or 40,
		high = isWestern and 55 or 49,
		continent = Kalimdor,
		paths = Z["Desolace"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Dire Maul"]] = {
		low = 56,
		high = 60,
		continent = Kalimdor,
		paths = Z["Feralas"],
		groupSize = 5,
		type = "Instance",
	}
	
	zones[Z["Onyxia's Lair"]] = {
		low = 60,
		high = 62,
		continent = Kalimdor,
		paths = Z["Dustwallow Marsh"],
		groupSize = 40,
		type = "Instance",
	}
	
	zones[Z["Ahn'Qiraj"]] = {
		low = 60,
		high = 65,
		continent = Kalimdor,
		paths = Z["Silithus"],
		groupSize = 40,
		type = "Instance",
	}
	
	zones[Z["Ruins of Ahn'Qiraj"]] = {
		low = 60,
		high = 65,
		continent = Kalimdor,
		paths = Z["Silithus"],
		groupSize = 20,
		type = "Instance",
	}
	
	for k,v in pairs(zones) do
		lows[k] = v.low or 0
		highs[k] = v.high or 0
		continents[k] = v.continent or UNKNOWN
		instances[k] = v.instances
		paths[k] = v.paths or false
		types[k] = v.type or "Zone"
		groupSizes[k] = v.groupSize
		factions[k] = v.faction
	end
	
	PLAYER_LEVEL_UP(self)
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function external(self, major, instance)
	if major == "AceConsole-2.0" then
		local print = print
		if DEFAULT_CHAT_FRAME then
			function print(text)
				DEFAULT_CHAT_FRAME:AddMessage(text)
			end
		end
		local t = {
			name = MAJOR_VERSION .. "." .. string.gsub(MINOR_VERSION, ".-(%d+).*", "%1"),
			desc = "A library to provide information about zones and instances.",
			type = "group",
			args = {
				zone = {
					name = "Zone",
					desc = "Get information about a zone",
					type = "text",
					usage = "<zone name>",
					get = false,
					set = function(text)
						local type
						if self:IsBattleground(text) then
							type = "Battleground"
						elseif self:IsInstance(text) then
							type = "Instance"
						else
							type = "Zone"
						end
						local faction
						if self:IsAlliance(text) then
							faction = "Alliance"
						elseif self:IsHorde(text) then
							faction = "Horde"
						else
							faction = "Contested"
						end
						if self:IsHostile(text) then
							faction = faction .. " (hostile)"
						elseif self:IsFriendly(text) then
							faction = faction .. " (friendly)"
						end
						local low, high = self:GetLevel(text)
						print("|cffffff7f" .. text .. "|r")
						print("  |cffffff7fType: [|r" .. type .. "|cffffff7f]|r")
						print("  |cffffff7fFaction: [|r" .. faction .. "|cffffff7f]|r")
						if low > 0 and high > 0 then
							if low == high then
								print("  |cffffff7fLevel: [|r" .. low .. "|cffffff7f]|r")
							else
								print("  |cffffff7fLevels: [|r" .. low .. "-" .. high .. "|cffffff7f]|r")
							end
						end
						print("  |cffffff7fContinent: [|r" .. self:GetContinent(text) .. "|cffffff7f]|r")
						local groupSize = self:GetInstanceGroupSize(text)
						if groupSize > 0 then
							print("  |cffffff7fGroup size: [|r" .. groupSize .. "|cffffff7f]|r")
						end
						if self:DoesZoneHaveInstances(text) then
							print("  |cffffff7fInstances:|r")
							for instance in self:IterateZoneInstances(text) do
								local isBG = self:IsBattleground(instance) and " (BG)" or ""
								local low, high = self:GetLevel(instance)
								local faction = ""
								if self:IsAlliance(instance) then
									faction = " - Alliance"
								elseif self:IsHorde(instance) then
									faction = " - Horde"
								end
								if self:IsHostile(instance) then
									faction = faction .. " (hostile)"
								elseif self:IsFriendly(instance) then
									faction = faction .. " (friendly)"
								end
								print("    " .. instance .. isBG .. " - " .. low .. "-" .. high .. faction)
							end
						end
					end,
					validate = {}
				},
				path = {
					name = "Shortest path to destination",
					desc = "Prints the fastest route from your current location to the destination.",
					type = "text",
					get = false,
					set = function(destination)
						if not Z:HasTranslation(destination) or not Z:HasReverseTranslation(destination) then return end
						local current = GetRealZoneText()
						print(string.format("|cffffff7fPath from %s to %s:|r", current, destination))
						for zone in self:IteratePath(current, destination) do
							local text
							if self:IsHostile(zone) then
								text = "    |cffff0000" .. zone .. "|r"
							elseif self:IsFriendly(zone) then
								text = "    |cff00ff00" .. zone .. "|r"
							else
								text = "    |cffffff00" .. zone .. "|r"
							end
							
							local low, high = self:GetLevel(zone)
							if low > 0 then
								local r, g, b = self:GetLevelColor(zone)
								if low == high then
									text = text .. string.format(" (|cff%02x%02x%02x%d|r)", r * 255, g * 255, b * 255, low)
								else
									text = text .. string.format(" (|cff%02x%02x%02x%d-%d|r)", r * 255, g * 255, b * 255, low, high)
								end
							end
							
							if zone == destination then
								print(text)
							else
								print(text .. " ->")
							end
						end
					end
				},
				recommend = {
					name = "Recommended Zones",
					desc = "List recommended zones",
					type = "execute",
					func = function()
						print("|cffffff7fRecommended zones:|r")
						for zone in self:IterateRecommendedZones() do
							local low, high = self:GetLevel(zone)
							local faction = ""
							if self:IsAlliance(zone) then
								faction = " - Alliance"
							elseif self:IsHorde(zone) then
								faction = " - Horde"
							end
							if self:IsHostile(zone) then
								faction = faction .. " (hostile)"
							elseif self:IsFriendly(zone) then
								faction = faction .. " (friendly)"
							end
							print("  |cffffff7f" .. zone .. "|r - " .. low .. "-" .. high .. faction)
						end
						if self:HasRecommendedInstances() then
							print("|cffffff7fRecomended instances:|r")
							for instance in self:IterateRecommendedInstances() do
								local isBG = self:IsBattleground(instance) and " (BG)" or ""
								local low, high = self:GetLevel(instance)
								local faction = ""
								if self:IsAlliance(instance) then
									faction = " - Alliance"
								elseif self:IsHorde(instance) then
									faction = " - Horde"
								end
								if self:IsHostile(instance) then
									faction = faction .. " (hostile)"
								elseif self:IsFriendly(instance) then
									faction = faction .. " (friendly)"
								end
								print("  |cffffff7f" .. instance .. "|r" .. isBG .. " - " .. low .. "-" .. high .. faction)
							end
						end
					end
				}
			}
		}
		for zone in self:IterateZonesAndInstances() do
			t.args.zone.validate[zone] = zone
		end
		t.args.path.validate = t.args.zone.validate
		instance.RegisterChatCommand(self, { "/tourist", "/touristLib" }, t, "TOURIST")
	end
end

AceLibrary:Register(Tourist, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)