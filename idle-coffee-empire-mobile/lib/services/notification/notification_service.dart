abstract class NotificationService {
  Future<void> scheduleOfflineIncomeReminder();
  Future<void> scheduleDailyRewardReminder();
  Future<void> scheduleEventReminder();
  Future<void> schedulePrestigeAvailableReminder();
  Future<void> cancelAll();
}
