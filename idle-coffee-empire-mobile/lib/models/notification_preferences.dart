class NotificationPreferences {
  const NotificationPreferences({
    required this.offlineIncomeReminder,
    required this.dailyRewardReminder,
    required this.eventReminder,
    required this.prestigeAvailableReminder,
  });

  final bool offlineIncomeReminder;
  final bool dailyRewardReminder;
  final bool eventReminder;
  final bool prestigeAvailableReminder;

  static const NotificationPreferences defaults = NotificationPreferences(
    offlineIncomeReminder: true,
    dailyRewardReminder: true,
    eventReminder: true,
    prestigeAvailableReminder: true,
  );

  NotificationPreferences copyWith({
    bool? offlineIncomeReminder,
    bool? dailyRewardReminder,
    bool? eventReminder,
    bool? prestigeAvailableReminder,
  }) {
    return NotificationPreferences(
      offlineIncomeReminder: offlineIncomeReminder ?? this.offlineIncomeReminder,
      dailyRewardReminder: dailyRewardReminder ?? this.dailyRewardReminder,
      eventReminder: eventReminder ?? this.eventReminder,
      prestigeAvailableReminder:
          prestigeAvailableReminder ?? this.prestigeAvailableReminder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'offlineIncomeReminder': offlineIncomeReminder,
      'dailyRewardReminder': dailyRewardReminder,
      'eventReminder': eventReminder,
      'prestigeAvailableReminder': prestigeAvailableReminder,
    };
  }

  factory NotificationPreferences.fromMap(Map<dynamic, dynamic> map) {
    return NotificationPreferences(
      offlineIncomeReminder: map['offlineIncomeReminder'] as bool? ?? true,
      dailyRewardReminder: map['dailyRewardReminder'] as bool? ?? true,
      eventReminder: map['eventReminder'] as bool? ?? true,
      prestigeAvailableReminder: map['prestigeAvailableReminder'] as bool? ?? true,
    );
  }
}
