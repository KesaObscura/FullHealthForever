-- Full Health Forever - TEMPORARY probe (0.0.x). Remove this file, its TOC line, its
-- SavedVariables entry and its locale keys before 0.1 (see TODO.md).
--
-- Finds out what WoW Forever lets an addon know about health:
--   /fhf probe                  one snapshot to chat: which API exists, what is secret
--   /fhf probe watch [seconds]  events per second in chat, plus a test frame on screen that
--                               shows secret values the only way the game allows (formatted
--                               into a FontString, fed into a StatusBar, alpha from a curve
--                               or from a secret boolean)
--   /fhf probe stop             ends the watch early
-- Chat lines are also kept in FullHealthForeverProbeLog (SavedVariables).
-- Secret values are never printed to chat or stored: only marked as SECRET. Unit tokens
-- (party1 ...) are used, never player names. Texts stay English (bug reports).
-- Spell and item IDs below are candidates: the probe prints the game's own name for each,
-- so a wrong ID shows at once. Only what the game confirms goes into the addon later.

local _, ns = ...
local L = ns.L

local P = {}
ns.Probe = P

local MAX_RUNS = 8

local function IsSecret(v) return issecretvalue ~= nil and issecretvalue(v) or false end

local function Show(v)
  if IsSecret(v) then return "SECRET" end
  local t = type(v)
  if v == nil then return "nil" end
  if t == "number" then
    if v == math.floor(v) then return tostring(v) end
    return ("%.2f"):format(v)
  end
  if t == "string" then return '"' .. v:sub(1, 40) .. '"' end
  if t == "boolean" then return tostring(v) end
  return t -- table, userdata, function: the type is enough
end

local function Err(e)
  if IsSecret(e) then return "SECRET error" end
  e = tostring(e):gsub("^.-:%d+: ", "")
  return e:sub(1, 90)
end

-- log -----------------------------------------------------------------------------------

local run

local function NewRun(kind)
  FullHealthForeverProbeLog = type(FullHealthForeverProbeLog) == "table" and FullHealthForeverProbeLog or {}
  local db = FullHealthForeverProbeLog
  db.runs = type(db.runs) == "table" and db.runs or {}
  run = { kind = kind, version = ns.VERSION, when = date and date("%Y-%m-%d %H:%M:%S") or "?", lines = {} }
  table.insert(db.runs, run)
  while #db.runs > MAX_RUNS do table.remove(db.runs, 1) end
end

-- every argument must already be a plain string or number (use Show)
local function Out(fmt, ...)
  local ok, text = pcall(string.format, fmt, ...)
  if not ok then text = "format error: " .. Err(text) end
  print("|cff33dd55FHF|r " .. text)
  if run then run.lines[#run.lines + 1] = text end
end

local function Pack(...) return { n = select("#", ...), ... } end

-- calls fn, prints "label: r1, r2, ..." and returns the packed results (nil on error)
local function Try(label, fn, ...)
  if type(fn) ~= "function" then Out("%s: missing", label) return end
  local r = Pack(pcall(fn, ...))
  if not r[1] then Out("%s: ERROR %s", label, Err(r[2])) return end
  local parts = {}
  for i = 2, math.max(r.n, 2) do parts[#parts + 1] = Show(r[i]) end
  Out("%s: %s", label, table.concat(parts, ", "))
  return r
end

local function Call(fn, ...)
  if type(fn) ~= "function" then return nil end
  local ok, a, b, c, d = pcall(fn, ...)
  if ok then return a, b, c, d end
end

-- a method call that never raises (also when the object is missing or the method is)
local function Method(obj, name, ...)
  if obj == nil then return false end
  local okM, fn = pcall(function() return obj[name] end)
  if not okM or type(fn) ~= "function" then return false end
  return pcall(fn, obj, ...)
end

local function Get(path)
  local v = _G
  for part in path:gmatch("[^%.]+") do
    if type(v) ~= "table" then return nil end
    v = v[part]
  end
  return v
end

-- the fields of a returned table, as "key=value" (values through Show)
local function Fields(t, keys)
  if type(t) ~= "table" or IsSecret(t) then return Show(t) end
  local parts = {}
  if keys then
    for _, k in ipairs(keys) do parts[#parts + 1] = k .. "=" .. Show(t[k]) end
  else
    local names = {}
    for k in pairs(t) do if type(k) == "string" then names[#names + 1] = k end end
    table.sort(names)
    for _, k in ipairs(names) do parts[#parts + 1] = k .. "=" .. Show(t[k]) end
  end
  return table.concat(parts, " ")
end

local API = {
  "UnitHealth", "UnitHealthMax", "UnitHealthMissing", "UnitHealthPercent", "UnitGetIncomingHeals",
  "UnitGetTotalAbsorbs", "UnitGetTotalHealAbsorbs", "UnitGetDetailedHealPrediction",
  "CreateUnitHealPredictionCalculator", "GetUnitTotalModifiedMaxHealthPercent",
  "C_CurveUtil.CreateCurve", "C_CurveUtil.CreateColorCurve", "C_CurveUtil.EvaluateColorValueFromBoolean",
  "CurveConstants.ScaleTo100", "C_StringUtil.TruncateWhenZero", "C_DurationUtil.CreateDuration",
  "UnitInRange", "UnitGroupRolesAssigned", "UnitThreatSituation", "UnitDetailedThreatSituation",
  "GetSpecialization", "UnitIsDeadOrGhost", "IsPlayerSpell",
  "C_Spell.GetSpellCooldown", "C_Spell.GetSpellCooldownDuration", "GetSpellBaseCooldown",
  "C_Item.GetItemCooldown", "C_Container.GetItemCooldown", "C_Item.GetItemCount", "C_Item.GetItemSpell",
  "C_UnitAuras.GetPlayerAuraBySpellID", "C_UnitAuras.AuraIsBigDefensive",
  "C_Secrets.HasSecretRestrictions", "C_Secrets.GetSpellAuraSecrecy", "C_Secrets.GetSpellCooldownSecrecy",
  "C_RestrictedActions.GetAddOnRestrictionState",
  "C_DamageMeter.IsDamageMeterAvailable", "C_DamageMeter.GetCombatSessionFromType",
  "C_DeathRecap.GetRecapEvents", "C_CombatAudioAlert.IsEnabled", "issecretvalue",
}

-- candidates, checked by the game's own names; rank 1 where a spell has ranks
local DEFENSIVES = {
  871, 12975, 2565, 20230,        -- Shield Wall, Last Stand, Shield Block, Retaliation
  642, 498, 1022, 633,            -- Divine Shield, Divine Protection, Blessing of Protection, Lay on Hands
  17, 13908,                      -- Power Word: Shield, Desperate Prayer
  22812, 22842,                   -- Barkskin, Frenzied Regeneration
  5277, 1856,                     -- Evasion, Vanish
  11958, 11426, 1463,             -- Ice Block, Ice Barrier, Mana Shield
  5384, 19263,                    -- Feign Death, Deterrence
  6789, 6229,                     -- Death Coil, Shadow Ward
  20594,                          -- Stoneform
}
local AURAS = { 11196, 25771, 6788 } -- Recently Bandaged, Forbearance, Weakened Soul
local ITEMS = {
  118, 858, 929, 1710, 3928, 13446,                     -- healing potions, Minor .. Major
  5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008,  -- healthstones
  19009, 5510, 19010, 19011, 9421, 19012, 19013,
  1251, 2581, 3530, 3531, 6450, 6451, 8544, 8545, 14529, 14530, -- bandages
}

-- a step curve 0..1 -> alpha 1 below `at`, 0 from `at` on (FMF builds them the same way)
local function StepColorCurve(points)
  if not (C_CurveUtil and C_CurveUtil.CreateColorCurve) then return end
  local ok, c = pcall(function()
    local c = C_CurveUtil.CreateColorCurve()
    if Enum and Enum.LuaCurveType and c.SetType then c:SetType(Enum.LuaCurveType.Step) end
    for _, p in ipairs(points) do c:AddPoint(p[1], CreateColor(1, 1, 1, p[2])) end
    return c
  end)
  if ok then return c end
end

local function StepCurve() return StepColorCurve({ { 0, 1 }, { 0.5, 0 } }) end
-- remaining cooldown in seconds: alpha 1 when (almost) nothing is left
local function ReadyCurve() return StepColorCurve({ { 0, 1 }, { 0.1, 0 } }) end

local CALC_METHODS = { "GetIncomingHeals", "GetIncomingHealOverflowPercent", "GetCurrentHealthPercent",
  "GetCurrentHealth", "GetMaximumHealth", "GetDamageAbsorbs", "GetHealAbsorbs", "HasSecretValues" }

-- the methods an object really has (names only), so we do not guess them
local function MethodNames(obj)
  local names = {}
  local ok, mt = pcall(getmetatable, obj)
  local idx = ok and type(mt) == "table" and mt.__index
  if type(idx) == "table" then
    for k, v in pairs(idx) do
      if type(k) == "string" and type(v) == "function" then names[#names + 1] = k end
    end
  end
  table.sort(names)
  return names
end

local function NewCalculator(overflow)
  if type(CreateUnitHealPredictionCalculator) ~= "function" then return end
  local ok, c = pcall(CreateUnitHealPredictionCalculator)
  if not ok or c == nil then return end
  if overflow then
    local mode = Enum and Enum.UnitIncomingHealClampMode and Enum.UnitIncomingHealClampMode.MissingHealth
    if mode then Method(c, "SetIncomingHealClampMode", mode) end
    Method(c, "SetIncomingHealOverflowPercent", overflow)
  end
  return c
end

local function S100() return CurveConstants and CurveConstants.ScaleTo100 end

local function GroupUnits()
  local units = {}
  if IsInRaid and IsInRaid() then
    for i = 1, 40 do units[#units + 1] = "raid" .. i end
  elseif IsInGroup and IsInGroup() then
    for i = 1, 4 do units[#units + 1] = "party" .. i end
  end
  local out = {}
  for _, u in ipairs(units) do
    local ok, e = pcall(UnitExists, u)
    if ok and not IsSecret(e) and e then out[#out + 1] = u end
    if #out >= 4 then break end
  end
  return out
end

local function SpellName(id)
  local n = C_Spell and Call(C_Spell.GetSpellName, id)
  if n == nil and GetSpellInfo then n = Call(GetSpellInfo, id) end
  return n
end

-- the player's own spells: id, name; only what the spell book lists, no other IDs
local function BookSpells()
  local out = {}
  local book = C_SpellBook
  if not (book and book.GetNumSpellBookSkillLines and book.GetSpellBookSkillLineInfo and book.GetSpellBookItemInfo) then
    return out
  end
  local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
  local future = Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.FutureSpell
  local lines = Call(book.GetNumSpellBookSkillLines) or 0
  for i = 1, lines do
    local line = Call(book.GetSpellBookSkillLineInfo, i)
    if type(line) == "table" and type(line.itemIndexOffset) == "number" and type(line.numSpellBookItems) == "number" then
      for j = line.itemIndexOffset + 1, line.itemIndexOffset + line.numSpellBookItems do
        local it = Call(book.GetSpellBookItemInfo, j, bank)
        if type(it) == "table" and type(it.spellID) == "number" and type(it.name) == "string"
          and not it.isPassive and not (future and it.itemType == future) then
          out[#out + 1] = { id = it.spellID, name = it.name }
        end
      end
    end
  end
  return out
end

-- own defensive spells: the spell book entries the game calls a big defensive, or that carry
-- the name of a candidate. The highest rank (last in the book) is kept per name.
local function MyDefensives()
  local wanted = {}
  for _, id in ipairs(DEFENSIVES) do
    local n = SpellName(id)
    if type(n) == "string" and not IsSecret(n) then wanted[n] = true end
  end
  local big = C_UnitAuras and C_UnitAuras.AuraIsBigDefensive
  local byName, order = {}, {}
  for _, sp in ipairs(BookSpells()) do
    local isBig = big and Call(big, sp.id)
    if wanted[sp.name] or (not IsSecret(isBig) and isBig == true) then
      if not byName[sp.name] then order[#order + 1] = sp.name end
      byName[sp.name] = sp.id
    end
  end
  local out = {}
  for _, n in ipairs(order) do out[#out + 1] = { id = byName[n], name = n } end
  return out
end

-- snapshot sections ------------------------------------------------------------------------

local RESTRICTIONS = { "Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map", "Chat" }

local function Restrictions()
  local get = C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState
  if not get then Out("restrictions: no API") return end
  local parts = {}
  for i, name in ipairs(RESTRICTIONS) do
    local v = Enum and Enum.AddOnRestrictionType and Enum.AddOnRestrictionType[name] or (i - 1)
    parts[#parts + 1] = name .. "=" .. Show(Call(get, v))
  end
  Out("restrictions (0 off, 1 activating, 2 on): %s", table.concat(parts, " "))
  local s = C_Secrets
  if s then
    Out("secrets: build=%s auras=%s cooldowns=%s stats=%s healthMax=%s",
      Show(Call(s.HasSecretRestrictions)), Show(Call(s.ShouldAurasBeSecret)), Show(Call(s.ShouldCooldownsBeSecret)),
      Show(Call(s.ShouldUnitStatsBeSecret)), Show(Call(s.ShouldUnitHealthMaxBeSecret, "player")))
  end
end

local function Health(p, curve)
  Try("UnitHealth(p)", UnitHealth, p)
  Try("UnitHealth(p,true)", UnitHealth, p, true)
  Try("UnitHealthMax(p)", UnitHealthMax, p)
  Try("UnitHealthMissing(p,true)", UnitHealthMissing, p, true)
  Try("GetUnitTotalModifiedMaxHealthPercent(p)", GetUnitTotalModifiedMaxHealthPercent, p)
  local s100 = S100()
  Out("ScaleTo100=%s  stepCurve=%s", Show(s100), Show(curve))
  Try("UnitHealthPercent(p)", UnitHealthPercent, p)
  Try("UnitHealthPercent(p,false)", UnitHealthPercent, p, false)
  Try("UnitHealthPercent(p,true)", UnitHealthPercent, p, true)
  if s100 then
    Try("UnitHealthPercent(p,false,S100)", UnitHealthPercent, p, false, s100)
    Try("UnitHealthPercent(p,true,S100)", UnitHealthPercent, p, true, s100)
    Try("UnitHealthPercent(p,S100)", UnitHealthPercent, p, s100)
  end
  if curve then
    Try("UnitHealthPercent(p,false,curve)", UnitHealthPercent, p, false, curve)
    Try("UnitHealthPercent(p,curve)", UnitHealthPercent, p, curve)
  end
end

local function Prediction(p, curve)
  Try("UnitGetIncomingHeals(p)", UnitGetIncomingHeals, p)
  Try("UnitGetIncomingHeals(p,p)", UnitGetIncomingHeals, p, p)
  Try("UnitGetTotalAbsorbs(p)", UnitGetTotalAbsorbs, p)
  Try("UnitGetTotalHealAbsorbs(p)", UnitGetTotalHealAbsorbs, p)
  local calc = NewCalculator()
  if not calc then Out("calculator: none") return end
  local names = MethodNames(calc)
  Out("calculator methods: %s", #names > 0 and table.concat(names, " ") or "(not listed)")
  Try("UnitGetDetailedHealPrediction(p,p,calc)", UnitGetDetailedHealPrediction, p, p, calc)
  for _, m in ipairs(CALC_METHODS) do
    local r = Pack(Method(calc, m))
    if r[1] then
      local parts = {}
      for i = 2, math.max(r.n, 2) do parts[#parts + 1] = Show(r[i]) end
      Out("  calc:%s: %s", m, table.concat(parts, ", "))
    end
  end
  if curve then
    local ok, col = Method(calc, "EvaluateCurrentHealthPercent", curve)
    Out("  calc:EvaluateCurrentHealthPercent(curve): %s", ok and Show(col) or "ERROR")
  end
  -- the overflow idea: with clamp mode MissingHealth, "clamped" may mean
  -- health + incoming heals > overflow x max health. Does the game take values below 1?
  for _, o in ipairs({ 0.5, 0.8, 1 }) do
    local c = NewCalculator(o)
    if c then
      Call(UnitGetDetailedHealPrediction, p, nil, c)
      local okO, back = Method(c, "GetIncomingHealOverflowPercent")
      local okI, amount, _, _, clamped = Method(c, "GetIncomingHeals")
      Out("  overflow %s: read back %s, incoming %s, clamped %s", Show(o), okO and Show(back) or "ERROR",
        okI and Show(amount) or "ERROR", okI and Show(clamped) or "ERROR")
    end
  end
end

-- can a StatusBar / texture take the values? (how a bar or icon would draw them)
local function Drawing(p)
  local okF, bar = pcall(CreateFrame, "StatusBar")
  if not (okF and bar) then Out("StatusBar: cannot create") return end
  Try("bar:SetMinMaxValues(0,max)", bar.SetMinMaxValues, bar, 0, Call(UnitHealthMax, p) or 1)
  local okH, hp = pcall(UnitHealth, p)
  if okH then Try("bar:SetValue(health)", bar.SetValue, bar, hp) end
  local okI, inc = pcall(UnitGetIncomingHeals or error, p)
  if okI and type(inc) ~= "nil" then Try("bar:SetValue(incoming)", bar.SetValue, bar, inc) end
  local tex = bar:CreateTexture()
  local calc = NewCalculator(0.5)
  if calc then
    Call(UnitGetDetailedHealPrediction, p, nil, calc)
    local _, _, _, _, clamped = Method(calc, "GetIncomingHeals")
    local okA = Method(tex, "SetAlphaFromBoolean", clamped, 0, 1)
    Out("texture:SetAlphaFromBoolean(clamped50): %s", okA and "ok" or "ERROR or missing")
  end
  local okT, txt = pcall(C_StringUtil and C_StringUtil.TruncateWhenZero or error, hp)
  Out("C_StringUtil.TruncateWhenZero(health): %s", okT and Show(txt) or "ERROR or missing")
  bar:Hide()
end

local function Threat()
  Try("UnitThreatSituation(p)", UnitThreatSituation, "player")
  Try("UnitThreatSituation(p,target)", UnitThreatSituation, "player", "target")
  Try("UnitDetailedThreatSituation(p,target)", UnitDetailedThreatSituation, "player", "target")
end

local function DamageMeter()
  local dm = C_DamageMeter
  if not dm then Out("damage meter: none") return end
  Try("C_DamageMeter.IsDamageMeterAvailable", dm.IsDamageMeterAvailable)
  local cur = Enum and Enum.DamageMeterSessionType and Enum.DamageMeterSessionType.Current or 1
  local taken = Enum and Enum.DamageMeterType and Enum.DamageMeterType.DamageTaken or 7
  Try("C_DamageMeter.GetSessionDurationSeconds(current)", dm.GetSessionDurationSeconds, cur)
  local ok, s = pcall(dm.GetCombatSessionFromType or error, cur, taken)
  if not ok then Out("damage taken session: ERROR %s", Err(s)) return end
  Out("damage taken session: %s", Fields(s, { "totalAmount", "maxAmount", "durationSeconds" }))
  if type(s) == "table" and not IsSecret(s) and type(s.combatSources) == "table" and not IsSecret(s.combatSources) then
    Out("  sources: %d", #s.combatSources)
    for _, src in ipairs(s.combatSources) do
      if type(src) == "table" and src.isLocalPlayer == true then
        Out("  me: %s", Fields(src, { "totalAmount", "amountPerSecond", "deathRecapID", "deathTimeSeconds" }))
      end
    end
  end
  local dr = C_DeathRecap
  if dr then
    Try("C_DeathRecap.HasRecapEvents()", dr.HasRecapEvents)
    local okE, events = pcall(dr.GetRecapEvents or error)
    if okE and type(events) == "table" and not IsSecret(events) then
      Out("death recap: %d events; first: %s", #events, Fields(events[1]))
    end
    Try("C_DeathRecap.GetRecapMaxHealth()", dr.GetRecapMaxHealth)
  end
end

local function Defensives()
  local list = MyDefensives()
  if #list == 0 then Out("defensives: none known (candidates or big defensive)") end
  local s = C_Secrets or {}
  local readyCurve = ReadyCurve()
  for _, sp in ipairs(list) do
    local base = Call(GetSpellBaseCooldown, sp.id)
    local big = C_UnitAuras and Call(C_UnitAuras.AuraIsBigDefensive, sp.id)
    Out("def %s %s: baseCD=%s big=%s cdSecrecy=%s auraSecrecy=%s cdSecretNow=%s", Show(sp.id), Show(sp.name),
      Show(base), Show(big), Show(Call(s.GetSpellCooldownSecrecy, sp.id)), Show(Call(s.GetSpellAuraSecrecy, sp.id)),
      Show(Call(s.ShouldSpellCooldownBeSecret, sp.id)))
    local cd = C_Spell and Call(C_Spell.GetSpellCooldown, sp.id)
    Out("  cooldown: %s", Fields(cd, { "isActive", "isOnGCD", "isEnabled", "startTime", "duration" }))
    local okD, dur = pcall(C_Spell and C_Spell.GetSpellCooldownDuration or error, sp.id, true)
    if okD and type(dur) ~= "nil" then
      local _, secret = Method(dur, "HasSecretValues")
      local okE, col = Method(dur, "EvaluateRemainingDuration", readyCurve)
      Out("  duration object: secretValues=%s evaluate(curve)=%s", Show(secret), okE and Show(col) or "ERROR")
    else
      Out("  duration object: %s", okD and "nil" or ("ERROR " .. Err(dur)))
    end
  end
  P.defensive = list[1]
end

local function Auras()
  local s = C_Secrets or {}
  for _, id in ipairs(AURAS) do
    local a = C_UnitAuras and Call(C_UnitAuras.GetPlayerAuraBySpellID, id)
    Out("aura %s %s: secrecy=%s secretNow=%s on me=%s", Show(id), Show(SpellName(id)), Show(Call(s.GetSpellAuraSecrecy, id)),
      Show(Call(s.ShouldSpellAuraBeSecret, id)), a and Fields(a, { "duration", "expirationTime" }) or "no")
  end
end

local function ItemCooldown(id)
  if C_Container and C_Container.GetItemCooldown then return Call(C_Container.GetItemCooldown, id) end
  return Call(GetItemCooldown, id)
end

local function ItemCount(id)
  if C_Item and C_Item.GetItemCount then return Call(C_Item.GetItemCount, id) end
  return Call(GetItemCount, id)
end

local function Items()
  local any = false
  for _, id in ipairs(ITEMS) do
    local n = ItemCount(id)
    if type(n) == "number" and not IsSecret(n) and n > 0 then
      any = true
      local start, dur, enable = ItemCooldown(id)
      local spellName, spellID = Call(C_Item and C_Item.GetItemSpell, id) -- not "x and f()": one value only
      Out("item %s x%s: cd start=%s dur=%s enable=%s  spell=%s %s", Show(id), Show(n), Show(start), Show(dur),
        Show(enable), Show(spellID), Show(spellName))
    end
  end
  if not any then Out("items: none of the candidate potions, healthstones, bandages in the bags") end
  -- other consumables with a use spell (new Forever items such as tourniquets, poultices)
  local c = C_Container
  if not (c and c.GetContainerNumSlots and c.GetContainerItemInfo) then return end
  local seen, shown = {}, 0
  for _, id in ipairs(ITEMS) do seen[id] = true end
  for bag = 0, 4 do
    for slot = 1, Call(c.GetContainerNumSlots, bag) or 0 do
      local info = Call(c.GetContainerItemInfo, bag, slot)
      local id = type(info) == "table" and info.itemID
      if type(id) == "number" and not seen[id] and shown < 20 then
        seen[id] = true
        local spellName, spellID = Call(C_Item and C_Item.GetItemSpell, id) -- not "x and f()": one value only
        local classID
        if C_Item and C_Item.GetItemInfoInstant then
          local okI, _, _, _, _, _, cls = pcall(C_Item.GetItemInfoInstant, id)
          if okI then classID = cls end
        end
        if spellID and classID == 0 then
          shown = shown + 1
          local start, dur = ItemCooldown(id)
          Out("bag consumable %s: spell=%s %s cd start=%s dur=%s", Show(id), Show(spellID), Show(spellName),
            Show(start), Show(dur))
        end
      end
    end
  end
end

local function Group(curve)
  for _, u in ipairs(GroupUnits()) do
    Try(u .. " UnitHealth", UnitHealth, u)
    Try(u .. " UnitHealthMax", UnitHealthMax, u)
    if curve then Try(u .. " UnitHealthPercent(false,curve)", UnitHealthPercent, u, false, curve) end
    Try(u .. " UnitInRange", UnitInRange, u)
    Try(u .. " UnitGroupRolesAssigned", UnitGroupRolesAssigned, u)
    Try(u .. " UnitGetIncomingHeals", UnitGetIncomingHeals, u)
    Try(u .. " UnitThreatSituation", UnitThreatSituation, u)
    Try(u .. " UnitClass", function() return select(2, UnitClass(u)) end)
  end
end

local function Section(name, fn, ...)
  local ok, e = pcall(fn, ...)
  if not ok then Out("section %s: ERROR %s", name, Err(e)) end
end

function P.Snapshot()
  NewRun("snapshot")
  local build = GetBuildInfo and select(4, GetBuildInfo())
  Out("probe %s  interface=%s  combat=%s  group=%s  raid=%s  class=%s  level=%s", ns.VERSION, Show(build),
    Show(InCombatLockdown and InCombatLockdown()), Show(IsInGroup and IsInGroup()), Show(IsInRaid and IsInRaid()),
    Show(Call(function() return select(2, UnitClass("player")) end)), Show(Call(UnitLevel, "player")))
  local inInstance, kind = Call(IsInInstance)
  Out("instance=%s type=%s", Show(inInstance), Show(kind))

  local yes, no = {}, {}
  for _, name in ipairs(API) do
    if Get(name) ~= nil then yes[#yes + 1] = name else no[#no + 1] = name end
  end
  Out("API yes: %s", table.concat(yes, " "))
  Out("API no: %s", #no > 0 and table.concat(no, " ") or "-")

  local p, curve = "player", StepCurve()
  Section("restrictions", Restrictions)
  Section("health", Health, p, curve)
  Section("prediction", Prediction, p, curve)
  Section("drawing", Drawing, p)
  Section("threat", Threat)
  Section("damage meter", DamageMeter)
  Section("defensives", Defensives)
  Section("auras", Auras)
  Section("items", Items)
  Try("GetSpecialization()", GetSpecialization)
  Try("UnitGroupRolesAssigned(p)", UnitGroupRolesAssigned, p)
  Section("group", Group, curve)
  ns.Print(L.snapDone)
end

-- watch -----------------------------------------------------------------------------------

local UNIT_EVENTS = { "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH", "UNIT_COMBAT",
  "UNIT_HEAL_PREDICTION", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "UNIT_AURA",
  "UNIT_SPELLCAST_SUCCEEDED", "UNIT_THREAT_SITUATION_UPDATE" }
local OTHER_EVENTS = { "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ADDON_RESTRICTION_STATE_CHANGED",
  "DAMAGE_METER_CURRENT_SESSION_UPDATED", "PLAYER_DEAD", "SPELL_UPDATE_COOLDOWN", "BAG_UPDATE_COOLDOWN" }
local SHORT = { UNIT_HEALTH = "H", UNIT_HEALTH_FREQUENT = "HF", UNIT_MAXHEALTH = "MAX", UNIT_COMBAT = "C",
  UNIT_HEAL_PREDICTION = "HP", UNIT_ABSORB_AMOUNT_CHANGED = "AB", UNIT_HEAL_ABSORB_AMOUNT_CHANGED = "HA",
  UNIT_AURA = "AU", UNIT_SPELLCAST_SUCCEEDED = "CAST", UNIT_THREAT_SITUATION_UPDATE = "THR",
  PLAYER_REGEN_DISABLED = "IN", PLAYER_REGEN_ENABLED = "OUT", ADDON_RESTRICTION_STATE_CHANGED = "RS",
  DAMAGE_METER_CURRENT_SESSION_UPDATED = "DM", PLAYER_DEAD = "DEAD", SPELL_UPDATE_COOLDOWN = "SCD",
  BAG_UPDATE_COOLDOWN = "BCD" }
local ALL_EVENTS = {}
for _, e in ipairs(UNIT_EVENTS) do ALL_EVENTS[#ALL_EVENTS + 1] = e end
for _, e in ipairs(OTHER_EVENTS) do ALL_EVENTS[#ALL_EVENTS + 1] = e end
local IS_UNIT = {}
for _, e in ipairs(UNIT_EVENTS) do IS_UNIT[e] = true end

local W = { running = false }
P.state = W -- for the tests

local function Text(fs, fmt, ...)
  local ok, s = pcall(string.format, fmt, ...)
  if not ok then s = "n/a" end
  if not pcall(fs.SetText, fs, s) then pcall(fs.SetText, fs, "n/a") end
end

local function FontObj()
  return _G.GameFontHighlightSmallOutline or _G.GameFontHighlightOutline or _G.GameFontHighlightSmall
end

local function MakeBar(parent, y, r, g, b)
  local bar = CreateFrame("StatusBar", nil, parent)
  bar:SetSize(260, 10)
  bar:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
  bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  bar:SetStatusBarColor(r, g, b)
  bar:SetMinMaxValues(0, 1)
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  return bar
end

local function MakeSquare(parent, x, y, r, g, b)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetSize(14, 14)
  t:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y)
  t:SetColorTexture(r, g, b, 1)
  return t
end

local NUM_LINES = 9

-- the on-screen frame: no mouse (nothing to click), top centre
local function Frame()
  if W.frame then return W.frame end
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetSize(300, 250)
  f:SetPoint("TOP", UIParent, "TOP", 0, -120)
  f:SetFrameStrata("HIGH")
  f:EnableMouse(false)
  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.6)
  W.lines = {}
  for i = 1, NUM_LINES do
    local fs = f:CreateFontString(nil, "OVERLAY")
    local obj = FontObj()
    if obj then fs:SetFontObject(obj) end
    fs:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -6 - (i - 1) * 14)
    fs:SetJustifyH("LEFT")
    W.lines[i] = fs
  end
  -- squares on the right of the lines they belong to: red = "health + incoming heals at or
  -- below 50 %" (line 4), orange = the same for 80 % (line 4), green = own defensive ready
  -- (line 7), white = health below 50 % by the curve (line 1)
  W.sqLow = MakeSquare(f, -6, -6, 1, 1, 1)
  W.sq50 = MakeSquare(f, -24, -48, 1, 0.2, 0.2)
  W.sq80 = MakeSquare(f, -6, -48, 1, 0.6, 0.1)
  W.sqDef = MakeSquare(f, -6, -90, 0.2, 1, 0.3)
  -- green: health now; grey: health 2 s ago (the gap is the damage of the last 2 s);
  -- blue: incoming heals; yellow: absorbs
  W.barNow = MakeBar(f, -136, 0.2, 0.9, 0.3)
  W.barAgo = MakeBar(f, -150, 0.6, 0.6, 0.6)
  W.barInc = MakeBar(f, -164, 0.3, 0.6, 1)
  W.barAbs = MakeBar(f, -178, 1, 0.85, 0.2)
  W.frame = f
  return f
end

local RING = 20 -- samples of 0.1 s: 2 s

local function SetBar(bar, max, value, key)
  if max then pcall(bar.SetMinMaxValues, bar, 0, max) end
  if type(value) == "nil" then return end -- type(): no comparison of a secret
  local ok = pcall(bar.SetValue, bar, value)
  W.barOk[key] = W.barOk[key] or ok
  W.barFail[key] = W.barFail[key] or not ok
end

local function ApplyColorAlpha(region, color, key)
  if type(color) == "nil" then pcall(region.SetAlpha, region, 0.15) return end -- type(): no secret test
  local ok, _, _, _, a = pcall(function() return color:GetRGBA() end)
  local fine = ok and pcall(region.SetAlpha, region, a)
  W.sqOk[key] = W.sqOk[key] or fine
  if not fine then pcall(region.SetAlpha, region, 0.15) end
end

local function ApplyBool(region, flag, ifTrue, ifFalse, key)
  local fine = Method(region, "SetAlphaFromBoolean", flag, ifTrue, ifFalse)
  W.sqOk[key] = W.sqOk[key] or fine
  if not fine then pcall(region.SetAlpha, region, 0.15) end
end

local function Refresh()
  local p = "player"
  local hp, max = Call(UnitHealth, p), Call(UnitHealthMax, p)
  local s100 = S100()
  local pf = s100 and Call(UnitHealthPercent, p, false, s100)
  local pt = s100 and Call(UnitHealthPercent, p, true, s100)
  local inc, abs, habs = Call(UnitGetIncomingHeals, p), Call(UnitGetTotalAbsorbs, p), Call(UnitGetTotalHealAbsorbs, p)

  -- a secret may be kept in a table and handed to a bar later: the "2 s ago" bar
  W.ring[W.ringPos] = hp
  W.ringPos = W.ringPos % RING + 1
  local ago = W.ring[W.ringPos]

  local l = W.lines
  Text(l[1], "health %s / %s", hp, max)
  Text(l[2], "pct false %s   true %s", pf, pt)
  Text(l[3], "incoming %s  absorb %s  healAbs %s", inc, abs, habs)
  if W.calc50 then
    Call(UnitGetDetailedHealPrediction, p, nil, W.calc50)
    Call(UnitGetDetailedHealPrediction, p, nil, W.calc80)
    local _, _, _, _, c50 = Method(W.calc50, "GetIncomingHeals")
    local _, _, _, _, c80 = Method(W.calc80, "GetIncomingHeals")
    -- clamped = above the line, so the square shows when NOT clamped
    ApplyBool(W.sq50, c50, 0.1, 1, "50")
    ApplyBool(W.sq80, c80, 0.1, 1, "80")
    Text(l[4], "health+heals <= 50 %% red, <= 80 %% orange")
  else
    Text(l[4], "calculator: none")
  end
  ApplyColorAlpha(W.sqLow, W.lowCurve and Call(UnitHealthPercent, p, false, W.lowCurve), "low")
  Text(l[5], "last UNIT_COMBAT: %s %s %s", W.lastAction, W.lastAmount, W.lastFlag)
  local thr = Call(UnitThreatSituation, "player")
  Text(l[6], "threat %s   damage taken/s %s", thr, W.dtps)
  if W.def then
    local cd = C_Spell and Call(C_Spell.GetSpellCooldown, W.def.id)
    local active = type(cd) == "table" and not IsSecret(cd) and cd.isActive
    local okD, dur = pcall(C_Spell and C_Spell.GetSpellCooldownDuration or error, W.def.id, true)
    local okE, col = false, nil
    if okD and type(dur) ~= "nil" then okE, col = Method(dur, "EvaluateRemainingDuration", W.readyCurve) end
    if not okE then col = nil end -- never "ok and secret or nil": that tests the secret
    ApplyColorAlpha(W.sqDef, col, "def")
    Text(l[7], "%s: isActive %s (green = ready)", W.def.name, Show(active))
  else
    Text(l[7], "no own defensive found")
  end
  Text(l[8], "combat %s   %d s left", InCombatLockdown and InCombatLockdown() and "yes" or "no",
    math.max(0, math.floor(W.stopAt - GetTime() + 0.5)))
  Text(l[9], "bars: now / 2 s ago / incoming / absorb")

  SetBar(W.barNow, max, hp, "health")
  SetBar(W.barAgo, max, ago, "ago")
  SetBar(W.barInc, max, inc, "incoming")
  SetBar(W.barAbs, max, abs, "absorb")
end

local function ReadDamageMeter()
  local dm = C_DamageMeter
  if not (dm and dm.GetCombatSessionFromType) then return end
  local cur = Enum and Enum.DamageMeterSessionType and Enum.DamageMeterSessionType.Current or 1
  local taken = Enum and Enum.DamageMeterType and Enum.DamageMeterType.DamageTaken or 7
  local s = Call(dm.GetCombatSessionFromType, cur, taken)
  if type(s) ~= "table" or IsSecret(s) or type(s.combatSources) ~= "table" or IsSecret(s.combatSources) then return end
  for _, src in ipairs(s.combatSources) do
    if type(src) == "table" and src.isLocalPlayer == true then W.dtps = src.amountPerSecond end
  end
end

local function CountLine(now)
  local parts = {}
  for _, e in ipairs(ALL_EVENTS) do
    local n = W.sec[e] or 0
    if n > 0 then parts[#parts + 1] = SHORT[e] .. "=" .. n end
  end
  Out("%2d s combat=%s %s", math.floor(now - W.start + 0.5), Show(InCombatLockdown and InCombatLockdown()),
    #parts > 0 and table.concat(parts, " ") or "-")
  W.sec = {}
end

local function Count(event)
  W.sec[event] = (W.sec[event] or 0) + 1
  W.total[event] = (W.total[event] or 0) + 1
end

local function OnEvent(_, event, a0, a1, a2, a3, a4)
  if not W.running then return end
  if not IS_UNIT[event] then
    Count(event)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
      Out("%s", event)
      Restrictions()
    elseif event == "ADDON_RESTRICTION_STATE_CHANGED" then
      Out("restriction %s -> %s", Show(a0), Show(a1))
    elseif event == "DAMAGE_METER_CURRENT_SESSION_UPDATED" then
      pcall(ReadDamageMeter)
    end
    return
  end
  local unit = a0
  if IsSecret(unit) or unit ~= "player" then
    if event == "UNIT_COMBAT" or event == "UNIT_HEALTH" then W.other = (W.other or 0) + 1 end
    return
  end
  Count(event)
  if event == "UNIT_COMBAT" then
    -- (unit, action, flag, amount, school): keep the values for the screen, print only types
    W.lastAction, W.lastFlag, W.lastAmount = a1, a2, a3
    if (W.combatPrinted or 0) < 16 then
      W.combatPrinted = (W.combatPrinted or 0) + 1
      Out("UNIT_COMBAT action=%s flag=%s amount=%s school=%s", Show(a1), Show(a2), Show(a3), Show(a4))
    end
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
    Out("cast spellID=%s", Show(a2))
  end
end

local function OnUpdate(_, elapsed)
  if not W.running then return end
  W.acc = (W.acc or 0) + (elapsed or 0)
  if W.acc < 0.1 then return end
  W.acc = 0
  local now = GetTime()
  pcall(Refresh)
  if now - W.lastLine >= 1 then
    W.lastLine = now
    pcall(CountLine, now)
  end
  if now >= W.stopAt then P.Stop() end
end

function P.Watch(seconds)
  if W.running then P.Stop() end
  seconds = math.floor(math.min(math.max(tonumber(seconds) or 30, 10), 300))
  NewRun("watch")
  W.running, W.start, W.lastLine, W.stopAt = true, GetTime(), GetTime(), GetTime() + seconds
  W.sec, W.total, W.ring, W.ringPos, W.barOk, W.barFail, W.sqOk = {}, {}, {}, 1, {}, {}, {}
  W.lastAction, W.lastFlag, W.lastAmount, W.combatPrinted, W.other, W.dtps = nil, nil, nil, 0, 0, nil
  W.calc50, W.calc80 = NewCalculator(0.5), NewCalculator(0.8)
  W.lowCurve, W.readyCurve = StepCurve(), ReadyCurve()
  local okD, list = pcall(MyDefensives)
  W.def = okD and list[1] or nil
  if not W.events then
    W.events = CreateFrame("Frame")
    W.events:SetScript("OnEvent", function(...) pcall(OnEvent, ...) end)
    W.events:SetScript("OnUpdate", function(...) pcall(OnUpdate, ...) end)
  end
  local ok, bad = {}, {}
  for _, e in ipairs(ALL_EVENTS) do
    local fine
    if IS_UNIT[e] then fine = pcall(W.events.RegisterUnitEvent, W.events, e, "player") end
    if not fine then fine = pcall(W.events.RegisterEvent, W.events, e) end
    if fine then ok[#ok + 1] = SHORT[e] else bad[#bad + 1] = e end
  end
  W.events:Show()
  Out("watch %d s  events ok: %s  failed: %s", seconds, table.concat(ok, " "), #bad > 0 and table.concat(bad, " ") or "-")
  Out("defensive on screen: %s", W.def and (Show(W.def.id) .. " " .. Show(W.def.name)) or "none")
  pcall(Restrictions)
  Frame():Show()
  ns.Print(L.watchStart, seconds)
end

function P.Stop()
  if not W.running then return end
  W.running = false
  pcall(W.events.UnregisterAllEvents, W.events)
  W.events:Hide()
  if W.frame then W.frame:Hide() end
  local parts = {}
  for _, e in ipairs(ALL_EVENTS) do parts[#parts + 1] = SHORT[e] .. "=" .. (W.total[e] or 0) end
  Out("total %s  other units=%d", table.concat(parts, " "), W.other or 0)
  local bars = {}
  for _, k in ipairs({ "health", "ago", "incoming", "absorb" }) do
    bars[#bars + 1] = k .. "=" .. (W.barOk[k] and "ok" or W.barFail[k] and "FAILED" or "no value")
  end
  Out("bars: %s", table.concat(bars, " "))
  local sq = {}
  for _, k in ipairs({ "low", "50", "80", "def" }) do sq[#sq + 1] = k .. "=" .. (W.sqOk[k] and "ok" or "FAILED") end
  Out("squares: %s", table.concat(sq, " "))
  ns.Print(L.watchDone)
end
