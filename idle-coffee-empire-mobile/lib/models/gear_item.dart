enum GearSlot { hat, shirt, pants, shoes }

enum GearRarity { common, rare, epic, legendary }

class GearItem {
  const GearItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.speedBonus,
    required this.tipBonus,
    required this.rarity,
  });

  final String id;
  final String name;
  final GearSlot slot;
  final GearRarity rarity;

  // Additive fractions: 0.05 means +5% to the running total.
  final double speedBonus;
  final double tipBonus;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slot': slot.name,
        'speedBonus': speedBonus,
        'tipBonus': tipBonus,
        'rarity': rarity.name,
      };

  factory GearItem.fromMap(Map<dynamic, dynamic> map) {
    final slotName = map['slot'] as String? ?? 'hat';
    final rarityName = map['rarity'] as String? ?? 'common';
    return GearItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      slot: GearSlot.values.firstWhere(
        (s) => s.name == slotName,
        orElse: () => GearSlot.hat,
      ),
      speedBonus: (map['speedBonus'] as num?)?.toDouble() ?? 0,
      tipBonus: (map['tipBonus'] as num?)?.toDouble() ?? 0,
      rarity: GearRarity.values.firstWhere(
        (r) => r.name == rarityName,
        orElse: () => GearRarity.common,
      ),
    );
  }
}
