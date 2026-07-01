import '../data/chef_gear_catalog.dart';
import '../models/chef_state.dart';
import '../models/gear_item.dart';

class ChefStats {
  const ChefStats({
    required this.speedMultiplier,
    required this.tipMultiplier,
  });

  final double speedMultiplier;
  final double tipMultiplier;

  static const ChefStats base = ChefStats(speedMultiplier: 1.0, tipMultiplier: 1.0);
}

/// Resolves a gear ID to a GearItem by checking the static catalog first,
/// then falling back to the player's owned (rolled) gear list.
GearItem? resolveGearItem(String id, List<GearItem> ownedGear) {
  final catalogItem = chefGearById[id];
  if (catalogItem != null) return catalogItem;
  for (final item in ownedGear) {
    if (item.id == id) return item;
  }
  return null;
}

class ChefStatManager {
  const ChefStatManager();

  ChefStats computeStats(ChefState chef, {List<GearItem> ownedGear = const []}) {
    var totalSpeedBonus = 0.0;
    var totalTipBonus = 0.0;

    final slotIds = <String?>[
      chef.equippedGear.hatId,
      chef.equippedGear.shirtId,
      chef.equippedGear.pantsId,
      chef.equippedGear.shoesId,
    ];

    for (final id in slotIds) {
      if (id == null) continue;
      final item = resolveGearItem(id, ownedGear);
      if (item == null) continue;
      totalSpeedBonus += item.speedBonus;
      totalTipBonus += item.tipBonus;
    }

    return ChefStats(
      speedMultiplier: 1.0 + totalSpeedBonus,
      tipMultiplier: 1.0 + totalTipBonus,
    );
  }
}
