-- Full Health Forever - core: settings, events, the update tick, commands.

local _, ns = ...
local L = ns.L
local E = ns.Engine
local H = ns.HUD

ns.VERSION = "0.1.0"
ns.BUG_URL = "https://github.com/KesaObscura/FullHealthForever/issues"

-- profile defaults (owner, 7 Nov: lines 35 / 25 / 30 %, shadow on, bar apart from FMF)
ns.DEFAULTS = {
  role = "auto",
  thrAggro = 0.35, thrNoAggro = 0.25, thrTank = 0.30,
  groups = { stone = true, potion = true, bandage = true, defensive = true },
  calmIcons = true,
  shadow = true, shadowSec = 2,
  healthText = "percent",
  threatIcon = true,
  onlyCombat = true,
  showSolo = true, showParty = true, showRaid = true,
  iconSize = 40, barWidth = 200, barHeight = 16, scale = 1,
  locked = true,
  point = false, -- false: the default place
}
ns.GROUPS = { "stone", "potion", "bandage", "defensive" }
local ACCOUNT_DEFAULTS = { language = "auto", dbVersion = 1 }

local acct, db
ns.state = { hold = false, holdArmed = false, bandagedUntil = nil, inCombat = false }
local st = ns.state

function ns.Print(fmt, ...)
  local ok, text = pcall(string.format, fmt, ...)
  if not ok then text = tostring(fmt) end
  print("|cffe8484cFull Health Forever|r " .. text)
end

local function DeepCopy(t)
  if type(t) ~= "table" then return t end
  local c = {}
  for k, v in pairs(t) do c[k] = DeepCopy(v) end
  return c
end

-- missing keys from the defaults; a value of the wrong type is replaced (a damaged file)
local function CopyDefaults(dst, src)
  for k, v in pairs(src) do
    if dst[k] == nil or (type(v) ~= type(dst[k]) and not (v == false and type(dst[k]) == "table")) then
      dst[k] = DeepCopy(v)
    elseif type(v) == "table" and type(dst[k]) == "table" then
      CopyDefaults(dst[k], v)
    end
  end
end
ns.CopyDefaults = CopyDefaults

function ns.DB() return db end
function ns.Acct() return acct end

-- the profile in use (after login and after every profile change)
function ns.ApplyProfile()
  db = ns.Profiles.ActiveTable()
  CopyDefaults(db, ns.DEFAULTS)
  ns.Relayout()
  ns.ApplyPosition()
  H.SetUnlocked(not db.locked)
  if ns.RefreshOptions then ns.RefreshOptions() end
end

-- the icons --------------------------------------------------------------------------------

local function PlayerClass()
  local ok, _, class = pcall(UnitClass, "player")
  if ok and type(class) == "string" and not E.IsSecret(class) then return class end
end

local function Usable(id)
  local ok, usable = pcall(C_Item and C_Item.IsUsableItem or IsUsableItem, id)
  if not ok or E.IsSecret(usable) then return true end
  return usable ~= false
end

-- order by role (healer: potion last; tank: own defensives first); bandage always last
local ORDER = {
  tank = { "defensive", "stone", "potion", "bandage" },
  healer = { "stone", "defensive", "potion", "bandage" },
  dps = { "stone", "potion", "defensive", "bandage" },
}

function ns.Entries(role)
  local out = {}
  local class = PlayerClass()
  for _, g in ipairs(ORDER[role] or ORDER.dps) do
    if db.groups[g] then
      if g == "stone" or g == "potion" or g == "bandage" then
        local list = (g == "stone" and ns.STONES) or (g == "potion" and ns.POTIONS) or ns.BANDAGES
        local id = E.Strongest(list, g == "bandage" and Usable or nil)
        if id then out[#out + 1] = { kind = "item", id = id, group = g } end
      else
        local book = E.BookByName()
        local list = {}
        for _, id in ipairs(class and ns.DEFENSIVES[class] or {}) do list[#list + 1] = id end
        for _, id in ipairs(ns.RACIAL_DEFENSIVES) do list[#list + 1] = id end
        for _, id in ipairs(list) do
          local name = E.SpellName(id)
          local skip = role == "tank" and ns.TANK_SKIP[id]
          if name and book[name] and not skip then
            out[#out + 1] = { kind = "spell", id = book[name], name = name, group = g }
          end
        end
      end
    end
  end
  return out
end

function ns.Relayout()
  if not db then return end
  local ok = pcall(function()
    st.role = E.Role(db.role)
    st.entries = ns.Entries(st.role)
    H.Layout(db, st.entries)
  end)
  if not ok then H.Dark() end
  ns.UpdateVisibility()
end

-- position ---------------------------------------------------------------------------------

function ns.ApplyPosition()
  H.Build()
  local f = H.frame
  f:ClearAllPoints()
  local p = db.point
  if type(p) == "table" and type(p[1]) == "string" and type(p[4]) == "number" and type(p[5]) == "number" then
    f:SetPoint(p[1], UIParent, p[3] or p[1], p[4], p[5])
  else
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
  end
end

function ns.SavePosition()
  local point, _, rel, x, y = H.frame:GetPoint()
  if point then db.point = { point, "UIParent", rel or point, x or 0, y or 0 } end
end

function ns.ResetPosition()
  db.point = false
  ns.ApplyPosition()
end

function ns.SetLocked(on)
  db.locked = on and true or false
  H.SetUnlocked(not db.locked)
  ns.UpdateVisibility()
  if ns.RefreshOptions then ns.RefreshOptions() end
end

-- visibility -------------------------------------------------------------------------------

local function GroupAllowed()
  if IsInRaid and IsInRaid() then return db.showRaid end
  if IsInGroup and IsInGroup() then return db.showParty end
  return db.showSolo
end

function ns.ShouldShow()
  if not db then return false end
  if not db.locked or ns.optionsOpen then return true end
  local dead = E.Call(UnitIsDeadOrGhost, "player")
  if dead == true then return false end
  if db.onlyCombat and not st.inCombat then return false end
  return GroupAllowed() and true or false
end

function ns.UpdateVisibility()
  if not H.frame then return end
  H.frame:SetShown(ns.ShouldShow())
end

-- the tick -----------------------------------------------------------------------------------

local function TankLost()
  if not (E.Call(UnitExists, "target") == true) then return false end
  if E.Call(UnitCanAttack, "player", "target") ~= true then return false end
  local s = E.Threat("player", "target")
  return s ~= nil and s < 2
end

function ns.Tick(now)
  if not db or not H.frame then return end
  st.now = now
  st.inGroup = (IsInGroup and IsInGroup()) and true or false
  st.mobOnMe = E.MobOnMe()
  st.tankLost = st.role == "tank" and TankLost() or false
  st.line = E.Line(db, st.role or "dps", st.mobOnMe)
  if st.bandagedUntil and st.bandagedUntil <= now then st.bandagedUntil = nil end
  H.Update(db, st)
end

-- fail closed: an error anywhere here darkens the icons (FMF 0.9.2)
local function SafeTick(now)
  local ok, err = pcall(ns.Tick, now)
  if not ok then
    H.Dark()
    if acct and acct.debug then ns.Print("tick error: %s", tostring(err)) end
  end
  return ok
end
ns.SafeTick = SafeTick

-- hold: no bright icons until the end of the next fight (a fight already running counts)
function ns.Hold()
  st.hold = true
  st.holdArmed = st.inCombat
  ns.Print(L.holdOn)
end

local function EndHold()
  if st.hold then
    st.hold, st.holdArmed = false, false
    ns.Print(L.holdOff)
  end
end

-- events -------------------------------------------------------------------------------------

local ev = CreateFrame("Frame")
ns.events = ev
local acc = 0

local function IsMyBandage(spellID)
  for _, id in ipairs(ns.BANDAGES) do
    local _, sid = E.Call(C_Item and C_Item.GetItemSpell, id)
    if sid == spellID then return true end
  end
  return false
end

local function OnEvent(_, event, a1, a2, a3)
  if event == "ADDON_LOADED" then
    if a1 ~= "FullHealthForever" then return end
    FullHealthForeverDB = type(FullHealthForeverDB) == "table" and FullHealthForeverDB or {}
    acct = FullHealthForeverDB
    CopyDefaults(acct, ACCOUNT_DEFAULTS)
    if acct.language ~= "auto" and ns.SetLanguage then ns.SetLanguage(acct.language) end
    return
  end
  if not acct then return end
  if event == "PLAYER_LOGIN" then
    ns.Profiles.Init(acct)
    H.Build()
    ns.ApplyProfile()
    if ns.InitOptions then pcall(ns.InitOptions) end
    st.inCombat = InCombatLockdown and InCombatLockdown() or false
    if acct.seenVersion ~= ns.VERSION then
      acct.seenVersion = ns.VERSION
      ns.Print(L.welcome, ns.VERSION)
    end
  elseif not db then
    return
  elseif event == "PLAYER_REGEN_DISABLED" then
    st.inCombat = true
    if not db.locked then
      ns.SetLocked(true)
      ns.Print(L.autoLocked)
    end
    if st.hold then st.holdArmed = true end
    ns.UpdateVisibility()
  elseif event == "PLAYER_REGEN_ENABLED" then
    st.inCombat = false
    if st.hold and st.holdArmed then EndHold() end
    ns.UpdateVisibility()
    ns.Relayout() -- items used up, spell book changes waited for the end of the fight
    -- out of combat the game's cooldowns are readable again: own timers follow them
    for _, e in ipairs(st.entries or {}) do
      if e.kind == "spell" then E.SyncSpell(e.name, e.id, GetTime()) end
    end
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
    if a1 ~= "player" or E.IsSecret(a3) or type(a3) ~= "number" then return end
    E.OnOwnCast(a3, GetTime())
    if IsMyBandage(a3) then st.bandagedUntil = GetTime() + ns.BANDAGE_LOCK end
  elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ROLES_ASSIGNED" or event == "SPELLS_CHANGED"
    or event == "PLAYER_LEVEL_UP" or event == "BAG_UPDATE_DELAYED" then
    if not st.inCombat or event == "BAG_UPDATE_DELAYED" then ns.Relayout() end
    ns.UpdateVisibility()
  elseif event == "PLAYER_DEAD" or event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
    ns.UpdateVisibility()
  end
end

ev:SetScript("OnEvent", function(...)
  local ok, err = pcall(OnEvent, ...)
  if not ok then
    H.Dark()
    if acct and acct.debug then ns.Print("event error: %s", tostring(err)) end
  end
end)
for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
  "GROUP_ROSTER_UPDATE", "PLAYER_ROLES_ASSIGNED", "SPELLS_CHANGED", "PLAYER_LEVEL_UP",
  "BAG_UPDATE_DELAYED", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST" }) do
  pcall(ev.RegisterEvent, ev, e)
end
if not pcall(ev.RegisterUnitEvent, ev, "UNIT_SPELLCAST_SUCCEEDED", "player") then
  pcall(ev.RegisterEvent, ev, "UNIT_SPELLCAST_SUCCEEDED")
end

ev:SetScript("OnUpdate", function(_, elapsed)
  acc = acc + (elapsed or 0)
  if acc < 0.1 then return end
  acc = 0
  if H.frame and H.frame:IsShown() then SafeTick(GetTime()) end
end)

-- commands -----------------------------------------------------------------------------------

local function Help()
  ns.Print(L.helpHead, ns.VERSION)
  for _, k in ipairs({ "helpConfig", "helpLock", "helpHold", "helpReset", "helpProfile", "helpStatus" }) do
    ns.Print(L[k])
  end
  ns.Print(L.bugReport, ns.BUG_URL)
end

-- technical lines for bug reports: English on purpose, no names
local function Status()
  ns.Print("v%s role=%s line=%d%% mobOnMe=%s hold=%s combat=%s danger=%s", ns.VERSION, tostring(st.role),
    math.floor((st.line or 0) * 100 + 0.5), tostring(st.mobOnMe), tostring(st.hold), tostring(st.inCombat),
    tostring(H.dangerOk))
  local parts = {}
  for _, e in ipairs(st.entries or {}) do
    parts[#parts + 1] = e.group .. ":" .. e.kind .. ":" .. tostring(e.id)
  end
  ns.Print("icons: %s", #parts > 0 and table.concat(parts, " ") or "none")
  ns.Print(L.bugReport, ns.BUG_URL)
end

SLASH_FULLHEALTHFOREVER1 = "/fhf"
SlashCmdList.FULLHEALTHFOREVER = function(msg)
  local cmd, rest = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
  if cmd == "" or cmd == "help" then return Help() end
  if not db then return end
  if cmd == "config" or cmd == "options" then
    if ns.ToggleOptions then ns.ToggleOptions() end
  elseif cmd == "lock" then
    ns.SetLocked(true)
    ns.Print(L.locked)
  elseif cmd == "unlock" then
    ns.SetLocked(false)
    ns.Print(L.unlocked)
  elseif cmd == "hold" then
    ns.Hold()
  elseif cmd == "reset" then
    ns.ResetPosition()
    ns.Print(L.posReset)
  elseif cmd == "profile" then
    if rest == "own" or rest == "shared" then
      if ns.Profiles.Use(rest) then
        ns.Print(rest == "own" and L.profOwn or L.profShared)
      else
        ns.Print(L.profNone)
      end
    else
      ns.Print(ns.Profiles.IsOwn() and L.profOwn or L.profShared)
    end
  elseif cmd == "status" then
    Status()
  elseif cmd == "debug" then
    acct.debug = not acct.debug
    ns.Print("debug %s", acct.debug and "on" or "off")
  else
    ns.Print(L.unknown)
  end
end
