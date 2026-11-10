local M, test, eq, ok = T.M, T.test, T.eq, T.ok

local function setup()
  M.reset()
  M.S.items[858] = { count = 2, spell = 440 }
  local ns = M.login()
  return ns
end

-- every frame that reacts to a click (OnClick, or a drag handle) needs a tooltip (owner rule)
test("every clickable control in the settings, the game's panel and the drag handle has a tooltip", function()
  local ns = setup()
  ns.ToggleOptions(true)
  local clickable, missing = 0, {}
  for _, o in ipairs(M.all) do
    if o.scripts.OnClick or o.scripts.OnDragStart then
      clickable = clickable + 1
      if not o.scripts.OnEnter then missing[#missing + 1] = tostring(o.kind) .. ":" .. tostring(o.text) end
    end
  end
  ok(clickable > 30, "found the controls (" .. clickable .. ")")
  eq(#missing, 0, "without tooltip: " .. table.concat(missing, ", "))
  ok(M.category and M.category.name == "Full Health Forever", "entry in the game's settings")
end)

test("the window changes the profile: check, stepper, dropdown, reset asks first", function()
  local ns = setup()
  local win = ns.OptionsWindow()
  ns.ToggleOptions(true)
  eq(win:IsShown(), true)
  eq(ns.HUD.frame:IsShown(), true, "the frame shows while the settings are open")
  local function find(pred) for _, o in ipairs(M.all) do if pred(o) then return o end end end
  -- the "Bandage" checkbox
  local cb = find(function(o) return o.kind == "CheckButton" and o.label and o.label.text == "Bandage" end)
  ok(cb, "bandage checkbox")
  cb:SetChecked(false)
  cb.scripts.OnClick(cb)
  eq(ns.DB().groups.bandage, false, "switched off")
  -- the + of the first line stepper (mob on you)
  local label = find(function(o) return o.kind == "FontString" and o.text == "Line, mob on you:" end)
  ok(label, "stepper label")
  local plus
  for _, o in ipairs(M.all) do
    if o.kind == "Button" and o.text == "+" and o.points and o.points[1] and o.points[1][2] and o.points[1][2].points then
      local minus = o.points[1][2]
      if minus.points[1] and minus.points[1][2] == label then plus = o end
    end
  end
  ok(plus, "plus button")
  plus.scripts.OnClick(plus)
  eq(ns.DB().thrAggro, 0.4, "35 % + 5 %")
  -- the role dropdown
  for _, w in ipairs(ns.OptionsWidgets()) do
    if w.Select and w.rows and #w.rows == 4 and w.rows[2].text == "Tank" then w.Select("tank") end
  end
  eq(ns.DB().role, "tank", "role picked")
  eq(ns.state.role, "tank", "applied at once")
  -- reset: first click arms, second resets
  local reset = win.resetProf
  reset.scripts.OnClick(reset)
  eq(ns.DB().role, "tank", "not yet")
  eq(reset.text, "Click again")
  reset.scripts.OnClick(reset)
  eq(ns.DB().role, "auto", "reset")
  win:Hide()
  eq(ns.optionsOpen, false)
end)
