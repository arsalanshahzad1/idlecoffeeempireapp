import 'permanent_upgrade_config.dart';

class PermanentUpgradeState {
  const PermanentUpgradeState({
    required this.config,
    required this.owned,
  });

  final PermanentUpgradeConfig config;
  final bool owned;
}
