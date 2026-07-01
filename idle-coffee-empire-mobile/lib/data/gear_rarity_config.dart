import '../models/gear_item.dart';

class GearRarityRange {
  const GearRarityRange({
    required this.speedMin,
    required this.speedMax,
    required this.tipMin,
    required this.tipMax,
  });

  final double speedMin;
  final double speedMax;
  final double tipMin;
  final double tipMax;
}

const Map<GearRarity, GearRarityRange> gearRarityRanges = {
  GearRarity.common:    GearRarityRange(speedMin: 0.02, speedMax: 0.05, tipMin: 0.02, tipMax: 0.05),
  GearRarity.rare:      GearRarityRange(speedMin: 0.05, speedMax: 0.10, tipMin: 0.05, tipMax: 0.10),
  GearRarity.epic:      GearRarityRange(speedMin: 0.10, speedMax: 0.18, tipMin: 0.10, tipMax: 0.18),
  GearRarity.legendary: GearRarityRange(speedMin: 0.18, speedMax: 0.30, tipMin: 0.18, tipMax: 0.30),
};
