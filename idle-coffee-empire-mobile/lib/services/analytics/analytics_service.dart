import 'analytics_event.dart';

abstract class AnalyticsService {
  Future<void> logEvent(AnalyticsEvent event);
  List<AnalyticsEvent> recentEvents();
}
