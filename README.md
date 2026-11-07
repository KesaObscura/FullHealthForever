# Full Health Forever

Addon for **WoW Forever** (World of Warcraft: Forever, client 1.60.1, Interface 16001).
Companion to [Full Mana Forever](https://github.com/KesaObscura/FullManaForever).

Goal: a health bar with incoming heals and absorbs, and a hint when to use a health potion,
healthstone, bandage or defensive cooldown - only when you are in danger, not whenever it
would fit.

**Status: test build 0.0.3.** It only contains a probe that finds out what the game lets an
addon read about health. No health bar yet.

## Commands

| Command | What it does |
| --- | --- |
| `/fhf` | Help |
| `/fhf probe` | Snapshot to chat: which API exists, what is secret |
| `/fhf probe watch [seconds]` | Events per second in chat and a test frame on screen (30 s, 10-300) |
| `/fhf probe stop` | Ends the watch early |

Results are also saved: `/reload`, then the file is
`WTF\Account\<account>\SavedVariables\FullHealthForever.lua`.

## Install

Unzip into `_forever_\Interface\AddOns` so that the folder is `FullHealthForever`.

## Tests

`lua5.1 tests/run.lua` (headless, with a WoW API mock; health is secret there).

## License

MIT
