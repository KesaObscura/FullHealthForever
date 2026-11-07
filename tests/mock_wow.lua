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
function methods:SetAlpha(a) self.alpha = a end
function methods:SetAlphaFromBoolean(flag, t, f)
  if M.noAlphaFromBoolean then error("no SetAlphaFromBoolean") end
  self.alpha = { flag = flag, ifTrue = t, ifFalse = f }
end
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
  _G.CreateColor = function(r, g, b, a)
    return { r, g, b, a, GetRGBA = function(c) return c[1], c[2], c[3], c[4] end }
  end
  _G.IsInInstance = function() return false, "none" end
  _G.UnitLevel = function() return 20 end
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
    if type(curve) == "table" then
      return { GetRGBA = function() return 1, 1, 1, M.secret(1) end } -- a colour with a secret alpha
    end
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
  for _, k in ipairs({ "C_Secrets", "C_RestrictedActions", "C_DamageMeter", "C_DeathRecap", "C_Spell",
    "C_SpellBook", "C_UnitAuras", "C_Item", "C_Container", "C_StringUtil", "UnitThreatSituation",
    "UnitDetailedThreatSituation", "GetSpellBaseCooldown", "UnitHealthMissing" }) do _G[k] = nil end
  if opts.full then M.full(S) end
  if opts.prediction then
    _G.UnitGetIncomingHeals = function() return M.secret(120) end
    _G.UnitGetTotalAbsorbs = function() return M.secret(0) end
    _G.UnitGetTotalHealAbsorbs = function() return M.secret(0) end
    local calcMethods = {
      SetIncomingHealOverflowPercent = function(c, o) c.overflow = o end,
      SetIncomingHealClampMode = function(c, m) c.mode = m end,
      GetIncomingHealOverflowPercent = function(c) return c.overflow or 1.05 end,
      -- clamped as seen in game (0.0.2): false while no heal comes; with a heal in flight
      -- true when health + heal pass overflow x max (the probe's idea, still to be confirmed)
      GetIncomingHeals = function(c)
        local inc = S.incoming or 0
        return M.secret(inc), M.secret(0), M.secret(inc),
          M.secret(inc > 0 and S.hpPct + inc / S.maxHP > (c.overflow or 1.05))
      end,
      GetCurrentHealthPercent = function() return M.secret(0.6) end,
      HasSecretValues = function() return true end,
    }
    _G.CreateUnitHealPredictionCalculator = function() return setmetatable({}, { __index = calcMethods }) end
    _G.UnitGetDetailedHealPrediction = M.noop
  end
end

-- every API the 0.0.2 probe asks for, with secrets where the game documents them
function M.full(S)
  _G.Enum.UnitIncomingHealClampMode = { MissingHealth = 0, MaximumHealth = 1 }
  _G.Enum.AddOnRestrictionType = { Combat = 0, Encounter = 1, ChallengeMode = 2, PvPMatch = 3, Map = 4, Chat = 5 }
  _G.Enum.SpellBookSpellBank = { Player = 0 }
  _G.UnitHealthMissing = function() return M.secret(math.floor(S.maxHP * (1 - S.hpPct))) end
  _G.C_Secrets = { HasSecretRestrictions = function() return true end, ShouldAurasBeSecret = function() return S.combat end,
    ShouldCooldownsBeSecret = function() return S.combat end, ShouldUnitStatsBeSecret = function() return false end,
    ShouldUnitHealthMaxBeSecret = function() return false end, GetSpellAuraSecrecy = function() return 2 end,
    GetSpellCooldownSecrecy = function() return 2 end, ShouldSpellCooldownBeSecret = function() return S.combat end,
    ShouldSpellAuraBeSecret = function() return S.combat end }
  _G.C_RestrictedActions = { GetAddOnRestrictionState = function(t) return (t == 0 and S.combat) and 2 or 0 end }
  _G.UnitThreatSituation = function(_, mob) if mob then return M.secret(3) end return 0 end
  _G.UnitDetailedThreatSituation = function() return M.secret(true), M.secret(3), M.secret(100) end
  _G.C_StringUtil = { TruncateWhenZero = function(v) return M.secret("600") end }
  _G.C_DamageMeter = {
    IsDamageMeterAvailable = function() return true, "" end,
    GetSessionDurationSeconds = function() return 12 end,
    GetCombatSessionFromType = function()
      return { totalAmount = M.secret(500), maxAmount = M.secret(500), durationSeconds = 12,
        combatSources = { { isLocalPlayer = true, totalAmount = M.secret(500), amountPerSecond = M.secret(41.6),
          deathRecapID = 0, deathTimeSeconds = M.secret(0) } } }
    end,
  }
  _G.C_DeathRecap = { HasRecapEvents = function() return false end, GetRecapEvents = function() return {} end,
    GetRecapMaxHealth = function() return 1000 end }
  local names = { [871] = "Shield Wall", [11196] = "Recently Bandaged", [17] = "Power Word: Shield" }
  _G.C_Spell = {
    GetSpellName = function(id) return names[id] end,
    GetSpellCooldown = function()
      return { isActive = S.cdActive or false, isOnGCD = false, isEnabled = true, startTime = M.secret(0), duration = M.secret(0) }
    end,
    GetSpellCooldownDuration = function()
      return { HasSecretValues = function() return true end,
        EvaluateRemainingDuration = function(_, curve) return { GetRGBA = function() return 1, 1, 1, M.secret(1) end } end }
    end,
  }
  _G.GetSpellBaseCooldown = function(id) return id == 871 and 300000 or 0, 0 end
  _G.C_SpellBook = {
    GetNumSpellBookSkillLines = function() return 1 end,
    GetSpellBookSkillLineInfo = function() return { itemIndexOffset = 0, numSpellBookItems = 3 } end,
    GetSpellBookItemInfo = function(i)
      return ({ { spellID = 78, name = "Heroic Strike" }, { spellID = 871, name = "Shield Wall" },
        { spellID = 6673, name = "Battle Shout" } })[i]
    end,
  }
  _G.C_UnitAuras = { AuraIsBigDefensive = function(id) return id == 871 end,
    GetPlayerAuraBySpellID = function(id) if id == 11196 then return { duration = 60, expirationTime = 160 } end end }
  _G.C_Item = {
    GetItemCount = function(id) return (id == 929 or id == 5509) and 3 or 0 end,
    GetItemSpell = function(id) if id == 929 or id == 77777 then return "Healing Potion", 441 end end,
    GetItemInfoInstant = function(id) return id, "Consumable", "Potion", "", 134830, 0, 1 end,
  }
  _G.C_Container = {
    GetItemCooldown = function() return 0, 0, 1 end,
    GetContainerNumSlots = function(bag) return bag == 0 and 2 or 0 end,
    GetContainerItemInfo = function(_, slot) return ({ { itemID = 929 }, { itemID = 77777 } })[slot] end,
  }
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
