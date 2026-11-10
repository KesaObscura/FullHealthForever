local M, test, eq, ok = T.M, T.test, T.eq, T.ok

local POTION, STONE, BANDAGE = 858, 5509, 2581

local function chatHas(pattern)
  for _, line in ipairs(M.chat) do if line:find(pattern) then return true end end
  return false
end

-- a logged-in priest with a potion, a healthstone and a bandage; opts change the state first
local function setup(opts)
  M.reset(opts)
  local S = M.S
  S.items[POTION] = { count = 3, spell = 440 }
  S.items[STONE] = { count = 1, spell = 6262 }
  S.items[BANDAGE] = { count = 5, spell = 1159 }
  S.book = { { id = 13908, name = "Desperate Prayer" } }
  if opts and opts.before then opts.before(S) end
  local ns = M.login()
  return ns, S
end

local function slot(ns, group)
  for _, s in ipairs(ns.HUD.slots) do
    if s.entry and s.entry.group == group then return s end
  end
end

local function bright(ns, group) return M.seen(slot(ns, group).bright) end
local function calm(ns, group) return M.seen(slot(ns, group).calm) end

local function fight(S, hp, threat, incoming)
  S.hpPct, S.threat, S.incoming = hp, threat, incoming or 0
  if not S.combat then M.combat(true) end
  M.tick(0.2)
end

test("login: frame built, icons in the dps order, hidden out of combat", function()
  local ns, S = setup()
  local H = ns.HUD
  ok(H.frame, "frame")
  local groups = {}
  for _, e in ipairs(ns.state.entries) do groups[#groups + 1] = e.group end
  eq(table.concat(groups, " "), "stone potion defensive bandage", "dps order")
  eq(H.frame:IsShown(), false, "only in combat by default")
  M.combat(true)
  eq(H.frame:IsShown(), true, "shown in combat")
  ok(chatHas("Full Health Forever 0.1.0"), "welcome once")
end)

test("danger: below the line with a mob on you lights the potion; above it does not", function()
  local ns, S = setup()
  fight(S, 0.30, 3)
  eq(ns.state.line, 0.35, "line with aggro")
  eq(bright(ns, "potion"), 1, "30 % < 35 %: lit")
  eq(bright(ns, "stone"), 1, "healthstone too")
  fight(S, 0.40, 3)
  eq(bright(ns, "potion"), 0, "40 % > 35 %: dark")
  eq(calm(ns, "potion"), 0.6, "ready icon shown dimmed")
end)

test("danger: a heal in flight that lifts you above the line keeps the icons dark", function()
  local ns, S = setup()
  fight(S, 0.30, 3, 100) -- 30 % + 10 % = 40 % > 35 %
  eq(bright(ns, "potion"), 0, "the heal will fix it")
  fight(S, 0.20, 3, 100) -- 20 % + 10 % = 30 % < 35 %
  eq(bright(ns, "potion"), 1, "the heal is too small")
end)

test("no mob on you: the lower line", function()
  local ns, S = setup()
  fight(S, 0.30, 0)
  eq(ns.state.line, 0.25, "line without aggro")
  eq(bright(ns, "potion"), 0, "30 % > 25 %")
  fight(S, 0.20, 0)
  eq(bright(ns, "potion"), 1, "20 % < 25 %")
end)

test("tank role: one line, defensives first, paladin tank without bubbles", function()
  local ns, S = setup({ before = function(S)
    S.class, S.role, S.inGroup = "PALADIN", "TANK", true
    S.book = { { id = 633, name = "Lay on Hands" }, { id = 498, name = "Divine Protection" },
      { id = 642, name = "Divine Shield" } }
  end })
  local groups, names = {}, {}
  for _, e in ipairs(ns.state.entries) do
    groups[#groups + 1] = e.group
    if e.name then names[#names + 1] = e.name end
  end
  eq(groups[1], "defensive", "defensives first for tanks")
  eq(table.concat(names, ","), "Lay on Hands", "no Divine Shield / Protection for a tank")
  fight(S, 0.32, 3)
  eq(ns.state.line, 0.30, "tank line")
  eq(bright(ns, "potion"), 0, "32 % > 30 %")
end)

test("healer role: healthstone first, potion last of the three", function()
  local ns = setup({ before = function(S) S.role, S.inGroup = "HEALER", true end })
  local groups = {}
  for _, e in ipairs(ns.state.entries) do groups[#groups + 1] = e.group end
  eq(table.concat(groups, " "), "stone defensive potion bandage", "healer order")
end)

test("the strongest item in the bags is shown", function()
  local ns, S = setup({ before = function(S) S.items[929] = { count = 1, spell = 441 } end })
  eq(slot(ns, "potion").entry.id, 929, "Healing Potion over Lesser")
  S.items[929] = nil
  M.fire("BAG_UPDATE_DELAYED")
  eq(slot(ns, "potion").entry.id, POTION, "back to the Lesser one")
end)

test("an item on cooldown stays dark; a wand's short cooldown is ignored", function()
  local ns, S = setup()
  S.items[POTION].start, S.items[POTION].dur = 100, 120
  fight(S, 0.10, 3)
  eq(bright(ns, "potion"), 0, "potion cooldown")
  eq(bright(ns, "stone"), 1, "healthstone still")
  S.items[POTION].start, S.items[POTION].dur = S.time, 1.8
  M.tick(0.1)
  eq(bright(ns, "potion"), 1, "wand cooldown ignored")
end)

test("bandage: never with a mob on you, then not for 60 s after the own one", function()
  local ns, S = setup()
  fight(S, 0.10, 3)
  eq(bright(ns, "bandage"), 0, "mob on you: damage would stop it")
  fight(S, 0.10, 0)
  eq(bright(ns, "bandage"), 1, "no mob: lit")
  M.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 1159)
  M.tick(0.1)
  eq(bright(ns, "bandage"), 0, "Recently Bandaged")
  S.time = S.time + 61
  M.tick(0.1)
  eq(bright(ns, "bandage"), 1, "60 s later")
end)

test("own defensive: dark after the own cast until its cooldown is over, game alpha in combat", function()
  local ns, S = setup()
  fight(S, 0.10, 3)
  eq(bright(ns, "defensive"), 1, "Desperate Prayer ready")
  M.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 13908)
  M.tick(0.1)
  eq(bright(ns, "defensive"), 0, "own timer: 10 min")
  ns.Engine.readyAt["Desperate Prayer"] = nil
  S.spellCd[13908] = true
  M.tick(0.1)
  eq(bright(ns, "defensive"), 0, "the game's cooldown alpha says no")
  S.spellCd[13908] = nil
  M.tick(0.1)
  eq(bright(ns, "defensive"), 1, "ready again")
end)

test("hold: nothing lights up until the end of the next fight", function()
  local ns, S = setup()
  SlashCmdList.FULLHEALTHFOREVER("hold")
  ok(chatHas("Hints on hold"), "hold message")
  fight(S, 0.10, 3)
  eq(bright(ns, "potion"), 0, "held")
  ok(ns.HUD.hold:IsShown(), "HOLD label")
  M.combat(false)
  ok(chatHas("Hints are back"), "released after the fight")
  fight(S, 0.10, 3)
  eq(bright(ns, "potion"), 1, "lit again in the next fight")
end)

test("fail closed: no answer from the game, nothing lights up", function()
  local ns, S = setup()
  M.healthPercentFails = true
  fight(S, 0.10, 3)
  M.healthPercentFails = nil
  eq(bright(ns, "potion"), 0, "dark")
end)

test("aggro icon: in a group for a mob on you, not solo; tank: target not on you", function()
  local ns, S = setup()
  fight(S, 0.9, 3)
  eq(ns.HUD.threat:IsShown(), false, "solo: the mob is always on you, no icon")
  S.inGroup = true
  M.tick(0.1)
  eq(ns.HUD.threat:IsShown(), true, "group: mob on you")
  eq(ns.HUD.threat.label:GetText(), "AGGRO")
  local ns2, S2 = setup({ before = function(S) S.role, S.inGroup, S.class = "TANK", true, "WARRIOR" end })
  S2.target, S2.targetThreat = true, 1
  fight(S2, 0.9, 3)
  eq(ns2.HUD.threat:IsShown(), true, "tank: target loose")
  S2.targetThreat = 3
  M.tick(0.1)
  eq(ns2.HUD.threat:IsShown(), false, "tank holds it")
end)

test("visibility: unlocked always, dead never, solo switched off", function()
  local ns, S = setup()
  SlashCmdList.FULLHEALTHFOREVER("unlock")
  eq(ns.HUD.frame:IsShown(), true, "unlocked out of combat")
  ok(ns.HUD.drag:IsShown(), "drag handle")
  M.combat(true)
  ok(chatHas("Fight started: frame locked"), "auto-lock")
  eq(ns.DB().locked, true)
  S.dead = true
  ns.UpdateVisibility()
  eq(ns.HUD.frame:IsShown(), false, "dead")
  S.dead = false
  ns.DB().showSolo = false
  ns.UpdateVisibility()
  eq(ns.HUD.frame:IsShown(), false, "solo off")
end)

test("the bar gets secrets only: health, shadow of the past, heals in flight", function()
  local ns, S = setup()
  fight(S, 0.8, 3, 50)
  for _ = 1, 25 do M.tick(0.1) end
  S.hpPct = 0.5
  M.tick(0.1)
  local H = ns.HUD
  ok(M.isSecret(H.health.value), "health secret")
  eq(M.plain(H.health.value), 500)
  eq(M.plain(H.shadow.value), 800, "shadow 2 s ago")
  ok(M.isSecret(H.incoming.value), "incoming secret")
  eq(H.text:GetText(), "50%", "percent text from the game")
end)

test("commands: help, status without names, profile own and shared", function()
  local ns = setup()
  SlashCmdList.FULLHEALTHFOREVER("")
  ok(chatHas("/fhf hold"), "help")
  SlashCmdList.FULLHEALTHFOREVER("status")
  ok(chatHas("role=dps"), "status")
  ok(chatHas("icons: stone:item:5509 potion:item:858"), "icons in status")
  for _, l in ipairs(M.chat) do ok(not l:find("Testname"), "no character name in chat") end
  ns.DB().thrAggro = 0.5
  SlashCmdList.FULLHEALTHFOREVER("profile own")
  ok(chatHas("its own profile"), "own")
  eq(ns.DB().thrAggro, 0.5, "own starts as a copy")
  ns.DB().thrAggro = 0.4
  SlashCmdList.FULLHEALTHFOREVER("profile shared")
  eq(ns.DB().thrAggro, 0.5, "shared unchanged")
  SlashCmdList.FULLHEALTHFOREVER("nonsense")
  ok(chatHas("Unknown command"), "unknown")
end)

test("settings saved: a damaged value is replaced by the default", function()
  M.reset()
  local ns = M.load()
  FullHealthForeverDB = { profiles = { Shared = { thrAggro = "x", groups = 5 } } }
  M.fire("ADDON_LOADED", "FullHealthForever")
  M.fire("PLAYER_LOGIN")
  eq(ns.DB().thrAggro, 0.35, "wrong type replaced")
  eq(type(ns.DB().groups), "table", "groups back")
end)
