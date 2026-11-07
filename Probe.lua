-- Full Health Forever - TEMPORARY probe (0.0.x). Remove this file, its TOC line, its
-- SavedVariables entry and its locale keys before 0.1 (see TODO.md).
--
-- Finds out what WoW Forever lets an addon know about health:
--   /fhf probe                  one snapshot to chat: which API exists, what is secret
--   /fhf probe watch [seconds]  events per second in chat, plus a test frame on screen that
--                               shows secret values the only way the game allows (formatted
--                               into a FontString, fed into a StatusBar)
--   /fhf probe stop             ends the watch early
-- Chat lines are also kept in FullHealthForeverProbeLog (SavedVariables).
-- Secret values are never printed to chat or stored: only marked as SECRET. Unit tokens
-- (party1 ...) are used, never player names. Texts stay English (bug reports).

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
  local ok, a, b = pcall(fn, ...)
  if ok then return a, b end
end

local function Get(path)
  local v = _G
  for part in path:gmatch("[^%.]+") do
    if type(v) ~= "table" then return nil end
    v = v[part]
  end
  return v
end

local API = {
  "UnitHealth", "UnitHealthMax", "UnitHealthPercent", "UnitGetIncomingHeals", "UnitGetTotalAbsorbs",
  "UnitGetTotalHealAbsorbs", "UnitGetDetailedHealPrediction", "CreateUnitHealPredictionCalculator",
  "C_CurveUtil.CreateCurve", "C_CurveUtil.CreateColorCurve", "CurveConstants.ScaleTo100",
  "UnitInRange", "UnitGroupRolesAssigned", "GetSpecialization", "UnitIsDeadOrGhost",
  "C_Spell.GetSpellCooldown", "GetSpellBaseCooldown", "C_Item.GetItemCooldown", "GetItemCooldown",
  "C_UnitAuras.GetPlayerAuraBySpellID", "C_UnitAuras.GetAuraDataByIndex", "issecretvalue",
}

-- a step curve 0..1 -> alpha, as Full Mana Forever builds it: alpha 1 below 50 %
local function StepCurve()
  if not (C_CurveUtil and C_CurveUtil.CreateColorCurve) then return end
  local ok, c = pcall(function()
    local c = C_CurveUtil.CreateColorCurve()
    if Enum and Enum.LuaCurveType and c.SetType then c:SetType(Enum.LuaCurveType.Step) end
    c:AddPoint(0, CreateColor(1, 1, 1, 1))
    c:AddPoint(0.5, CreateColor(1, 1, 1, 0))
    return c
  end)
  if ok then return c end
end

local function NewCalculator()
  if type(CreateUnitHealPredictionCalculator) ~= "function" then return end
  local ok, c = pcall(CreateUnitHealPredictionCalculator)
  if ok then return c end
end

-- the methods a calculator really has (names only), so we do not guess them
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

local CALC_METHODS = { "GetIncomingHeals", "GetIncomingHealOverflowPercent", "GetCurrentHealthPercent",
  "GetPredictedValues", "HasSecretValues" }

local function ProbeCalculator(unit)
  local calc = NewCalculator()
  if not calc then Out("calculator: none") return end
  local names = MethodNames(calc)
  Out("calculator methods: %s", #names > 0 and table.concat(names, " ") or "(not listed)")
  Try("UnitGetDetailedHealPrediction(" .. unit .. ",nil,calc)", UnitGetDetailedHealPrediction, unit, nil, calc)
  local list = #names > 0 and names or CALC_METHODS
  for _, m in ipairs(list) do
    if m:match("^Get") or m:match("^Has") or m:match("^Is") then
      local okM, fn = pcall(function() return calc[m] end)
      if okM and type(fn) == "function" then Try("  calc:" .. m, fn, calc) end
    end
  end
end

local S100 = function() return CurveConstants and CurveConstants.ScaleTo100 end

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

-- snapshot --------------------------------------------------------------------------------

function P.Snapshot()
  NewRun("snapshot")
  local inCombat = InCombatLockdown and InCombatLockdown()
  local build = GetBuildInfo and select(4, GetBuildInfo())
  Out("probe %s  interface=%s  combat=%s  group=%s  raid=%s  class=%s", ns.VERSION, Show(build),
    Show(inCombat), Show(IsInGroup and IsInGroup()), Show(IsInRaid and IsInRaid()), Show(Call(function() return select(2, UnitClass("player")) end)))

  local yes, no = {}, {}
  for _, name in ipairs(API) do
    local v = Get(name)
    if v ~= nil then yes[#yes + 1] = name else no[#no + 1] = name end
  end
  Out("API yes: %s", table.concat(yes, " "))
  Out("API no: %s", #no > 0 and table.concat(no, " ") or "-")

  local p = "player"
  Try("UnitHealth(p)", UnitHealth, p)
  Try("UnitHealth(p,true)", UnitHealth, p, true)
  Try("UnitHealth(p,false)", UnitHealth, p, false)
  Try("UnitHealthMax(p)", UnitHealthMax, p)

  local s100, curve = S100(), StepCurve()
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
    Try("UnitHealthPercent(p,true,curve)", UnitHealthPercent, p, true, curve)
    Try("UnitHealthPercent(p,curve)", UnitHealthPercent, p, curve)
  end

  Try("UnitGetIncomingHeals(p)", UnitGetIncomingHeals, p)
  Try("UnitGetIncomingHeals(p,p)", UnitGetIncomingHeals, p, p)
  Try("UnitGetTotalAbsorbs(p)", UnitGetTotalAbsorbs, p)
  Try("UnitGetTotalHealAbsorbs(p)", UnitGetTotalHealAbsorbs, p)
  ProbeCalculator(p)

  -- can a StatusBar / FontString take the values? (how a bar would draw them)
  local okF, bar = pcall(CreateFrame, "StatusBar")
  if okF and bar then
    Try("bar:SetMinMaxValues(0,max)", bar.SetMinMaxValues, bar, 0, UnitHealthMax and UnitHealthMax(p) or 1)
    local okH, hp = pcall(UnitHealth, p)
    if okH then Try("bar:SetValue(health)", bar.SetValue, bar, hp) end
    local okI, inc = pcall(UnitGetIncomingHeals or error, p)
    if okI and type(inc) ~= "nil" then Try("bar:SetValue(incoming)", bar.SetValue, bar, inc) end
    local okA, abs = pcall(UnitGetTotalAbsorbs or error, p)
    if okA and type(abs) ~= "nil" then Try("bar:SetValue(absorbs)", bar.SetValue, bar, abs) end
    bar:Hide()
  end

  Try("GetSpecialization()", GetSpecialization)
  Try("UnitGroupRolesAssigned(p)", UnitGroupRolesAssigned, p)

  for _, u in ipairs(GroupUnits()) do
    Try(u .. " UnitHealth", UnitHealth, u)
    if curve then Try(u .. " UnitHealthPercent(curve)", UnitHealthPercent, u, curve) end
    Try(u .. " UnitInRange", UnitInRange, u)
    Try(u .. " UnitGroupRolesAssigned", UnitGroupRolesAssigned, u)
    Try(u .. " UnitGetIncomingHeals", UnitGetIncomingHeals, u)
    Try(u .. " UnitClass", function() return select(2, UnitClass(u)) end)
  end
  ns.Print(L.snapDone)
end

-- watch -----------------------------------------------------------------------------------

local EVENTS = { "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH", "UNIT_COMBAT",
  "UNIT_HEAL_PREDICTION", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "UNIT_AURA",
  "UNIT_SPELLCAST_SUCCEEDED" }
local SHORT = { UNIT_HEALTH = "H", UNIT_HEALTH_FREQUENT = "HF", UNIT_MAXHEALTH = "MAX", UNIT_COMBAT = "C",
  UNIT_HEAL_PREDICTION = "HP", UNIT_ABSORB_AMOUNT_CHANGED = "AB", UNIT_HEAL_ABSORB_AMOUNT_CHANGED = "HA",
  UNIT_AURA = "AU", UNIT_SPELLCAST_SUCCEEDED = "CAST" }

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

-- the on-screen frame: no mouse (nothing to click), top centre
local function Frame()
  if W.frame then return W.frame end
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetSize(276, 190)
  f:SetPoint("TOP", UIParent, "TOP", 0, -120)
  f:SetFrameStrata("HIGH")
  f:EnableMouse(false)
  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.6)
  W.lines = {}
  for i = 1, 7 do
    local fs = f:CreateFontString(nil, "OVERLAY")
    local obj = FontObj()
    if obj then fs:SetFontObject(obj) end
    fs:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -6 - (i - 1) * 14)
    fs:SetJustifyH("LEFT")
    W.lines[i] = fs
  end
  -- green: health now; grey: health 2 s ago (the gap is the damage of the last 2 s);
  -- blue: incoming heals; yellow: absorbs. Labels in the text above.
  W.barNow = MakeBar(f, -108, 0.2, 0.9, 0.3)
  W.barAgo = MakeBar(f, -122, 0.6, 0.6, 0.6)
  W.barInc = MakeBar(f, -136, 0.3, 0.6, 1)
  W.barAbs = MakeBar(f, -150, 1, 0.85, 0.2)
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
  if W.calc then
    pcall(UnitGetDetailedHealPrediction, p, nil, W.calc)
    local okI, ci = pcall(function() return W.calc:GetIncomingHeals() end)
    local okP, cp = pcall(function() return W.calc:GetCurrentHealthPercent() end)
    if not okI then ci = "err" end -- never "x and secret or y": that tests the secret
    if not okP then cp = "err" end
    Text(l[4], "calc incoming %s  pct %s", ci, cp)
  else
    Text(l[4], "calc: none")
  end
  Text(l[5], "last UNIT_COMBAT: %s %s %s", W.lastAction, W.lastAmount, W.lastFlag)
  Text(l[6], "combat %s   %d s left", InCombatLockdown and InCombatLockdown() and "yes" or "no",
    math.max(0, math.floor(W.stopAt - GetTime() + 0.5)))
  Text(l[7], "bars: now / 2 s ago / incoming / absorb")

  SetBar(W.barNow, max, hp, "health")
  SetBar(W.barAgo, max, ago, "ago")
  SetBar(W.barInc, max, inc, "incoming")
  SetBar(W.barAbs, max, abs, "absorb")
end

local function CountLine(now)
  local parts = {}
  for _, e in ipairs(EVENTS) do
    local n = W.sec[e] or 0
    if n > 0 then parts[#parts + 1] = SHORT[e] .. "=" .. n end
  end
  Out("%2d s combat=%s %s", math.floor(now - W.start + 0.5), Show(InCombatLockdown and InCombatLockdown()),
    #parts > 0 and table.concat(parts, " ") or "-")
  W.sec = {}
end

local function OnEvent(_, event, unit, a1, a2, a3, a4)
  if not W.running then return end
  if IsSecret(unit) or unit ~= "player" then
    if event == "UNIT_COMBAT" or event == "UNIT_HEALTH" then W.other = (W.other or 0) + 1 end
    return
  end
  W.sec[event] = (W.sec[event] or 0) + 1
  W.total[event] = (W.total[event] or 0) + 1
  if event == "UNIT_COMBAT" then
    -- (unit, action, flag, amount, school): keep the values for the screen, print only types
    W.lastAction, W.lastFlag, W.lastAmount = a1, a2, a3
    if (W.combatPrinted or 0) < 12 then
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
  W.sec, W.total, W.ring, W.ringPos, W.barOk, W.barFail = {}, {}, {}, 1, {}, {}
  W.lastAction, W.lastFlag, W.lastAmount, W.combatPrinted, W.other = nil, nil, nil, 0, 0
  W.calc = NewCalculator()
  if not W.events then
    W.events = CreateFrame("Frame")
    W.events:SetScript("OnEvent", function(...) pcall(OnEvent, ...) end)
    W.events:SetScript("OnUpdate", function(...) pcall(OnUpdate, ...) end)
  end
  local ok, bad = {}, {}
  for _, e in ipairs(EVENTS) do
    local fine = pcall(W.events.RegisterUnitEvent, W.events, e, "player")
    if not fine then fine = pcall(W.events.RegisterEvent, W.events, e) end
    if fine then ok[#ok + 1] = SHORT[e] else bad[#bad + 1] = e end
  end
  W.events:Show()
  Out("watch %d s  events ok: %s  failed: %s", seconds, table.concat(ok, " "), #bad > 0 and table.concat(bad, " ") or "-")
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
  for _, e in ipairs(EVENTS) do parts[#parts + 1] = SHORT[e] .. "=" .. (W.total[e] or 0) end
  Out("total %s  other units=%d", table.concat(parts, " "), W.other or 0)
  local bars = {}
  for _, k in ipairs({ "health", "ago", "incoming", "absorb" }) do
    bars[#bars + 1] = k .. "=" .. (W.barOk[k] and "ok" or W.barFail[k] and "FAILED" or "no value")
  end
  Out("bars: %s", table.concat(bars, " "))
  ns.Print(L.watchDone)
end
