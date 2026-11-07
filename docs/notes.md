# Notes: what WoW Forever lets an addon know about health

Facts shared with Full Mana Forever are in its `docs/notes.md` and `CLAUDE.md`
(github.com/KesaObscura/FullManaForever).

Legend: **[doc]** = Blizzard's API documentation of the Forever client (the `forever` branch of
the public UI source mirror, build 1.60.1 (70862), 7 Nov 2026), **[addon]** = what another
public Forever addon reports, not checked by us, **[FMF]** = checked in game for Full Mana
Forever, **[probe]** = checked by our probe in game. Nothing here is "tested" unless it says
[FMF] or [probe].

## The client

- Forever runs the modern client with the 12.x "secret values" rules [doc]: the UI source has the
  retail add-ons (Blizzard_DamageMeter, Blizzard_CooldownViewer, Blizzard_DeathRecap,
  Blizzard_CombatAudioAlerts, Blizzard_AuraContainer, Blizzard_PersonalResourceDisplay).
- Addon restrictions [doc] (`C_RestrictedActions.GetAddOnRestrictionState`, event
  `ADDON_RESTRICTION_STATE_CHANGED`): Combat, Encounter, ChallengeMode, PvPMatch, Map
  (dungeons / raids), Chat. Some values are secret only on restricted maps
  (`SecretOnRestrictedMaps`): **test in a dungeon too**, not only in the open world.
- `C_Secrets` [doc] answers in advance whether something will be secret:
  `HasSecretRestrictions`, `ShouldAurasBeSecret`, `ShouldCooldownsBeSecret`,
  `GetSpellAuraSecrecy(id)` / `GetSpellCooldownSecrecy(id)` (0 never, 1 always, 2 depends),
  `ShouldSpellCooldownBeSecret(id)`, `ShouldUnitHealthMaxBeSecret(unit)` ...
- Built-in help that competes with us: a red screen edge below 35 % health (`LowHealthFrame`,
  CVar `doNotFlashLowHealthWarning`), spoken health alerts and a "health pulse" sound below a
  chosen percent (`C_CombatAudioAlert`, accessibility options).

## Health

- `UnitHealth`, `UnitHealthMissing`, `UnitHealthPercent`: `SecretReturns` [doc]; current health is
  secret (rune health check in FMF works only through a curve [FMF]).
- `UnitHealthMax`: secret only when the unit is not player-controlled [doc]; readable in combat
  for the player [FMF].
- `UnitHealthPercent(unit, usePredicted, curve)` [doc]: the order of arguments is now known. The
  boolean is `usePredicted` as in `UnitHealth(unit, usePredicted)`: the client's prediction of the
  value, very likely NOT incoming heals (probe compares `true` / `false`).
- `UNIT_HEALTH` exists; `UNIT_HEALTH_FREQUENT` is not in the event list [doc].

## Incoming heals, absorbs

- `UnitGetIncomingHeals`, `UnitGetTotalAbsorbs`, `UnitGetTotalHealAbsorbs`: `SecretReturns` [doc];
  unit type `UnitTokenPvPRestrictedForAddOns` (restricted in PvP).
- `CreateUnitHealPredictionCalculator` + `UnitGetDetailedHealPrediction(unit, healer, calc)` [doc]:
  `GetIncomingHeals()` -> all, from the healer, from others, **clamped** (bool);
  `GetDamageAbsorbs()` / `GetHealAbsorbs()` -> amount, clamped;
  `EvaluateCurrentHealthPercent(curve)`; clamp modes; `SetIncomingHealOverflowPercent`.
  Used on Forever by public unit frame addons [addon].
- `clamped` + `Region:SetAlphaFromBoolean(flag, a, b)` [doc]: a secret yes/no becomes an alpha.
  Blizzard's own frames clamp when health + incoming heals > max x overflow. **Idea:** an overflow
  below 1 (0.5) would make `clamped` mean "health + heals above 50 %": the hint "nobody heals you
  in time" without reading a value. The probe tests whether the game takes values below 1.
- Heals over time are NOT in incoming heals, only heals being cast [addon, two addons agree].
  Own HoTs can be known from own casts; other players' HoTs cannot.

## Damage taken

- No combat log for addons [FMF].
- `UNIT_COMBAT` (unit, action, flags, amount, school) [doc]: `amount` is marked secret. One addon
  says heal amounts on you are readable, another says the amount is secret [addon]: probe.
- `C_DamageMeter` [doc]: the built-in meter keeps "damage taken" per fight, with
  `amountPerSecond`, deaths and a death recap ID. `SecretWhenInCombat`: secret in combat
  (can still be formatted into a text or fed to a bar), readable after the fight.
- `C_DeathRecap.GetRecapEvents(id)` [doc]: no secret flag: "what killed you" after death.
- A secret kept in a table can be drawn later: the probe shows "health 2 s ago" as a bar.

## Threat

- `UnitThreatSituation("player")` and `UnitThreatSituation("player", mob)` [doc]: "generally not
  secret" when one token is the player. "A mob is on you" may be readable in combat: a danger
  signal for damage dealers and solo players, "lost aggro" for tanks. Probe.

## Cooldowns, auras

- `C_Spell.GetSpellCooldown(id)` [doc]: `startTime` / `duration` secret when cooldowns are
  restricted, but `isActive`, `isEnabled`, `isOnGCD` are `NeverSecret`. If true in game, "own
  defensive ready" is readable in combat. FMF does not ask in combat today. Probe.
- `C_Spell.GetSpellCooldownDuration(id)` -> duration object; `EvaluateRemainingDuration(curve)`
  gives an alpha even when secret [doc]. Probe.
- `C_UnitAuras.AuraIsBigDefensive(spellID)` [doc]: the game's own list of big defensives.
- In combat auras are secret (`ShouldAurasBeSecret()` true; HoTs `ContextuallySecret`) [addon].
  `AuraContainer` (Blizzard_AuraContainer) shows auras by spell ID filter also in combat, for buffs
  on units you can assist; debuffs on friendly units are dropped [addon].
- Item cooldowns and counts readable in combat [FMF].

## Forever game changes that matter (third-party guides, check in game)

- Healing potions are made by First Aid; all ranks share the potion cooldown (2 min).
- Bandages as in Classic, Recently Bandaged 60 s; the First Aid talent "Field Medicine" shortens it
  outside dungeons, raids and battlegrounds (FMF notes: health and mana over 10 s).
- New First Aid items: poultices (diseases), tourniquets (bleeding); out of combat only, shared
  1-minute cooldown.
- Class changes touch defensives: Shield Wall talent now cuts the cooldown; paladin Sacred Duty
  shortens Forbearance; Barkskin usable in forms.

## Open questions (asked by probe 0.0.2)

1. `UnitHealth` secret out of combat? in combat? in a dungeon?
2. `usePredicted` true vs false while a heal is cast on you.
3. Incoming heals / absorbs: secret? StatusBar takes them? HoTs included?
4. Overflow below 1 accepted (read back 0.5)? Do the red / orange squares follow "health + heals"?
5. `UNIT_COMBAT` amount: number or secret (damage and heals, in and out of combat)?
6. Threat readable in combat?
7. Damage meter: available, numbers after the fight, DTPS text in combat?
8. Own defensive: `isActive` readable in combat? Duration curve square right?
9. Potions, healthstones, bandages: counts and cooldowns; does a mana potion start the healing
   potion cooldown?
10. Group: `UnitInRange`, roles, party health through a curve.

## Results

### Probe 0.0.2, 7 Nov 2026 (priest 21, solo, open world, ruRU client)

- [probe] Restrictions: only `Combat` turns on (2) in a fight in the open world; Encounter, Map and
  the others stay 0. `C_Secrets`: out of combat auras / cooldowns / stats not secret, in combat
  all three secret; `ShouldUnitHealthMaxBeSecret("player")` false.
- [probe] In combat: `UnitHealth`, `UnitHealthMissing`, `UnitHealthPercent` (also with
  `ScaleTo100`) secret; `UnitHealthMax` readable (732). Out of combat: not snapshotted yet.
- [probe] `UnitHealthPercent(p, false, curve)` returns the colour (table); `(p, curve)` returns a
  secret number: the order is `(unit, usePredicted, curve)` (FMF's first variant).
- [probe] Incoming heals, absorbs, heal absorbs secret in combat; StatusBar takes all of them;
  the bars and the "2 s ago" bar draw (screenshot).
- [probe] Calculator: works; methods are not listed (userdata), but each one answers;
  `SetIncomingHealOverflowPercent(0.5)` is kept (read back 0.50); `clamped` secret;
  `SetAlphaFromBoolean(secret)` works; `EvaluateCurrentHealthPercent(curve)` works.
- [probe] **`clamped` is false while no heal is in flight** (squares bright at 100 % health out of
  combat). So it alone does not mean "health + heals below the line"; the danger test is
  "health below the line (curve)" AND "not clamped", two nested alphas (probe 0.0.3).
- [probe] `UNIT_COMBAT`: `amount` SECRET for damage AND heals, in combat AND out of combat
  (bandage); `action` (WOUND, MISS, HEAL) and `school` readable. Hits can be counted, not summed.
- [probe] `UNIT_HEALTH` fires about once per hit in combat; `UNIT_HEALTH_FREQUENT` cannot be
  registered.
- [probe] Threat readable in combat: `UnitThreatSituation("player")` = 3,
  `UnitThreatSituation("player", "target")` = 3, `UnitDetailedThreatSituation` = true, 3, 100,
  255, 39 (raw values too). Open world only so far.
- [probe] Damage meter available; in combat the session's totals, DTPS and even
  `durationSeconds` are secret; `GetSessionDurationSeconds` readable.
- [probe] `C_Spell.GetSpellCooldown`: in combat `startTime` / `duration` secret, `isActive`
  readable (false), `isOnGCD` nil. Not yet seen while a cooldown runs (0.0.3 tracks own spells
  with a base cooldown of 10 s or more).
- [probe] Lesser Healing Potion (858): cooldown readable in combat after drinking (120 s).
  Heavy Linen Bandage (2581) -> spell 1159 "First Aid". Forever items in the bags with new IDs
  (e.g. food 4592 -> spell 1249506, an elixir 247754 -> spell 1245244).
- [probe] Aura secrecy (Recently Bandaged, Forbearance, Weakened Soul): 2 (depends), secret in
  combat.
- [probe] `GetSpecialization` does not exist; `UnitGroupRolesAssigned("player")` "NONE" solo.

### Probe 0.0.3, 7 Nov 2026 (same priest, solo, open world; log + 5 screenshots)

- [probe] **Danger with heals in flight works.** Red square = frame alpha from the health curve
  (below 50 %) x square alpha `SetAlphaFromBoolean(clamped50, 0.1, 1)` (calculator with
  overflow 0.5, clamp mode MissingHealth):
  - 295 / 732 (40 %), Heal in flight 349 (-> 88 %): red off, orange (clamped) on;
  - 347 / 732 (47 %), no heal: red on, orange off;
  - 197 / 732 (27 %), Lesser Heal in flight 99 (-> 40 %): red on, orange off.
  So `clamped` = "a heal is in flight and health + heal pass overflow x max".
- [probe] `UnitHealthPercent(p, true, S100)` equals `(p, false, S100)` also with a heal in flight
  (40.30 / 40.30): `usePredicted` does NOT add incoming heals.
- [probe] Health is secret **also out of combat** (`UnitHealth`, percent, missing), like mana.
- [probe] Threat out of combat: `nil` for all three calls; in combat 3 (readable).
- [probe] Damage meter **out of combat readable**: damage taken 455 in 47 s, 9.68 per second
  (and 930 / 95 s / 9.79 for a second fight); in combat secret.
- [probe] `isActive` of `C_Spell.GetSpellCooldown` is true during the **global cooldown** for every
  spell (all eight watched spells flip together on each cast; `isOnGCD` is nil). Alone it cannot
  tell "on its own cooldown". The duration object with `ignoreGCD = true` + a curve stayed "ready"
  during the GCD (green square bright while `isActive` true). A spell's own cooldown in combat
  (e.g. Psychic Scream) not seen yet.
- [probe] Lesser Healing Potion cooldown after the fight: start + 120 s, readable.
- [probe] Spells with a base cooldown >= 10 s in a level 21 priest's book include racials and
  Forever spells with new IDs (1259823, 1277462, 1277455).

### Probe 0.0.4, 7 Nov 2026 (same priest as healer, group of 5 in the open world and in a dungeon)

- [probe] **In a dungeon `Map` is 2 all the time**, `Combat` 2 in fights; at a boss `Encounter`
  and `Chat` turn on too (events: 1 -> activating, then active; off after the boss).
  `C_Secrets` the same as in the open world.
- [probe] In a dungeon fight (Combat 2 + Map 2): health, incoming heals, calculator, curve and
  `SetAlphaFromBoolean` behave exactly as in the open world; the test frame showed no failure.
- [probe] **Threat readable in a dungeon fight**: `UnitThreatSituation("player")` 0,
  `UnitDetailedThreatSituation("player", "target")` false, 0, 38.18, 42, 127; party members too
  (tank 3, a damage dealer 3, others 0). `nil` out of combat. A snapshot during a boss
  (Encounter 2) was not taken.
- [probe] **Roles readable in a group**: `UnitGroupRolesAssigned` HEALER (me), TANK, DAMAGER
  (also out of the dungeon in a group); "NONE" solo.
- [probe] Party members: `UnitHealth` and **`UnitHealthMax` secret** (also out of combat in the
  open world), `UnitHealthPercent(unit, false, curve)` works, `UnitInRange` -> two secrets,
  `UnitGetIncomingHeals` secret (nil once: probably out of range), class readable.
- [probe] Damage meter after each dungeon fight readable (whole group's damage taken and own,
  e.g. group 2557 / own 46 in 112 s); secret again if the next fight starts within the second.
- Same day, Full Mana Forever's `/fmf probe` in the dungeon: `map=2`, `UnitPowerPercent` + curve
  works (variant 1), max mana readable, in and out of combat.

Still open: own cooldown in combat via the duration curve (Psychic Scream not cast yet), shared
potion cooldown (no mana potion in the bags yet), a snapshot during a boss, other classes.
