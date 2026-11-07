# Store pages, GitHub and SEO (Full Health Forever, and ideas for Full Mana Forever)

Owner decisions (7 Nov 2026): name and folder `FullHealthForever` / "Full Health Forever"; own
CurseForge page (created by the owner at 0.1); same family look as Full Mana Forever; icon like
FMF's but with a red flask (a present from a colleague: `icon.tga`, preview
`docs/images/icon.png`, both side by side `docs/images/full-forever-family.png`); SEO as strong as
possible for both addons.

## SEO rules (same as FMF, in force)

- Keywords: **WoW, WoW Forever, World of Warcraft: Forever, Classic+ / Classic Plus**; for this
  addon also: health bar, incoming heals / heal prediction, shields (absorbs), healthstone,
  health potion, bandage, defensive cooldown, threat / aggro, survival / don't die, tank, healer,
  solo levelling.
- Only true claims: no Classic Era or retail support; no "damage per second of the last N
  seconds" (Forever hides it); no "reads your health" (it is secret: the game decides).
- No player names in texts. "Features asked for in the comments get built" is fine.
- 9 languages, not 10. Not only for healers or tanks: every class.
- CurseForge summary and gallery descriptions: at most 256 characters each.

## GitHub (the owner sets these by hand: Settings / About)

- **About** (description):
  "World of Warcraft: Forever addon (WoW Forever, Classic+): a health bar with incoming heals and
  shields, and your healthstone, health potion, bandage or defensive cooldown lights up only when
  you are in real danger: low health the heals in flight will not fix. Sister of Full Mana
  Forever." (until 0.1 add: " In development.")
- **Website**: the CurseForge page once it exists.
- **Topics** (up to 20): `wow`, `world-of-warcraft`, `wow-addon`, `wow-forever`,
  `world-of-warcraft-forever`, `classic-plus`, `wow-classic-plus`, `lua`, `addon`, `health-bar`,
  `heal-prediction`, `incoming-heals`, `healthstone`, `health-potion`, `threat`, `tank`,
  `healer`, `curseforge`.
- **Settings / General**: Pull requests: allow **squash merging only** (as FMF); "Automatically
  delete head branches" off (the session branch is reused); Issues on; Wiki off; Discussions off.
- **Social preview**: 1280x640 picture with the red flask and the title (to make when there is a
  screenshot of the bar; until then the icon is enough).
- Releases: tag `vX.Y.Z`, not a pre-release, title "Full Health Forever X.Y.Z – WoW Forever
  health addon", zip `FullHealthForever-X.Y.Z.zip`, body = two-line pitch, install line,
  changelog, bug-report link (as FMF).

## CurseForge (at 0.1, not before)

- **Title**: Full Health Forever.
- **Summary** draft (≤ 256): "Don't die in WoW Forever: your healthstone, health potion, bandage
  or defensive lights up only in real danger, when low health won't be fixed by the heals in
  flight. Health bar with incoming heals, shields and an aggro warning. For every class."
- **Categories**: main Combat (or HUDs, as FMF); additional Unit Frames? no (it is not a unit
  frame); Tank, Healer, Damage Dealer if CurseForge offers them; Buffs & Debuffs no.
- **Game version** 1.60.1, release type Release.
- **Avatar**: the red flask (256x256 `docs/images/icon.png`).
- **Description** (`CURSEFORGE.md` at 0.1): three blocks like FMF (what it does, how it works with
  Forever's rules, commands), images from GitHub raw links, "Tested so far", a line "From the
  maker of Full Mana Forever" with a link, and the bug-report link.
- **Gallery**: 1280x720 by `tools/gallery.py` from FMF (copy the tool), English addon texts.

## Ideas for Full Mana Forever (for the colleague; nothing changed in FMF from here)

1. **Cross-links both ways** (once FHF has a page): CurseForge "Relations" / description line
   "Sister addon: Full Health Forever"; README badge or line; GitHub About ending
   "Sister of Full Health Forever". Two pages linking each other help both in search.
2. **Family look**: blue and red flask side by side (`docs/images/full-forever-family.png`) in
   both READMEs and both CurseForge descriptions.
3. **README title keywords**: FMF's README title already carries "mana potion, five-second rule
   and mana regen addon for WoW Forever"; consider "World of Warcraft: Forever" spelled out once
   in the first line of the CurseForge description too (the site search reads it).
4. **Topics**: check FMF has `world-of-warcraft-forever`, `wow-classic-plus`, `mana-potion`,
   `healer`, `curseforge` (GitHub allows 20; FMF has 16).
5. **Alt texts**: every image in README and CurseForge already has a describing alt text (keep it);
   gallery descriptions ≤ 256 with one keyword each.
6. **New fact that can become a feature line**: own spell readiness in combat may come from the
   game (duration object + curve, `docs/forever-addon-api.md` §6) once tested.
