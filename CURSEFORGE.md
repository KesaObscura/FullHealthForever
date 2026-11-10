# Full Health Forever

**Don't die in World of Warcraft: Forever (WoW Forever, Classic+).** Your healthstone, healing potion, bandage or defensive spell lights up **only in real danger**: when your health is low **and the heals in flight will not fix it**. From the maker of [Full Mana Forever](https://www.curseforge.com/wow/addons/full-mana-forever).

![Full Mana Forever and Full Health Forever](https://raw.githubusercontent.com/KesaObscura/FullHealthForever/main/docs/images/full-forever-family.png)

*Features asked for in the comments get built. Tell us what you need: comment here or open an issue on [GitHub](https://github.com/KesaObscura/FullHealthForever/issues).*

## What it does

- **Danger, not "it fits".** A tank at 60 % with a healer casting is fine; a mage at 20 % with nobody healing is not. Each icon lights up when your health is below the line **and** the heals being cast on you will not lift it above. Fewer hints, but right ones.
- **The line follows the fight:** 35 % while a mob is on you, 25 % while none is, 30 % for tanks. All three adjustable.
- **Health bar with incoming heals and shields,** drawn right after your health.
- **Shadow: your health a moment ago.** A dark red bar under your health shows where it was 2 seconds ago: the bigger the gap, the faster you are losing health. Forever hides damage numbers from addons; this is the honest view of them.
- **Your role decides the order.** Tanks: own defensives first (Shield Wall, Last Stand, Lay on Hands, Frenzied Regeneration ...); paladin tanks never get Divine Shield or Divine Protection, they drop the aggro. Healers: healthstone first, potion last (it may share the cooldown with your mana potion). The role comes from your group, or you pick it.
- **Aggro warning.** In a group an icon shows when a mob is on you; tanks see when their target is not on them.
- **Bandages** light up only while no mob is on you (damage stops a bandage) and not within 60 s of the last one.
- **Hold:** `/fhf hold` (best in a macro) keeps every icon dark until the end of the next fight, for when you want to save a cooldown.
- Shown only in combat by default, solo / party / raid switches, ready icons dimmed or hidden, shared or own profile per character, **9 languages** (English, Deutsch, Русский, Español, Français, Português, 한국어, 简体中文, 繁體中文).

## How it works with Forever's addon rules

In WoW Forever your current health is a secret value, in and out of combat: addons cannot read or compare it. Full Health Forever never tries to. It hands the game a curve and the game's own heal prediction, and the game itself decides whether an icon lights up. Nothing that the game hides is guessed.

## Commands

- `/fhf` help, `/fhf config` settings (also in Esc > Options > AddOns)
- `/fhf unlock` / `/fhf lock` move the frame (it locks itself when a fight starts)
- `/fhf hold` no lit icons until the end of the next fight
- `/fhf reset` frame back to its place, `/fhf profile own | shared`, `/fhf status` (for bug reports)

## Tested so far

Tested in game with a priest (level 21): solo, in a group and in a dungeon (test builds 0.0.2 to 0.0.4). Other classes, raids and battlegrounds: tell us how it works for you.

Found a bug? [GitHub issues](https://github.com/KesaObscura/FullHealthForever/issues) or a comment here.
