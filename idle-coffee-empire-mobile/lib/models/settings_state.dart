class SettingsState {
  const SettingsState({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.floatingTextEnabled,
    required this.debugEnabled,
    required this.autosaveIntervalSeconds,
  });

  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool floatingTextEnabled;
  final bool debugEnabled;
  final int autosaveIntervalSeconds;

  static const SettingsState defaults = SettingsState(
    soundEnabled: true,
    musicEnabled: false,
    hapticsEnabled: true,
    floatingTextEnabled: true,
    debugEnabled: false,
    autosaveIntervalSeconds: 15,
  );

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? floatingTextEnabled,
    bool? debugEnabled,
    int? autosaveIntervalSeconds,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      floatingTextEnabled: floatingTextEnabled ?? this.floatingTextEnabled,
      debugEnabled: debugEnabled ?? this.debugEnabled,
      autosaveIntervalSeconds: autosaveIntervalSeconds ?? this.autosaveIntervalSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'hapticsEnabled': hapticsEnabled,
      'floatingTextEnabled': floatingTextEnabled,
      'debugEnabled': debugEnabled,
      'autosaveIntervalSeconds': autosaveIntervalSeconds,
    };
  }

  factory SettingsState.fromMap(Map<dynamic, dynamic> map) {
    return SettingsState(
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      musicEnabled: map['musicEnabled'] as bool? ?? false,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      floatingTextEnabled: map['floatingTextEnabled'] as bool? ?? true,
      debugEnabled: map['debugEnabled'] as bool? ?? false,
      autosaveIntervalSeconds: (map['autosaveIntervalSeconds'] as num?)?.toInt() ?? 15,
    );
  }
}
