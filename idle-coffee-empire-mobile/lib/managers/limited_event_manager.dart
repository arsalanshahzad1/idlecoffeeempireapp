import '../data/limited_event_configs.dart';
import '../models/limited_event_state.dart';

class LimitedEventManager {
  const LimitedEventManager();

  List<LimitedEventConfig> get all => limitedEventConfigs;

  List<LimitedEventConfig> active(LimitedEventState state) {
    return limitedEventConfigs.where((e) => state.activeEventIds.contains(e.id)).toList(growable: false);
  }

  LimitedEventState toggle(LimitedEventState state, String eventId, bool active) {
    final ids = Set<String>.from(state.activeEventIds);
    if (active) {
      ids.add(eventId);
    } else {
      ids.remove(eventId);
    }
    return state.copyWith(activeEventIds: ids);
  }

  double combinedEspressoProfit(LimitedEventState state) => _product(state, (e) => e.espressoProfitMultiplier);
  double combinedCustomerSpawnRate(LimitedEventState state) => _product(state, (e) => e.customerSpawnRateMultiplier);
  double combinedCustomerReward(LimitedEventState state) => _product(state, (e) => e.customerRewardMultiplier);
  double combinedVipChance(LimitedEventState state) => _product(state, (e) => e.vipChanceMultiplier);
  double combinedVipReward(LimitedEventState state) => _product(state, (e) => e.vipRewardMultiplier);
  double combinedDecorationCost(LimitedEventState state) => _product(state, (e) => e.decorationCostMultiplier);

  double _product(LimitedEventState state, double Function(LimitedEventConfig cfg) pick) {
    var value = 1.0;
    for (final config in active(state)) {
      value *= pick(config);
    }
    return value;
  }
}
