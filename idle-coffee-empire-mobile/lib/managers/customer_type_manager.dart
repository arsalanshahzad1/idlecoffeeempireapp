import '../data/customer_type_configs.dart';
import '../models/customer_type_config.dart';

class CustomerTypeManager {
  const CustomerTypeManager();

  List<CustomerTypeConfig> get all => customerTypeConfigs;

  CustomerTypeConfig byId(String id) {
    for (final cfg in customerTypeConfigs) {
      if (cfg.id == id) {
        return cfg;
      }
    }
    return customerTypeConfigs.first;
  }

  String pickType(
    double seed, {
    bool Function(CustomerTypeConfig config)? eligibility,
  }) {
    final eligible = customerTypeConfigs
        .where((cfg) => eligibility == null || eligibility(cfg))
        .toList(growable: false);
    final source = eligible.isEmpty ? customerTypeConfigs : eligible;
    final totalWeight = source.fold<double>(
      0,
      (sum, cfg) => sum + cfg.spawnWeight,
    );
    final normalizedSeed = seed.clamp(0.0, 0.999999);
    var cursor = normalizedSeed * totalWeight;
    for (final cfg in source) {
      cursor -= cfg.spawnWeight;
      if (cursor <= 0) {
        return cfg.id;
      }
    }
    return source.first.id;
  }
}
