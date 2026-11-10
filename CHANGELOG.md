# Changelog

**Full Health Forever 0.1.0**

First version with the real addon (the test probe of 0.0.x is gone).

- **Health bar** with your heals in flight and shields drawn after the health, and a dark red
  **shadow** of your health a moment ago: the gap shows how fast you are losing health
  (Forever hides damage numbers from addons; this is the honest view).
- **Icons that light up only in real danger:** healthstone, healing potion, bandage and your
  own defensive spells light up when your health is below the line **and the heals being cast
  on you will not lift it above**. The game decides this itself; the addon never reads your
  health.
- **The line follows the fight:** 35 % while a mob is on you, 25 % while none is, 30 % for
  tanks (all three adjustable).
- **Roles from the group** (tank, healer, damage; solo counts as damage) or set by hand. Tanks:
  own defensives first, no Divine Shield / Divine Protection for paladin tanks. Healers:
  healthstone first, potion last.
- **Aggro warning:** in a group an icon when a mob is on you; tanks see when their target is
  not on them.
- **Bandage** only while no mob is on you and not within 60 s of your last one.
- **`/fhf hold`:** no lit icons until the end of the next fight.
- Ready icons can show dimmed; grey ones are not ready. Shown only in combat by default; solo,
  party and raid switches.
- Settings window (`/fhf config`, also in the game's AddOns settings), shared and own
  profiles, 9 languages.

**Full Health Forever 0.0.4** (test build, not for CurseForge)

- Own icon in the addon list: the Full Mana Forever flask in red.
- Probe unchanged.

**Full Health Forever 0.0.3** (test build, not for CurseForge)

- Probe after the first test: the red square is now "danger" (health below 50 % and the heals
  in flight do not lift it above 50 %), the orange one shows the game's "heal reaches 50 %"
  flag alone.
- Own spells with a cooldown of 10 s or more are watched: every change of "on cooldown" is
  written down, also in combat.
- One second after each fight the probe writes what is readable again: health, damage meter,
  Recently Bandaged, potion cooldowns (mana potions too: shared cooldown?).
- Fixed: empty values made two lines of the test frame show "n/a"; a snapshot taken during a
  watch took over the watch's lines.

**Full Health Forever 0.0.2** (test build, not for CurseForge)

- The probe asks more: addon restrictions and the game's own secrecy answers, the heal
  prediction calculator with an overflow below 100 % (can the game tell "health plus incoming
  heals below X %"?), alpha from a secret yes/no, threat, the built-in damage meter and death
  recap, own defensive cooldowns in combat, potions, healthstones, bandages and other
  consumables in the bags, Recently Bandaged / Forbearance / Weakened Soul.
- The test frame shows four squares: health below 50 %, health plus heals at or below 50 % and
  80 %, own defensive ready.

**Full Health Forever 0.0.1** (test build, not for CurseForge)

- `/fhf probe`, `/fhf probe watch [seconds]`, `/fhf probe stop`: find out what WoW Forever lets
  an addon know about health (secret values, incoming heals, absorbs, events). The results
  decide what the addon can do. The probe is removed again before 0.1.
