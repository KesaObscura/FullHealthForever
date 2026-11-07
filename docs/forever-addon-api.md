# WoW Forever for addon authors: what an addon can know (health, heals, threat, cooldowns)

Written for Full Mana Forever and Full Health Forever (same owner). Status: 7 Nov 2026,
client 1.60.1, Interface 16001.

**How sure is each line?**
- **[game]**: seen in game by the Full Health Forever probe (`Probe.lua`, `/fhf probe`; logs in
  `docs/notes.md`, "Results"), or checked in game for Full Mana Forever (**[FMF]**).
- **[doc]**: from Blizzard's API documentation of the Forever client: the generated files in
  `Interface/AddOns/Blizzard_APIDocumentationGenerated` of the public UI source mirror, branch
  `forever` (build 1.60.1 (70862)). Correct about what exists and what *may* be secret, not
  about every case.
- **[addon]**: what another public Forever addon reports. Not checked by us.

All probe tests so far: one priest (level 21), ruRU client: solo and in a group of 5 in the open
world, and in a 5-player dungeon (also a boss fight, without a snapshot during it). Raids,
battlegrounds and other classes are **not tested**.

---

## 1. The ground rules

1. Forever runs the **modern client with the 12.x secret values** [doc]. The UI source contains the
   retail add-ons: `Blizzard_DamageMeter`, `Blizzard_CooldownViewer`, `Blizzard_DeathRecap`,
   `Blizzard_CombatAudioAlerts`, `Blizzard_AuraContainer`, `Blizzard_PersonalResourceDisplay`.
2. A **secret** value may be: stored in a table and passed on [game], formatted into a FontString
   (`string.format` -> `SetText`) [game], fed to `StatusBar:SetMinMaxValues / SetValue` [game],
   handed to a curve API that returns a colour whose alpha goes to `SetAlpha` [FMF, game], or (a
   secret boolean) to `Region:SetAlphaFromBoolean(flag, alphaIfTrue, alphaIfFalse)` [game].
   It may NOT be compared, used in arithmetic, concatenated, tested with `if x then`, or given to
   `Curve:Evaluate` [FMF]. Use `type(x) == "nil"` instead of `x == nil` when x may be secret.
   `issecretvalue(x)` tells [game].
3. **Never print a secret to chat or store it in SavedVariables** (another Forever addon reports
   that a secret in chat corrupted the chat history [addon]). Print `"SECRET"` instead.
4. `string.format("%s", nil)` raises: guard optional values before formatting (the probe showed
   "n/a" lines because of this).
5. **Restrictions** [doc, game]: `C_RestrictedActions.GetAddOnRestrictionState(type)`, types
   Combat 0, Encounter 1, ChallengeMode 2, PvPMatch 3, Map 4 (dungeons, raids), Chat 5; states
   0 off, 1 activating, 2 on; event `ADDON_RESTRICTION_STATE_CHANGED`. In the open world only
   **Combat** turns on in a fight [game]. **In a dungeon `Map` is on all the time**; at a boss
   `Encounter` and `Chat` turn on as well [game]. With Combat + Map on, everything in this
   document behaved as in the open world [game]; during a boss (Encounter) only the events were
   seen, no snapshot yet. Raids not tested.
6. **The game tells you in advance** what will be secret [doc, game]: `C_Secrets.HasSecretRestrictions()`
   (true), `ShouldAurasBeSecret()`, `ShouldCooldownsBeSecret()`, `ShouldUnitStatsBeSecret()`
   (all three false out of combat, true in combat [game]), `ShouldUnitHealthMaxBeSecret(unit)`
   (false for the player [game]), `GetSpellAuraSecrecy(id)` / `GetSpellCooldownSecrecy(id)`
   (0 never, 1 always, 2 depends; Recently Bandaged, Forbearance, Weakened Soul, Power Word:
   Shield: 2 [game]), `ShouldSpellCooldownBeSecret(id)` / `ShouldSpellAuraBeSecret(id)`.

## 2. Health

| What | Out of combat | In combat | Source |
| --- | --- | --- | --- |
| `UnitHealth`, `UnitHealthMissing`, `UnitHealthPercent` | **secret** | secret | [game] |
| `UnitHealthMax("player")` | readable | readable (732) | [game] |
| `UnitHealthPercent(unit, usePredicted, curve)` -> colour | works | works | [game] |
| `UnitHealthPercent(unit, curve)` (2 arguments) | returns a secret number, the curve is taken as `usePredicted` | | [game] |
| `usePredicted = true` | same value as `false`, also with a heal in flight (40.30 / 40.30) | | [game] |
| `UNIT_HEALTH` | fires | about once per hit | [game] |
| `UNIT_HEALTH_FREQUENT` | cannot be registered | | [game] |
| `CurveConstants.ScaleTo100` | percent 0..100 (secret) | | [game] |

- **Health is secret also out of combat**, exactly like mana (FMF 0.9.4 finding) [game].
- "Health below X %" = a step colour curve through `UnitHealthPercent(unit, false, curve)`, alpha
  to a frame (FMF's rune health check) [FMF, game].
- `usePredicted` is the client's prediction of its own value, **not** "health plus incoming heals".

## 3. Incoming heals, absorbs: the heal prediction calculator

- `UnitGetIncomingHeals(unit[, healer])`, `UnitGetTotalAbsorbs`, `UnitGetTotalHealAbsorbs`:
  secret in and out of combat [game]; a StatusBar takes them [game]. Unit type
  `UnitTokenPvPRestrictedForAddOns`: restricted in PvP [doc].
- `CreateUnitHealPredictionCalculator()` + `UnitGetDetailedHealPrediction(unit, healer, calc)`
  [doc, game]. Methods (they answer, but cannot be listed: the object is userdata) [game]:
  `GetIncomingHeals()` -> all, from healer, from others, **clamped**; `GetDamageAbsorbs()` /
  `GetHealAbsorbs()` -> amount, clamped; `GetCurrentHealth`, `GetMaximumHealth`,
  `GetCurrentHealthPercent` (all secret); `EvaluateCurrentHealthPercent(curve)` -> colour;
  `SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)`;
  `SetIncomingHealOverflowPercent(x)` / `GetIncomingHealOverflowPercent()` (default 1.05,
  **0.5 and 0.8 are kept** [game]).
- **`clamped` = a heal is in flight AND health + heal pass overflow x max health** [game]:
  - false while no heal is in flight (also at 100 % health);
  - 40 % health + 349 heal (-> 88 %), overflow 0.5: true;
  - 27 % + 99 (-> 40 %): false.
- **Danger test "health below X % and the heals in flight do not lift it above X %"** [game]:
  a frame with alpha from the health curve (below X) holding a texture with
  `SetAlphaFromBoolean(clamped, dim, bright)` from a calculator with overflow X. Nested alphas
  multiply, so the texture is bright only when both say yes. Nothing is read in Lua.
- **Heals over time are not in incoming heals**, only heals being cast [addon, two addons agree].
  Own HoTs can be followed from own casts (`UNIT_SPELLCAST_SUCCEEDED`, spell ID [FMF]); other
  players' HoTs cannot be seen in combat.
- The addon itself never learns "danger" (it is an alpha inside the engine). Lua cannot branch on
  it, log it or pass it to another addon.

## 4. Damage taken

- **No combat log** for addons (`COMBAT_LOG_EVENT_UNFILTERED` shows the blocked action pop-up)
  [FMF].
- `UNIT_COMBAT` (unit, action, flags, amount, school) [game]: `amount` **secret always**: damage and
  heals, in and out of combat (also a bandage out of combat). `action` (WOUND, MISS, HEAL ...),
  `flags`, `school` readable: hits can be counted and timed, not summed.
- **Built-in damage meter** `C_DamageMeter` [doc, game]: `IsDamageMeterAvailable()` true; session
  "Current", type `DamageTaken` (7): in combat the totals, the per-second value and even
  `durationSeconds` are secret; **out of combat readable**: `totalAmount` 455, `amountPerSecond`
  9.68, `durationSeconds` 47, own source with `isLocalPlayer` [game]. `GetSessionDurationSeconds`
  readable always.
- `C_DeathRecap.GetRecapEvents(id)`, `HasRecapEvents`, `GetRecapMaxHealth` exist, no secret flag
  [doc]; not seen after a death yet.
- "Health 2 s ago": keep the secret `UnitHealth` values in a ring buffer and draw the old one as a
  second bar [game]. The gap shows the damage; nothing is calculated.

## 5. Threat, roles, other group members

- `UnitThreatSituation("player")`, `UnitThreatSituation("player", "target")`,
  `UnitDetailedThreatSituation("player", "target")` [game]: **readable in combat** (3; true, 3,
  100, 255, 39); `nil` out of combat. **Also in a dungeon fight**, for the player and for party
  members (`UnitThreatSituation("party2")` 3) [game]. Documentation: secret for other unit pairs
  on restricted maps [doc].
- `UnitGroupRolesAssigned(unit)`: readable in a group (TANK, HEALER, DAMAGER), "NONE" solo [game].
  `GetSpecialization` does not exist.
- Party members [game]: `UnitHealth` and **`UnitHealthMax` secret** (even out of combat),
  `UnitHealthPercent(unit, false, curve)` works, `UnitInRange` two secrets,
  `UnitGetIncomingHeals` secret, class readable.

## 6. Spell cooldowns in combat

- `C_Spell.GetSpellCooldown(id)` [game]: out of combat everything readable; in combat
  `startTime`, `duration` secret, **`isActive`, `isEnabled` readable** (`NeverSecret` [doc]),
  `isOnGCD` nil.
- **`isActive` is true during the global cooldown** for every spell [game] (all watched spells flip
  together on each cast). Alone it cannot tell "this spell is on its own cooldown".
- `C_Spell.GetSpellCooldownDuration(id, ignoreGCD)` -> duration object [doc, game]:
  `HasSecretValues()` true in combat; `EvaluateRemainingDuration(colourCurve)` -> colour (works in
  combat) [game]. With `ignoreGCD = true` and a step curve (alpha 1 below 0.1 s left) the icon
  stayed "ready" during the global cooldown [game]. **During a spell's own cooldown in combat not
  seen yet** (next test: Psychic Scream). If it works: own spells' readiness in combat without own
  timers, for FMF's spells too.
- `GetSpellBaseCooldown(id)` readable (ms) [FMF, game]; `C_UnitAuras.AuraIsBigDefensive(id)` exists
  [doc, game] (Power Word: Shield: false).
- `Cooldown:SetCooldownFromDurationObject` exists but is marked protected [doc]; not tried.

## 7. Items

- Item counts and cooldowns readable in and out of combat [FMF, game]: Lesser Healing Potion 858:
  `start, 120` after drinking. `C_Container.GetItemCooldown`, `C_Item.GetItemCount`,
  `C_Item.GetItemSpell` (858 -> 440, Heavy Linen Bandage 2581 -> 1159 "First Aid").
- Forever items and spells have new IDs (food 4592 -> spell 1249506, an elixir 247754 -> spell
  1245244; priest spells 1259823, 1277462, 1277455) [game]: read IDs from the game, do not
  assume Classic tables.
- **Shared potion cooldown (mana / health): not tested yet.** In Classic all potions share it;
  guides say all Forever healing potion ranks share 2 min. If mana and health potions share it, a
  healing potion makes FMF's potion icon wait, and the reverse.

## 8. Auras

- In combat auras are secret (`ShouldAurasBeSecret()` true [game]); `GetPlayerAuraBySpellID`
  returns nothing then [FMF]. Out of combat readable.
- `AuraContainer` (`Blizzard_AuraContainer`) shows auras by a spell ID filter also in combat, for
  buffs on units you can assist; debuffs on friendly units are dropped [addon]. Not tried.

## 9. Built-in features that compete

- Red screen edge below 35 % health (`LowHealthFrame`, CVar `doNotFlashLowHealthWarning`) [doc].
- Spoken health alerts and a "health pulse" sound below a chosen percent
  (`C_CombatAudioAlert`, accessibility options) [doc].
- Cooldown manager (`C_CooldownViewer`) with sound / visual alerts [doc].

## 10. Missing or different

- `GetSpecialization` does not exist [game]; `UnitGroupRolesAssigned("player")` "NONE" solo [game].
- `UNIT_HEALTH_FREQUENT` does not exist [game].
- Calculator methods are not listed by `getmetatable` (userdata) [game]: call them by name in `pcall`.

## 11. For Full Mana Forever

| Finding | What FMF could do | Status |
| --- | --- | --- |
| Duration object + curve gives "ready" in combat, GCD ignored | Own spells (Evocation, Life Tap ...) ready in combat from the game instead of own timers | GCD part [game]; own cooldown in combat not seen yet |
| `isActive` true during GCD | Do not use `isActive` alone for readiness | [game] |
| Shared potion cooldown? | If shared: show it (a healing potion blocks the mana potion) | not tested |
| Threat readable in combat | not needed by FMF | [game] |
| Damage meter readable after a fight | not needed by FMF | [game] |
| Health secret also out of combat | the rune / Life Tap health checks must stay curve-based | [game] |
| Restrictions in dungeons | `Map` on all the time; FMF's curve, max mana and the FHF calculator work there (both probes, 7 Nov) | boss fight (Encounter) not snapshotted |
| `C_Secrets` predicates | clearer warnings / diagnostics ("cooldowns are secret now") | [doc, game] |

## 12. How these facts were found

The probe (`Probe.lua` in Full Health Forever 0.0.x; removed before 0.1): `/fhf probe` prints a
snapshot (which API exists, what is secret), `/fhf probe watch [s]` shows a test frame (texts
from secrets, bars, alpha squares) and logs events; one second after each fight it writes what is
readable again. Logs go to `FullHealthForeverProbeLog` (SavedVariables), without names and
without secrets. Tests run on a mock where secrets raise on compare, arithmetic and concat
(`tests/mock_wow.lua`).
