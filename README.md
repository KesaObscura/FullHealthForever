# Full Health Forever – health bar, incoming heals and danger warning addon for WoW Forever

<img src="docs/images/icon.png" alt="Full Health Forever: red flask with an infinity sign" width="96" align="right">

An addon for **World of Warcraft: Forever** (WoW Forever, "Classic+", client 1.60.1) for every
class: tanks, healers, damage dealers and solo players levelling 1-60. Sister of
[Full Mana Forever](https://github.com/KesaObscura/FullManaForever).

Your **healthstone, healing potion, bandage or defensive spell lights up only in real danger**:
your health is low **and the heals in flight will not fix it**. A tank at 60 % with a healer
casting is not in danger; a mage at 20 % with nobody healing is. Fewer hints, but right ones.

![Full Mana Forever and Full Health Forever: a blue and a red flask](docs/images/full-forever-family.png)

## What it does

- **Health bar with incoming heals and shields.** The heals being cast on you and your shields
  are drawn right after your health.
- **Shadow: your health a moment ago.** A dark red bar under your health shows where it was
  2 seconds ago (adjustable): the bigger the gap, the faster you are losing health.
- **Danger, not "it fits".** Each icon lights up when your health is below the line **and** the
  heals in flight will not lift it above. The line is **35 %** while a mob is on you, **25 %**
  while none is, **30 %** for tanks (all adjustable).
- **Your role decides the order.** Tanks: own defensives first (Shield Wall, Last Stand, Lay on
  Hands ...), and paladin tanks never get Divine Shield or Divine Protection (they drop the
  aggro). Healers: healthstone first, potion last. The role comes from your group, or you set
  it.
- **Aggro warning.** In a group an icon shows when a mob is on you; tanks see when their target
  is not on them.
- **Bandage** only while no mob is on you (damage stops it) and not within 60 s of the last one.
- **`/fhf hold`** (handy in a macro): no lit icons until the end of the next fight.
- Shown only in combat by default; solo / party / raid switches; ready icons can show dimmed;
  shared or own profile per character; 9 languages.

## How it works with Forever's addon rules

In Forever your current health is a *secret value*, in and out of combat: addons cannot read or
compare it. Full Health Forever never tries to. It hands the game a step curve
(`UnitHealthPercent`) and the game's own heal prediction calculator, and the game returns an
alpha for the icons: "health below the line **and** the heals being cast will not lift it
above". Nothing is calculated in Lua. Details for addon authors: `docs/forever-addon-api.md`.

## Commands

| Command | What it does |
| --- | --- |
| `/fhf` | Help |
| `/fhf config` | Settings (also in Esc > Options > AddOns) |
| `/fhf unlock`, `/fhf lock` | Move the frame, then lock it (it locks itself when a fight starts) |
| `/fhf hold` | No lit icons until the end of the next fight |
| `/fhf reset` | Frame back to its default place |
| `/fhf profile own` / `shared` | Own profile for this character, or the shared one |
| `/fhf status` | What the addon found (for bug reports) |

## Install

Unzip into `_forever_\Interface\AddOns` so that the folder is `FullHealthForever`.

## Languages

English, Deutsch, Русский, Español, Français, Português (Brasil), 한국어, 简体中文, 繁體中文.

## Tests

`lua5.1 tests/run.lua` (headless, with a WoW API mock; health is secret there). GitHub runs them
on every pull request.

## License

MIT
