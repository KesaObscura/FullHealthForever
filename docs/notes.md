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

## Open questions (probe 0.0.2)

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

(none yet)
