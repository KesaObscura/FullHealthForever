# Notes: what WoW Forever lets an addon know about health

Facts shared with Full Mana Forever are in its `docs/notes.md` and `CLAUDE.md`
(github.com/KesaObscura/FullManaForever). Short version, as far as it concerns health:

- Max health is readable in combat (`UnitHealthMax`, FMF fifth log).
- Current health is treated as secret by FMF (rune health check through `UnitHealthPercent`
  with a curve). Not logged on its own yet: probe question 1.
- `UnitHealthPercent` takes a curve; FMF tries two argument orders, `(unit, false, curve)` and
  `(unit, curve)`. Which one Forever uses for health is not logged.
- Secret values: only `string.format` into a FontString, a StatusBar, or a curve (alpha) work;
  comparisons and arithmetic fail; `Curve:Evaluate` refuses them.
- No combat log for addons (`COMBAT_LOG_EVENT_UNFILTERED` shows the blocked action pop-up).
- In combat: auras and spell cooldowns secret; item cooldowns and counts readable; own casts
  readable (`UNIT_SPELLCAST_SUCCEEDED`, spell ID).

## Open questions (probe 0.0.1)

1. `UnitHealth` secret out of combat? in combat?
2. `UnitHealthPercent`: which argument order works; does the boolean change anything? In retail
   it is `usePredicted` (client-side prediction of the value), very likely NOT incoming heals.
3. `UnitGetIncomingHeals`, `UnitGetTotalAbsorbs`, `UnitGetTotalHealAbsorbs`,
   `UnitGetDetailedHealPrediction` + `CreateUnitHealPredictionCalculator`: present? secret?
   accepted by a StatusBar?
4. Events: `UNIT_HEALTH`, `UNIT_HEALTH_FREQUENT`, `UNIT_COMBAT` (amount readable?),
   `UNIT_HEAL_PREDICTION`, `UNIT_ABSORB_AMOUNT_CHANGED`.
5. Group: `UnitInRange`, `UnitGroupRolesAssigned`, party health through a curve.
6. Can a secret kept in a table be drawn later (the "health 2 s ago" bar)?

## Results

(none yet)
