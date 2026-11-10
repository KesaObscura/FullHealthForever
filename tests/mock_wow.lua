-- Minimal World of Warcraft API mock for headless tests (Lua 5.1).
-- Health is SECRET here, in and out of combat (as in Forever): a secret may be stored, passed
-- on, formatted, fed to a StatusBar or turned into an alpha by the "game"; comparing,
-- arithmetic and concatenation raise an error, so a test fails when the addon tries.
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
local function plain(v) if isSecret(v) then return v.v end return v end
M.plain = plain

-- the real engine lets string.format print a secret value; emulate that
local rawformat = string.format
string.format = function(fmt, ...)
  local n, args = select("#", ...), { ... }
  for i = 1, n do if isSecret(args[i]) then args[i] = args[i].v end end
  return rawformat(fmt, unpack(args, 1, n))
end

-- widgets ----------------------------------------------------------------------------------
local methods = {}
-- unknown methods (capitalised, as in the game) are no-ops; unknown fields stay nil
local Widget = { __index = function(_, k)
  if methods[k] then return methods[k] end
  if type(k) == "string" and k:match("^%u") then return M.noop end
end }
function M.noop() end
M.all = {}
local level = 0
local function new(kind, parent, name)
  level = level + 1
  local o = setmetatable({ kind = kind, shown = true, scripts = {}, events = {}, parent = parent,
    alpha = 1, level = parent and (parent.level or 0) + 1 or 1, name = name }, Widget)
  M.all[#M.all + 1] = o
  if name then _G[name] = o end
  return o
end
M.new = new
function methods:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide()
  local was = self.shown
  self.shown = false
  if was and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:SetShown(v) if v then self:Show() else self:Hide() end end
function methods:IsShown() return self.shown end
function methods:IsVisible()
  local o = self
  while o do if not o.shown then return false end o = o.parent end
  return true
end
function methods:SetScript(k, f) self.scripts[k] = f end
function methods:GetScript(k) return self.scripts[k] end
function methods:HookScript(k, f)
  local old = self.scripts[k]
  self.scripts[k] = old and function(...) old(...); f(...) end or f
end
function methods:RegisterEvent(e) self.events[e] = true; return true end
function methods:RegisterUnitEvent(e) self.events[e] = true; return true end
function methods:UnregisterAllEvents() self.events = {} end
function methods:CreateFontString() return new("FontString", self) end
function methods:CreateTexture() return new("Texture", self) end
function methods:SetText(t)
  if t ~= nil and type(t) ~= "string" and type(t) ~= "number" and not isSecret(t) then error("SetText wants a string") end
  self.text = t
end
function methods:GetText() return self.text end
function methods:GetStringWidth() return #(tostring(self.text or "")) * 6 end
function methods:GetFontString()
  if not self.fs then self.fs = new("FontString", self) end
  return self.fs
end
local origSetText = methods.SetText
function methods:SetText(t)
  if self.kind == "Button" or self.kind == "CheckButton" then
    self:GetFontString().text = t
    self.text = t
    return
  end
  origSetText(self, t)
end
function methods:SetMinMaxValues(a, b) self.min, self.max = a, b end
function methods:SetValue(v)
  if M.barRefusesSecret and isSecret(v) then error("secret not accepted") end
  self.value = v
end
function methods:GetStatusBarTexture()
  if not self.sbt then self.sbt = new("Texture", self) end
  return self.sbt
end
function methods:SetAlpha(a)
  if type(a) ~= "number" and not isSecret(a) then error("SetAlpha wants a number") end
  self.alpha = a
end
function methods:GetAlpha() return self.alpha end
function methods:SetAlphaFromBoolean(flag, t, f)
  if M.noAlphaFromBoolean then error("no SetAlphaFromBoolean") end
  self.alpha = { flag = flag, ifTrue = t == nil and 1 or t, ifFalse = f == nil and 0 or f }
end
function methods:SetFrameLevel(l) self.level = l end
function methods:GetFrameLevel() return self.level or 1 end
function methods:SetChecked(v) self.checked = v and true or false end
function methods:GetChecked() return self.checked end
function methods:SetEnabled(v) self.enabled = v and true or false end
function methods:IsEnabled() return self.enabled ~= false end
function methods:SetPoint(...) self.points = self.points or {}; self.points[#self.points + 1] = { ... } end
function methods:ClearAllPoints() self.points = {} end
function methods:GetPoint() local p = (self.points or {})[1] or {} return p[1], p[2], p[3], p[4], p[5] end
function methods:SetSize(w, h) self.w, self.h = w, h end
function methods:GetWidth() return self.w or 0 end
function methods:GetHeight() return self.h or 0 end
function methods:SetWidth(w) self.w = w end
function methods:SetTexture(t) self.texture = t end
function methods:SetScale(s) self.scale = s end

-- what the player sees of a region: shown along the parent chain, alphas multiplied (secret
-- alphas unwrapped, alpha-from-boolean resolved)
local function alphaOf(o)
  local a = o.alpha
  if type(a) == "table" and not isSecret(a) and a.ifTrue ~= nil then
    return plain(a.flag) and a.ifTrue or a.ifFalse
  end
  return plain(a) or 1
end
function M.seen(o)
  local a = 1
  while o do
    if not o.shown then return 0 end
    a = a * alphaOf(o)
    o = o.parent
  end
  return a
end

-- curves: the "game" evaluates them
local function NewCurve()
  local c = { points = {} }
  function c.SetType() end
  function c.AddPoint(self, x, col) self.points[#self.points + 1] = { x = x, col = col } end
  function c.Eval(self, x) -- step curve
    local col = self.points[1] and self.points[1].col
    for _, p in ipairs(self.points) do if x >= p.x then col = p.col end end
    return col
  end
  return c
end
local function SecretColor(col)
  return { GetRGBA = function() return col[1], col[2], col[3], M.secret(col[4]) end }
end

function M.reset(opts)
  opts = opts or {}
  local S = { time = 100, combat = false, maxHP = 1000, hpPct = 1, incoming = 0, threat = nil,
    targetThreat = nil, role = "NONE", class = "PRIEST", inGroup = false, inRaid = false,
    items = {}, book = {}, spellCd = {}, dead = false, target = false }
  M.S, M.all, M.chat = S, {}, {}
  M.barRefusesSecret, M.noAlphaFromBoolean = nil, nil
  _G.print = function(s) M.chat[#M.chat + 1] = s end
  _G.date = function() return "2026-11-10 12:00:00" end
  _G.time = function() return 1794000000 end
  _G.GetLocale = function() return opts.locale or "enUS" end
  _G.GetTime = function() return S.time end
  _G.InCombatLockdown = function() return S.combat end
  _G.IsInGroup = function() return S.inGroup or S.inRaid end
  _G.IsInRaid = function() return S.inRaid end
  _G.UnitExists = function(u) return u == "player" or (u == "target" and S.target) end
  _G.UnitCanAttack = function() return S.target end
  _G.UnitClass = function() return "Class", S.class end
  _G.UnitName = function() return "Testname", "Testsurname" end
  _G.GetRealmName = function() return "Test Realm" end
  _G.UnitLevel = function() return 30 end
  _G.UnitIsDeadOrGhost = function() return S.dead end
  _G.UIParent = new("Frame")
  _G.CreateFrame = function(kind, name, parent) return new(kind, parent, name) end
  _G.CreateColor = function(r, g, b, a) return { r, g, b, a } end
  _G.SlashCmdList = {}
  _G.UISpecialFrames = {}
  _G.issecretvalue = isSecret
  _G.FullHealthForeverDB = nil
  _G.GameTooltip = new("GameTooltip")
  _G.GameTooltip.SetOwner = function(self) self.owned = true end
  _G.GameTooltip.SetText = function(self, t) self.title = t end
  _G.GameTooltip.AddLine = function(self, t) self.line = t end
  _G.Settings = {
    RegisterCanvasLayoutCategory = function(panel, name) return { panel = panel, name = name } end,
    RegisterAddOnCategory = function(c) M.category = c end,
  }
  _G.Enum = { LuaCurveType = { Step = 1 }, UnitIncomingHealClampMode = { MissingHealth = 0 },
    SpellBookSpellBank = { Player = 0 } }
  _G.CurveConstants = { ScaleTo100 = "S100" }
  _G.C_CurveUtil = { CreateColorCurve = NewCurve }

  -- health: secret always
  _G.UnitHealth = function() return M.secret(math.floor(S.maxHP * S.hpPct)) end
  _G.UnitHealthMax = function() return S.maxHP end
  _G.UnitHealthPercent = function(_, _, curve)
    if M.healthPercentFails then error("no curve for you") end
    if curve == "S100" then return M.secret(S.hpPct * 100) end
    if type(curve) == "table" and curve.Eval then return SecretColor(curve:Eval(S.hpPct)) end
    return M.secret(S.hpPct)
  end
  _G.UnitGetIncomingHeals = function() return M.secret(S.incoming) end
  _G.UnitGetTotalAbsorbs = function() return M.secret(0) end
  _G.UnitGetDetailedHealPrediction = M.noop
  local calcMethods = {
    SetIncomingHealOverflowPercent = function(c, o) c.overflow = o end,
    SetIncomingHealClampMode = function(c, m) c.mode = m end,
    -- clamped as seen in game (probe 0.0.3): only with a heal in flight that passes the line
    GetIncomingHeals = function(c)
      local inc = S.incoming or 0
      return M.secret(inc), M.secret(0), M.secret(inc),
        M.secret(inc > 0 and S.hpPct + inc / S.maxHP > (c.overflow or 1.05))
    end,
  }
  _G.CreateUnitHealPredictionCalculator = function() return setmetatable({}, { __index = calcMethods }) end

  -- threat and roles (readable in combat in game)
  _G.UnitThreatSituation = function(_, mob)
    if not S.combat then return nil end
    if mob then return S.targetThreat end
    return S.threat
  end
  _G.UnitGroupRolesAssigned = function() return S.role end

  -- items: S.items[id] = { count, start, dur, spell }
  _G.C_Item = {
    GetItemCount = function(id) return S.items[id] and S.items[id].count or 0 end,
    GetItemSpell = function(id) local it = S.items[id]; if it and it.spell then return "Use", it.spell end end,
    IsUsableItem = function(id) local it = S.items[id]; return not (it and it.unusable) end,
    GetItemIconByID = function(id) return "icon" .. id end,
  }
  _G.C_Container = { GetItemCooldown = function(id)
    local it = S.items[id]
    if not it then return 0, 0, 1 end
    return it.start or 0, it.dur or 0, 1
  end }

  -- spells: S.book = { { id, name } }, S.spellCd[id] = true while on its own cooldown
  local names = { [871] = "Shield Wall", [12975] = "Last Stand", [633] = "Lay on Hands", [498] = "Divine Protection",
    [642] = "Divine Shield", [13908] = "Desperate Prayer", [5277] = "Evasion", [1856] = "Vanish",
    [20594] = "Stoneform" }
  M.names = names
  _G.C_Spell = {
    GetSpellName = function(id)
      if names[id] then return names[id] end
      for _, b in ipairs(S.book) do if b.id == id then return b.name end end
    end,
    GetSpellTexture = function(id) return "spell" .. id end,
    GetSpellCooldown = function(id)
      if S.combat then return { isActive = false, startTime = M.secret(0), duration = M.secret(0), isEnabled = true } end
      local cd = S.spellCdTime and S.spellCdTime[id]
      return { isActive = cd ~= nil, startTime = cd and cd[1] or 0, duration = cd and cd[2] or 0, isEnabled = true }
    end,
    GetSpellCooldownDuration = function(id)
      return { EvaluateRemainingDuration = function(_, curve)
        return SecretColor(curve:Eval(S.spellCd[id] and 10 or 0))
      end }
    end,
    IsSpellUsable = function() return true, false end,
  }
  _G.GetSpellBaseCooldown = function(id) return id == 871 and 300000 or (id == 13908 and 600000 or 0), 0 end
  _G.C_SpellBook = {
    GetNumSpellBookSkillLines = function() return 1 end,
    GetSpellBookSkillLineInfo = function() return { itemIndexOffset = 0, numSpellBookItems = #S.book } end,
    GetSpellBookItemInfo = function(i) local b = S.book[i]; if b then return { spellID = b.id, name = b.name } end end,
  }
end

-- loads the addon files like the game (same namespace table), in TOC order
function M.load()
  local ns = {}
  local h = assert(io.open(M.ROOT .. "FullHealthForever.toc"))
  local toc = h:read("*a")
  h:close()
  for line in toc:gmatch("[^\r\n]+") do
    if line:match("^[%w_]+%.lua$") then
      assert(loadfile(M.ROOT .. line))("FullHealthForever", ns)
    end
  end
  return ns
end

-- runs the addon's events and its update tick
function M.fire(event, ...)
  for _, o in ipairs(M.all) do
    if o.events[event] and o.scripts.OnEvent then o.scripts.OnEvent(o, event, ...) end
  end
end

function M.tick(seconds)
  M.S.time = M.S.time + (seconds or 0.1)
  for _, o in ipairs(M.all) do
    if o.scripts.OnUpdate then o.scripts.OnUpdate(o, seconds or 0.1) end
  end
end

-- a logged-in player (ADDON_LOADED + PLAYER_LOGIN)
function M.login()
  local ns = M.load()
  M.fire("ADDON_LOADED", "FullHealthForever")
  M.fire("PLAYER_LOGIN")
  return ns
end

function M.combat(on)
  M.S.combat = on
  M.fire(on and "PLAYER_REGEN_DISABLED" or "PLAYER_REGEN_ENABLED")
end

return M
