# Full Health Forever – health bar, incoming heals and danger warning addon for WoW Forever

<img src="docs/images/icon.png" alt="Full Health Forever: red flask with an infinity sign" width="96" align="right">

An addon for **World of Warcraft: Forever** (WoW Forever, "Classic+", client 1.60.1) for every
class: tanks, healers, damage dealers and solo players levelling 1-60. Sister of
[Full Mana Forever](https://github.com/KesaObscura/FullManaForever).

**The plan:** a health bar with **incoming heals** and **shields (absorbs)**, and your
**healthstone, health potion, bandage or defensive cooldown lights up only when you are in real
danger**: your health is low **and the heals in flight will not fix it**, or a mob is on you. A
tank at 60 % with a healer casting is not in danger; a mage at 30 % with nobody healing is. Fewer
hints, but right ones.

**Status: test build 0.0.4.** It only contains a probe that finds out what the game lets an addon
read about health. No health bar yet. The first finding: the game itself can tell "low health and
the heals in flight won't lift it" (tested in game, see `docs/notes.md`).

![Full Mana Forever and Full Health Forever: a blue and a red flask](docs/images/full-forever-family.png)

## How it works with Forever's addon rules

In Forever your current health is a *secret value*, in and out of combat: addons cannot read or
compare it. Full Health Forever never tries to. It gives the game a step curve
(`UnitHealthPercent`) and the game's own heal prediction calculator, and the game returns an
alpha for the icon: "health below the line **and** the heals being cast will not lift it above".
Nothing is calculated in Lua. Details for addon authors: `docs/forever-addon-api.md`.

## Commands (test build)

| Command | What it does |
| --- | --- |
| `/fhf` | Help |
| `/fhf probe` | Snapshot to chat: which API exists, what is secret |
| `/fhf probe watch [seconds]` | Events in chat and a test frame on screen (30 s, 10-300) |
| `/fhf probe stop` | Ends the watch early |

Results are also saved: `/reload`, then the file is
`WTF\Account\<account>\SavedVariables\FullHealthForever.lua`.

## Install

Unzip into `_forever_\Interface\AddOns` so that the folder is `FullHealthForever`.

## Languages

English, Deutsch, Русский, Español, Français, Português (Brasil), 한국어, 简体中文, 繁體中文.

## Tests

`lua5.1 tests/run.lua` (headless, with a WoW API mock; health is secret there).

## License

MIT
