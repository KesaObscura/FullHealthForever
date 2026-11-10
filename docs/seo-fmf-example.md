> Example from Full Mana Forever (owner, 10 Nov 2026): its SEO plan from three expert reviews. Kept as a model; the rules for this addon are in `docs/store.md`.

# SEO: сводный план (3 эксперта: CurseForge, GitHub, ключевые слова)

Страницу CurseForge агенты открыть не смогли (сеть сессии), работали по нашим файлам, поиску и API GitHub.
Поиск «curseforge WoW Forever mana addon» → мы **первые**. Конкуренты за слова: DruidForeverManaBar,
Forever_DruidManaBar, Time To Drink, What Should I Drink, Healer Mana Watch, ManaMaster, EnergyWatch Forever.
Никто не делает «правильное зелье под недостающую ману» — это наша главная фраза, она остаётся первой.

**Главная дыра:** новый таймер «time to full mana» (0.9.7) поиск почти не видит — его нет в summary, About, начале описаний.

---

## A. Делаешь ты руками (10 минут)

### 1. Краткое описание CurseForge (summary) — мой выбор, 254 символа
```
Never waste a mana potion in WoW Forever: the right potion, rune, mana gem or mana spell (Evocation, Innervate, Mana Tide) lights up when it fits your missing mana. Mana bar with five-second rule (5SR), live regen, time to full mana. For every mana user.
```
Крючок «Never waste a mana potion» остаётся, «WoW Forever» ближе к началу, добавлены «5SR» и «time to full mana».
Вставлять **после выхода 0.9.7** (иначе обещаем таймер, которого ещё нет).
Вариант с «Healer and caster…» не беру: нарушает твоё правило «не только хилеры» (без охотников).

### 2. CurseForge → General: поля **Source** и **Issues** → ссылки на GitHub
(`https://github.com/KesaObscura/FullManaForever` и `/issues`). Проверь, заполнены ли. Это самая сильная ссылка на репозиторий без постов.

### 3. GitHub → About (294 символа, после 0.9.7)
```
Mana addon for World of Warcraft: Forever (WoW Forever, Classic+): the right mana potion, rune, mana gem or own mana spell (Evocation, Innervate, Mana Tide) lights up when it is ready and fits your missing mana. Mana bar with the five-second rule, live regen and time to full mana. 9 languages.
```
Сейчас начинается с «for healers» и в Google обрезается до «mana potion».

### 4. GitHub → Topics: добавить 4 (будет 20/20)
`wow-forever-addon`, `warcraft`, `hud`, `healing` — старые все оставить.
**Не** добавлять `wow-classic` и похожие (читалось бы как поддержка Classic Era).

### 5. GitHub → Settings → выключить пустой **Wiki** (мелочь)

---

## B. Делаю я в репозитории (тексты, на код не влияет) — нужен твой «да»
1. **CURSEFORGE.md**:
   - убрать заголовок `# Full Mana Forever` сверху (CurseForge сам показывает название, он сдвигает первую картинку вниз);
   - «time to full mana» — в первый абзац;
   - подзаголовок **«Know when to drink»** (игроки ищут «drink»);
   - «WoW Forever» в двух заголовках, «mana regen» вместо голого «regen» в заголовках;
   - картинка своих заклинаний (есть в README, нет на CurseForge);
   - **«Tested so far»** переписать коротким списком: сейчас там «could not be tested in the beta yet» — устарело;
   - FAQ: «Работает с рамками юнитов?» и «Сколько пить?» (таймер);
   - в конце — 9 строк описания на всех языках из `.toc` (Google найдёт «зелье маны», «Manatrank»…).
2. **README.md**: строка **Download** сразу под значками (CurseForge + последний релиз), «time to full mana» в первый абзац, ключевые слова в заголовках.
3. **Релизы**: «CurseForge app» в строке установки — ссылкой (шаблон в CLAUDE.md и docs/notes.md).
4. **docs/notes.md**: новые summary, About, topics — как только ты их поставишь.

## C. Позже (нужны твои скрины)
- Галерея: две новые картинки — «Works with your unit frames» и «Time to full mana» (подписи агенты уже написали).
- Картинка для соцсетей (social preview) с «World of Warcraft: Forever».
- Скрины в README после пересъёмки 06.

## Не берём (и почему)
- Переименовать проект («… – Mana Potion & 5SR Bar»): ломает бренд серии, выигрыш не доказан.
- Поменять категорию «Bags & Inventory» на «Unit Frames»: эффект неизвестен, оба агента «не уверены».
- Посты на форумах / Reddit: твоё решение — нет.
- Строка про друида «полоса маны в облике кошки» — только после проверки в игре.

---

## Для Full Health Forever и Time to Die (передай разработчикам)
1. **Развести слова, чтобы не отбирать поиск друг у друга:** мана / 5SR / regen — только FMF; health / healing potion / healthstone / defensive — FHF; «time to die» / TTD / kill time — третий. FMF говорит только «time to full mana».
2. **Названия в одном ряду:** Full Mana Forever, Full Health Forever, **Time to Die Forever** (если имя свободно на CurseForge — проверить первым делом).
3. **Summary каждого начинается со своего главного слова** и с «WoW Forever»; до 256 символов.
4. **Главные категории разные:** HUDs для первых двух, Combat для Time to Die — меньше конкуренции между собой.
5. **Логотипы одной серии:** та же колба / стиль — синяя, красная, третий предмет своего цвета.
6. **Ссылки друг на друга — только когда страница уже есть** (блок «More Forever addons» в конце описаний, README, About). Не через «зависимости» CurseForge.
7. **Честные обещания:** здоровье в Forever секретно — в описании только то, что уже работает в игре; «не проверено» так и писать.
8. **Одинаковое оформление:** README, релизы (`Название X.Y.Z – WoW Forever … addon`), картинка для соцсетей, общий подвал галереи.

Полные отчёты: `seo-A.md` (CurseForge), `seo-B.md` (GitHub), `seo-C.md` (слова и бренд) — в той же папке.
