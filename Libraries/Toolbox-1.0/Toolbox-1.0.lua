--[[
Name: Toolbox-1.0
Revision: $Rev: 16120 $
Author: Kodewulf (kodewulf@gmail.com)
Website: http://www.wowace.com
Description: Collection of various utility functions
Dependencies: AceLibrary, AceOO-2.0
]]

local MAJOR_VERSION = "Toolbox-1.0"
local MINOR_VERSION = "$Rev: 16120 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end 
if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end

local L = AceLibrary("AceLocale-2.2"):new(MAJOR_VERSION)

L:RegisterTranslations("enUS", function() return {
    ["zero"] = true,
    ["one"] = true,
    ["two"] = true,
    ["three"] = true,
    ["four"] = true,
    ["five"] = true,
    ["six"] = true,
    ["seven"] = true,
    ["eight"] = true,
    ["nine"] = true,
    ["ten"] = true,
    ["eleven"] = true,
    ["twelve"] = true,
    ["thirteen"] = true,
    ["fourteen"] = true,
    ["fifteen"] = true,
    ["sixteen"] = true,
    ["seventeen"] = true,
    ["eighteen"] = true,
    ["nineteen"] = true,
    ["twenty"] = true,
    ["thirty"] = true,
    ["forty"] = true,
    ["fifty"] = true,
    ["sixty"] = true,
    ["seventy"] = true,
    ["eighty"] = true,
    ["ninety"] = true,
    ["hundred"] = true,
    ["thousand"] = true,
    ["million"] = true,
    ["and"] = true,
    ["dot"] = true,
    ["minus"] = true,
} end)

-- lua 5.1 check
if(not loadstring("return function(...) return ... end")  and true or false) then
	string.gmatch = string.gfind;
    math.fmod = math.mod;    
    table.maxn = table.getn;
end

local AceOO = AceLibrary:GetInstance("AceOO-2.0")

local Toolbox = AceOO.Mixin {"Trim",
                             "RTrim",
                             "LTrim",
                             "Split",
                             "Reverse",
                             "Commify",
                             "Wordify"
                            }

-- Trim whitespace from beginning and end of string
function Toolbox:Trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- Trim whitepace from beginning of string
function Toolbox:LTrim(s)
    return (string.gsub(s, "^%s*(.-)%s*", "%1"))
end

-- Trim whitespace from end of string
function Toolbox:RTrim(s)
    return (string.gsub(s, "%s*(.-)%s*$", "%1"))
end

-- Split a string based on pattern into a table
-- optionally trim each element
function Toolbox:Split(str, pat, trim)
    local ftrim = function (s) return s end
    if (not trim) then trim = true end
    if (trim == true) then ftrim = function (s) return self:Trim(s) end end

    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = string.find(str, fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, ftrim(cap))
        end
        last_end = e+1
        s, e, cap = string.find(str, fpat, last_end)
    end
    if last_end <= string.len(str) then
        cap = string.sub(str, last_end)
        table.insert(t, ftrim(cap))
    end
    
    return t
end

-- Reverse a string
-- Reverse("teststring") will return "gnirtstset"
function Toolbox:Reverse(fs)
    if (not fs) then return end
    if (type(fs) ~= "string") then return end
    if (string.len(fs) < 1) or (fs == "") then return end
    
    local rs = ""
    for i = string.len(fs), 0, -1 do
        rs = rs .. string.sub(fs, i, i)
    end

    return rs
end

-- Adds commas to numbers
-- Commify(10000) returns "10,000" as string
function Toolbox:Commify(number)
    if (not number) then return "" end
    if (type(number) == "string") then return number end
    if (type(number) ~= "number") then return "" end

    if (string.len(number) < 1) then return "" end
    local ns = self:Split(tostring(number), "%.")

    local rs = self:Reverse(ns[1])
    local cs = ""
    local sc = 0
    
    for i = string.len(rs), 0, -1 do
        if (sc == 3) and (i > 0) then
            cs = cs .. ","
            sc = 0
        end
        
        cs = cs .. string.sub(ns[1], i, i)
        sc = sc + 1
    end
    
    cs = self:Reverse(cs)
    if (ns[2] ~= nil) then cs = cs .. "." .. ns[2] end
    return cs
end

-- Number to words
-- Wordify(10000) returns "ten thousand" as string
-- Decimals are supported
function Toolbox:Wordify(number)
    if (not number) then return "" end
    local nt = self:Split(tostring(number), "%.")
    
    local nwords = {}
    nwords[0] = L["zero"]
    nwords[1] = L["one"]
    nwords[2] = L["two"]
    nwords[3] = L["three"]
    nwords[4] = L["four"]
    nwords[5] = L["five"]
    nwords[6] = L["six"]
    nwords[7] = L["seven"]
    nwords[8] = L["eight"]
    nwords[9] = L["nine"]
    nwords[10] = L["ten"]
    nwords[11] = L["eleven"]
    nwords[12] = L["twelve"]
    nwords[13] = L["thirteen"]
    nwords[14] = L["fourteen"]
    nwords[15] = L["fifteen"]
    nwords[16] = L["sixteen"]
    nwords[17] = L["seventeen"]
    nwords[18] = L["eighteen"]
    nwords[19] = L["nineteen"]
    nwords[20] = L["twenty"]
    nwords[30] = L["thirty"]
    nwords[40] = L["forty"]
    nwords[50] = L["fifty"]
    nwords[60] = L["sixty"]
    nwords[70] = L["seventy"]
    nwords[80] = L["eighty"]
    nwords[90] = L["ninety"]
        
    local function intToWords(number)
        --[[
            Ported from PHP code
            --------------------
            
            lixlpixel PHParadise
            http://www.fundisom.com/phparadise/php/string_handling/number_to_words
        --]]
    
        if (type(number) ~= "number") then return "#" end
        if (math.fmod(number, 1) ~= 0) then return "#" end
        
        local words = ''
        if (number < 0) then
            words = L["minus"] .. ' '
            number = -number
        end
        
        if (number < 21) then 
            words = words .. nwords[number]
        elseif (number < 100) then
            words = words .. nwords[10 * math.floor(number / 10)]
            r = math.fmod(number, 10)
            if (r > 0) then words = words .. '-' .. nwords[r] end
        elseif (number < 1000) then
            words = words .. nwords[math.floor(number / 100)] .. ' ' .. L["hundred"]
            r = math.fmod(number, 100)
            if (r > 0) then words = words .. ' and ' .. intToWords(r) end
        elseif (number < 1000000) then
            words = words .. intToWords(math.floor(number / 1000)) .. ' ' .. L["thousand"]
            r = math.fmod(number, 1000)
            if (r > 0) then
                words = words .. ' '
                if (r < 100) then words = words .. L["and"] .. ' ' end
                words = words .. intToWords(r)
            end
        else
            words = words .. intToWords(math.floor(number / 1000000)) .. ' ' .. L["million"]
            r = math.fmod(number, 1000000)
            if (r > 0) then
                words = words .. ' '
                if (r < 100) then words = words .. L["and"] .. ' ' end
                words = words .. intToWords(r)
            end
        end

        return words
    end
    
    local ns = intToWords(tonumber(nt[1]))
    if (nt[2] ~= nil) then
        ns = ns .. ' ' .. L["dot"] 
        for i = 1, string.len(nt[2]) do
            ns = ns .. ' ' .. nwords[tonumber(string.sub(nt[2], i, i))]
        end
    end

    return ns
end

AceLibrary:Register(Toolbox, MAJOR_VERSION, MINOR_VERSION, Toolbox.activate)
Toolbox = AceLibrary(MAJOR_VERSION)

