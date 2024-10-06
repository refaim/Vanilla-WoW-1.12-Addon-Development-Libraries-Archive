--[[
Name: Babble-Race-2.1
Revision: $Rev: 13630 $
Author(s): eternally777 (eternally777@gmail.com)
Based On: BabbleLib-2.0 by ckknight
Website: http://www.wowace.com/index.php/Babble-Race-2.1
Documentation: http://www.wowace.com/index.php/Babble-Race-2.1
SVN: http://svn.wowace.com/root/trunk/BabbleLib/BabbleLib-2.1/Babble-Race-2.1
Description: A library to provide localizations for races.
Dependencies: AceLibrary, AceLocale-2.1
]]

local MAJOR_VERSION = "Babble-Race-2.1"
local MINOR_VERSION = tonumber(string.sub("$Revision: 13630 $", 12, -3))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:HasInstance("AceLocale-2.1") then error(MAJOR_VERSION .. " requires AceLocale-2.1") end

local AceLocale = AceLibrary("AceLocale-2.1")

if AceLocale:HasInstance(MAJOR_VERSION) then
    BabbleRace = AceLocale:GetInstance(MAJOR_VERSION)
    if not BabbleRace:NeedsUpgrade(MINOR_VERSION) then return end
    BabbleRace:ClearLocales()
end

AceLocale:RegisterTranslation(MAJOR_VERSION, "enUS", function()
	return {
		["Human"] = "Human",
		["Night elf"] = "Night elf",
		["Dwarf"] = "Dwarf",
		["Gnome"] = "Gnome",
		
		["Orc"] = "Orc",
		["Tauren"] = "Tauren",
		["Troll"] = "Troll",
		["Undead"] = "Undead",
		
		["Humans"] = "Humans",
		["Night elves"] = "Night elves",
		["Dwarves"] = "Dwarves",
		["Gnomes"] = "Gnomes",
		
		["Orcs"] = "Orcs",
		["Tauren_PL"] = "Tauren",
		["Trolls"] = "Trolls",
		["Undead_PL"] = "Undead",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "deDE", function()
	return {
		["Human"] = "Mensch",
		["Night elf"] = "Nachtelf",
		["Dwarf"] = "Zwerg",
		["Gnome"] = "Gnom",
		
		["Orc"] = "Orc",
		["Tauren"] = "Tauren",
		["Troll"] = "Troll",
		["Undead"] = "Untoter",
		
		["Humans"] = "Menschen",
		["Night elves"] = "Nachtelfen",
		["Dwarves"] = "Zwerge",
		["Gnomes"] = "Gnome",
		
		["Orcs"] = "Orcs",
		["Tauren_PL"] = "Tauren",
		["Trolls"] = "Trolle",
		["Undead_PL"] = "Untote",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "frFR", function()
	return {
		["Human"] = "Humain",
		["Night elf"] = "Elfe de la nuit",
		["Dwarf"] = "Nain",
		["Gnome"] = "Gnome",
		
		["Orc"] = "Orc",
		["Tauren"] = "Tauren",
		["Troll"] = "Troll",
		["Undead"] = "Mort-vivant",
		
		["Humans"] = "Humains",
		["Night elves"] = "Elfes de la nuit",
		["Dwarves"] = "Nains",
		["Gnomes"] = "Gnomes",
		
		["Orcs"] = "Orcs",
		["Tauren_PL"] = "Taurens",
		["Trolls"] = "Trolls",
		["Undead_PL"] = "Morts-vivants",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "koKR", function()
	return {	
		["Human"] = "인간",
		["Night elf"] = "나이트 엘프",
		["Dwarf"] = "드워프",
		["Gnome"] = "노움",
		
		["Orc"] = "오크",
		["Tauren"] = "타우렌",
		["Troll"] = "트롤",
		["Undead"] = "언데드", 
				
		["Humans"] = "인간",
		["Night elves"] = "나이트 엘프",
		["Dwarves"] = "드워프",
		["Gnomes"] = "노움",
		
		["Orcs"] = "오크",
		["Tauren_PL"] = "타우렌",
		["Trolls"] = "트롤",
		["Undead_PL"] = "언데드",		
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "zhCN", function()
	return {	
		["Human"] = "人类",
		["Night elf"] = "暗夜精灵",
		["Dwarf"] = "矮人",
		["Gnome"] = "侏儒",
		
		["Orc"] = "兽人",
		["Tauren"] = "牛头人",
		["Troll"] = "巨魔",
		["Undead"] = "亡灵", 
				
		["Humans"] = "人类",
		["Night elves"] = "暗夜精灵",
		["Dwarves"] = "矮人",
		["Gnomes"] = "侏儒",
		
		["Orcs"] = "兽人",
		["Tauren_PL"] = "牛头人",
		["Trolls"] = "巨魔",
		["Undead_PL"] = "亡灵",		
	}
end)

BabbleRace = AceLocale:GetInstance(MAJOR_VERSION, true)
BabbleRace:SetStrictness(true)

function BabbleRace:NeedsUpgrade(revision)
    if tonumber(revision) > tonumber(MINOR_VERSION) then return true else return false end
end