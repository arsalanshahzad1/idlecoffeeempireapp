import 'analytics_event.dart';
import 'analytics_service.dart';

class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> _events = <AnalyticsEvent>[];

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    // TODO(backend): Forward this event to the production analytics SDK.
    _events.add(event);
    if (_events.length > 100) {
      _events.removeAt(0);
    }
  }

  @override
  List<AnalyticsEvent> recentEvents() {
    return List<AnalyticsEvent>.unmodifiable(_events);
  }
}
