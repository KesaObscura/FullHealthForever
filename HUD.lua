-- Full Health Forever - what is on the screen: the health bar and the icon row.
--
-- Bar: health, the heals in flight and shields drawn after the health fill (anchored to its
-- end, so the game adds the amounts, Lua never does), the "health a moment ago" shadow under
-- it (old secret values kept in a ring and drawn: the gap is the damage), a text.
-- Icons, three layers per slot:
--   base   always, grey: the item or spell is there;
--   calm   (optional) ready, no danger: the icon in colour, dimmed;
--   bright ready AND in danger: full icon with a glow. It sits inside the two danger frames
--          (Engine.ApplyDanger), then in a "ready" frame (Lua: items, own spell timer), then in
--          a frame with the game's own cooldown alpha (spells in combat).

local _, ns = ...
local L = ns.L
local E = ns.Engine
local H = {}
ns.HUD = H

local BAR_TEX = "Interface\\TargetingFrame\\UI-StatusBar"
local GLOW_TEX = "Interface\\Buttons\\UI-ActionButton-Border"
local THREAT_TEX = "Interface\\Icons\\Ability_Warrior_Challange"

local function Font(fs, size)
  local obj = _G.GameFontHighlightOutline or _G.GameFontHighlight
  if obj then fs:SetFontObject(obj) end
  if size and fs.GetFont and fs.SetFont then
    pcall(function()
      local file, _, flags = fs:GetFont()
      if file then fs:SetFont(file, size, flags) end
    end)
  end
end

local function StatusBar(parent, r, g, b, a)
  local s = CreateFrame("StatusBar", nil, parent)
  s:SetStatusBarTexture(BAR_TEX)
  s:SetStatusBarColor(r, g, b, a or 1)
  s:SetMinMaxValues(0, 1)
  s:SetValue(0)
  return s
end

local function Tip(frame, title, text)
  if frame.SetMotionScriptsWhileDisabled then frame:SetMotionScriptsWhileDisabled(true) end
  frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(title, 1, 1, 1)
    GameTooltip:AddLine(text, 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
H.Tip = Tip

function H.Build()
  if H.frame then return H.frame end
  local f = CreateFrame("Frame", "FullHealthForeverFrame", UIParent)
  f:SetMovable(true)
  f:SetClampedToScreen(true)
  f:SetFrameStrata("MEDIUM")
  H.frame = f

  -- the bar
  local bar = CreateFrame("Frame", nil, f)
  H.bar = bar
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.55)
  H.shadow = StatusBar(bar, 0.62, 0.12, 0.10, 0.9)
  H.shadow:SetAllPoints()
  H.health = StatusBar(bar, 0.16, 0.74, 0.26)
  H.health:SetAllPoints()
  H.health:SetFrameLevel(H.shadow:GetFrameLevel() + 1)
  local clip = CreateFrame("Frame", nil, bar)
  clip:SetAllPoints()
  if clip.SetClipsChildren then clip:SetClipsChildren(true) end
  clip:SetFrameLevel(H.health:GetFrameLevel() + 1)
  H.incoming = StatusBar(clip, 0.45, 1, 0.55, 0.55)
  H.absorb = StatusBar(clip, 1, 0.92, 0.55, 0.55)
  local text = CreateFrame("Frame", nil, bar)
  text:SetAllPoints()
  text:SetFrameLevel(clip:GetFrameLevel() + 1)
  H.text = text:CreateFontString(nil, "OVERLAY")
  Font(H.text)
  H.text:SetPoint("CENTER")

  -- aggro warning left of the bar
  H.threat = CreateFrame("Frame", nil, f)
  H.threat.icon = H.threat:CreateTexture(nil, "ARTWORK")
  H.threat.icon:SetAllPoints()
  H.threat.icon:SetTexture(THREAT_TEX)
  H.threat.label = H.threat:CreateFontString(nil, "OVERLAY")
  Font(H.threat.label, 10)
  H.threat.label:SetPoint("TOP", H.threat, "BOTTOM", 0, -1)
  H.threat:Hide()

  -- the icon row and its danger frames
  H.row = CreateFrame("Frame", nil, f)
  H.dangerA = CreateFrame("Frame", nil, H.row)
  H.dangerA:SetAllPoints(H.row)
  H.dangerB = CreateFrame("Frame", nil, H.dangerA)
  H.dangerB:SetAllPoints(H.row)
  H.hold = H.row:CreateFontString(nil, "OVERLAY")
  Font(H.hold, 14)
  H.hold:SetPoint("CENTER", H.row, "CENTER")
  H.hold:SetText(L.holdLabel)
  H.hold:Hide()
  H.slots = {}

  -- unlocked: a handle over everything to drag the frame; right-click opens the settings
  local drag = CreateFrame("Button", nil, f)
  drag:SetAllPoints()
  drag:SetFrameLevel(f:GetFrameLevel() + 20)
  local dbg = drag:CreateTexture(nil, "BACKGROUND")
  dbg:SetAllPoints()
  dbg:SetColorTexture(0.2, 0.45, 1, 0.25)
  drag.label = drag:CreateFontString(nil, "OVERLAY")
  Font(drag.label, 11)
  drag.label:SetPoint("BOTTOM", drag, "TOP", 0, 2)
  drag.label:SetText(L.dragHint)
  drag:RegisterForDrag("LeftButton")
  if drag.RegisterForClicks then drag:RegisterForClicks("RightButtonUp") end
  drag:SetScript("OnDragStart", function() f:StartMoving() end)
  drag:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
    if ns.SavePosition then ns.SavePosition() end
  end)
  drag:SetScript("OnClick", function() if ns.ToggleOptions then ns.ToggleOptions(true) end end)
  Tip(drag, L.addonName, L.dragTip)
  drag:Hide()
  H.drag = drag
  return f
end

-- a slot: base, calm, bright (see the top of the file)
local function Slot(i)
  local s = H.slots[i]
  if s then return s end
  s = CreateFrame("Frame", nil, H.row)
  s.base = s:CreateTexture(nil, "BACKGROUND")
  s.base:SetAllPoints()
  if s.base.SetDesaturated then s.base:SetDesaturated(true) end
  s.base:SetAlpha(0.35)
  s.calmReady = CreateFrame("Frame", nil, s)
  s.calmReady:SetAllPoints(s)
  s.calmGame = CreateFrame("Frame", nil, s.calmReady)
  s.calmGame:SetAllPoints(s)
  s.calm = s.calmGame:CreateTexture(nil, "ARTWORK")
  s.calm:SetAllPoints()
  s.calm:SetAlpha(0.6)
  s.brightReady = CreateFrame("Frame", nil, H.dangerB)
  s.brightReady:SetAllPoints(s)
  s.brightGame = CreateFrame("Frame", nil, s.brightReady)
  s.brightGame:SetAllPoints(s)
  s.bright = s.brightGame:CreateTexture(nil, "ARTWORK")
  s.bright:SetAllPoints()
  s.glow = s.brightGame:CreateTexture(nil, "OVERLAY")
  s.glow:SetTexture(GLOW_TEX)
  if s.glow.SetBlendMode then s.glow:SetBlendMode("ADD") end
  s.glow:SetVertexColor(1, 0.25, 0.2)
  s.glow:SetPoint("CENTER", s, "CENTER")
  local countHolder = CreateFrame("Frame", nil, s)
  countHolder:SetAllPoints(s)
  countHolder:SetFrameLevel(H.dangerB:GetFrameLevel() + 5)
  s.count = countHolder:CreateFontString(nil, "OVERLAY")
  Font(s.count, 11)
  s.count:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", -2, 2)
  H.slots[i] = s
  return s
end

local function Icon(entry)
  if entry.kind == "item" then
    return E.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon, entry.id) or "Interface\\Icons\\INV_Misc_QuestionMark"
  end
  return E.Call(C_Spell and C_Spell.GetSpellTexture, entry.id) or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- places everything; entries: { kind = "item" | "spell", id, name, group }
function H.Layout(db, entries)
  H.Build()
  local size, gap = db.iconSize, 4
  local w, h = db.barWidth, db.barHeight
  H.bar:SetSize(w, h)
  H.bar:ClearAllPoints()
  H.bar:SetPoint("TOPLEFT", H.frame, "TOPLEFT", 0, 0)
  for _, s in ipairs({ H.incoming, H.absorb }) do s:SetSize(w, h) end
  H.incoming:ClearAllPoints()
  H.incoming:SetPoint("TOPLEFT", H.health:GetStatusBarTexture(), "TOPRIGHT")
  H.absorb:ClearAllPoints()
  H.absorb:SetPoint("TOPLEFT", H.incoming:GetStatusBarTexture(), "TOPRIGHT")
  H.threat:SetSize(h + 4, h + 4)
  H.threat:ClearAllPoints()
  H.threat:SetPoint("RIGHT", H.bar, "LEFT", -4, 0)
  local n = #entries
  local rowW = math.max(0, n * size + (n - 1) * gap)
  H.row:SetSize(math.max(rowW, 1), size)
  H.row:ClearAllPoints()
  H.row:SetPoint("TOP", H.bar, "BOTTOM", 0, -6)
  for i, entry in ipairs(entries) do
    local s = Slot(i)
    s.entry = entry
    s:SetSize(size, size)
    s:ClearAllPoints()
    s:SetPoint("TOPLEFT", H.row, "TOPLEFT", (i - 1) * (size + gap), 0)
    local tex = Icon(entry)
    s.base:SetTexture(tex)
    s.calm:SetTexture(tex)
    s.bright:SetTexture(tex)
    s.glow:SetSize(size * 1.75, size * 1.75)
    s:Show()
    s.brightReady:Show()
  end
  for i = n + 1, #H.slots do
    H.slots[i].entry = nil
    H.slots[i]:Hide()
    H.slots[i].brightReady:Hide()
  end
  H.entries = entries
  H.frame:SetSize(math.max(w, rowW), h + 6 + (n > 0 and size or 0))
  H.frame:SetScale(db.scale)
end

-- ring of old health values (secret): drawn as the shadow
local ring, ringPos, ringMax = {}, 1, 20

local function Fmt(fs, fmt, ...)
  local ok, s = pcall(string.format, fmt, ...)
  if not ok or not pcall(fs.SetText, fs, s) then pcall(fs.SetText, fs, "") end
end

-- per tick: bar values, danger, readiness. st = { line, inCombat, now, hold, mobOnMe, tankLost,
-- inGroup, role }
function H.Update(db, st)
  local p = "player"
  local max = E.Call(UnitHealthMax, p)
  if type(max) ~= "number" or E.IsSecret(max) or max <= 0 then max = 1 end
  local hp = E.Call(UnitHealth, p)
  for _, s in ipairs({ H.health, H.shadow, H.incoming, H.absorb }) do pcall(s.SetMinMaxValues, s, 0, max) end
  if type(hp) ~= "nil" then pcall(H.health.SetValue, H.health, hp) end
  -- shadow: the value of shadowSec seconds ago (ticks of 0.1 s)
  local want = math.max(1, math.floor((db.shadowSec or 2) * 10 + 0.5))
  if want ~= ringMax then ring, ringPos, ringMax = {}, 1, want end
  local old = ring[ringPos]
  ring[ringPos] = hp
  ringPos = ringPos % ringMax + 1
  if db.shadow and type(old) ~= "nil" then
    pcall(H.shadow.SetValue, H.shadow, old)
    H.shadow:Show()
  else
    H.shadow:Hide()
  end
  local inc = E.Call(UnitGetIncomingHeals, p)
  if type(inc) ~= "nil" then pcall(H.incoming.SetValue, H.incoming, inc) end
  local abs = E.Call(UnitGetTotalAbsorbs, p)
  if type(abs) ~= "nil" then pcall(H.absorb.SetValue, H.absorb, abs) end
  local s100 = CurveConstants and CurveConstants.ScaleTo100
  if db.healthText == "percent" and s100 then
    Fmt(H.text, "%.0f%%", E.Call(UnitHealthPercent, p, false, s100))
  elseif db.healthText == "value" then
    Fmt(H.text, "%s / %s", hp, max)
  elseif db.healthText == "both" and s100 then
    Fmt(H.text, "%s  %.0f%%", hp, E.Call(UnitHealthPercent, p, false, s100))
  else
    H.text:SetText("")
  end

  -- aggro: someone else's mob on me (party / raid, not tank), or a tank whose target is loose
  local showThreat = false
  if db.threatIcon and st.inCombat then
    if st.role == "tank" then
      showThreat = st.tankLost
      H.threat.label:SetText(L.lostLabel)
    else
      showThreat = st.inGroup and st.mobOnMe
      H.threat.label:SetText(L.aggroLabel)
    end
  end
  H.threat:SetShown(showThreat and true or false)

  -- danger
  local okDanger = E.ApplyDanger(H.dangerA, H.dangerB, st.line)
  H.dangerOk = okDanger
  H.dangerA:SetShown(not st.hold)
  H.hold:SetShown(st.hold and true or false)

  for _, s in ipairs(H.slots) do
    local e = s.entry
    if e then
      local ready
      if e.kind == "item" then
        ready = E.ItemReady(e.id, st.now)
        if ready and e.group == "bandage" then
          ready = not st.mobOnMe and not (st.bandagedUntil and st.bandagedUntil > st.now)
        end
        local n = E.Count(e.id)
        s.count:SetText(n > 1 and tostring(n) or "")
        s.calmGame:SetAlpha(1)
        s.brightGame:SetAlpha(1)
      else
        ready = E.SpellReady(e.name, e.id, st.now)
        s.count:SetText("")
        if st.inCombat then
          E.ApplySpellCooldown(s.brightGame, e.id)
          E.ApplySpellCooldown(s.calmGame, e.id)
        else
          s.brightGame:SetAlpha(1)
          s.calmGame:SetAlpha(1)
        end
      end
      s.ready = ready
      s.brightReady:SetAlpha(ready and 1 or 0)
      s.calmReady:SetAlpha((ready and db.calmIcons) and 1 or 0)
    end
  end
end

-- fail closed: something went wrong, nothing may light up
function H.Dark()
  if not H.frame then return end
  H.dangerA:SetAlpha(0)
  for _, s in ipairs(H.slots) do s.brightReady:SetAlpha(0) end
end

function H.SetUnlocked(on)
  H.Build()
  H.drag:SetShown(on and true or false)
end
