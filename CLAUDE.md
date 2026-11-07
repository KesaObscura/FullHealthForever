# Working on Full Health Forever

WoW: Forever addon (client 1.60.1, interface 16001). Plain Lua 5.1, no libraries. Sister addon
of Full Mana Forever (github.com/KesaObscura/FullManaForever): same owner, same rules; its
`CLAUDE.md` and `docs/notes.md` hold the Forever facts both addons rely on.
Files load in TOC order: Locale.lua -> Core.lua -> Probe.lua.

Status 0.0.1: test build. `Probe.lua` (`/fhf probe`) is temporary: it is removed before 0.1
(checklist in `TODO.md`). The real addon is planned only after the probe results
(`docs/notes.md`, "Results") and three player reviews.

## Rules

- **Public repository: nothing personal.** No session links, no `Co-Authored-By:` trailers,
  no e-mail addresses, no player names in commits, PR texts, code, logs or docs. Commit messages
  describe the change only.
- **Every user-visible text in all 9 locale tables** of `Locale.lua` (enUS, deDE, ruRU, esES,
  frFR, ptBR, koKR, zhCN, zhTW; esMX falls back to esES); informal "you" (ru ты, fr tu).
  Technical probe output stays English (bug reports).
- **Every control that can be clicked has a tooltip** (also while greyed out).
- **Run the tests after every change:** `lua5.1 tests/run.lua` must end with `0 failed`. The
  mock keeps health SECRET (compare / arithmetic / concat raise errors).
- **After every change, hand the owner a test zip** built from the committed state:
  `git archive --format=zip --prefix=FullHealthForever/ -o FullHealthForever-<version>-<hash>.zip HEAD -- . ':!tests' ':!tools' ':!docs' ':!.gitignore' ':!.pkgmeta' ':!CLAUDE.md' ':!TODO.md'`
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

## Keep in sync on every user-visible change

- `CHANGELOG.md`: headings `**Full Health Forever X.Y.Z**`.
- `README.md`: commands table.
- Version in `FullHealthForever.toc` and `ns.VERSION` in `Core.lua` (a test checks both).
