class LimitedEventState {
  const LimitedEventState({required this.activeEventIds});

  final Set<String> activeEventIds;

  static const LimitedEventState initial = LimitedEventState(activeEventIds: <String>{});

  LimitedEventState copyWith({Set<String>? activeEventIds}) {
    return LimitedEventState(activeEventIds: activeEventIds ?? this.activeEventIds);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'activeEventIds': activeEventIds.toList(growable: false),
    };
  }

  factory LimitedEventState.fromMap(Map<dynamic, dynamic> map) {
    final ids = <String>{};
    final raw = map['activeEventIds'];
    if (raw is List) {
      for (final value in raw) {
        if (value is String) {
          ids.add(value);
        }
      }
    }
    return LimitedEventState(activeEventIds: ids);
  }
}
