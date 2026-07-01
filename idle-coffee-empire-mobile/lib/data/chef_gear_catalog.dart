import '../models/gear_item.dart';

const List<GearItem> chefHats = <GearItem>[
  GearItem(id: 'hat_toque',        name: 'Classic Toque',      slot: GearSlot.hat,   speedBonus: 0.03, tipBonus: 0.02, rarity: GearRarity.common),
  GearItem(id: 'hat_beanie',       name: 'Cozy Beanie',        slot: GearSlot.hat,   speedBonus: 0.02, tipBonus: 0.05, rarity: GearRarity.common),
  GearItem(id: 'hat_beret',        name: 'Parisian Beret',     slot: GearSlot.hat,   speedBonus: 0.04, tipBonus: 0.06, rarity: GearRarity.common),
  GearItem(id: 'hat_bandana',      name: 'Barista Bandana',    slot: GearSlot.hat,   speedBonus: 0.07, tipBonus: 0.03, rarity: GearRarity.common),
];

const List<GearItem> chefShirts = <GearItem>[
  GearItem(id: 'shirt_apron',      name: 'Canvas Apron',       slot: GearSlot.shirt, speedBonus: 0.04, tipBonus: 0.02, rarity: GearRarity.common),
  GearItem(id: 'shirt_chef_coat',  name: 'Chef Coat',          slot: GearSlot.shirt, speedBonus: 0.03, tipBonus: 0.05, rarity: GearRarity.common),
  GearItem(id: 'shirt_polo',       name: 'Café Polo',          slot: GearSlot.shirt, speedBonus: 0.06, tipBonus: 0.03, rarity: GearRarity.common),
  GearItem(id: 'shirt_vest',       name: 'Barista Vest',       slot: GearSlot.shirt, speedBonus: 0.02, tipBonus: 0.08, rarity: GearRarity.common),
];

const List<GearItem> chefPants = <GearItem>[
  GearItem(id: 'pants_checkered',  name: 'Checkered Slacks',   slot: GearSlot.pants, speedBonus: 0.05, tipBonus: 0.02, rarity: GearRarity.common),
  GearItem(id: 'pants_joggers',    name: 'Kitchen Joggers',    slot: GearSlot.pants, speedBonus: 0.08, tipBonus: 0.02, rarity: GearRarity.common),
  GearItem(id: 'pants_chinos',     name: 'Café Chinos',        slot: GearSlot.pants, speedBonus: 0.03, tipBonus: 0.06, rarity: GearRarity.common),
  GearItem(id: 'pants_denim',      name: 'Denim Apron-Pants',  slot: GearSlot.pants, speedBonus: 0.04, tipBonus: 0.04, rarity: GearRarity.common),
];

const List<GearItem> chefShoes = <GearItem>[
  GearItem(id: 'shoes_clogs',      name: 'Kitchen Clogs',      slot: GearSlot.shoes, speedBonus: 0.06, tipBonus: 0.02, rarity: GearRarity.common),
  GearItem(id: 'shoes_sneakers',   name: 'Non-Slip Sneakers',  slot: GearSlot.shoes, speedBonus: 0.09, tipBonus: 0.01, rarity: GearRarity.common),
  GearItem(id: 'shoes_loafers',    name: 'Café Loafers',       slot: GearSlot.shoes, speedBonus: 0.03, tipBonus: 0.07, rarity: GearRarity.common),
  GearItem(id: 'shoes_boots',      name: 'Barista Boots',      slot: GearSlot.shoes, speedBonus: 0.04, tipBonus: 0.05, rarity: GearRarity.common),
];

// Flat lookup map for O(1) access in ChefStatManager.
final Map<String, GearItem> chefGearById = {
  for (final item in [...chefHats, ...chefShirts, ...chefPants, ...chefShoes])
    item.id: item,
};
