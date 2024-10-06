local MAJOR_VERSION = "ItemBonusLib-1.0"
local MINOR_VERSION = "$Revision: 19761 $"

if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end
if not AceLibrary:HasInstance("Gratuity-2.0") then error(MAJOR_VERSION .. " requires Gratuity-2.0") end
if not AceLibrary:HasInstance("Deformat-2.0") then error(MAJOR_VERSION .. " requires Deformat-2.0") end

local DEBUG = false

local GetBonus, GetFriendlyBonus
do
  local CombatRatingMap = {
    CR_WEAPON = 2.5,
    CR_WEAPON_DAGGER = 2.5,
    CR_WEAPON_SWORD = 2.5,
    CR_WEAPON_SWORD_2H = 2.5,
    CR_WEAPON_AXE = 2.5,
    CR_WEAPON_MACE = 2.5,

    CR_DEFENSE = 1.5,
    CR_DODGE = 12,
    CR_PARRY = 20,
    CR_BLOCK = 5,
    CR_HIT = 10,
    CR_CRIT = 14,
    CR_HASTE = 10,
    CR_SPELLHIT = 8,
    CR_SPELLCRIT = 14,
    CR_SPELLHASTE = 10,
    CR_RESILIENCE = 25
  }

  local BonusRatingMap = {
    DEFENSE = "CR_DEFENSE",
    DODGE = "CR_DODGE",
    PARRY = "CR_PARRY",
    TOHIT = "CR_HIT",
    CRIT = "CR_CRIT",
    SPELLTOHIT = "CR_SPELLHIT",
    SPELLCRIT = "CR_SPELLCRIT",
  }

  local InverseBonusRatingMap = { }
  for k, v in pairs(BonusRatingMap) do
    InverseBonusRatingMap[v] = k
  end

  --[[
	The following calculations are based on Whitetooth's calculations:
	http://www.wowinterface.com/downloads/info5819-Rating_Buster.html
	]]
  local function GetRatingMultiplier(level)
    level = level or UnitLevel("player")
    if level < 9 then
      return 52
    elseif level <= 60 then
      return 52 /(level - 8)
    elseif level <= 70 then
      -- return 1 - (level - 60) * 3 / 82
      return 3.1951219512195124 - 0.036585365853658534 * level
    end
  end

  local function GetRatingBonus(type, value, level)
    local F = CombatRatingMap[type]
    if not F then
      return nil
    end
    return value / F * GetRatingMultiplier(level)
  end

  function GetBonus(type, map, level)
    local value = map[type]
    if not value then
      local rating = BonusRatingMap[type]
      if rating then
        value = map[rating]
        if value then
          value = GetRatingBonus(rating, value, level)
        end
      end
    end
    return value or 0
  end

  function GetFriendlyBonus(type, map, level)
    local rev = InverseBonusRatingMap[type]
    if not rev then
      return type, map[type]
    end
    return rev, GetRatingBonus(type, map[type], level)
  end
end

local ItemBonusLib = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDebug-2.0")
ItemBonusLib:SetDebugging(DEBUG)

local Gratuity = AceLibrary("Gratuity-2.0")
local Deformat = AceLibrary("Deformat-2.0")

local CHAT_COMMANDS = { "/ibonus" }
local ABOUT_ADDON = "An addon to get information about bonus from equipped items"
local SHOW_CMD = "show"
local SHOW_ABOUT = "Show all bonuses from the current equipment"
local SHOW_INFO = "Current equipment bonuses:"
local DETAILS_CMD = "details"
local DETAILS_ABOUT = "Shows bonuses with slot distribution"
local DETAILS_INFO = "Current equipment bonus details:"
local ITEM_CMD = "item"
local ITEM_ABOUT = "show bonuses of given itemlink"
local ITEM_USAGE = "<itemlink>"
local ITEM_INFO = "Bonuses for %s:"
local ITEM_SET = "Item is part of set [%s]"
local SET_BONUS = " %sBonus for %d pieces :"
local SLOT_CMD = "slot"
local SLOT_ABOUT = "show bonuses of given slot"
local SLOT_USAGE = "<slotname>"
local SLOT_INFO = "Bonuses of slot %s:"
local INSPECT_CMD = "inspect"
local INSPECT_ABOUT = "show bonuses of the equipment of the given unit (must be able to inspect the unit)"
local INSPECT_USAGE = "<unit>"
local INSPECT_ERROR = "Unable to inspect unit \"%s\""
local INSPECT_INFO = "Bonuses of \"%s\":"
local L
do
  local locale = GetLocale()
  if locale == "frFR" then
    -- CHAT_COMMANDS = { "/ibonus" }
    ABOUT_ADDON = "Un addon pour obtenir les bonus concernant les items équipés"
    -- SHOW_CMD = "show"
    SHOW_ABOUT = "Afficher tous les bonus de l'équipement actuel"
    SHOW_INFO = "Bonus de l'équipement actuel :"
    -- DETAILS_CMD = "details"
    DETAILS_ABOUT = "Afficher les détails des bonus par emplacement d'inventaire"
    DETAILS_INFO = "Détails des bonus de l'équipement :"
    -- ITEM_CMD = "item"
    ITEM_ABOUT = "Afficher les bonus détectés sur l'objet donnée"
    -- ITEM_USAGE = "<itemlink>"
    ITEM_INFO = "Bonus de %s :"
    ITEM_SET = "L'objet fait partie du set [%s]"
    SET_BONUS = " %sBonus pour %d pièces :"
    -- SLOT_CMD = "slot"
    SLOT_ABOUT = "Afficher les bonus de l'emplacement spécifié"
    SLOT_USAGE = "<emplacement>"
    SLOT_INFO = "Bonus de l'emplacement %s:"
    -- INSPECT_CMD = "inspect"
    INSPECT_ABOUT = "Afficher les bonus de l'équipement de l'unité donnée (vous devez être en mesure d'inspecter l'unité"
    INSPECT_USAGE = "<unité>"
    INSPECT_ERROR = "Impossible d'inspecter l'unité \"%s\""
    INSPECT_INFO = "Bonus de \"%s\" :"
  elseif locale == "deDE" then
    -- CHAT_COMMANDS = { "/ibonus" }
    -- ABOUT_ADDON = "An addon to get information about bonus from equipped items"
    -- SHOW_CMD = "show"
    -- SHOW_ABOUT = "Show all bonuses from the current equipment"
    -- SHOW_INFO = "Current equipment bonuses:"
    -- DETAILS_CMD = "details"
    -- DETAILS_ABOUT = "Shows bonuses with slot distribution"
    -- DETAILS_INFO = "Current equipment bonus details:"
    -- ITEM_CMD = "item"
    -- ITEM_ABOUT = "show bonuses of given itemlink"
    -- ITEM_USAGE = "<itemlink>"
    -- ITEM_INFO = "Bonuses for %s:"
    -- ITEM_SET = "Item is part of set [%s]"
    -- SET_BONUS = " %sBonus for %d pieces :"
    -- SLOT_CMD = "slot"
    -- SLOT_ABOUT = "show bonuses of given slot"
    -- SLOT_USAGE = "<slotname>"
    -- SLOT_INFO = "Bonuses of slot %s:"
    -- INSPECT_CMD = "inspect"
    -- INSPECT_ABOUT = "show bonuses of the equipment of the given unit (must be able to inspect the unit)"
    -- INSPECT_USAGE = "<unit>"
    -- INSPECT_ERROR = "Unable to scan unit \"%s\""
    -- INSPECT_INFO = "Bonuses of \"%s\":"
  elseif locale == "koKR" then
    ABOUT_ADDON = "착용 장비의 보너스 효과에 대한 정보를 작성하는 애드온입니다"
    SHOW_CMD = "표시"
    SHOW_ABOUT = "현재 착용 장비의 모든 보너스 표시"
    SHOW_INFO = "현재 착용 장비 보너스:"
    DETAILS_CMD = "상세정보"
    DETAILS_ABOUT = "슬롯 부위별 보너스를 표시합니다"
    DETAILS_INFO = "현재 착용 보너스 상세정보:"
    ITEM_CMD = "아이템"
    ITEM_ABOUT = "주어진 아이템 링크에 대한 보너스를 표시합니다."
    ITEM_USAGE = "<아이템링크>"
    ITEM_INFO = "%s의 보너스 효과:"
    ITEM_SET = "[%s] 세트의 부분 아이템"
    SET_BONUS = "%d 피스 %s 보너스 효과"
    SLOT_CMD = "슬롯"
    SLOT_ABOUT = "주어진 슬롯에 대한 보너스 효과 표시"
    SLOT_USAGE = "<슬롯명칭>"
    SLOT_INFO = "%s 슬롯의 보너스 효과:"
    -- INSPECT_CMD = "inspect"
    -- INSPECT_ABOUT = "show bonuses of the equipment of the given unit (must be able to inspect the unit)"
    -- INSPECT_USAGE = "<unit>"
    -- INSPECT_ERROR = "Unable to scan unit \"%s\""
    -- INSPECT_INFO = "Bonuses of \"%s\":"
  end
end

-- bonuses[BONUS] = VALUE
local bonuses = { }

-- details[BONUS][SLOT] = VALUE
local details = { }

-- items[LINK].bonuses[BONUS] = VALUE
-- items[LINK].set = SETNAME
-- items[LINK].set_line = number
local items = { }

-- sets[SETNAME].bonuses[NUM][BONUS] = VALUE
-- sets[SETNAME].scan_count = COUNT
-- sets[SETNAME].scan_bonuses = COUNT
local sets = { }

local slots = {
  ["Head"] = true,
  ["Neck"] = true,
  ["Shoulder"] = true,
  ["Shirt"] = true,
  ["Chest"] = true,
  ["Waist"] = true,
  ["Legs"] = true,
  ["Feet"] = true,
  ["Wrist"] = true,
  ["Hands"] = true,
  ["Finger0"] = true,
  ["Finger1"] = true,
  ["Trinket0"] = true,
  ["Trinket1"] = true,
  ["Back"] = true,
  ["MainHand"] = true,
  ["SecondaryHand"] = true,
  ["Ranged"] = true,
  ["Tabard"] = true,
}

function ItemBonusLib:OnInitialize()
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("PLAYER_LEAVING_WORLD")
  for s in pairs(slots) do
    slots[s] = GetInventorySlotInfo(s .. "Slot")
  end

  local options = {
    type = "group",
    desc = ABOUT_ADDON,
    args =
    {
      show =
      {
        type = "execute",
        name = SHOW_CMD,
        desc = SHOW_ABOUT,
        func = function()
          self:Print(SHOW_INFO)
          for bonus in pairs(bonuses) do
            local type, value = GetFriendlyBonus(bonus, bonuses)
            self:Print("%s : %d", self:GetBonusFriendlyName(type), value)
          end
        end
      },
      details =
      {
        type = "execute",
        name = DETAILS_CMD,
        desc = DETAILS_ABOUT,
        func = function()
          self:Print(DETAILS_INFO)
          for bonus, detail in pairs(details) do
            local s = { }
            for slot, value in pairs(detail) do
              table.insert(s, string.format("%s : %d", slot, value))
            end
            local type, value = GetFriendlyBonus(bonus, bonuses)
            if type ~= bonus then
              value = string.format("%s (%s : %d)", tostring(bonuses[bonus]), self:GetBonusFriendlyName(type), value)
            else
              value = tostring(bonuses[bonus])
            end
            self:Print("%s : %s (%s)", self:GetBonusFriendlyName(bonus), value, table.concat(s, ", "))
          end
        end
      },
      item =
      {
        type = "text",
        name = ITEM_CMD,
        desc = ITEM_ABOUT,
        usage = ITEM_USAGE,
        get = false,
        set = function(link)
          local info = self:ScanItemLink(link)
          self:Print(ITEM_INFO, link)
          for bonus, value in pairs(info.bonuses) do
            self:Print("%s : %d", self:GetBonusFriendlyName(bonus), value)
          end
          if info.set then
            self:Print(ITEM_SET, info.set)
            local set = sets[info.set]
            for number, bonuses in pairs(set.bonuses) do
              local has_bonus = number <= set.count and "*" or " "
              self:Print(SET_BONUS, has_bonus, number)
              for bonus, value in pairs(bonuses) do
                self:Print("    %s : %d", self:GetBonusFriendlyName(bonus), value)
              end
            end
          end
        end
      },
      slot =
      {
        type = "text",
        name = SLOT_CMD,
        desc = SLOT_ABOUT,
        usage = SLOT_USAGE,
        get = false,
        set = function(slot)
          self:Print(SLOT_INFO, slot)
          for bonus, detail in pairs(details) do
            if detail[slot] then
              self:Print("%s : %d", self:GetBonusFriendlyName(bonus), detail[slot])
            end
          end
        end
      },
      inspect =
      {
        type = "text",
        name = INSPECT_CMD,
        desc = INSPECT_ABOUT,
        usage = INSPECT_USAGE,
        get = false,
        set = function(unit)
          local eq = self:GetUnitEquipment(unit)
          if not eq then
            self:Print(string.format(INSPECT_ERROR, unit))
            return
          end
          local b = self:MergeDetails(self:BuildBonusSet(eq))
          local n = UnitName(unit)
          local level = UnitLevel(unit)
          if n then
            n = string.format("|Hplayer:%s|h[%s]|h", n, n)
          else
            n = unit
          end
          self:Print(string.format(INSPECT_INFO, n))
          for bonus in pairs(b) do
            local type, value = GetFriendlyBonus(bonus, b, level)
            self:Print("%s : %d", self:GetBonusFriendlyName(type), value)
          end
        end
      },
    },
  }

  self:RegisterChatCommand(CHAT_COMMANDS, options)

end

function ItemBonusLib:PLAYER_ENTERING_WORLD()
  self:RegisterBucketEvent("UNIT_INVENTORY_CHANGED", 0.5)
  self:ScheduleEvent( function() self:ScanEquipment() end, 1)
end

function ItemBonusLib:PLAYER_LEAVING_WORLD()
  self:UnregisterBucketEvent("UNIT_INVENTORY_CHANGED")
end

function ItemBonusLib:UNIT_INVENTORY_CHANGED(units)
  if units.player then
    self:ScanEquipment()
  end
end

local cleanItemLink
do
  -- AddValue & line scanning
  local s = string
  local trim = function(str)
    local gsub = s.gsub
    str = gsub(str, "^%s+", "")
    str = gsub(str, "%s+$", "")
    str = gsub(str, "%.$", "")
    return str
  end

  local equip = ITEM_SPELL_TRIGGER_ONEQUIP
  local l_equip = s.len(equip)

  function cleanItemLink(itemLink)
    local _, _, link = s.find(itemLink, "|H(item[%d:]*)|")
    return link or itemLink
  end

  function ItemBonusLib:AddValue(bonuses, effect, value)
    if type(effect) == "string" then
      bonuses[effect] =(bonuses[effect] or 0) + value
    elseif type(value) == "table" then
      for i, e in ipairs(effect) do
        self:AddValue(bonuses, e, value[i])
      end
    else
      for _, e in ipairs(effect) do
        self:AddValue(bonuses, e, value)
      end
    end
  end

  function ItemBonusLib:CheckPassive(bonuses, line)
    for _, p in pairs(L.PATTERNS_PASSIVE) do
      local _, _, value1, value2 = s.find(line, p.pattern)
      if value1 then
        if value2 and type(p.effect) == "table" then
          self:AddValue(bonuses, p.effect[1], value1)
          self:AddValue(bonuses, p.effect[2], value2)
        else
          self:AddValue(bonuses, p.effect, value1)
        end
        return true
      end
    end
  end

  function ItemBonusLib:CheckToken(bonuses, token, value)
    local t = L.PATTERNS_GENERIC_LOOKUP[token]
    if t then
      self:AddValue(bonuses, t, value)
      return true
    else
      local s1, s2

      for _, p in ipairs(L.PATTERNS_GENERIC_STAGE1) do
        if s.find(token, p.pattern, 1, 1) then
          s1 = p.effect
          break
        end
      end
      for _, p in ipairs(L.PATTERNS_GENERIC_STAGE2) do
        if s.find(token, p.pattern, 1, 1) then
          s2 = p.effect
          break
        end
      end
      if s1 and s2 then
        self:AddValue(bonuses, s1 .. s2, value)
        return true
      end
    end
    self:Debug("CheckToken failed for \"%s\" (%d)", token, value)
  end

  function ItemBonusLib:CheckGeneric(bonuses, line)
    local found

    while s.len(line) > 0 do
      local tmpStr
      local pos = s.find(line, "/", 1, true)
      if pos then
        tmpStr = s.sub(line, 1, pos - 1)
        line = s.sub(line, pos + 1)
      else
        tmpStr = line
        line = ""
      end

      -- trim line
      tmpStr = trim(tmpStr)

      local _, _, value, token = s.find(tmpStr, "^%+(%d+)%%?(.*)$")
      if not value then
        _, _, token, value = s.find(tmpStr, "^(.*)%+(%d+)%%?$")
      end
      if token and value then
        -- trim token
        token = trim(token)
        if self:CheckToken(bonuses, token, value) then
          found = true
        end
      end
    end
    return found
  end

  function ItemBonusLib:CheckOther(bonuses, line)
    for _, p in ipairs(L.PATTERNS_OTHER) do
      local start, _, value = s.find(line, "^" .. p.pattern)
      if start then
        if p.value then
          self:AddValue(bonuses, p.effect, p.value)
        elseif value then
          self:AddValue(bonuses, p.effect, value)
        end
        return true
      end
    end
  end

  function ItemBonusLib:AddBonusInfo(bonuses, line)
    local found
    if s.sub(line, 0, 2) == "|c" then
      -- fix for white enchants
      line = s.sub(line, 11, -3)
    end
    if s.sub(line, 0, l_equip) == equip then
      line = s.sub(line, l_equip + 2)
    end
    found = self:CheckPassive(bonuses, line)
    if not found then
      found = self:CheckGeneric(bonuses, line)
      if not found then
        found = self:CheckOther(bonuses, line)
        if not found then
          self:Debug("Unmatched bonus line \"%s\"", line)
        end
      end
    end
  end
end

do
  -- Item scanning
  local ITEM_SET_NAME = ITEM_SET_NAME
  local ITEM_SET_BONUS = ITEM_SET_BONUS
  local ITEM_SET_BONUS_GRAY = ITEM_SET_BONUS_GRAY

  function ItemBonusLib:ScanItemLink(link)
    link = cleanItemLink(link)
    local info = items[link]
    local scan_set
    local set_name, set_count, set_total
    if not info then
      info = { bonuses = { } }
      Gratuity:SetHyperlink(link)
      for i = 2, Gratuity:NumLines() do
        local line = Gratuity:GetLine(i)
        set_name, set_count, set_total = Deformat(line, ITEM_SET_NAME)
        if set_name then
          info.set = set_name
          info.set_line = i
          local set = sets[set_name]
          if not set or set.scan_count > set_count and set.scan_bonuses > 1 then
            scan_set = true
          end
          break
        end
        self:AddBonusInfo(info.bonuses, line)
      end
      items[link] = info
    elseif info.set then
      Gratuity:SetHyperlink(link)
      set_name, set_count, set_total = Deformat(Gratuity:GetLine(info.set_line), ITEM_SET_NAME)
      local set = sets[set_name]
      if set.scan_count > set_count and set.scan_bonuses > 1 then
        scan_set = true
      end
    end
    if scan_set then
      self:Debug("Scanning set \"%s\"", set_name)
      local set = { count = 0, bonuses = { }, scan_count = set_count, scan_bonuses = 0 }
      for i = info.set_line + set_total + 2, Gratuity:NumLines() do
        local line = Gratuity:GetLine(i)
        local count, bonus
        local bonus = Deformat(line, ITEM_SET_BONUS)
        if bonus then
          set.scan_bonuses = set.scan_bonuses + 1
          count = set_count
        else
          count, bonus = Deformat(
          line, ITEM_SET_BONUS_GRAY)
        end
        if not bonus then
          self:Debug("Invalid set line \"%s\"", line)
          -- break
        else
          local bonuses = set.bonuses[count] or { }
          self:AddBonusInfo(bonuses, bonus, true)
          set.bonuses[count] = bonuses
        end
      end
      sets[set_name] = set
    end
    return info
  end
end

function ItemBonusLib:GetUnitEquipment(unit)
  local inspect
  if unit ~= "player" then
    if not CheckInteractDistance(unit, 1) or
      not CanInspect(unit, true) then
      return nil
    end
    HideUIPanel(InspectFrame)
    NotifyInspect(unit)
    inspect = true
  end
  local eq = { }
  for slot, id in pairs(slots) do
    eq[slot] = GetInventoryItemLink(unit, id)
  end
  if inspect then
    ClearInspectPlayer()
  end
  return eq
end

local function mergeBonusTable(result, operand)
  for k, v in pairs(operand) do
    result[k] =(result[k] or 0) + v
  end
end

function ItemBonusLib:BuildBonusSet(eq)
  local details = { }
  local set_count = { }
  for slot, link in pairs(eq) do
    local info = self:ScanItemLink(link)
    local set = info.set
    if set then
      set_count[set] =(set_count[set] or 0) + 1
    end
    for bonus, value in pairs(info.bonuses) do
      local b = details[bonus]
      if not b then
        b = { }
        details[bonus] = b
      end
      b[slot] = value
    end
  end
  for set, count in pairs(set_count) do
    local info = sets[set]
    for i = 2, count do
      local bonuses = info.bonuses[i]
      if bonuses then
        for bonus, value in pairs(bonuses) do
          local b = details[bonus]
          if not b then
            b = { }
            details[bonus] = b
          end
          b.Set =(b.Set or 0) + value
        end
      end
    end
  end
  return details
end

function ItemBonusLib:MergeDetails(details)
  local bonuses = { }
  for bonus, slots in pairs(details) do
    for slot, value in pairs(slots) do
      bonuses[bonus] =(bonuses[bonus] or 0) + value
    end
  end
  return bonuses
end

function ItemBonusLib:ScanEquipment()
  local eq = self:GetUnitEquipment("player")
  details = self:BuildBonusSet(eq)
  bonuses = self:MergeDetails(details)

  self:TriggerEvent("ItemBonusLib_Update")
end

-- DEBUG
if DEBUG and type(DevTools_Dump)=="function" then
  function ItemBonusLib:DumpCachedItems(clear)
    DevTools_Dump(items)
    if clear then
      items = { }
    end
  end

  function ItemBonusLib:DumpCachedSets(clear)
    DevTools_Dump(sets)
  end

  function ItemBonusLib:DumpBonuses()
    DevTools_Dump(bonuses)
  end

  function ItemBonusLib:DumpDetails()
    DevTools_Dump(details)
  end

  function ItemBonusLib:Reload()
    items = { }
    sets = { }
    self:ScanEquipment()
  end
end

-- BonusScanner compatible API
function ItemBonusLib:GetBonus(bonus)
  return GetBonus(bonus, bonuses)
end

function ItemBonusLib:GetSlotBonuses(slotname)
  local bonuses = { }
  for bonus, detail in pairs(details) do
    if detail[slotname] then
      bonuses[bonus] = detail[slotname]
    end
  end
  return bonuses
end

function ItemBonusLib:GetBonusDetails(bonus)
  return details[bonus] or { }
end

function ItemBonusLib:GetSlotBonus(bonus, slotname)
  local detail = details[bonus]
  return detail and detail[slotname] or 0
end

function ItemBonusLib:GetBonusFriendlyName(bonus)
  return L.NAMES[bonus] or bonus
end

function ItemBonusLib:IsActive()
  return true
end

function ItemBonusLib:ScanItem(itemlink, excludeSet)
  if not excludeSet then
    self:error("excludeSet can't be false on BonusScanner compatible API")
  end
  local name, link = GetItemInfo(itemlink)
  if not name then
    return
  end
  return self:ScanItemLink(link).bonuses
end

function ItemBonusLib:ScanTooltipFrame(frame, excludeSet)
  self:error("BonusScanner:ScanTooltipFrame() is not available")
end

AceLibrary:Register(ItemBonusLib, MAJOR_VERSION, MINOR_VERSION)


do
  -- localisation of regexp
  local locale = GetLocale()
  if locale == "enUS" or locale == "enGB" then
    L = {
      NAMES =
      {
        STR = "Strength",
        AGI = "Agility",
        STA = "Stamina",
        INT = "Intellect",
        SPI = "Spirit",
        ARMOR = "Reinforced Armor",

        ARCANERES = "Arcane Resistance",
        FIRERES = "Fire Resistance",
        NATURERES = "Nature Resistance",
        FROSTRES = "Frost Resistance",
        SHADOWRES = "Shadow Resistance",

        FISHING = "Fishing",
        MINING = "Mining",
        HERBALISM = "Herbalism",
        SKINNING = "Skinning",
        DEFENSE = "Defense",

        BLOCK = "Chance to Block",
        BLOCKVALUE = "Block value",
        DODGE = "Dodge",
        PARRY = "Parry",
        ATTACKPOWER = "Attack Power",
        ATTACKPOWERUNDEAD = "Attack Power against Undead",
        ATTACKPOWERFERAL = "Attack Power in feral form",
        CRIT = "Crit. hits",
        RANGEDATTACKPOWER = "Ranged Attack Power",
        RANGEDCRIT = "Crit. Shots",
        TOHIT = "Chance to Hit",

        DMG = "Spell Damage",
        DMGUNDEAD = "Spell Damage against Undead",
        ARCANEDMG = "Arcane Damage",
        FIREDMG = "Fire Damage",
        FROSTDMG = "Frost Damage",
        HOLYDMG = "Holy Damage",
        NATUREDMG = "Nature Damage",
        SHADOWDMG = "Shadow Damage",
        SPELLCRIT = "Crit. Spell",
        SPELLTOHIT = "Chance to Hit with spells",
        SPELLPEN = "Spell Penetration",
        HEAL = "Healing",
        HOLYCRIT = "Crit. Holy Spell",

        HEALTHREG = "Life Regeneration",
        MANAREG = "Mana Regeneration",
        HEALTH = "Life Points",
        MANA = "Mana Points",
      },


      PATTERNS_PASSIVE =
      {
        { pattern = "+(%d+) ranged Attack Power%.", effect = "RANGEDATTACKPOWER" },
        { pattern = "Increases your chance to block attacks with a shield by (%d+)%%%.", effect = "BLOCK" },
        { pattern = "Increases the block value of your shield by (%d+)%.", effect = "BLOCKVALUE" },
        { pattern = "Increases your chance to dodge an attack by (%d+)%%%.", effect = "DODGE" },
        { pattern = "Increases your chance to parry an attack by (%d+)%%%.", effect = "PARRY" },
        { pattern = "+(%d+) Block", effect = "BLOCKVALUE"},
        { pattern = "(%d+) Block", effect = "BLOCKVALUE"},
        { pattern = "+(%d+) Armor", effect = "ARMOR" },-- order matters
        { pattern = "(%d+) Armor", effect = "ARMOR" },
        { pattern = "Improves your chance to get a critical strike with spells by (%d+)%%%.", effect = "SPELLCRIT" },
        { pattern = "Improves your chance to get a critical strike with Holy spells by (%d+)%%%.", effect = "HOLYCRIT" },
        { pattern = "Increases the critical effect chance of your Holy spells by (%d+)%%%.", effect = "HOLYCRIT" },
        { pattern = "Improves your chance to get a critical strike by (%d+)%%%.", effect = "CRIT" },
        { pattern = "Improves your chance to get a critical strike with missile weapons by (%d+)%%%.", effect = "RANGEDCRIT" },
        { pattern = "Increases damage done by Arcane spells and effects by up to (%d+)%.", effect = "ARCANEDMG" },
        { pattern = "Increases damage done by Fire spells and effects by up to (%d+)%.", effect = "FIREDMG" },
        { pattern = "Increases damage done by Frost spells and effects by up to (%d+)%.", effect = "FROSTDMG" },
        { pattern = "Increases damage done by Holy spells and effects by up to (%d+)%.", effect = "HOLYDMG" },
        { pattern = "Increases damage done by Nature spells and effects by up to (%d+)%.", effect = "NATUREDMG" },
        { pattern = "Increases damage done by Shadow spells and effects by up to (%d+)%.", effect = "SHADOWDMG" },
        { pattern = "Increases healing done by spells and effects by up to (%d+)%.", effect = "HEAL" },
        { pattern = "Increases damage and healing done by magical spells and effects by up to (%d+)%.", effect = { "HEAL", "DMG" } },
        { pattern = "Increases damage done to Undead by magical spells and effects by up to (%d+)", effect = "DMGUNDEAD" },
        { pattern = "+(%d+) Attack Power when fighting Undead.", effect = "ATTACKPOWERUNDEAD" },
        { pattern = "Restores (%d+) health per 5 sec%.", effect = "HEALTHREG" },
        { pattern = "Restores (%d+) health every 5 sec%.", effect = "HEALTHREG" },-- both versions ('per' and 'every') seem to be used
        { pattern = "Restores (%d+) mana per 5 sec%.", effect = "MANAREG" },
        { pattern = "Restores (%d+) mana every 5 sec%.", effect = "MANAREG" },
        { pattern = "Improves your chance to hit by (%d+)%%%.", effect = "TOHIT" },
        { pattern = "Improves your chance to hit with spells by (%d+)%%%.", effect = "SPELLTOHIT" },
        { pattern = "Decreases the magical resistances of your spell targets by (%d+)%.", effect = "SPELLPEN" },
        -- Atiesh related patterns
        { pattern = "Increases your spell damage by up to (%d+) and your healing by up to (%d+)%.", effect = { "DMG", "HEAL" } },
        { pattern = "Increases healing done by magical spells and effects of all party members within %d+ yards by up to (%d+)%.", effect = "HEAL" },
        { pattern = "Increases damage and healing done by magical spells and effects of all party members within %d+ yards by up to (%d+)%.", effect = { "HEAL", "DMG" } },
        { pattern = "Restores (%d+) mana per 5 seconds to all party members within %d+ yards%.", effect = "MANAREG" },
        { pattern = "Increases the spell critical chance of all party members within %d+ yards by (%d+)%%%.", effect = "SPELLCRIT" },

        -- Added for HealPoints
        { pattern = "Allows (%d+)%% of your Mana regeneration to continue while casting%.", effect = "CASTINGREG" },
        { pattern = "Improves your chance to get a critical strike with Nature spells by (%d+)%%%.", effect = "NATURECRIT" },
        { pattern = "Reduces the casting time of your Regrowth spell by 0%.(%d+) sec%.", effect = "CASTINGREGROWTH" },
        { pattern = "Reduces the casting time of your Holy Light spell by 0%.(%d+) sec%.", effect = "CASTINGHOLYLIGHT" },
        { pattern = "Reduces the casting time of your Healing Touch spell by 0%.(%d+) sec%.", effect = "CASTINGHEALINGTOUCH" },
        { pattern = "%-0%.(%d+) sec to the casting time of your Flash Heal spell%.", effect = "CASTINGFLASHHEAL" },
        { pattern = "%-0%.(%d+) seconds on the casting time of your Chain Heal spell%.", effect = "CASTINGCHAINHEAL" },
        { pattern = "Increases the duration of your Rejuvenation spell by (%d+) sec%.", effect = "DURATIONREJUV" },
        { pattern = "Increases the duration of your Renew spell by (%d+) sec%.", effect = "DURATIONRENEW" },
        { pattern = "Increases your normal health and mana regeneration by (%d+)%.", effect = "MANAREGNORMAL" },
        { pattern = "Increases the amount healed by Chain Heal to targets beyond the first by (%d+)%%%.", effect = "IMPCHAINHEAL" },
        { pattern = "Increases healing done by Rejuvenation by up to (%d+)%.", effect = "IMPREJUVENATION" },
        { pattern = "Increases healing done by Lesser Healing Wave by up to (%d+)%.", effect = "IMPLESSERHEALINGWAVE" },
        { pattern = "Increases healing done by Flash of Light by up to (%d+)%.", effect = "IMPFLASHOFLIGHT" },
        { pattern = "After casting your Healing Wave or Lesser Healing Wave spell%, gives you a 25%% chance to gain Mana equal to (%d+)%% of the base cost of the spell%.", effect = "REFUNDHEALINGWAVE" },
        { pattern = "Your Healing Wave will now jump to additional nearby targets%. Each jump reduces the effectiveness of the heal by (%d+)%%%, and the spell will jump to up to two additional targets%.", effect = "JUMPHEALINGWAVE" },
        { pattern = "Reduces the mana cost of your Healing Touch%, Regrowth%, Rejuvenation and Tranquility spells by (%d+)%%%.", effect = "CHEAPERDRUID" },
        { pattern = "On Healing Touch critical hits%, you regain (%d+)%% of the mana cost of the spell%.", effect = "REFUNDHTCRIT" },
        { pattern = "Reduces the mana cost of your Renew spell by (%d+)%%%.", effect = "CHEAPERRENEW" },

        -- Updated Patterns (in 2.0)
        { pattern = "Increases your spell penetration by (%d+)%.", effect = "SPELLPEN" },
        { pattern = "Increases attack power by (%d+)%.", effect = "ATTACKPOWER" },
      },

      PATTERNS_GENERIC_LOOKUP =
      {
        ["All Stats"] = { "STR", "AGI", "STA", "INT", "SPI" },
        ["Strength"] = "STR",
        ["Agility"] = "AGI",
        ["Stamina"] = "STA",
        ["Intellect"] = "INT",
        ["Spirit"] = "SPI",

        ["All Resistances"] = { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES" },

        ["Fishing"] = "FISHING",
        ["Fishing Lure"] = "FISHING",
        ["Increased Fishing"] = "FISHING",
        ["Mining"] = "MINING",
        ["Herbalism"] = "HERBALISM",
        ["Skinning"] = "SKINNING",
        ["Defense"] = "DEFENSE",
        ["Increased Defense"] = "DEFENSE",

        ["Attack Power"] = "ATTACKPOWER",
        ["Attack Power when fighting Undead"] = "ATTACKPOWERUNDEAD",
        ["Attack Power in Cat, Bear, and Dire Bear forms only"] = "ATTACKPOWERFERAL",

        ["Dodge"] = "DODGE",
        ["Block"] = "BLOCK",
        ["Block Value"] = "BLOCKVALUE",
        ["Hit"] = "TOHIT",
        ["Spell Hit"] = "SPELLTOHIT",
        ["Blocking"] = "BLOCK",
        ["Ranged Attack Power"] = "RANGEDATTACKPOWER",
        ["health every 5 sec"] = "HEALTHREG",
        ["Healing Spells"] = "HEAL",
        ["Increases Healing"] = "HEAL",
        ["Healing and Spell Damage"] = { "HEAL", "DMG" },
        ["Damage and Healing Spells"] = { "HEAL", "DMG" },
        ["Spell Damage and Healing"] = { "HEAL", "DMG" },
        ["mana every 5 sec"] = "MANAREG",
        ["Mana Regen"] = "MANAREG",
        ["Spell Damage"] = { "HEAL", "DMG" },
        ["Critical"] = "CRIT",
        ["Critical Hit"] = "CRIT",
        ["Damage"] = "DMG",
        ["Health"] = "HEALTH",
        ["HP"] = "HEALTH",
        ["Mana"] = "MANA",
        ["Armor"] = "ARMOR",
        ["Reinforced Armor"] = "ARMOR",
      },

      PATTERNS_GENERIC_STAGE1 =
      {
        { pattern = "Arcane", effect = "ARCANE" },
        { pattern = "Fire", effect = "FIRE" },
        { pattern = "Frost", effect = "FROST" },
        { pattern = "Holy", effect = "HOLY" },
        { pattern = "Shadow", effect = "SHADOW" },
        { pattern = "Nature", effect = "NATURE" }
      },

      PATTERNS_GENERIC_STAGE2 =
      {
        { pattern = "Resist", effect = "RES" },
        { pattern = "Damage", effect = "DMG" },
        { pattern = "Effects", effect = "DMG" },
      },

      PATTERNS_OTHER =
      {
        { pattern = "Mana Regen (%d+) per 5 sec%.", effect = "MANAREG" },

        { pattern = "Minor Wizard Oil", effect = { "DMG", "HEAL" }, value = 8 },
        { pattern = "Lesser Wizard Oil", effect = { "DMG", "HEAL" }, value = 16 },
        { pattern = "Wizard Oil", effect = { "DMG", "HEAL" }, value = 24 },
        { pattern = "Brilliant Wizard Oil", effect = { "DMG", "HEAL", "SPELLCRIT" }, value = { 36, 36, 1 } },

        { pattern = "Minor Mana Oil", effect = "MANAREG", value = 4 },
        { pattern = "Lesser Mana Oil", effect = "MANAREG", value = 8 },
        { pattern = "Brilliant Mana Oil", effect = { "MANAREG", "HEAL" }, value = { 12, 25 } },

        { pattern = "Eternium Line", effect = "FISHING", value = 5 },

        { pattern = "Healing %+31 and 5 mana per 5 sec%.", effect = { "MANAREG", "HEAL" }, value = { 5, 31 } },
        { pattern = "Stamina %+16 and Armor %+100", effect = { "STA", "ARMOR" }, value = { 16, 100 } },
        { pattern = "Attack Power %+26 and %+1%% Critical Strike", effect = { "ATTACKPOWER", "CRIT" }, value = { 26, 1 } },
        { pattern = "Spell Damage %+15 and %+1%% Spell Critical Strike", effect = { "DMG", "HEAL", "SPELLCRIT" }, value = { 15, 15, 1 } },
      },
    }
  elseif locale == "frFR" then
    L = {
      NAMES =
      {
        STR = "Force",
        AGI = "Agilité",
        STA = "Endurance",
        INT = "Intelligence",
        SPI = "Esprit",
        ARMOR = "Bonus d'Armure",

        ARCANERES = "Arcane",
        FIRERES = "Feu",
        NATURERES = "Nature",
        FROSTRES = "Givre",
        SHADOWRES = "Ombre",

        FISHING = "Pêche",
        MINING = "Minage",
        HERBALISM = "Herborisme",
        SKINNING = "Dépeçage",
        DEFENSE = "Défense",

        BLOCK = "Chance de Bloquer",
        BLOCKVALUE = "Valeur de blocage",
        DODGE = "Esquive",
        PARRY = "Parade",
        ATTACKPOWER = "Puissance d'attaque",
        ATTACKPOWERUNDEAD = "Puissance d'attaque contre les morts-vivants",
        ATTACKPOWERFERAL = "Puissance d'attaque en forme férale",
        CRIT = "Coups Critiques",
        RANGEDATTACKPOWER = "Puissance d'attaque à distance",
        RANGEDCRIT = "Tirs Critiques",
        TOHIT = "Chances de toucher",

        DMG = "Dégâts",
        DMGUNDEAD = "Dégâts des sorts contre les morts-vivants",
        ARCANEDMG = "Dégâts d'Arcanes",
        FIREDMG = "Dégâts de Feu",
        FROSTDMG = "Dégâts de Froid",
        HOLYDMG = "Dégâts Sacrés",
        NATUREDMG = "Dégâts de Nature",
        SHADOWDMG = "Dégâts des Ombres",
        SPELLCRIT = "Critiques",
        HEAL = "Soins",
        HOLYCRIT = "Soins Crit.",
        SPELLTOHIT = "Chance de toucher avec les sorts",
        SPELLPEN = "Diminue les résistances",

        HEALTHREG = "Régeneration Vie",
        MANAREG = "Régeneration Mana",
        HEALTH = "Points de Vie",
        MANA = "Points de Mana",
      },

      PATTERNS_PASSIVE =
      {
        { pattern = "+(%d+) à la puissance d'attaque%.", effect = "ATTACKPOWER" },
        { pattern = "Augmente de +(%d+) la puissance d'attaque lorsque vous combattez des morts%-vivants%.", effect = "ATTACKPOWERUNDEAD" },
        { pattern = "+(%d+) à la puissance des attaques à distance%.", effect = "RANGEDATTACKPOWER" },
        { pattern = "Augmente vos chances de bloquer les attaques avec un bouclier de (%d+)%%%.", effect = "BLOCK" },
        { pattern = "Augmente le score de blocage de votre bouclier de (%d+)%.", effect = "BLOCKVALUE" },
        { pattern = "Augmente vos chances d'esquiver une attaque de (%d+)%%%.", effect = "DODGE" },
        { pattern = "Augmente vos chances de parer une attaque de (%d+)%%%.", effect = "PARRY" },
        { pattern = "Augmente vos chances d'infliger un coup critique avec vos sorts de (%d+)%%%.", effect = "SPELLCRIT" },
        { pattern = "Augmente vos chances d'infliger un coup critique de (%d+)%%%.", effect = "CRIT" },
        { pattern = "Augmente vos chances d'infliger un coup critique avec une arme à feu par (%d+)%%%.", effect = "RANGEDCRIT" },
        { pattern = "Augmente vos chances de lancer un soin critique par (%d+)%%%.", effect = "HEALCRIT" },
        { pattern = "Augmente les dégâts infligés par les effets et les sorts des Arcanes de (%d+)% au maximum%.", effect = "ARCANEDMG" },
        { pattern = "Augmente les dégâts infligés par les sorts et effets de Feu de (%d+)% au maximum%.", effect = "FIREDMG" },
        { pattern = "Augmente les dégâts infligés par les sorts et les effets de givre de (%d+)% au maximum%.", effect = "FROSTDMG" },
        { pattern = "Augmente les dommages realises par les sorts Sacrés de (%d+)%.", effect = "HOLYDMG" },
        { pattern = "Augmente les dégâts infligés par les sorts et les effets de Nature (%d+)% au maximum%.", effect = "NATUREDMG" },
        { pattern = "Augmente les dégâts infligés par les sorts et les effets d'ombre de (%d+)% au maximum%.", effect = "SHADOWDMG" },
        { pattern = "(%d+)% aux dégâts des sorts d'ombres%.", effect = "SHADOWDMG" },
        { pattern = "Augmente les effets des sorts de soins de (%d+)% au maximum%.", effect = "HEAL" },
        { pattern = "Augmente les soins prodigués par les sorts et effets de (%d+)% au maximum%.", effect = "HEAL" },
        { pattern = "Augmente les soins et dégâts produits par les sorts et effets magiques de (%d+) au maximum%.", effect = { "HEAL", "DMG" } },
        { pattern = "Augmente les dégâts et les soins produits par les sorts et effets magiques de (%d+) au maximum%.", effect = { "HEAL", "DMG" } },
        { pattern = "Augmente les dégâts infligés aux morts%-vivants par les sorts et effets magiques d'un maximum de (%d+)%.", effect = "DMGUNDEAD" },
        { pattern = "Rend (%d+) points de vie toutes les 5 sec%.", effect = "HEALTHREG" },
        { pattern = "Rend (%d+) points de mana toutes les 5 secondes%.", effect = "MANAREG" },
        { pattern = "Augmente vos chances de toucher de (%d+)%%%.", effect = "TOHIT" },
        { pattern = "Augmente vos chances de toucher avec des sorts de (%d+)%%%.", effect = "SPELLTOHIT" },
        { pattern = "Diminue les résistances magiques des cibles de vos sorts de (%d+)%.", effect = "SPELLPEN" },
        { pattern = "Pêche augmentée de (%d+).", effect = "FISHING" },
        { pattern = "Défense augmentée de (%d+).", effect = "DEFENSE" },
        { pattern = "+(%d+) à l'Armure", effect = "ARMOR" },
        { pattern = "+(%d+) à la puissance d'attaque pour les formes de félin, d'ours et d'ours redoutable uniquement%.", effect = "ATTACKPOWERFERAL" },
        { pattern = "+(%d+) à toutes les résistances%.", effect = { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES" } },
        -- Atiesh related patterns
        { pattern = "Augmente les dégâts infligés par vos sorts d'un maximum de (%d+) et vos soins d'un maximum de (%d+).", effect = { "DMG", "HEAL" } },
        { pattern = "Augmente de (%d+) au maximum les soins prodigués par les sorts et effets magiques de tous les membres du groupe situés à moins de %d+ mètres%.", effect = "HEAL" },
        { pattern = "Augmente de (%d+) au maximum les dégâts et les soins produits par les sorts et effets magiques de tous les membres du groupe situés à moins de %d+ mètres%.", effect = { "HEAL", "DMG" } },
        -- { pattern = "Restores (%d+) mana per 5 seconds to all party members within %d+ yards%.", effect = "MANAREG" },
        -- { pattern = "Increases the spell critical chance of all party members within %d+ yards by (%d+)%%%.", effect = "SPELLCRIT" },

        -- Added
        { pattern = "(%d+)%% de votre vitesse de récupération du Mana sont actifs lorsque vous incantez%.", effect = "CASTINGREG" },
        { pattern = "Vous confère (%d+)%% de votre vitesse normale de récupération du mana pendant l'incantation%.", effect = "CASTINGREG" },
        { pattern = "Augmente vos chances d'infliger un coup critique avec les sorts de Nature de (%d+)%%%.", effect = "NATURECRIT" },
        { pattern = "Réduit le temps d'incantation de votre sort Rétablissement de 0.(%d+) sec%.", effect = "CASTINGREGROWTH" },
        { pattern = "Réduit le temps d'incantation de votre sort Lumière sacrée de 0.(%d+) sec%.", effect = "CASTINGHOLYLIGHT" },
        { pattern = "-0.(%d+) sec. au temps d'incantation de votre sort Soins rapides%.", effect = "CASTINGFLASHHEAL" },
        { pattern = "-0.(%d+) secondes au temps d'incantation de votre sort Salve de guérison%.", effect = "CASTINGCHAINHEAL" },
        { pattern = "Réduit le temps de lancement de Toucher Guérisseur de 0.(%d+) secondes%.", effect = "CASTINGHEALINGTOUCH" },
        { pattern = "Augmente la durée de votre sort Récupération de (%d+) sec%.", effect = "DURATIONREJUV" },
        { pattern = "Augmente la durée de votre sort Rénovation de (%d+) sec%.", effect = "DURATIONRENEW" },
        { pattern = "Augmente la régénération des points de vie et de mana de (%d+)%.", effect = "MANAREGNORMAL" },
        { pattern = "Augmente de (%d+)%% le montant de points de vie rendus par Salve de guérison aux cibles qui suivent la première%.", effect = "IMPCHAINHEAL" },
        { pattern = "Augmente les soins prodigués par Récupération de (%d+) au maximum%.", effect = "IMPREJUVENATION" },
        { pattern = "Augmente les soins prodigués par votre Vague de Soins Inférieurs de (%d+)%.", effect = "IMPLESSERHEALINGWAVE" },
        { pattern = "Augmente les soins prodigués par votre Eclair lumineux de (%d+)%.", effect = "IMPFLASHOFLIGHT" },
        { pattern = "Après avoir lancé un sort de Vague de soins ou de Vague de soins inférieurs, vous avez 25%% de chances de gagner un nombre de points de mana égal à (%d+)%% du coût de base du sort%.", effect = "REFUNDHEALINGWAVE" },
        { pattern = "Votre Vague de soins soigne aussi des cibles proches supplémentaires. Chaque nouveau soin perd (%d+)%% d'efficacité, et le sort soigne jusqu'à deux cibles supplémentaires%.", effect = "JUMPHEALINGWAVE" },
        { pattern = "Réduit de (%d+)%% le coût en mana de vos sorts Toucher guérisseur% Rétablissement% Récupération et Tranquillité%.", effect = "CHEAPERDRUID" },
        { pattern = "En cas de réussite critique sur un Toucher guérisseur, vous récupérez (%d+)%% du coût en mana du sort%.", effect = "REFUNDHTCRIT" },
        { pattern = "Reduit le coût en mana de votre sort Rénovation de (%d+)%%%.", effect = "CHEAPERRENEW" },

        -- Updated Patterns (in 2.0)
        -- ~ 				{ pattern = "Increases your spell penetration by (%d+)%.", effect = "SPELLPEN" },
        { pattern = "Augmente de (%d+) la puissance d'attaque%.", effect = "ATTACKPOWER" },
      },


      PATTERNS_GENERIC_LOOKUP =
      {
        ["Toutes les caractéristiques"] = { "STR", "AGI", "STA", "INT", "SPI" },
        ["Force"] = "STR",
        ["Agilité"] = "AGI",
        ["Endurance"] = "STA",
        ["Intelligence"] = "INT",
        ["Esprit"] = "SPI",
        ["à toutes les résistances"] = { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES" },
        ["Pêche"] = "FISHING",
        ["Minage"] = "MINING",
        ["Herborisme"] = "HERBALISM",
        ["Dépeçage"] = "SKINNING",
        ["Défense"] = "DEFENSE",
        ["puissance d'Attaque"] = "ATTACKPOWER",
        ["Puissance d'attaque contre les morts%-vivants"] = "ATTACKPOWERUNDEAD",
        ["Esquive"] = "DODGE",
        ["Blocage"] = "BLOCK",
        ["Score de blocage"] = "BLOCKVALUE",
        ["Puissance d'Attaque à distance"] = "RANGEDATTACKPOWER",
        ["Soins chaque 5 sec."] = "HEALTHREG",
        ["Sorts de Soins"] = "HEAL",
        ["Sorts de soin"] = "HEAL",
        ["Sorts de soins"] = "HEAL",
        ["Mana chaque 5 sec."] = "MANAREG",
        ["Sorts de Dommages"] = "DMG",
        ["dégâts des sorts"] = { "HEAL", "DMG" },
        ["dégâts et les effets des sorts"] = "DMG",
        ["aux dégâts des sorts et aux soins"] = { "HEAL", "DMG" },
        ["points de mana toutes les 5 sec"] = "MANAREG",
        ["aux sorts de soins"] = "HEAL",
        ["Armure : "] = "ARMOR",
        ["Bloquer"] = "BLOCKVALUE",
        ["Coup Critique"] = "CRIT",
        ["Dommage"] = "DMG",
        ["Soins"] = "HEALTH",
        ["Mana"] = "MANA",
        ["Armure renforcée"] = "ARMOR",
      },

      PATTERNS_GENERIC_STAGE1 =
      {
        { pattern = "Arcane", effect = "ARCANE" },
        { pattern = "Feu", effect = "FIRE" },
        { pattern = "Givre", effect = "FROST" },
        { pattern = "Sacré", effect = "HOLY" },
        { pattern = "Ombre", effect = "SHADOW" },
        { pattern = "Nature", effect = "NATURE" },
        { pattern = "arcanes", effect = "ARCANE" },
        { pattern = "feu", effect = "FIRE" },
        { pattern = "givre", effect = "FROST" },
        { pattern = "ombre", effect = "SHADOW" },
        { pattern = "nature", effect = "NATURE" }
      },

      PATTERNS_GENERIC_STAGE2 =
      {
        { pattern = "résistance", effect = "RES" },
        { pattern = "dégâts", effect = "DMG" },
        { pattern = "effets", effect = "DMG" }
      },


      PATTERNS_OTHER =
      {
        { pattern = "(%d+) Mana chaque 5 sec.", effect = "MANAREG" },-- ?
        { pattern = "Récup. mana (%d+)/5 sec.", effect = "MANAREG" },-- ?
        { pattern = "Cachet de mojo zandalar", effect = "HEAL", value = 18 },-- ?
        { pattern = "Cachet de sérénité zandalar", effect = "HEAL", value = 33 },

        { pattern = "Huile de sorcier mineure", effect = "HEAL", value = 8 },
        { pattern = "Huile de sorcier inférieure", effect = "HEAL", value = 16 },
        { pattern = "Huile de sorcier", effect = "HEAL", value = 24 },
        { pattern = "Huile de sorcier brillante", effect = { "HEAL", "SPELLCRIT" }, value = { 36, 1 } },

        { pattern = "Huile de mana mineure", effect = "MANAREG", value = 4 },
        { pattern = "Huile de mana inférieure", effect = "MANAREG", value = 8 },
        { pattern = "Huile de mana brillante", effect = { "MANAREG", "HEAL" }, value = { 12, 25 } },
        -- enchantements de Saphirron
        -- { pattern = "Healing %+31 and 5 mana per 5 sec%.", effect = { "MANAREG", "HEAL"}, value = {5, 31} },
        -- { pattern = "Stamina %+16 and Armor %+100", effect = { "STA", "ARMOR"}, value = {16, 100} },
        -- { pattern = "Attack Power %+26 and %+1%% Critical Strike", effect = { "ATTACKPOWER", "CRIT"}, value = {26, 1} },
        -- { pattern = "Spell Damage %+15 and %+1%% Spell Critical Strike", effect = { "DMG", "HEAL", "SPELLCRIT"}, value = {15, 15, 1} },
      }
    }
  elseif locale == "deDE" then
    L = {
      NAMES =
      {
        STR = "Stärke",
        AGI = "Beweglichkeit",
        STA = "Ausdauer",
        INT = "Intelligenz",
        SPI = "Willenskraft",
        ARMOR = "Verstärkte Rüstung",

        ARCANERES = "Arkanwiderstand",
        FIRERES = "Feuerwiderstand",
        NATURERES = "Naturwiderstand",
        FROSTRES = "Frostwiderstand",
        SHADOWRES = "Schattenwiderstand",

        FISHING = "Angeln",
        MINING = "Bergbau",
        HERBALISM = "Kräuterkunde",
        SKINNING = "Kürschnerei",
        DEFENSE = "Verteidigung",

        BLOCK = "Blockchance",
        BLOCKVALUE = "Blockwert",
        DODGE = "Ausweichen",
        PARRY = "Parieren",
        ATTACKPOWER = "Angriffskraft",
        ATTACKPOWERUNDEAD = "Angriffskraft gegen Untote",
        ATTACKPOWERFERAL = "Angriffskraft in Tierform",
        CRIT = "krit. Treffer",
        RANGEDATTACKPOWER = "Distanzangriffskraft",
        RANGEDCRIT = "krit. Schuss",
        TOHIT = "Trefferchance",
        DMG = "Zauberschaden",
        DMGUNDEAD = "Zauberschaden gegen Untote",
        ARCANEDMG = "Arkanschaden",
        FIREDMG = "Feuerschaden",
        FROSTDMG = "Frostschaden",
        HOLYDMG = "Heiligschaden",
        NATUREDMG = "Naturschaden",
        SHADOWDMG = "Schattenschaden",
        HOLYCRIT = "krit. Heiligzauber",
        SPELLCRIT = "krit. Zauber",
        SPELLTOHIT = "Zaubertrefferchance",
        SPELLPEN = "Magiedurchdringung",
        HEAL = "Heilung",
        HEALTHREG = "Lebensregeneration",
        MANAREG = "Manaregeneration",
        HEALTH = "Lebenspunkte",
        MANA = "Manapunkte",
      },

      PATTERNS_PASSIVE =
      {
        { pattern = "%+(%d+) bei allen Widerstandsarten%.", effect = { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES" } },
        { pattern = "Erhöht Eure Chance, Angriffe mit einem Schild zu blocken, um (%d+)%%%.", effect = "BLOCK" },
        { pattern = "Erhöht den Blockwert Eures Schilde?s um (%d+)%.", effect = "BLOCKVALUE" },
        { pattern = "Erhöht Eure Chance, einem Angriff auszuweichen, um (%d+)%%%.", effect = "DODGE" },
        { pattern = "Erhöht Eure Chance, einen Angriff zu parieren, um (%d+)%%%.", effect = "PARRY" },
        { pattern = "Erhöht Eure Chance, einen kritischen Treffer durch Zauber zu erzielen, um (%d+)%%%.", effect = "SPELLCRIT" },
        { pattern = "Erhöht Eure Chance, einen kritischen Treffer durch Heiligzauber zu erzielen, um (%d+)%%%.", effect = "HOLYCRIT" },
        { pattern = "Erhöht Eure Chance, einen kritischen Treffer zu erzielen, um (%d+)%%%.", effect = "CRIT" },
        { pattern = "Erhöht Eure Chance, mit Geschosswaffen einen kritischen Schlag zu erzielen, um (%d+)%.", effect = "RANGEDCRIT" },
        { pattern = "Erhöht durch Arkanzauber und Arkaneffekte zugefügten Schaden um bis zu (%d+)%.", effect = "ARCANEDMG" },
        { pattern = "Erhöht durch Feuerzauber und Feuereffekte zugefügten Schaden um bis zu (%d+)%.", effect = "FIREDMG" },
        { pattern = "Erhöht durch Frostzauber und Frosteffekte zugefügten Schaden um bis zu (%d+)%.", effect = "FROSTDMG" },
        { pattern = "Erhöht durch Heiligzauber und Heiligeffekte zugefügten Schaden um bis zu (%d+)%.", effect = "HOLYDMG" },
        { pattern = "Erhöht durch Naturzauber und Natureffekte zugefügten Schaden um bis zu (%d+)%.", effect = "NATUREDMG" },
        { pattern = "Erhöht durch Schattenzauber und Schatteneffekte zugefügten Schaden um bis zu (%d+)%.", effect = "SHADOWDMG" },
        { pattern = "Erhöht durch Zauber und magische Effekte zugefügten Schaden und Heilung um bis zu (%d+)%.", effect = { "HEAL", "DMG" } },
        { pattern = "Erhöht den durch magische Zauber und magische Effekte zugefügten Schaden gegen Untote um bis zu (%d+)", effect = "DMGUNDEAD" },
        { pattern = "+(%d+) Angriffskraft gegen Untote.", effect = "ATTACKPOWERUNDEAD" },
        { pattern = "Erhöht durch Zauber und Effekte verursachte Heilung um bis zu (%d+)%.", effect = "HEAL" },
        { pattern = "Erhöht die durch Zauber und Effekte verursachte Heilung um bis zu (%d+)%.", effect = "HEAL" },
        { pattern = "Stellt alle 5 Sek%. (%d+) Punkt%(e%) Gesundheit wieder her%.", effect = "HEALTHREG" },
        { pattern = "Stellt alle 5 Sek%. (%d+) Punkt%(e%) Mana wieder her%.", effect = "MANAREG" },
        { pattern = "Verbessert Eure Trefferchance um (%d+)%%%.", effect = "TOHIT" },
        { pattern = "Erhöht Eure Chance mit Zaubern zu treffen um (%d+)%%%.", effect = "SPELLTOHIT" },
        { pattern = "Reduziert die Magiewiderstände der Ziele Eurer Zauber um (%d+)%.", effect = "SPELLPEN" }
      },


      PATTERNS_GENERIC_LOOKUP =
      {
        ["Alle Werte"] = { "STR", "AGI", "STA", "INT", "SPI" },
        ["Stärke"] = "STR",
        ["Beweglichkeit"] = "AGI",
        ["Ausdauer"] = "STA",
        ["Intelligenz"] = "INT",
        ["Willenskraft"] = "SPI",

        ["Alle Widerstandsarten"] = { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES" },

        ["Angeln"] = "FISHING",
        ["Angelköder"] = "FISHING",
        ["Bergbau"] = "MINING",
        ["Kräuterkunde"] = "HERBALISM",
        ["Kürschnerei"] = "SKINNING",
        ["Verteidigung"] = "DEFENSE",
        ["Verteidigungsfertigkeit"] = "DEFENSE",

        ["Angriffskraft"] = "ATTACKPOWER",
        ["Angriffskraft gegen Untote"] = "ATTACKPOWERUNDEAD",
        ["Angriffskraft in Katzengestalt, Bärengestalt oder Terrorbärengestalt"] = "ATTACKPOWERFERAL",
        ["Ausweichen"] = "DODGE",
        ["Blocken"] = "BLOCK",
        ["Blockwert"] = "BLOCKVALUE",
        ["Trefferchance"] = "TOHIT",
        ["Distanzangriffskraft"] = "RANGEDATTACKPOWER",
        ["Gesundheit alle 5 Sek"] = "HEALTHREG",
        ["Heilzauber"] = "HEAL",
        ["Mana alle 5 Sek"] = "MANAREG",
        ["Manaregeneration"] = "MANAREG",
        ["Zauberschaden erhöhen"] = "DMG",
        ["Kritischer Treffer"] = "CRIT",
        ["Zauberschaden"] = { "HEAL", "DMG" },
        ["Blocken"] = "BLOCK",
        ["Gesundheit"] = "HEALTH",
        ["HP"] = "HEALTH",
        ["Heilzauber"] = "HEAL",
        ["Heilung und Zauberschaden"] = { "HEAL", "DMG" },
        ["Zauberschaden und Heilung"] = { "HEAL", "DMG" },
        ["Schadenszauber und Heilzauber"] = { "HEAL", "DMG" },
        ["Schadens- und Heilzauber"] = { "HEAL", "DMG" },
        ["Zaubertrefferchance"] = "SPELLTOHIT",

        ["Mana"] = "MANA",
        ["Rüstung"] = "ARMOR",
        ["Verstärkte Rüstung"] = "ARMOR"
      },

      PATTERNS_GENERIC_STAGE1 =
      {
        { pattern = "Arkan", effect = "ARCANE" },
        { pattern = "Feuer", effect = "FIRE" },
        { pattern = "Frost", effect = "FROST" },
        { pattern = "Heilig", effect = "HOLY" },
        { pattern = "Schatten", effect = "SHADOW" },
        { pattern = "Natur", effect = "NATURE" },
      },

      PATTERNS_GENERIC_STAGE2 =
      {
        { pattern = "widerst", effect = "RES" },
        { pattern = "schaden", effect = "DMG" },
        { pattern = "effekte", effect = "DMG" },
      },


      PATTERNS_OTHER =
      {
        { pattern = "Manaregeneration (%d+) per 5 Sek%.", effect = "MANAREG" },

        { pattern = "Schwaches Zauberöl", effect = { "DMG", "HEAL" }, value = 8 },
        { pattern = "Geringes Zauberöl", effect = { "DMG", "HEAL" }, value = 16 },
        { pattern = "Zauberöl", effect = { "DMG", "HEAL" }, value = 24 },
        { pattern = "Hervorragendes Zauberöl", effect = { "DMG", "HEAL", "SPELLCRIT" }, value = { 36, 36, 1 } },

        { pattern = "Schwaches Manaöl", effect = "MANAREG", value = 4 },
        { pattern = "Geringes Manaöl", effect = "MANAREG", value = 8 },
        { pattern = "Hervorragendes Manaöl", effect = { "MANAREG", "HEAL" }, value = { 12, 25 } },

        { pattern = "Eterniumschnur", effect = "FISHING", value = 5 },

        { pattern = "Heilung %+31 und 5 Mana alle 5 Sek%.", effect = { "MANAREG", "HEAL" }, value = { 5, 31 } },
        { pattern = "Ausdauer %+16 und Rüstung %+100", effect = { "STA", "ARMOR" }, value = { 16, 100 } },
        { pattern = "Angriffskraft %+26 und %+1%% kritische Treffer", effect = { "ATTACKPOWER", "CRIT" }, value = { 26, 1 } },
        { pattern = "Zauberschaden %+15 und %+1%% kritische Zaubertreffer", effect = { "DMG", "HEAL", "SPELLCRIT" }, value = { 15, 15, 1 } },
      }
    }
  elseif locale == "koKR" then
    L = {
      NAMES =
      {
        STR = "힘",
        AGI = "민첩성",
        STA = "체력",
        INT = "지능",
        SPI = "정신력",
        ARMOR = "방어도",

        ARCANERES = "비전 저항력",
        FIRERES = "화염 저항력",
        NATURERES = "자연 저항력",
        FROSTRES = "냉기 저항력",
        SHADOWRES = "암흑 저항력",

        FISHING = "낚시",
        MINING = "채광",
        HERBALISM = "약초 채집",
        SKINNING = "무두질",
        DEFENSE = "방어 숙련도",

        BLOCK = "방어율",
        BLOCKVALUE = "방패 피해 흡수량",
        DODGE = "회피",
        PARRY = "무기막기",
        ATTACKPOWER = "전투력",
        ATTACKPOWERUNDEAD = "언데드에 대한 전투력",
        ATTACKPOWERFERAL = "야수 변신시 전투력",
        CRIT = "치명타 적중률",
        RANGEDATTACKPOWER = "원거리 전투력",
        RANGEDCRIT = "원거리 치명타 적중률",
        TOHIT = "적중률",

        DMG = "주문 공격력",
        DMGUNDEAD = "언데드에 대한 주문 공격력",
        ARCANEDMG = "비전계 주문 공격력",
        FIREDMG = "화염계 주문 공격력",
        FROSTDMG = "냉기계 주문 공격력",
        HOLYDMG = "신성계 주문 공격력",
        NATUREDMG = "자연계 주문 공격력",
        SHADOWDMG = "암흑계 주문 공격력",
        SPELLCRIT = "주문 극대화율",
        SPELLTOHIT = "주문 적중율",
        SPELLPEN = "대상 저항 감소",
        HEAL = "치유 증가량",
        HOLYCRIT = "신성계 주문 극대화율",

        HEALTHREG = "생명력 회복",
        MANAREG = "마나 회복",
        HEALTH = "생명력",
        MANA = "마나"
      };


      PATTERNS_PASSIVE = {


        --[[		{ pattern = "비전 주문으로 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "ARCANECRIT" },
				{ pattern = "화염 주문으로 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "FIRECRIT" },
				{ pattern = "냉기 주문으로 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "FROSTCRIT" },
				{ pattern = "자연 주문으로 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "NATURECRIT" },
				{ pattern = "암흑 주문으로 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "SHADOWCRIT" },

				{ pattern = "비전 주문이 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "ARCANECRIT" },
				{ pattern = "화염 주문이 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "FIRECRIT" },
				{ pattern = "냉기 주문이 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "FROSTCRIT" },
				{ pattern = "자연 주문이 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "NATURECRIT" },
				{ pattern = "암흑 주문이 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "SHADOWCRIT" },]]

        { pattern = "매 5초마다 (%d+)의 생명력이 회복됩니다%.", effect = "HEALTHREG" },
        { pattern = "매 5초마다 (%d+)의 마나가 회복됩니다%.", effect = "MANAREG" },

        { pattern = "방어 숙련도 ++(%d+)", effect = "DEFENSE" },
        { pattern = "방패의 피해 방어량이 (%d+)만큼 증가합니다%.", effect = "BLOCKAMT" },
        --[[		{ pattern = "타격 시 (%d+)%%의 확률로 1회의 추가 공격을 합니다%.", effect = "XTRAHIT" },
				{ pattern = "상처를 내 (%d+)의 피해를 입힙니다%.", effect = "HIT_WOUND" },
				{ pattern = "적에게 어둠의 화살을 발사하여 %d+~(%d+)의 암흑 피해를 입힙니다%.", effect = "HIT_SHADOW" }]]

        { pattern = "전투력 ++(%d+)", effect = "ATTACKPOWER" },
        { pattern = "원거리 전투력 ++(%d+)", effect = "RANGEDATTACKPOWER" },
        { pattern = "방패로 적의 공격을 방어할 확률이 (%d+)%%만큼 증가합니다%.", effect = "BLOCK" },
        { pattern = "Increases the block value of your shield by (%d+)%.", effect = "BLOCKVALUE" },
        { pattern = "공격을 회피할 확률이 (%d+)%%만큼 증가합니다%.", effect = "DODGE" },
        { pattern = "무기 막기 확률이 (%d+)%%만큼 증가합니다%.", effect = "PARRY" },
        { pattern = "주문이 극대화 효과를 낼 확률이 (%d+)%%만큼 증가합니다%.", effect = "SPELLCRIT" },
        { pattern = "신성 주문으로 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "HOLYCRIT" },
        { pattern = "신성 주문이 극대화 효과를 발휘할 확률이 (%d+)%%만큼 증가합니다%.", effect = "HOLYCRIT" },
        { pattern = "치명타를 적중시킬 확률이 (%d+)%%만큼 증가합니다%.", effect = "CRIT" },
        { pattern = "원거리 무기로 치명타를 적중시킬 확률이 (%d+)%%만큼 증가합니다%.", effect = "RANGEDCRIT" },
        { pattern = "비전 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "ARCANEDMG" },
        { pattern = "화염 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "FIREDMG" },
        { pattern = "냉기 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "FROSTDMG" },
        { pattern = "신성 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "HOLYDMG" },
        { pattern = "자연 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "NATUREDMG" },
        { pattern = "암흑 계열의 주문과 효과의 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "SHADOWDMG" },
        { pattern = "모든 주문 및 효과에 의한 치유량이 최대 (%d+)만큼 증가합니다%.", effect = "HEAL" },
        { pattern = "모든 주문 및 효과에 의한 피해와 치유량이 최대 (%d+)만큼 증가합니다%.", effect = { "HEAL", "DMG" } },
        { pattern = "언데드에 대한 주문 및 효과에 의한 공격력이 최대 (%d+)만큼 증가합니다%.", effect = "DMGUNDEAD" },
        { pattern = "언데드에 대한 효과나 주문에 의한 피해가 최대 (%d+)만큼 증가합니다%.", effect = "DMGUNDEAD" },
        { pattern = "언데드 공격 시 전투력이 (%d+)만큼 증가합니다%.", effect = "ATTACKPOWERUNDEAD" },
        { pattern = "무기의 적중률이 (%d+)%%만큼 증가합니다%.", effect = "TOHIT" },
        { pattern = "주문의 적중률이 (%d+)%%만큼 증가합니다%.", effect = "SPELLTOHIT" },
        { pattern = "자신의 주문에 대한 대상의 마법 저항력을 (%d+)만큼 감소시킵니다%.", effect = "SPELLPEN" },
        { pattern = "표범, 광포한 곰, 곰 변신 상태일 때 전투력이 (%d+)만큼 증가합니다%.", effect = "ATTACKPOWERFERAL" },

        -- Atiesh related patterns
        { pattern = "주문의 공격력이 최대 (%d+)만큼 치유량을 최대 (%d+)만큼 증가합니다%.", effect = { "DMG", "HEAL" } },
        { pattern = "주위 %d+미터 반경에 있는 모든 파티원의 모든 주문 및 효과에 의한 치유량이 최대 (%d+)만큼 증가합니다%.", effect = "HEAL" },
        -- 	{ pattern = "Increases damage and healing done by magical spells and effects of all party members within %d+ yards by up to (%d+)%.", effect = {"HEAL", "DMG"} },
        { pattern = "주위 %d+미터 반경 내에 있는 모든 파티원의 마나가 매 5초마다 (%d+)만큼 회복됩니다%.", effect = "MANAREG" },
        { pattern = "주위 %d+미터 반경에 있는 모든 파티원의 주문 극대화 확률이 (%d+)%%만큼 증가합니다%.", effect = "SPELLCRIT" },

        -- Added for HealPoints
        { pattern = "시전 중에도 평소의 (%d+)%%에 달하는 속도로 마나가 회복됩니다%.", effect = "CASTINGREG" },
        { pattern = "자연 계열 주문이 치명타로 적중할 확률이 (%d+)%%만큼 증가합니다%.", effect = "NATURECRIT" },
        { pattern = "재생의 시전 시간이 0%.(%d+)초만큼 단축됩니다%.", effect = "CASTINGREGROWTH" },
        -- 	{ pattern = "Reduces the casting time of your Holy Light spell by 0%.(%d+) sec%.", effect = "CASTINGHOLYLIGHT"},
        -- 	{ pattern = "Reduces the casting time of your Healing Touch spell by 0%.(%d+) sec%.", effect = "CASTINGHEALINGTOUCH"},
        { pattern = "순간 치유의 시전 시간이 0%.(%d+)초만큼 단축됩니다%.", effect = "CASTINGFLASHHEAL" },
        { pattern = "연쇄 치유의 시전 시간이 0%.(%d+)초만큼 단축됩니다%.", effect = "CASTINGCHAINHEAL" },
        { pattern = "회복의 지속시간이 (%d+)만큼 증가합니다%.", effect = "DURATIONREJUV" },
        { pattern = "소생의 지속시간이 (%d+)초만큼 증가합니다%.", effect = "DURATIONRENEW" },
        { pattern = "평상시 생명력과 마나의 회복 속도를 (%d+)만큼 향상시킵니다%.", effect = "MANAREGNORMAL" },
        { pattern = "연쇄 치유 사용 시 처음 회복되는 대상 외에 치유되는 생명력이 각각 (%d+)%%만큼 증가합니다%.", effect = "IMPCHAINHEAL" },
        { pattern = "회복에 의한 치유량이 최대 (%d+)까지 증가합니다%.", effect = "IMPREJUVENATION" },
        { pattern = "하급 치유의 물결에 의한 치유량이 최대 (%d+)까지 증가합니다%.", effect = "IMPLESSERHEALINGWAVE" },
        { pattern = "빛의 섬광에 의한 치유량이 최대 (%d+)만큼 증가합니다%.", effect = "IMPFLASHOFLIGHT" },
        { pattern = "치유의 물결이나 하급 치유의 물결 시전 후 25%%의 확률로 소비된 마나의 (%d+)%%를 다시 회복합니다%.", effect = "REFUNDHEALINGWAVE" },
        { pattern = "치유의 물결 사용 시 추가로 주위 아군을 연쇄적으로 회복시킵니다%. 대상이 바뀔 때마다 치유 효과는 (%d+)%%씩 감소됩니다%. 최대 2명의 추가 대상에게 효력을 미칩니다%.", effect = "JUMPHEALINGWAVE" },
        { pattern = "치유의 손길%, 재생%, 회복%, 평온에 소비되는 마나가 (%d+)%%만큼 감소합니다%.", effect = "CHEAPERDRUID" },
        { pattern = "치유의 손길이 극대화 효과를 발휘할 시 주문에 소비된 마나의 (%d+)%%만큼을 회복합니다%.", effect = "REFUNDHTCRIT" },
        { pattern = "소생에 소비되는 마나가 (%d+)%%만큼 감소합니다%.", effect = "CHEAPERRENEW" },
      };

      PATTERNS_GENERIC_LOOKUP = {
        ["모든 능력치"] = { "STR", "AGI", "STA", "INT", "SPI" },
        ["힘"] = "STR",
        ["민첩성"] = "AGI",
        ["체력"] = "STA",
        ["지능"] = "INT",
        ["정신력"] = "SPI",

        ["모든 저항력"] = { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES" },

        ["낚시"] = "FISHING",
        ["낚시용 미끼"] = "FISHING",
        ["낚시 숙련도"] = "FISHING",
        ["채광"] = "MINING",
        ["약초 채집"] = "HERBALISM",
        ["무두질"] = "SKINNING",
        ["방어 숙련도"] = "DEFENSE",

        ["전투력"] = "ATTACKPOWER",
        ["언데드 공격 시 전투력"] = "ATTACKPOWERUNDEAD",
        -- 	["Attack Power in Cat, Bear, and Dire Bear forms only"] = "ATTACKPOWERFERAL",

        ["회피율"] = "DODGE",
        ["방어율"] = "BLOCK",
        ["방패 피해 방어량"] = "BLOCKVALUE",
        ["적중률"] = "TOHIT",
        ["주문 적중률"] = "SPELLTOHIT",
        -- 	["Blocking"]			= "BLOCK",
        ["원거리 전투력"] = "RANGEDATTACKPOWER",
        ["5초당 생명력 회복"] = "HEALTHREG",
        ["치유 주문 효과"] = "HEAL",
        ["치유량 증가"] = "HEAL",
        ["치유 효과 증가"] = "HEAL",
        ["치유 및 공격 주문 위력"] = { "HEAL", "DMG" },
        ["치유 및 주문 공격력"] = { "HEAL", "DMG" },
        -- 	["Spell Damage and Healing"] = {"HEAL", "DMG"},	
        ["5초당 마나 회복"] = "MANAREG",
        ["마나 회복"] = "MANAREG",
        ["주문 피해"] = { "HEAL", "DMG" },
        ["치명타"] = "CRIT",
        -- 	["Critical Hit"] 		= "CRIT",
        ["주문 공격력"] = "DMG",
        ["생명력"] = "HEALTH",
        -- 	["HP"]					= "HEALTH",
        ["마나"] = "MANA",
        ["방어도"] = "ARMOR",
        ["방어도 보강"] = "ARMOR",
      };

      PATTERNS_GENERIC_STAGE1 = {
        { pattern = "비전", effect = "ARCANE" },
        { pattern = "화염", effect = "FIRE" },
        { pattern = "냉기", effect = "FROST" },
        { pattern = "신성", effect = "HOLY" },
        { pattern = "암흑", effect = "SHADOW" },
        { pattern = "자연", effect = "NATURE" }
      };

      PATTERNS_GENERIC_STAGE2 = {
        { pattern = "저항", effect = "RES" },
        { pattern = "피해", effect = "DMG" },
        { pattern = "주문 공격력", effect = "DMG" },
        { pattern = "공격력", effect = "DMG" }
      };

      PATTERNS_OTHER = {
        { pattern = "Mana Regen (%d+) per 5 sec%.", effect = "MANAREG" },

        { pattern = "최하급 마술사 오일", effect = { "DMG", "HEAL" }, value = 8 },
        { pattern = "하급 마술사 오일", effect = { "DMG", "HEAL" }, value = 16 },
        { pattern = "마술사 오일", effect = { "DMG", "HEAL" }, value = 24 },
        { pattern = "반짝이는 마술사 오일", effect = { "DMG", "HEAL", "SPELLCRIT" }, value = { 36, 36, 1 } },

        { pattern = "최하급 마나 오일", effect = "MANAREG", value = 4 },
        { pattern = "하급 마나 오일", effect = "MANAREG", value = 8 },
        { pattern = "반짝이는 마나 오일", effect = { "MANAREG", "HEAL" }, value = { 12, 25 } },

        { pattern = "Eternium Line", effect = "FISHING", value = 5 },

        { pattern = "Healing %+31 and 5 mana per 5 sec%.", effect = { "MANAREG", "HEAL" }, value = { 5, 31 } },
        { pattern = "Stamina %+16 and Armor %+100", effect = { "STA", "ARMOR" }, value = { 16, 100 } },
        { pattern = "Attack Power %+26 and %+1%% Critical Strike", effect = { "ATTACKPOWER", "CRIT" }, value = { 26, 1 } },
        { pattern = "Spell Damage %+15 and %+1%% Spell Critical Strike", effect = { "DMG", "HEAL", "SPELLCRIT" }, value = { 15, 15, 1 } },

      }
    }
  end

  for _, p in ipairs(L.PATTERNS_PASSIVE) do
    p.pattern = "^" .. p.pattern .. "$"
    -- Perfect match only
  end
end