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

## Family rules (from Full Mana Forever's SEO plan, 10 Nov 2026; example in `docs/seo-fmf-example.md`)

1. **Separate words, so the addons do not take searches from each other:** mana / 5SR / regen
   only FMF; **health / healing potion / healthstone / bandage / defensive only FHF**; "time to
   die" / TTD / kill time only a third addon (Time to Die Forever, if the name is free).
   FHF mentions mana only where a fact needs it (healers: shared potion cooldown).
2. **Names in one row:** Full Mana Forever, Full Health Forever, Time to Die Forever.
3. **Every summary starts with its own main word and "WoW Forever"**, at most 256 characters.
4. **Main categories:** HUDs for FMF and FHF, Combat for Time to Die.
5. **One logo series:** the same flask style; blue (mana), red (health), a third item in its own
   colour.
6. **Links to each other only once a page exists** ("More Forever addons" block at the end of the
   descriptions, README, About); not through CurseForge dependencies.
7. **Honest promises:** only what works in game; "not tested" written as such.
8. **Same look:** README, releases ("Name X.Y.Z – WoW Forever … addon"), social preview, a common
   gallery footer.

Lessons from the FMF plan for our own pages:
- CurseForge **Source** and **Issues** fields -> the GitHub repository and its issues (strongest
  link without posts).
- `CURSEFORGE.md` without a `#` title on top (CurseForge shows the name itself; a title pushes the
  first image down).
- At the end of the description: one line per language (the TOC notes), so searches in other
  languages find it.
- "Tested so far" as a short, current list; FAQ entries for the questions players search.
- README: a **Download** line right under the badges (CurseForge + latest release); keywords in
  the headings; install line with a link to the CurseForge app in release texts.
- A new feature goes into the summary, About and the first paragraph, or search does not see it.
- GitHub Topics up to 20; never topics that read as Classic Era support (`wow-classic`).
- Not taken there and not here: renaming for keywords, forum / Reddit posts.

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
- **Summary** draft (≤ 256; starts with the main word and WoW Forever, family rule 3): "Health
  addon for WoW Forever: your healthstone, healing potion, bandage or defensive lights up only in
  real danger, when the heals in flight won't fix your low health. Health bar with incoming heals,
  shields and an aggro warning." (to check the length before use)
- **Categories**: main **HUDs** (family rule 4); additional Combat, Tank, Healer, Damage Dealer if
  CurseForge offers them; not Unit Frames (it is not a unit frame).
- **Source** and **Issues** fields: `https://github.com/KesaObscura/FullHealthForever` and its
  `/issues`.
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
