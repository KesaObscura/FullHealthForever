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
  ok(chatHas("calculator methods: GetCurrentHealthPercent GetIncomingHealOverflowPercent GetIncomingHeals"), "methods listed")
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

test("snapshot with every 0.0.2 API: restrictions, overflow idea, threat, meter, defensives, items", function()
  M.reset({ prediction = true, full = true })
  M.load()
  M.S.combat = true
  slash("probe")
  ok(chatHas("restrictions %(0 off, 1 activating, 2 on%): Combat=2 Encounter=0"), "restrictions")
  ok(chatHas("secrets: build=true auras=true cooldowns=true"), "secret predicates")
  ok(chatHas("overflow 0.50: read back 0.50, incoming SECRET, clamped SECRET"), "overflow read back")
  ok(chatHas("texture:SetAlphaFromBoolean%(clamped50%): ok"), "alpha from a secret boolean")
  ok(chatHas("UnitThreatSituation%(p%): 0"), "threat readable")
  ok(chatHas("UnitThreatSituation%(p,target%): SECRET"), "threat on a mob secret")
  ok(chatHas("damage taken session: totalAmount=SECRET maxAmount=SECRET durationSeconds=12"), "meter")
  ok(chatHas("me: totalAmount=SECRET amountPerSecond=SECRET deathRecapID=0"), "own source")
  ok(chatHas('def 871 "Shield Wall": baseCD=300000 big=true'), "defensive from the spell book")
  ok(not chatHas('def 78 '), "other spells left out")
  ok(chatHas("cooldown: isActive=false isOnGCD=false isEnabled=true startTime=SECRET"), "isActive shown")
  ok(chatHas("duration object: secretValues=true evaluate%(curve%)=table"), "duration curve")
  ok(chatHas('aura 11196 "Recently Bandaged": secrecy=2 secretNow=true on me=duration=60'), "aura")
  ok(chatHas("item 929 x3: cd start=0 dur=0 enable=1  spell=441"), "potion")
  ok(chatHas("item 5509 x3"), "healthstone")
  ok(chatHas("bag consumable 77777: spell=441"), "new consumable from the bags")
  ok(not chatHas("bag consumable 929"), "known items not listed twice")
  ok(not chatHas("section .*ERROR"), "no section failed")
  noSecretStored()
end)

test("watch with every 0.0.2 API: squares get the engine's alpha, meter and restrictions", function()
  M.reset({ prediction = true, full = true })
  local ns = M.load()
  slash("probe watch 20")
  local W = ns.Probe.state
  ok(chatHas('defensive on screen: 871 "Shield Wall"'), "defensive picked")
  M.S.combat = true
  M.fire("PLAYER_REGEN_DISABLED")
  ok(chatHas("PLAYER_REGEN_DISABLED"), "combat start printed")
  ok(chatHas("Combat=2"), "restrictions on combat start")
  M.fire("ADDON_RESTRICTION_STATE_CHANGED", 0, 2)
  ok(chatHas("restriction 0 %-> 2"), "restriction event")
  M.fire("DAMAGE_METER_CURRENT_SESSION_UPDATED")
  for _ = 1, 12 do M.tick(0.1) end
  ok(M.isSecret(W.sqLow.alpha), "health curve alpha applied")
  ok(M.isSecret(W.sqDef.alpha), "cooldown curve alpha applied")
  eq(type(W.sq50.alpha), "table", "50 % square from a boolean")
  ok(M.isSecret(W.sq50.alpha.flag), "secret flag handed to the game")
  eq(W.lines[6]:GetText(), "threat 0   damage taken/s 41.6", "threat and meter on screen")
  eq(W.lines[7]:GetText(), "Shield Wall: isActive false (green = ready)", "defensive line")
  ok(chatHas("IN=1"), "non-unit events counted")
  slash("probe stop")
  ok(chatHas("squares: low=ok 50=ok 80=ok def=ok"), "squares reported")
  noSecretStored()
end)

test("watch without SetAlphaFromBoolean reports the squares as failed", function()
  M.reset({ prediction = true, full = true })
  M.noAlphaFromBoolean = true
  M.load()
  slash("probe watch")
  M.tick(0.2)
  slash("probe stop")
  M.noAlphaFromBoolean = nil
  ok(chatHas("squares: low=ok 50=FAILED 80=FAILED def=ok"), "failures reported")
end)
