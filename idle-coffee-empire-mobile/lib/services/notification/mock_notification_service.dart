import 'notification_service.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> scheduleDailyRewardReminder() async {}

  @override
  Future<void> scheduleEventReminder() async {}

  @override
  Future<void> schedulePrestigeAvailableReminder() async {}

  @override
  Future<void> scheduleOfflineIncomeReminder() async {}
}
