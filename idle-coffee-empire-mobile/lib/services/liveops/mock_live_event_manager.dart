import 'live_event_manager.dart';
import 'live_event_model.dart';

class MockLiveEventManager implements LiveEventManager {
  final List<LiveEventModel> _events = <LiveEventModel>[
    const LiveEventModel(
      id: 'weekend_income_boost',
      title: 'Weekend Boost',
      description: 'Mock event: +20% income for local simulation.',
      multiplier: 1.2,
      isActive: false,
    ),
  ];

  @override
  Future<List<LiveEventModel>> getActiveEvents() async {
    return _events.where((event) => event.isActive).toList(growable: false);
  }

  @override
  Future<void> simulateEvent(LiveEventModel event) async {
    _events.removeWhere((item) => item.id == event.id);
    _events.add(event);
  }
}
