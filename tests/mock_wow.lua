-- Minimal World of Warcraft API mock for headless tests (Lua 5.1).
-- Health is SECRET here (as current mana is in Forever): a secret may be passed around,
-- stored, formatted and handed to a StatusBar, but comparing, arithmetic and concatenation
-- raise an error, so a test fails when the addon tries.
local M = {}
M.ROOT = (arg and arg[0] and arg[0]:match("^(.*)tests/run%.lua$")) or "./"

local secretMT = {
  __lt = function() error("compare secret") end, __le = function() error("compare secret") end,
  __eq = function() error("compare secret") end,
  __add = function() error("arith secret") end, __sub = function() error("arith secret") end,
  __mul = function() error("arith secret") end, __div = function() error("arith secret") end,
  __concat = function() error("concat secret") end,
}
function M.secret(v) return setmetatable({ v = v }, secretMT) end
local function isSecret(v) return type(v) == "table" and getmetatable(v) == secretMT end
M.isSecret = isSecret

-- the real engine lets string.format print a secret value; emulate that
local rawformat = string.format
string.format = function(fmt, ...)
  local n, args = select("#", ...), { ... }
  for i = 1, n do if isSecret(args[i]) then args[i] = args[i].v end end
  return rawformat(fmt, unpack(args, 1, n))
end

-- widgets: every unknown method is a no-op, the ones the tests look at keep state
local methods = {}
local Widget = { __index = function(_, k) return methods[k] or M.noop end }
function M.noop() end

M.all = {}
local function new(kind, parent)
  local o = setmetatable({ kind = kind, shown = true, scripts = {}, events = {}, parent = parent }, Widget)
  M.all[#M.all + 1] = o
  return o
end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:SetScript(k, f) self.scripts[k] = f end
function methods:RegisterEvent(e)
  if M.badEvents[e] then error("unknown event " .. e) end
  self.events[e] = true
end
function methods:RegisterUnitEvent(e) methods.RegisterEvent(self, e) end
function methods:UnregisterAllEvents() self.events = {} end
function methods:CreateFontString() return new("FontString", self) end
function methods:CreateTexture() return new("Texture", self) end
function methods:SetText(t)
  if t ~= nil and type(t) ~= "string" and not isSecret(t) then error("SetText wants a string") end
  self.text = t
end
function methods:GetText() return self.text end
function methods:SetMinMaxValues(a, b) self.min, self.max = a, b end
function methods:SetValue(v)
  if M.barRefusesSecret and isSecret(v) then error("secret not accepted") end
  self.value = v
end

function M.reset(opts)
  opts = opts or {}
  local S = { time = 100, combat = false, maxHP = 1000, hpPct = 0.6 }
  M.S, M.all, M.chat = S, {}, {}
  M.badEvents = opts.badEvents or {}
  M.barRefusesSecret = opts.barRefusesSecret
  _G.print = function(s) M.chat[#M.chat + 1] = s end
  _G.date = function() return "2026-11-07 12:00:00" end
  _G.GetLocale = function() return opts.locale or "enUS" end
  _G.GetTime = function() return S.time end
  _G.GetBuildInfo = function() return "1.60.1", "1", "Nov 1 2026", 16001 end
  _G.InCombatLockdown = function() return S.combat end
  _G.IsInGroup = function() return opts.party or false end
  _G.IsInRaid = function() return false end
  _G.UnitExists = function(u) return u == "player" or (opts.party and u == "party1") end
  _G.UnitClass = function() return "Priest", "PRIEST" end
  _G.UIParent = new("Frame")
  _G.CreateFrame = function(kind, _, parent) return new(kind, parent) end
  _G.CreateColor = function(r, g, b, a) return { r, g, b, a } end
  _G.SlashCmdList = {}
  _G.issecretvalue = isSecret
  _G.FullHealthForeverProbeLog = nil

  local hpSecret = function() return M.secret(math.floor(S.maxHP * S.hpPct)) end
  _G.UnitHealth = hpSecret
  _G.UnitHealthMax = function() return S.maxHP end
  _G.CurveConstants = { ScaleTo100 = "S100" }
  _G.UnitHealthPercent = function(_, a, b)
    local curve = b or a
    if curve == "S100" then return M.secret(S.hpPct * 100) end
    if type(curve) == "table" then return M.secret({ alpha = 1 }) end
    return M.secret(S.hpPct)
  end
  _G.C_CurveUtil = { CreateColorCurve = function()
    return { points = {}, AddPoint = function(c, x, col) c.points[#c.points + 1] = { x, col } end, SetType = M.noop }
  end }
  _G.Enum = { LuaCurveType = { Step = 1 } }
  _G.UnitInRange = function() return M.secret(true), true end
  _G.UnitGroupRolesAssigned = function() return "NONE" end

  -- incoming heals / absorbs / calculator only when asked for: unknown in Forever
  _G.UnitGetIncomingHeals, _G.UnitGetTotalAbsorbs, _G.UnitGetTotalHealAbsorbs = nil, nil, nil
  _G.UnitGetDetailedHealPrediction, _G.CreateUnitHealPredictionCalculator = nil, nil
  if opts.prediction then
    _G.UnitGetIncomingHeals = function() return M.secret(120) end
    _G.UnitGetTotalAbsorbs = function() return M.secret(0) end
    _G.UnitGetTotalHealAbsorbs = function() return M.secret(0) end
    local calcMethods = {
      GetIncomingHeals = function() return M.secret(120) end,
      GetCurrentHealthPercent = function() return M.secret(0.6) end,
      HasSecretValues = function() return true end,
    }
    _G.CreateUnitHealPredictionCalculator = function() return setmetatable({}, { __index = calcMethods }) end
    _G.UnitGetDetailedHealPrediction = M.noop
  end
end

-- loads the addon files like the game (same namespace table for all)
function M.load(files)
  local ns = {}
  for _, f in ipairs(files or { "Locale.lua", "Core.lua", "Probe.lua" }) do
    assert(loadfile(M.ROOT .. f))("FullHealthForever", ns)
  end
  return ns
end

-- runs the OnUpdate script of every frame that has one
function M.tick(seconds)
  M.S.time = M.S.time + seconds
  for _, o in ipairs(M.all) do
    if o.shown and o.scripts.OnUpdate then o.scripts.OnUpdate(o, seconds) end
  end
end

function M.fire(event, ...)
  for _, o in ipairs(M.all) do
    if o.events[event] and o.scripts.OnEvent then o.scripts.OnEvent(o, event, ...) end
  end
end

return M
