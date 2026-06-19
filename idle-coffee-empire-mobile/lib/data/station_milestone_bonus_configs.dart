import '../models/station_milestone_bonus.dart';

const Map<String, List<StationMilestoneBonus>> stationMilestoneBonusConfigs =
    <String, List<StationMilestoneBonus>>{
      'espresso_machine': <StationMilestoneBonus>[
        StationMilestoneBonus(level: 5, profitMultiplier: 1.10),
        StationMilestoneBonus(level: 10, productionSpeedMultiplier: 1.10),
        StationMilestoneBonus(
          level: 25,
          profitMultiplier: 1.20,
          productionSpeedMultiplier: 1.12,
        ),
      ],
      'coffee_grinder': <StationMilestoneBonus>[
        StationMilestoneBonus(level: 5, profitMultiplier: 1.08),
        StationMilestoneBonus(level: 10, productionSpeedMultiplier: 1.10),
        StationMilestoneBonus(level: 25, profitMultiplier: 1.18),
      ],
      'cashier_counter': <StationMilestoneBonus>[
        StationMilestoneBonus(level: 5, profitMultiplier: 1.10),
        StationMilestoneBonus(level: 10, productionSpeedMultiplier: 1.10),
        StationMilestoneBonus(level: 25, profitMultiplier: 1.22),
      ],
    };
