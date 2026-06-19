class LoginStreakState {
  const LoginStreakState({
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.lastActiveDate,
    required this.claimedMilestones,
  });

  final int currentStreakDays;
  final int bestStreakDays;
  final String lastActiveDate;
  final Set<int> claimedMilestones;

  static const LoginStreakState initial = LoginStreakState(
    currentStreakDays: 0,
    bestStreakDays: 0,
    lastActiveDate: '',
    claimedMilestones: <int>{},
  );

  LoginStreakState copyWith({
    int? currentStreakDays,
    int? bestStreakDays,
    String? lastActiveDate,
    Set<int>? claimedMilestones,
  }) {
    return LoginStreakState(
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      claimedMilestones: claimedMilestones ?? this.claimedMilestones,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentStreakDays': currentStreakDays,
      'bestStreakDays': bestStreakDays,
      'lastActiveDate': lastActiveDate,
      'claimedMilestones': claimedMilestones.toList(growable: false),
    };
  }

  factory LoginStreakState.fromMap(Map<dynamic, dynamic> map) {
    final claimed = <int>{};
    final raw = map['claimedMilestones'];
    if (raw is List) {
      for (final value in raw) {
        if (value is num) {
          claimed.add(value.toInt());
        }
      }
    }
    return LoginStreakState(
      currentStreakDays: (map['currentStreakDays'] as num?)?.toInt() ?? 0,
      bestStreakDays: (map['bestStreakDays'] as num?)?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] as String? ?? '',
      claimedMilestones: claimed,
    );
  }
}
