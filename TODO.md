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
- [ ] Owner runs the probe (`docs/probe-test.md`) and sends the SavedVariables file.
- [ ] Final work plan from the probe results and the three player reviews.
