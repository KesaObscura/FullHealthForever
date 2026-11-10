-- Full Health Forever - settings window. Plain frames, no Blizzard templates (as Full Mana
-- Forever: templates change between client versions). Every control that can be clicked has a
-- tooltip, also while greyed out (owner rule).

local _, ns = ...
local L = ns.L
local win
local widgets = {}
local openList

local COL_W, PAD, ROW = 420, 16, 28
local VALUE_X = 250
local BTN_X = VALUE_X + 70

-- widget helpers (from Full Mana Forever, shortened) -----------------------------------------

local function Label(parent, text, font)
  local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
  fs:SetJustifyH("LEFT")
  fs:SetText(text or "")
  return fs
end

local function Tip(frame, title, text)
  if not text then return end
  if frame.SetMotionScriptsWhileDisabled then frame:SetMotionScriptsWhileDisabled(true) end
  frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(title, 1, 1, 1)
    GameTooltip:AddLine(text, 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function TipArea(parent, fs, title, text)
  local f = CreateFrame("Frame", nil, parent)
  f:SetAllPoints(fs)
  f:EnableMouse(true)
  Tip(f, title, text)
  return f
end

local function Button(parent, text, w, h)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(w, h or 22)
  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.24, 0.12, 0.13, 0.95)
  local hl = b:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 0.35, 0.3, 0.3)
  b:SetNormalFontObject("GameFontNormalSmall")
  b:SetHighlightFontObject("GameFontHighlightSmall")
  b:SetDisabledFontObject("GameFontDisableSmall")
  b:SetText(text)
  local fs = b:GetFontString()
  if fs and fs.GetStringWidth then b:SetWidth(math.max(w, math.ceil(fs:GetStringWidth() or 0) + 20)) end
  return b
end

local function Check(parent, text, get, set, tip, enabledIf)
  local cb = CreateFrame("CheckButton", nil, parent)
  cb:SetSize(24, 24)
  cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
  cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
  cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
  cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
  cb:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
  cb.label = Label(parent, text)
  cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
  cb:SetHitRectInsets(0, -math.ceil((cb.label:GetStringWidth() or 0) + 4), 0, 0)
  Tip(cb, text, tip)
  cb:SetScript("OnClick", function(self)
    set(self:GetChecked() and true or false)
    ns.Changed()
  end)
  cb.Refresh = function()
    cb:SetChecked(get() and true or false)
    if enabledIf then
      local on = enabledIf() and true or false
      cb:SetEnabled(on)
      cb:SetAlpha(on and 1 or 0.6)
      if on then cb.label:SetTextColor(1, 1, 1) else cb.label:SetTextColor(0.5, 0.5, 0.5) end
    end
  end
  widgets[#widgets + 1] = cb
  return cb
end

-- "Label:   value [-] [+]"; o = { step, lo, hi, fmt, tip, enabledIf }
local function Stepper(parent, text, get, set, o)
  local s = {}
  s.label = Label(parent, text .. ":")
  s.value = Label(parent, "", "GameFontNormal")
  s.minus = Button(parent, "-", 22)
  s.plus = Button(parent, "+", 22)
  s.value:SetPoint("LEFT", s.label, "LEFT", VALUE_X, 0)
  s.minus:SetPoint("LEFT", s.label, "LEFT", BTN_X, 0)
  s.plus:SetPoint("LEFT", s.minus, "RIGHT", 4, 0)
  TipArea(parent, s.label, text, o.tip)
  Tip(s.minus, text, o.tip)
  Tip(s.plus, text, o.tip)
  local function step(v, dir)
    return tonumber(("%.2f"):format(math.min(o.hi, math.max(o.lo, v + dir * o.step))))
  end
  local function change(dir)
    local v = get()
    local nv = step(v, dir)
    if nv ~= v then set(nv) end
    ns.Changed()
  end
  s.minus:SetScript("OnClick", function() change(-1) end)
  s.plus:SetScript("OnClick", function() change(1) end)
  s.Refresh = function()
    local v = get()
    s.value:SetText(o.fmt(v))
    local on = not o.enabledIf or o.enabledIf()
    for _, b in ipairs({ { s.minus, -1 }, { s.plus, 1 } }) do
      local can = on and step(v, b[2]) ~= v
      b[1]:SetEnabled(can)
      b[1]:SetAlpha(can and 1 or 0.3)
    end
    if on then s.label:SetTextColor(1, 1, 1) else s.label:SetTextColor(0.5, 0.5, 0.5) end
  end
  widgets[#widgets + 1] = s
  return s
end

-- a button that opens a list of choices below it; dd.Select(value) = a click on a row
local function Dropdown(parent, width, entries, getText, onPick, title, tip)
  local dd = Button(parent, " ", width)
  dd:SetWidth(width)
  local fs = dd:GetFontString()
  if fs then
    fs:ClearAllPoints()
    fs:SetPoint("LEFT", 10, 0)
    fs:SetPoint("RIGHT", -24, 0)
    fs:SetJustifyH("LEFT")
  end
  local arrow = dd:CreateTexture(nil, "OVERLAY")
  arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
  arrow:SetSize(12, 12)
  arrow:SetPoint("RIGHT", -6, 0)
  arrow:SetRotation(-math.pi / 2)
  Tip(dd, title, tip)
  local list = CreateFrame("Frame", nil, dd)
  list:SetFrameStrata("FULLSCREEN_DIALOG")
  list:SetPoint("TOPRIGHT", dd, "BOTTOMRIGHT", 0, -2)
  list:SetClampedToScreen(true)
  list:EnableMouse(true)
  local lbg = list:CreateTexture(nil, "BACKGROUND")
  lbg:SetAllPoints()
  lbg:SetColorTexture(0.06, 0.03, 0.04, 0.98)
  list:Hide()
  dd.list = list
  function dd.Select(value)
    list:Hide()
    onPick(value)
    ns.Changed()
  end
  local maxW = width
  dd.rows = {}
  for i, e in ipairs(entries) do
    local r = Button(list, e.text, width, 20)
    r:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -2 - (i - 1) * 21)
    r:SetScript("OnClick", function() dd.Select(e.value) end)
    Tip(r, e.text, e.tip or tip)
    maxW = math.max(maxW, r:GetWidth())
    dd.rows[i] = r
  end
  for _, r in ipairs(dd.rows) do r:SetWidth(maxW) end
  list:SetSize(maxW + 4, #entries * 21 + 3)
  dd:SetScript("OnClick", function()
    if list:IsShown() then list:Hide() return end
    if openList and openList ~= list then openList:Hide() end
    openList = list
    list:Show()
  end)
  dd:SetScript("OnHide", function() list:Hide() end)
  dd.Refresh = function() dd:SetText(getText()) end
  widgets[#widgets + 1] = dd
  return dd
end

-- a section title with a line to the end of its column (col 1 or 2)
local function Header(parent, text, col)
  local fs = Label(parent, text, "GameFontNormal")
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(1, 0.35, 0.3, 0.5)
  line:SetHeight(1)
  line:SetPoint("LEFT", fs, "RIGHT", 6, 0)
  line:SetPoint("RIGHT", parent, "LEFT", (col or 1) * COL_W - PAD, 0)
  return fs
end

-- the window ------------------------------------------------------------------------------------

local function DB() return ns.DB() end
local function Pct(v) return ("%d %%"):format(math.floor(v * 100 + 0.5)) end

local ROLE_TEXT = { auto = "roleAuto", tank = "roleTank", healer = "roleHealer", dps = "roleDps" }
local TEXT_TEXT = { percent = "htPercent", value = "htValue", both = "htBoth", off = "htOff" }

local function Build()
  if win then return win end
  win = CreateFrame("Frame", "FullHealthForeverOptions", UIParent)
  win:SetSize(COL_W * 2, 470)
  win:SetFrameStrata("DIALOG")
  win:SetMovable(true)
  win:SetClampedToScreen(true)
  win:EnableMouse(true)
  -- moved by its title bar only (a tooltip over the whole window would be in the way)
  local titleBar = CreateFrame("Frame", nil, win)
  titleBar:SetPoint("TOPLEFT")
  titleBar:SetPoint("TOPRIGHT")
  titleBar:SetHeight(36)
  titleBar:EnableMouse(true)
  titleBar:RegisterForDrag("LeftButton")
  titleBar:SetScript("OnDragStart", function() win:StartMoving() end)
  titleBar:SetScript("OnDragStop", function()
    win:StopMovingOrSizing()
    local point, _, rel, x, y = win:GetPoint()
    if point then ns.Acct().optPoint = { point, rel or point, x or 0, y or 0 } end
  end)
  Tip(titleBar, L.addonName, L.tipDragWindow)
  local bg = win:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.05, 0.03, 0.04, 0.96)
  local title = Label(win, L.addonName .. " " .. ns.VERSION, "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", PAD, -12)
  if UISpecialFrames then table.insert(UISpecialFrames, "FullHealthForeverOptions") end
  win:SetScript("OnShow", function() ns.optionsOpen = true; ns.UpdateVisibility() end)
  win:SetScript("OnHide", function() ns.optionsOpen = false; ns.UpdateVisibility() end)

  local left, right = PAD, COL_W + PAD
  local y = { -44, -44 }
  local function At(col, fs, dy)
    fs:SetPoint("TOPLEFT", win, "TOPLEFT", col == 1 and left or right, y[col])
    y[col] = y[col] - (dy or ROW)
  end

  -- left column: general, when to light up, profile
  At(1, Header(win, L.secGeneral, 1))
  At(1, Check(win, L.optLocked, function() return DB().locked end, function(v) ns.SetLocked(v) end, L.tipLocked))
  At(1, Check(win, L.optOnlyCombat, function() return DB().onlyCombat end, function(v) DB().onlyCombat = v end,
    L.tipOnlyCombat))
  local solo = Check(win, L.showSolo, function() return DB().showSolo end, function(v) DB().showSolo = v end,
    L.tipShowIn)
  At(1, solo)
  local party = Check(win, L.showParty, function() return DB().showParty end, function(v) DB().showParty = v end,
    L.tipShowIn)
  party:SetPoint("LEFT", solo, "LEFT", 130, 0)
  local raid = Check(win, L.showRaid, function() return DB().showRaid end, function(v) DB().showRaid = v end,
    L.tipShowIn)
  raid:SetPoint("LEFT", solo, "LEFT", 260, 0)
  At(1, Stepper(win, L.optScale, function() return DB().scale end, function(v) DB().scale = v end,
    { step = 0.05, lo = 0.5, hi = 2, fmt = Pct, tip = L.tipScale }).label)
  local langs = { { value = "auto", text = L.langAuto } }
  for _, l in ipairs(ns.LANGUAGES) do langs[#langs + 1] = { value = l.code, text = l.name } end
  local langLabel = Label(win, L.optLanguage .. ":")
  At(1, langLabel)
  local lang = Dropdown(win, 150, langs, function()
    local code = ns.Acct().language
    if code == "auto" then return L.langAuto end
    return ns.LanguageName(code)
  end, function(v)
    ns.Acct().language = v
    ns.Print(L.langReload)
  end, L.optLanguage, L.tipLanguage)
  lang:SetPoint("LEFT", langLabel, "LEFT", VALUE_X, 0)
  TipArea(win, langLabel, L.optLanguage, L.tipLanguage)

  y[1] = y[1] - 6
  At(1, Header(win, L.secDanger, 1))
  local roles = {}
  for _, r in ipairs({ "auto", "tank", "healer", "dps" }) do roles[#roles + 1] = { value = r, text = L[ROLE_TEXT[r]] } end
  local roleLabel = Label(win, L.optRole .. ":")
  At(1, roleLabel)
  local role = Dropdown(win, 150, roles, function() return L[ROLE_TEXT[DB().role] or "roleAuto"] end,
    function(v) DB().role = v end, L.optRole, L.tipRole)
  role:SetPoint("LEFT", roleLabel, "LEFT", VALUE_X, 0)
  TipArea(win, roleLabel, L.optRole, L.tipRole)
  local function Line(key, text, tip)
    At(1, Stepper(win, text, function() return DB()[key] end, function(v) DB()[key] = v end,
      { step = 0.05, lo = 0.1, hi = 0.8, fmt = Pct, tip = tip }).label)
  end
  Line("thrAggro", L.optThrAggro, L.tipThrAggro)
  Line("thrNoAggro", L.optThrNoAggro, L.tipThrNoAggro)
  Line("thrTank", L.optThrTank, L.tipThrTank)
  At(1, Check(win, L.optCalm, function() return DB().calmIcons end, function(v) DB().calmIcons = v end, L.tipCalm))

  y[1] = y[1] - 6
  At(1, Header(win, L.secProfile, 1))
  local profLabel = Label(win, L.optProfile .. ":")
  At(1, profLabel)
  local prof = Dropdown(win, 150, {
    { value = "shared", text = L.profSharedName },
    { value = "own", text = L.profOwnName },
  }, function() return ns.Profiles.IsOwn() and L.profOwnName or L.profSharedName end,
    function(v) if not ns.Profiles.Use(v) then ns.Print(L.profNone) end end, L.optProfile, L.tipProfile)
  prof:SetPoint("LEFT", profLabel, "LEFT", VALUE_X, 0)
  TipArea(win, profLabel, L.optProfile, L.tipProfile)

  -- right column: icons, bar
  At(2, Header(win, L.secIcons, 2))
  for _, g in ipairs(ns.GROUPS) do
    At(2, Check(win, L["grp_" .. g], function() return DB().groups[g] end, function(v) DB().groups[g] = v end,
      L["tipGrp_" .. g]))
  end
  At(2, Stepper(win, L.optIconSize, function() return DB().iconSize end, function(v) DB().iconSize = v end,
    { step = 2, lo = 24, hi = 72, fmt = tostring, tip = L.tipIconSize }).label)

  y[2] = y[2] - 6
  At(2, Header(win, L.secBar, 2))
  local texts = {}
  for _, k in ipairs({ "percent", "value", "both", "off" }) do texts[#texts + 1] = { value = k, text = L[TEXT_TEXT[k]] } end
  local textLabel = Label(win, L.optHealthText .. ":")
  At(2, textLabel)
  local htext = Dropdown(win, 150, texts, function() return L[TEXT_TEXT[DB().healthText] or "htPercent"] end,
    function(v) DB().healthText = v end, L.optHealthText, L.tipHealthText)
  htext:SetPoint("LEFT", textLabel, "LEFT", VALUE_X, 0)
  TipArea(win, textLabel, L.optHealthText, L.tipHealthText)
  At(2, Check(win, L.optShadow, function() return DB().shadow end, function(v) DB().shadow = v end, L.tipShadow))
  At(2, Stepper(win, L.optShadowSec, function() return DB().shadowSec end, function(v) DB().shadowSec = v end,
    { step = 0.5, lo = 0.5, hi = 5, fmt = function(v) return L.secondsFmt:format(v) end, tip = L.tipShadowSec,
      enabledIf = function() return DB().shadow end }).label)
  At(2, Stepper(win, L.optBarWidth, function() return DB().barWidth end, function(v) DB().barWidth = v end,
    { step = 10, lo = 80, hi = 400, fmt = tostring, tip = L.tipBarWidth }).label)
  At(2, Stepper(win, L.optBarHeight, function() return DB().barHeight end, function(v) DB().barHeight = v end,
    { step = 2, lo = 6, hi = 40, fmt = tostring, tip = L.tipBarHeight }).label)
  At(2, Check(win, L.optThreat, function() return DB().threatIcon end, function(v) DB().threatIcon = v end,
    L.tipThreat))

  -- buttons at the bottom
  local close = Button(win, L.btnClose, 90)
  close:SetPoint("BOTTOMRIGHT", -PAD, 12)
  close:SetScript("OnClick", function() win:Hide() end)
  Tip(close, L.btnClose, L.tipClose)
  local resetPos = Button(win, L.btnResetPos, 120)
  resetPos:SetPoint("RIGHT", close, "LEFT", -8, 0)
  resetPos:SetScript("OnClick", function() ns.ResetPosition(); ns.Print(L.posReset) end)
  Tip(resetPos, L.btnResetPos, L.tipResetPos)
  local resetProf = Button(win, L.btnResetProfile, 120)
  resetProf:SetPoint("RIGHT", resetPos, "LEFT", -8, 0)
  Tip(resetProf, L.btnResetProfile, L.tipResetProfile)
  -- reset asks first: the first click arms, a second one within 4 s resets (FMF 0.9.1)
  resetProf:SetScript("OnClick", function(self)
    local now = GetTime()
    if self.armedAt and now - self.armedAt < 4 then
      self.armedAt = nil
      self:SetText(L.btnResetProfile)
      ns.Profiles.Reset()
      ns.Print(L.profReset)
    else
      self.armedAt = now
      self:SetText(L.resetConfirm)
    end
  end)
  win.resetProf = resetProf
  local hold = Button(win, L.btnHold, 90)
  hold:SetPoint("BOTTOMLEFT", PAD, 12)
  hold:SetScript("OnClick", function() ns.Hold() end)
  Tip(hold, L.btnHold, L.tipHold)

  win:Hide()
  return win
end

function ns.RefreshOptions()
  if not win then return end
  for _, w in ipairs(widgets) do pcall(w.Refresh) end
end

-- every change: apply, redraw the window
function ns.Changed()
  ns.Relayout()
  ns.RefreshOptions()
end

function ns.ToggleOptions(forceShow)
  if not ns.DB() then return end
  Build()
  if win:IsShown() and not forceShow then win:Hide() return end
  win:ClearAllPoints()
  local p = ns.Acct().optPoint
  if type(p) == "table" and type(p[1]) == "string" and type(p[3]) == "number" then
    win:SetPoint(p[1], UIParent, p[2] or p[1], p[3], p[4] or 0)
  else
    win:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
  end
  ns.RefreshOptions()
  win:Show()
end

-- an entry in the game's own settings (Esc > Options > AddOns): one button that opens the window
function ns.InitOptions()
  if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
  local panel = CreateFrame("Frame")
  local t = Label(panel, L.addonName, "GameFontNormalLarge")
  t:SetPoint("TOPLEFT", 16, -16)
  local b = Button(panel, L.btnOpen, 160, 24)
  b:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -12)
  b:SetScript("OnClick", function()
    if SettingsPanel and SettingsPanel.Close then pcall(SettingsPanel.Close, SettingsPanel) end
    ns.ToggleOptions(true)
  end)
  Tip(b, L.btnOpen, L.tipOpen)
  local category = Settings.RegisterCanvasLayoutCategory(panel, L.addonName)
  Settings.RegisterAddOnCategory(category)
  ns.settingsPanel, ns.settingsButton = panel, b
end

-- for the tests: every widget
function ns.OptionsWidgets() return widgets end
function ns.OptionsWindow() Build() return win end
