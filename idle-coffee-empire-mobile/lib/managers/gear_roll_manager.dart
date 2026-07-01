import 'dart:math';

import '../data/gear_rarity_config.dart';
import '../models/gear_item.dart';

// Name fragments used to build item names per slot and rarity.
const _hatFragments = <GearRarity, List<String>>{
  GearRarity.common:    ['Simple Cap', 'Work Beanie', 'Cotton Toque'],
  GearRarity.rare:      ['Artisan Cap', 'Brewer\'s Beret', 'Barista Crown'],
  GearRarity.epic:      ['Master\'s Toque', 'Grand Barista Hat', 'Roastery Helm'],
  GearRarity.legendary: ['Crown of Brewing', 'Legendary Toque', 'Mythic Barista Crown'],
};

const _shirtFragments = <GearRarity, List<String>>{
  GearRarity.common:    ['Simple Apron', 'Work Shirt', 'Canvas Coat'],
  GearRarity.rare:      ['Artisan Apron', 'Brewer\'s Coat', 'Fine Café Shirt'],
  GearRarity.epic:      ['Master\'s Coat', 'Grand Chef Jacket', 'Roastery Vest'],
  GearRarity.legendary: ['Mantle of Espresso', 'Legendary Chef Coat', 'Mythic Barista Jacket'],
};

const _pantsFragments = <GearRarity, List<String>>{
  GearRarity.common:    ['Simple Slacks', 'Work Joggers', 'Cotton Chinos'],
  GearRarity.rare:      ['Artisan Slacks', 'Brewer\'s Chinos', 'Fine Café Pants'],
  GearRarity.epic:      ['Master\'s Trousers', 'Grand Kitchen Pants', 'Roastery Joggers'],
  GearRarity.legendary: ['Trousers of the Brew', 'Legendary Chef Pants', 'Mythic Kitchen Slacks'],
};

const _shoesFragments = <GearRarity, List<String>>{
  GearRarity.common:    ['Simple Clogs', 'Work Sneakers', 'Cotton Loafers'],
  GearRarity.rare:      ['Swift Treads', 'Brewer\'s Boots', 'Fine Café Loafers'],
  GearRarity.epic:      ['Master\'s Boots', 'Grand Kitchen Clogs', 'Roastery Sneakers'],
  GearRarity.legendary: ['Boots of the Barista', 'Legendary Swift Treads', 'Mythic Kitchen Boots'],
};

const _slotNameFragments = <GearSlot, Map<GearRarity, List<String>>>{
  GearSlot.hat:   _hatFragments,
  GearSlot.shirt: _shirtFragments,
  GearSlot.pants: _pantsFragments,
  GearSlot.shoes: _shoesFragments,
};

double _lerp(double min, double max, double t) => min + (max - min) * t;

GearItem rollRandomGearItem({
  required GearSlot slot,
  required GearRarity rarity,
  required Random random,
}) {
  final range = gearRarityRanges[rarity]!;
  final speedBonus = _lerp(range.speedMin, range.speedMax, random.nextDouble());
  final tipBonus = _lerp(range.tipMin, range.tipMax, random.nextDouble());

  final fragments = _slotNameFragments[slot]![rarity]!;
  final name = fragments[random.nextInt(fragments.length)];

  final id = '${slot.name}_${rarity.name}_${DateTime.now().microsecondsSinceEpoch}';

  return GearItem(
    id: id,
    name: name,
    slot: slot,
    speedBonus: speedBonus,
    tipBonus: tipBonus,
    rarity: rarity,
  );
}
