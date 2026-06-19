class AdPlacementConfig {
  const AdPlacementConfig({
    required this.id,
    required this.cooldownSeconds,
    required this.frequencyCapPerSession,
    this.enabled = true,
  });

  final String id;
  final int cooldownSeconds;
  final int frequencyCapPerSession;
  final bool enabled;
}

const List<AdPlacementConfig> adPlacementConfigs = <AdPlacementConfig>[
  AdPlacementConfig(id: 'reward_offline_double', cooldownSeconds: 30, frequencyCapPerSession: 20),
  AdPlacementConfig(id: 'reward_gems', cooldownSeconds: 45, frequencyCapPerSession: 20),
  AdPlacementConfig(id: 'reward_speed_boost', cooldownSeconds: 45, frequencyCapPerSession: 20),
  AdPlacementConfig(id: 'reward_skip_timer', cooldownSeconds: 20, frequencyCapPerSession: 30),
  AdPlacementConfig(id: 'interstitial_progression', cooldownSeconds: 300, frequencyCapPerSession: 5),
];
