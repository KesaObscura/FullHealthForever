local _, ns = ...

-- Items and spells the addon knows. IDs are Classic IDs; every one is checked by the game at
-- runtime (an item the game does not know has no use spell, a spell not in the spell book is
-- skipped), so a wrong or changed ID only means "not shown". Checked in game (probe 0.0.2):
-- Lesser Healing Potion 858 (spell 440), Heavy Linen Bandage 2581 (spell 1159 "First Aid").
-- Not checked in game: everything else in this file.

-- strongest first: the strongest one in the bags is shown
ns.POTIONS = { 13446, 3928, 1710, 929, 858, 118 } -- Major .. Minor Healing Potion
ns.STONES = { -- healthstones, Major .. Minor, with the improved (talent) versions
  19013, 19012, 9421, 19011, 19010, 5510, 19009, 19008, 5509, 19007, 19006, 5511, 19005, 19004, 5512,
}
ns.BANDAGES = { 14530, 14529, 8545, 8544, 6451, 6450, 3531, 3530, 2581, 1251 } -- Heavy Runecloth .. Linen

ns.RECENTLY_BANDAGED = 11196 -- debuff after a bandage: no other bandage for 60 s
ns.BANDAGE_LOCK = 60

-- own defensive spells per class, rank 1 IDs; the spell book is searched by their names, the
-- highest rank found is used. Order = order of the icons.
ns.DEFENSIVES = {
  WARRIOR = { 871, 12975 },        -- Shield Wall, Last Stand
  PALADIN = { 633, 498, 642 },     -- Lay on Hands, Divine Protection, Divine Shield
  PRIEST  = { 13908 },             -- Desperate Prayer
  DRUID   = { 22812, 22842 },      -- Barkskin, Frenzied Regeneration
  ROGUE   = { 5277, 1856 },        -- Evasion, Vanish
  MAGE    = { 11958, 11426 },      -- Ice Block, Ice Barrier
  HUNTER  = { 5384, 19263 },       -- Feign Death, Deterrence
  WARLOCK = { 6789 },              -- Death Coil
  SHAMAN  = {},
}
ns.RACIAL_DEFENSIVES = { 20594 } -- Stoneform

-- a paladin who tanks must not be told to bubble: it drops the aggro (tank review)
ns.TANK_SKIP = { [498] = true, [642] = true }

-- cooldowns this short on items come from wand shots (weapon speed, FMF sixth log): ignored
ns.ITEM_GCD = 3
-- spell cooldowns this short are the global cooldown
ns.SPELL_GCD = 1.6
