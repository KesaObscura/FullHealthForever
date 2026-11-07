# TODO

## Before 0.1 (first real release)

- [ ] **Remove the probe from the code** (it is a test tool, not a feature):
  - delete `Probe.lua` and its line in `FullHealthForever.toc`;
  - drop `FullHealthForeverProbeLog` from `## SavedVariables`;
  - drop the locale keys `helpProbe`, `helpWatch`, `helpStop`, `helpSend`, `watchStart`,
    `watchDone`, `snapDone` in all 9 languages;
  - delete `tests/test_probe.lua` and its line in `tests/run.lua`;
  - change the TOC `## Notes` (all languages): no more "test build";
  - keep the findings: move every result into `docs/notes.md` first.
- [x] Owner ran probes 0.0.2 and 0.0.3 (results in `docs/notes.md`).
- [x] Work plan: `docs/plan.md`; facts for both addons: `docs/forever-addon-api.md`.
- [ ] Still to test in game: own cooldown in combat (duration curve), shared potion cooldown,
  group with a healer, a dungeon.
