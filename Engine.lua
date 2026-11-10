-- Full Health Forever - the danger test, the line, readiness.
--
-- Current health is secret in Forever, also out of combat (probe 0.0.3): the addon never reads
-- it. "Danger" is decided by the game and never known to Lua:
--   frame A alpha = UnitHealthPercent(player, false, step curve): 1 below the line, 0 above;
--   frame B (child of A) alpha = SetAlphaFromBoolean(clamped, 0, 1) of a heal prediction
--     calculator with overflow = the line: clamped is true only while a heal is in flight that
--     lifts health above the line (probe 0.0.3, three cases in game);
--   nested alphas multiply: an icon inside B is visible only when health is below the line AND
--   the heals in flight will not lift it above.
-- What Lua does know (readable in combat, probes 0.0.2-0.0.4): threat ("a mob is on you"),
-- the group role, item cooldowns and counts, own casts.

local _, ns = ...
local E = {}
ns.Engine = E

local function IsSecret(v) return issecretvalue ~= nil and issecretvalue(v) or false end
E.IsSecret = IsSecret

local function Call(fn, ...)
  if type(fn) ~= "function" then return nil end
  local ok, a, b, c, d = pcall(fn, ...)
  if ok then return a, b, c, d end
end
E.Call = Call

-- curves ------------------------------------------------------------------------------------

local curves = {} -- [key] = curve, built once
local function StepCurve(key, points)
  if curves[key] ~= nil then return curves[key] or nil end
  local c = false
  if C_CurveUtil and C_CurveUtil.CreateColorCurve and CreateColor then
    local ok, made = pcall(function()
      local cc = C_CurveUtil.CreateColorCurve()
      if Enum and Enum.LuaCurveType and cc.SetType then cc:SetType(Enum.LuaCurveType.Step) end
      for _, p in ipairs(points) do cc:AddPoint(p[1], CreateColor(1, 1, 1, p[2])) end
      return cc
    end)
    if ok and made then c = made end
  end
  curves[key] = c
  return c or nil
end

-- alpha 1 below the line, 0 from the line on (health 0..1)
function E.LowCurve(line)
  line = math.floor(line * 100 + 0.5) / 100
  return StepCurve("low" .. line, { { 0, 1 }, { line, 0 } })
end

-- alpha 1 while (almost) nothing is left of a cooldown, seconds
function E.ReadyCurve() return StepCurve("ready", { { 0, 1 }, { 0.1, 0 } }) end

-- applies the game's (secret) alpha of a colour; without a usable answer: failAlpha
function E.ApplyColor(frame, color, failAlpha)
  if type(color) ~= "nil" then -- type(): a secret is never compared
    local ok, _, _, _, a = pcall(function() return color:GetRGBA() end)
    if ok and pcall(frame.SetAlpha, frame, a) then return true end
  end
  frame:SetAlpha(failAlpha)
  return false
end

-- the line --------------------------------------------------------------------------------

-- threat status of the player: 0 none .. 3 tanking; nil out of combat or when secret
function E.Threat(unit, mob)
  local s = Call(UnitThreatSituation, unit or "player", mob)
  if type(s) ~= "number" or IsSecret(s) then return nil end
  return s
end

function E.MobOnMe()
  local s = E.Threat("player")
  return s ~= nil and s >= 2
end

-- "tank", "healer" or "dps"; auto = the group role from the game (readable in a group,
-- probe 0.0.4), solo counts as dps
function E.Role(setting)
  if setting == "tank" or setting == "healer" or setting == "dps" then return setting end
  local r = Call(UnitGroupRolesAssigned, "player")
  if IsSecret(r) then return "dps" end
  if r == "TANK" then return "tank" end
  if r == "HEALER" then return "healer" end
  return "dps"
end

-- the health line for the role and the aggro: tank one line; others higher while a mob is on them
function E.Line(db, role, mobOnMe)
  if role == "tank" then return db.thrTank end
  if mobOnMe then return db.thrAggro end
  return db.thrNoAggro
end

-- danger: sets the alphas of the two nested frames; returns false when the game did not answer
local calc
function E.ApplyDanger(frameA, frameB, line)
  local okA = E.ApplyColor(frameA, Call(UnitHealthPercent, "player", false, E.LowCurve(line)), 0)
  if not calc and type(CreateUnitHealPredictionCalculator) == "function" then
    calc = Call(CreateUnitHealPredictionCalculator) or false
    if calc then
      local mode = Enum and Enum.UnitIncomingHealClampMode and Enum.UnitIncomingHealClampMode.MissingHealth
      if mode then pcall(calc.SetIncomingHealClampMode, calc, mode) end
    end
  end
  if not calc then
    -- without the calculator the health line alone decides (heals in flight not counted)
    frameB:SetAlpha(1)
    return okA
  end
  pcall(calc.SetIncomingHealOverflowPercent, calc, line)
  Call(UnitGetDetailedHealPrediction, "player", nil, calc)
  local ok, _, _, _, clamped = pcall(calc.GetIncomingHeals, calc)
  local okB = ok and pcall(frameB.SetAlphaFromBoolean, frameB, clamped, 0, 1)
  if not okB then frameB:SetAlpha(1) end
  return okA and okB
end

-- items ---------------------------------------------------------------------------------------

local function Count(id)
  local n = Call(C_Item and C_Item.GetItemCount or GetItemCount, id)
  if type(n) ~= "number" or IsSecret(n) then return 0 end
  return n
end
E.Count = Count

local function ItemCooldown(id)
  local fn = (C_Container and C_Container.GetItemCooldown) or GetItemCooldown
  local start, dur, enable = Call(fn, id)
  if IsSecret(start) or IsSecret(dur) then return nil end
  return start, dur, enable
end

-- the strongest owned item of a list (the list is strongest first); nil if none
function E.Strongest(list, usable)
  for _, id in ipairs(list) do
    if Count(id) > 0 and (not usable or usable(id)) then return id end
  end
end

-- ready now? Wand shots put a short cooldown on all items: ignored (FMF)
function E.ItemReady(id, now)
  if Count(id) <= 0 then return false end
  local start, dur, enable = ItemCooldown(id)
  if start == nil then return false end
  if enable == 0 or enable == false then return false end
  if start == 0 or dur <= ns.ITEM_GCD then return true end
  return start + dur - now <= 0.05
end

-- spells --------------------------------------------------------------------------------------

-- the player's spell book: name -> highest-rank spell ID (later in the book = higher rank)
function E.BookByName()
  local found = {}
  local book = C_SpellBook
  if not (book and book.GetNumSpellBookSkillLines and book.GetSpellBookSkillLineInfo and book.GetSpellBookItemInfo) then
    return found
  end
  local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
  local future = Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.FutureSpell
  for i = 1, Call(book.GetNumSpellBookSkillLines) or 0 do
    local line = Call(book.GetSpellBookSkillLineInfo, i)
    if type(line) == "table" and type(line.itemIndexOffset) == "number" and type(line.numSpellBookItems) == "number" then
      for j = line.itemIndexOffset + 1, line.itemIndexOffset + line.numSpellBookItems do
        local it = Call(book.GetSpellBookItemInfo, j, bank)
        if type(it) == "table" and type(it.spellID) == "number" and type(it.name) == "string"
          and not it.isPassive and not (future and it.itemType == future) then
          found[it.name] = it.spellID
        end
      end
    end
  end
  return found
end

function E.SpellName(id)
  local n = Call(C_Spell and C_Spell.GetSpellName, id)
  if type(n) ~= "string" or IsSecret(n) then return nil end
  return n
end

-- own cooldowns from own casts (the game hides spell cooldowns in combat): name -> ready time
local readyAt = {}
E.readyAt = readyAt

function E.OnOwnCast(spellID, now)
  local name = E.SpellName(spellID)
  if not name then return end
  local base = Call(GetSpellBaseCooldown, spellID)
  if type(base) == "number" and not IsSecret(base) and base / 1000 > ns.SPELL_GCD then
    readyAt[name] = now + base / 1000
  end
end

-- out of combat the game's cooldown is readable: the own timer follows it (talents, resets)
function E.SyncSpell(name, id, now)
  local cd = Call(C_Spell and C_Spell.GetSpellCooldown, id)
  if type(cd) ~= "table" or IsSecret(cd) then return end
  local start, dur = cd.startTime, cd.duration
  if IsSecret(start) or IsSecret(dur) or type(start) ~= "number" or type(dur) ~= "number" then return end
  if start > 0 and dur > ns.SPELL_GCD then readyAt[name] = start + dur else readyAt[name] = nil end
end

-- Lua side: ready by the own timer and usable (forms, mana: readable)
function E.SpellReady(name, id, now)
  local r = readyAt[name]
  if r and r - now > 0.05 then return false end
  local usable = Call(C_Spell and C_Spell.IsSpellUsable, id)
  if usable == false then return false end
  return true
end

-- game side: alpha from the spell's own cooldown (duration object, GCD ignored); applies 1 when
-- the game has no answer. In game the GCD part is checked (probe 0.0.3), a spell's own cooldown
-- in combat is NOT checked yet.
function E.ApplySpellCooldown(frame, id)
  local ok, dur = pcall(C_Spell and C_Spell.GetSpellCooldownDuration or error, id, true)
  if ok and type(dur) ~= "nil" then
    local okE, col = pcall(function() return dur:EvaluateRemainingDuration(E.ReadyCurve()) end)
    if okE then return E.ApplyColor(frame, col, 1) end
  end
  frame:SetAlpha(1)
  return false
end

-- for the tests
function E.Reset()
  calc = nil
  for k in pairs(curves) do curves[k] = nil end
  for k in pairs(readyAt) do readyAt[k] = nil end
end
