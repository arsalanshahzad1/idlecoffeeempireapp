class DailyRewardState {
  const DailyRewardState({
    required this.currentDayIndex,
    required this.lastClaimDate,
    required this.lastEvaluatedDate,
  });

  final int currentDayIndex;
  final String lastClaimDate;
  final String lastEvaluatedDate;

  static const DailyRewardState initial = DailyRewardState(
    currentDayIndex: 0,
    lastClaimDate: '',
    lastEvaluatedDate: '',
  );

  DailyRewardState copyWith({
    int? currentDayIndex,
    String? lastClaimDate,
    String? lastEvaluatedDate,
  }) {
    return DailyRewardState(
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      lastEvaluatedDate: lastEvaluatedDate ?? this.lastEvaluatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentDayIndex': currentDayIndex,
      'lastClaimDate': lastClaimDate,
      'lastEvaluatedDate': lastEvaluatedDate,
    };
  }

  factory DailyRewardState.fromMap(Map<dynamic, dynamic> map) {
    return DailyRewardState(
      currentDayIndex: (map['currentDayIndex'] as num?)?.toInt() ?? 0,
      lastClaimDate: map['lastClaimDate'] as String? ?? '',
      lastEvaluatedDate: map['lastEvaluatedDate'] as String? ?? '',
    );
  }
}
