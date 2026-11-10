**Don't die in World of Warcraft: Forever (WoW Forever, Classic+).** Your healthstone, healing potion, bandage or defensive spell lights up **only in real danger**: when your health is low **and the heals in flight will not fix it**. From the maker of [Full Mana Forever](https://www.curseforge.com/wow/addons/full-mana-forever).

![Full Mana Forever and Full Health Forever](https://raw.githubusercontent.com/KesaObscura/FullHealthForever/main/docs/images/full-forever-family.png)

*Features asked for in the comments get built. Tell us what you need: comment here or open an issue on [GitHub](https://github.com/KesaObscura/FullHealthForever/issues).*

## What it does

- **Danger, not "it fits".** A tank at 60 % with a healer casting is fine; a mage at 20 % with nobody healing is not. Each icon lights up when your health is below the line **and** the heals being cast on you will not lift it above. Fewer hints, but right ones.
- **The line follows the fight:** 35 % while a mob is on you, 25 % while none is, 30 % for tanks. All three adjustable.
- **Health bar with incoming heals and shields,** drawn right after your health.
- **Shadow: your health a moment ago.** A dark red bar under your health shows where it was 2 seconds ago: the bigger the gap, the faster you are losing health. Forever hides damage numbers from addons; this is the honest view of them.
- **Your role decides the order.** Tanks: own defensives first (Shield Wall, Last Stand, Lay on Hands, Frenzied Regeneration ...); paladin tanks never get Divine Shield or Divine Protection, they drop the aggro. Healers: healthstone first, potion last (it shares the cooldown with your mana potion). The role comes from your group, or you pick it.
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

- Priest, level 21: solo, in a group and in a 5-player dungeon (test builds 0.0.2 to 0.0.4).
- Not tested yet: other classes, raids, battlegrounds. Tell us how it works for you.

Found a bug? [GitHub issues](https://github.com/KesaObscura/FullHealthForever/issues) or a comment here.

---

- Deutsch: Gesundheitsleiste mit eingehenden Heilungen und Schilden. Gesundheitsstein, Heiltrank, Verband oder Verteidigungszauber leuchten nur bei echter Gefahr.
- Русский: Полоса здоровья с летящим хилом и щитами. Камень здоровья, лечебное зелье, бинт или защитное умение загораются только при настоящей опасности.
- Español: Barra de salud con curaciones entrantes y escudos. Tu piedra de salud, poción de sanación, venda o hechizo defensivo se ilumina solo con peligro real.
- Français : barre de santé avec soins entrants et boucliers. Ta pierre de soins, potion de soins, bandage ou sort défensif s'allume seulement en vrai danger.
- Português: barra de vida com curas a caminho e escudos. Sua pedra de vida, poção de cura, atadura ou feitiço defensivo acende só em perigo real.
- 한국어: 들어오는 치유와 보호막이 보이는 생명력 바. 생명석, 치유 물약, 붕대, 방어 주문은 진짜 위험할 때만 켜집니다.
- 简体中文：显示即将到来的治疗和护盾的生命条。治疗石、治疗药水、绷带或防御技能只在真正危险时亮起。
- 繁體中文：顯示即將到來的治療和護盾的生命條。治療石、治療藥水、繃帶或防禦技能只在真正危險時亮起。
