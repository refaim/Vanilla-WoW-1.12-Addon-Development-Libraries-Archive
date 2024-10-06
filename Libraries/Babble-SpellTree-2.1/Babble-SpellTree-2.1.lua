--[[
Name: Babble-SpellTree-2.1
Revision: $Rev: 10836 $
Author(s): eternally777 (eternally777@gmail.com)
Based On: BabbleLib-2.0 by ckknight
Website: http://www.wowace.com/index.php/Babble-SpellTree-2.1
Documentation: http://www.wowace.com/index.php/Babble-SpellTree-2.1
SVN: http://svn.wowace.com/root/trunk/BabbleLib/BabbleLib-2.1/Babble-SpellTree-2.1
Description: A library to provide localizations for spell and talent trees.
Dependencies: AceLibrary, AceLocale-2.1
]]

local MAJOR_VERSION = "Babble-SpellTree-2.1"
local MINOR_VERSION = tonumber(string.sub("$Revision: 10836 $", 12, -3))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:HasInstance("AceLocale-2.1") then error(MAJOR_VERSION .. " requires AceLocale-2.1") end

local AceLocale = AceLibrary("AceLocale-2.1")

if AceLocale:HasInstance(MAJOR_VERSION) then
    BabbleSpellTree = AceLocale:GetInstance(MAJOR_VERSION)
    if not BabbleSpellTree:NeedsUpgrade(MINOR_VERSION) then return end
    BabbleSpellTree:ClearLocales()
end

AceLocale:RegisterTranslation(MAJOR_VERSION, "enUS", function()
	return {
		-- Druid
		["Balance"] = "Balance",
		["Feral Combat"] = "Feral Combat",
		["Restoration"] = "Restoration",
		-- Hunter
		["Beast Mastery"] = "Beast Mastery",
		["Marksmanship"] = "Marksmanship",
		["Survival"] = "Survival",
		-- Mage
		["Arcane"] = "Arcane",
		["Fire"] = "Fire",
		["Frost"] = "Frost",
		-- Paladin
		["Holy"] = "Holy",
		["Protection"] = "Protection",
		["Retribution"] = "Retribution",
		-- Priest
		["Discipline"] = "Discipline",
		["Holy"] = "Holy", -- same as Paladin
		["Shadow"] = "Shadow",
		-- Rogue
		["Assassination"] = "Assassination",
		["Combat"] = "Combat",
		["Subtlety"] = "Subtlety",
		-- Shaman
		["Elemental"] = "Elemental",
		["Enhancement"] = "Enhancement",
		["Restoration"] = "Restoration", -- same as Druid
		-- Warrior
		["Arms"] = "Arms",
		["Fury"] = "Fury",
		["Protection"] = "Protection", -- same as Paladin
		-- Warlock
		["Affliction"] = "Affliction",
		["Demonology"] = "Demonology",
		["Destruction"] = "Destruction",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "deDE", function()
	return {
		-- Druid
		["Balance"] = "Gleichgewicht",
		["Feral Combat"] = "Wilder Kampf",
		["Restoration"] = "Wiederherstellung",
		-- Hunter
		["Beast Mastery"] = "Tierherrschaft",
		["Marksmanship"] = "Treffsicherheit",
		["Survival"] = "Überleben",
		-- Mage
		["Arcane"] = "Arcan",
		["Fire"] = "Feuer",
		["Frost"] = "Frost",
		-- Paladin
		["Holy"] = "Heilig",
		["Protection"] = "Schutz",
		["Retribution"] = "Vergeltung",
		-- Priest
		["Discipline"] = "Disziplin",
		["Holy"] = "Heilig", -- same as Paladin
		["Shadow"] = "Schatten",
		-- Rogue
		["Assassination"] = "Meucheln",
		["Combat"] = "Kampf",
		["Subtlety"] = "Täuschung",
		-- Shaman
		["Elemental"] = "Elementar",
		["Enhancement"] = "Verstärkung",
		["Restoration"] = "Wiederherstellung", -- same as Druid
		-- Warrior
		["Arms"] = "Waffen",
		["Fury"] = "Furor",
		["Protection"] = "Schutz", -- same as Paladin
		-- Warlock
		["Affliction"] = "Gebrechen",
		["Demonology"] = "Dämonologie",
		["Destruction"] = "Zerstörung",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "frFR", function()
	return {
		-- Druid
		["Balance"] = "Equilibre",
		["Feral Combat"] = "Combat sauvage",
		["Restoration"] = "Restauration",
		-- Hunter
		["Beast Mastery"] = "Maîtrise des bêtes",
		["Marksmanship"] = "Précision",
		["Survival"] = "Survie",
		-- Mage
		["Arcane"] = "Arcanes",
		["Fire"] = "Feu",
		["Frost"] = "Givre",
		-- Paladin
		["Holy"] = "Sacré",
		["Protection"] = "Protection",
		["Retribution"] = "Vindicte",
		-- Priest
		["Discipline"] = "Discipline",
		["Holy"] = "Sacré", -- same as Paladin
		["Shadow"] = "Ombre",
		-- Rogue
		["Assassination"] = "Assassinat",
		["Combat"] = "Combat",
		["Subtlety"] = "Finesse",
		-- Shaman
		["Elemental"] = "Élémentaire",
		["Enhancement"] = "Amélioration",
		["Restoration"] = "Restauration", -- same as Druid
		-- Warrior
		["Arms"] = "Armes",
		["Fury"] = "Fureur",
		["Protection"] = "Protection", -- same as Paladin
		-- Warlock
		["Affliction"] = "Affliction",
		["Demonology"] = "Démonologie",
		["Destruction"] = "Destruction",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "koKR", function()
	return {		
		-- Druid
		["Balance"] = "조화",
		["Feral Combat"] = "야성",
		["Restoration"] = "회복",
		-- Hunter
		["Beast Mastery"] = "야수",
		["Marksmanship"] = "사격",
		["Survival"] = "생존",
		-- Mage
		["Arcane"] = "비전",
		["Fire"] = "화염",
		["Frost"] = "냉기",
		-- Paladin
		["Holy"] = "신성",
		["Protection"] = "보호",
		["Retribution"] = "징벌",
		-- Priest
		["Discipline"] = "수양",
		["Holy"] = "신성", -- same as Paladin
		["Shadow"] = "암흑",
		-- Rogue
		["Assassination"] = "암살",
		["Combat"] = "전투",
		["Subtlety"] = "잠행",
		-- Shaman
		["Elemental"] = "정기",
		["Enhancement"] = "고양",
		["Restoration"] = "복원", -- not same as Druid in Korean locale
		-- Warrior
		["Arms"] = "무기",
		["Fury"] = "분노",
		["Protection"] = "방어", -- not same as Paladin in Korean locale
		-- Warlock
		["Affliction"] = "고통",
		["Demonology"] = "악마",
		["Destruction"] = "파괴",
	}
end)

AceLocale:RegisterTranslation(MAJOR_VERSION, "zhCN", function()
	return {
		-- Druid
		["Balance"] = "平衡",
		["Feral Combat"] = "野性战斗",
		["Restoration"] = "恢复",
		-- Hunter
		["Beast Mastery"] = "野兽掌握",
		["Marksmanship"] = "射击",
		["Survival"] = "生存",
		-- Mage
		["Arcane"] = "奥术",
		["Fire"] = "火焰",
		["Frost"] = "冰霜",
		-- Paladin
		["Holy"] = "神圣",
		["Protection"] = "防护",
		["Retribution"] = "惩戒",
		-- Priest
		["Discipline"] = "戒律",
		["Holy"] = "神圣", -- same as Paladin
		["Shadow"] = "暗影",
		-- Rogue
		["Assassination"] = "刺杀",
		["Combat"] = "战斗",
		["Subtlety"] = "敏锐",
		-- Shaman
		["Elemental"] = "元素战斗",
		["Enhancement"] = "增强",
		["Restoration"] = "恢复", -- same as Druid
		-- Warrior
		["Arms"] = "武器",
		["Fury"] = "狂怒",
		["Protection"] = "防护", -- same as Paladin
		-- Warlock
		["Affliction"] = "痛苦",
		["Demonology"] = "恶魔学识",
		["Destruction"] = "毁灭",
	}
end)

BabbleSpellTree = AceLocale:GetInstance(MAJOR_VERSION, true)
BabbleSpellTree:SetStrictness(true)

function BabbleSpellTree:NeedsUpgrade(revision)
    if tonumber(revision) > tonumber(MINOR_VERSION) then return true else return false end
end