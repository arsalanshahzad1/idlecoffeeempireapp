class BoostState {
  const BoostState({
    required this.boostId,
    required this.expiresAtUtcMillis,
  });

  final String boostId;
  final int expiresAtUtcMillis;

  bool isActiveAt(DateTime nowUtc) => expiresAtUtcMillis > nowUtc.millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'boostId': boostId,
      'expiresAtUtcMillis': expiresAtUtcMillis,
    };
  }

  factory BoostState.fromMap(Map<dynamic, dynamic> map) {
    return BoostState(
      boostId: map['boostId'] as String? ?? '',
      expiresAtUtcMillis: (map['expiresAtUtcMillis'] as num?)?.toInt() ?? 0,
    );
  }
}
