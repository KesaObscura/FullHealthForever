-- The probe (temporary, see TODO.md): it must never touch a secret except by formatting it
-- or handing it to a StatusBar, never print or store one, and never break on a missing API.
local M, test, eq, ok = T.M, T.test, T.eq, T.ok

local function chatHas(pattern)
  for _, line in ipairs(M.chat) do if line:find(pattern) then return true end end
  return false
end

local function noSecretStored()
  for _, run in ipairs(FullHealthForeverProbeLog.runs) do
    for _, line in ipairs(run.lines) do ok(type(line) == "string", "log line is not a plain string") end
  end
  for _, line in ipairs(M.chat) do ok(type(line) == "string", "chat line is not a plain string") end
end

local function slash(msg) SlashCmdList.FULLHEALTHFOREVER(msg) end

test("help lists the probe commands", function()
  M.reset()
  M.load()
  slash("")
  ok(chatHas("/fhf probe watch"), "help shows watch")
  slash("nonsense")
  ok(chatHas("Unknown command"), "unknown command")
end)

test("snapshot with secret health and no prediction API: no error, secrets marked", function()
  M.reset()
  M.load()
  slash("probe")
  ok(chatHas("UnitHealth%(p%): SECRET"), "health marked secret")
  ok(chatHas("UnitHealthMax%(p%): 1000"), "max readable")
  ok(chatHas("API no: .*UnitGetIncomingHeals"), "missing API listed")
  ok(chatHas("UnitGetIncomingHeals%(p%): missing"), "missing call reported")
  ok(chatHas("Snapshot done"), "finished")
  noSecretStored()
  eq(#FullHealthForeverProbeLog.runs, 1)
end)

test("snapshot with prediction API, calculator and a party member", function()
  M.reset({ prediction = true, party = true })
  M.load()
  M.S.combat = true
  slash("probe")
  ok(chatHas("combat=true"), "combat flag")
  ok(chatHas("UnitGetIncomingHeals%(p%): SECRET"), "incoming secret")
  ok(chatHas("calculator methods: GetCurrentHealthPercent GetIncomingHeals HasSecretValues"), "methods listed")
  ok(chatHas("calc:HasSecretValues: true"), "calculator method called")
  ok(chatHas("bar:SetValue%(health%): "), "bar accepts secret health")
  ok(chatHas("party1 UnitInRange: SECRET, true"), "group unit probed")
  noSecretStored()
end)

test("snapshot survives an API that errors", function()
  M.reset()
  M.load()
  UnitHealthPercent = function() error("Usage: bad arguments") end
  slash("probe")
  ok(chatHas("UnitHealthPercent%(p%): ERROR Usage: bad arguments"), "error reported")
  ok(chatHas("Snapshot done"), "finished")
end)

test("watch: events counted, secrets only on screen, stops by itself", function()
  M.reset({ prediction = true, badEvents = { UNIT_HEALTH_FREQUENT = true } })
  local ns = M.load()
  slash("probe watch 10")
  local W = ns.Probe.state
  ok(W.running, "running")
  ok(chatHas("failed: UNIT_HEALTH_FREQUENT"), "unknown event reported")
  M.fire("UNIT_HEALTH", "player")
  M.fire("UNIT_COMBAT", "player", "WOUND", "", M.secret(150), 1)
  M.fire("UNIT_COMBAT", "party1", "WOUND", "", M.secret(10), 1)
  M.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "cast-guid", 2050)
  M.tick(0.2)
  M.tick(1)
  ok(chatHas("UNIT_COMBAT action=\"WOUND\" flag=\"\" amount=SECRET"), "amount marked secret")
  ok(chatHas("cast spellID=2050"), "own cast")
  ok(chatHas("C=1"), "per-second count")
  ok(W.frame.shown, "frame shown")
  eq(W.lines[1]:GetText(), "health 600 / 1000", "secret formatted on screen")
  eq(W.lines[5]:GetText(), "last UNIT_COMBAT: WOUND 150 ", "last combat on screen")
  ok(M.isSecret(W.barNow.value), "bar fed with the secret")
  for _ = 1, 30 do M.tick(0.3) end
  ok(not W.running, "stopped after its time")
  ok(not W.frame.shown, "frame hidden")
  ok(chatHas("total H=1 HF=0 MAX=0 C=1"), "totals")
  ok(chatHas("other units=1"), "other units counted, not shown")
  ok(chatHas("bars: health=ok ago=ok incoming=ok absorb=ok"), "bars")
  noSecretStored()
end)

test("watch: a bar that refuses secrets is reported, nothing breaks", function()
  M.reset({ barRefusesSecret = true })
  local ns = M.load()
  slash("probe watch")
  for _ = 1, 25 do M.tick(0.1) end -- past the 2 s of the "ago" ring
  slash("probe stop")
  ok(not ns.Probe.state.running, "stopped")
  ok(chatHas("bars: health=FAILED ago=FAILED incoming=no value absorb=no value"), "failures reported")
end)

test("watch length is clamped and old runs are dropped", function()
  M.reset()
  local ns = M.load()
  slash("probe watch 5000")
  ok(chatHas("watch 300 s"), "max 300")
  slash("probe stop")
  for _ = 1, 10 do slash("probe") end
  eq(#FullHealthForeverProbeLog.runs, 8, "kept runs")
end)
