import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/limited_event_configs.dart';
import '../game/game_controller.dart';

class EventPanel extends ConsumerWidget {
  const EventPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final active = state.activeEvents.activeEventIds;
    return AlertDialog(
      title: const Text('Events'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: ListView(
          shrinkWrap: true,
          children: limitedEventConfigs
              .map(
                (event) => SwitchListTile(
                  title: Text(event.title),
                  subtitle: Text(event.description),
                  value: active.contains(event.id),
                  onChanged: (value) => controller.setLimitedEventActive(event.id, value),
                ),
              )
              .toList(growable: false),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
