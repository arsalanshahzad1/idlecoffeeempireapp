class StationState {
  const StationState({
    required this.stationId,
    required this.level,
    required this.isUnlocked,
    required this.autoEnabled,
    this.autoProgressSeconds = 0,
    this.isProducing = false,
    this.productionProgress = 0,
    this.blockedReason,
  });

  final String stationId;
  final int level;
  final bool isUnlocked;
  final bool autoEnabled;
  final double autoProgressSeconds;
  final bool isProducing;
  final double productionProgress;
  final String? blockedReason;

  StationState copyWith({
    int? level,
    bool? isUnlocked,
    bool? autoEnabled,
    double? autoProgressSeconds,
    bool? isProducing,
    double? productionProgress,
    String? blockedReason,
    bool clearBlockedReason = false,
  }) {
    return StationState(
      stationId: stationId,
      level: level ?? this.level,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      autoEnabled: autoEnabled ?? this.autoEnabled,
      autoProgressSeconds: autoProgressSeconds ?? this.autoProgressSeconds,
      isProducing: isProducing ?? this.isProducing,
      productionProgress: productionProgress ?? this.productionProgress,
      blockedReason: clearBlockedReason ? null : (blockedReason ?? this.blockedReason),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stationId': stationId,
      'level': level,
      'isUnlocked': isUnlocked,
      'autoEnabled': autoEnabled,
      'autoProgressSeconds': autoProgressSeconds,
      'isProducing': isProducing,
      'productionProgress': productionProgress,
      'blockedReason': blockedReason,
    };
  }

  factory StationState.fromMap(Map<dynamic, dynamic> map) {
    return StationState(
      stationId: map['stationId'] as String,
      level: (map['level'] as num?)?.toInt() ?? 1,
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      autoEnabled: map['autoEnabled'] as bool? ?? false,
      autoProgressSeconds: (map['autoProgressSeconds'] as num?)?.toDouble() ?? 0,
      isProducing: map['isProducing'] as bool? ?? false,
      productionProgress: (map['productionProgress'] as num?)?.toDouble() ?? 0,
      blockedReason: map['blockedReason'] as String?,
    );
  }
}
