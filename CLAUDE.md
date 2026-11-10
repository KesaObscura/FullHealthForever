# Working on Full Health Forever

WoW: Forever addon (client 1.60.1, interface 16001). Plain Lua 5.1, no libraries. Sister addon
of Full Mana Forever (github.com/KesaObscura/FullManaForever): same owner, same rules; its
`CLAUDE.md` and `docs/notes.md` hold the Forever facts both addons rely on.
Files load in TOC order: Locale.lua -> Data.lua -> Profiles.lua -> Engine.lua -> HUD.lua ->
Core.lua -> Options.lua. Engine.lua: the danger test (health curve x heal prediction flag, two
nested alphas), the line, readiness; HUD.lua: bar, icon layers, aggro icon; Core.lua: settings,
events, tick, commands; Profiles.lua: from Full Mana Forever.

Status 0.1.0 (10 Nov 2026): first real version (MVP of `docs/plan.md`). The probe of 0.0.x is
removed; its results are in `docs/notes.md`. `Locale.lua` is generated: edit the texts in
`tools/locale_gen.py`, then `python3 tools/locale_gen.py Locale.lua`.

## Rules

- **Public repository: nothing personal.** No session links, no `Co-Authored-By:` trailers,
  no e-mail addresses, no player names in commits, PR texts, code, logs or docs. Commit messages
  describe the change only.
- **Every user-visible text in all 9 locale tables** of `Locale.lua` (enUS, deDE, ruRU, esES,
  frFR, ptBR, koKR, zhCN, zhTW; esMX falls back to esES); informal "you" (ru ты, fr tu).
  Technical output (`/fhf status`, `/fhf debug`) stays English (bug reports).
- **Every control that can be clicked has a tooltip** (also while greyed out).
- **Run the tests after every change:** `lua5.1 tests/run.lua` must end with `0 failed`. The
  mock keeps health SECRET (compare / arithmetic / concat raise errors). GitHub runs the same
  tests on every PR and every push to `main` (`.github/workflows/tests.yml`).
- **After every change, hand the owner a test zip** built from the committed state:
  `git archive --format=zip --prefix=FullHealthForever/ -o FullHealthForever-<version>-<hash>.zip HEAD -- . ':!tests' ':!tools' ':!docs' ':!.gitignore' ':!.github' ':!.pkgmeta' ':!CLAUDE.md' ':!TODO.md' ':!CURSEFORGE.md'`
- Work on the session branch; `main` changes only through a PR the owner merges with **Squash
  and merge**. No PR unless the owner asks.
- Commit author `Claude <noreply@anthropic.com>`; never rewrite the history of `main`.
- The owner's private research tooling is never described here and no scan commands go into the
  addon; only single facts checked against the game's API go into the code.
- Never guess for the game: unverified things are written down as "not tested in game".

## Design principle (owner)

Health is not mana. A potion "fits" almost always (a tank at 60 % is normal), so the signal is
**danger**, not "fits": low health counting heals in flight and absorbs, fast drop, no healer.
A wrong "press it now" is worse than no hint: fewer hints, but right ones. Roles differ: tank
(lower threshold, defensive cooldown first), solo / damage (potion or bandage earlier),
healer (own heal first, potion last).

## Owner decisions in force (7 Nov 2026)

- Name and folder `FullHealthForever` / "Full Health Forever"; own CurseForge page (owner creates
  it at 0.1); family look with Full Mana Forever; icon = FMF's flask in red (`icon.tga`, a
  present from a colleague; previews in `docs/images/`).
- Bar placed apart from FMF by default; "health 2 s ago" shadow on by default for now;
  thresholds 35 % (aggro on you) / 25 % (no aggro) / 30 % (tank) as the start.
- Plan: `docs/plan.md`; facts for both addons: `docs/forever-addon-api.md`; player reviews:
  `docs/reviews/`.
- SEO and store pages as strong as FMF's, for both addons: `docs/store.md` (keywords, GitHub
  About / topics / settings, CurseForge summary draft, ideas for FMF). FMF itself is changed only
  in its own sessions.
- **Family SEO rules (owner, 10 Nov; `docs/store.md`, example `docs/seo-fmf-example.md`):** each
  addon keeps its own words (FHF: health, healing potion, healthstone, bandage, defensive; never
  mana / 5SR / regen as keywords), every summary starts with its main word and "WoW Forever",
  main category HUDs, one logo series, links between the addons only once a page exists, only
  promises that work in game. Read `docs/store.md` before any store, README or release text.

## Keep in sync on every user-visible change

- `CHANGELOG.md`: headings `**Full Health Forever X.Y.Z**`.
- `README.md`: commands table.
- Version in `FullHealthForever.toc` and `ns.VERSION` in `Core.lua` (a test checks both).
- From 0.1: `CURSEFORGE.md` (the CurseForge description; the owner copies it by hand).

## Releases (from 0.1, as FMF)

- The owner uploads to CurseForge by hand, release type **Release**, game version 1.60.1.
- GitHub release: the owner creates the tag `vX.Y.Z`; title "Full Health Forever X.Y.Z – WoW
  Forever health addon"; zip `FullHealthForever-X.Y.Z.zip` (no hash).
