import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/theme_configs.dart';
import '../game_controller.dart';
import 'debug_panel.dart';
import 'game_dialogs.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final settings = state.settings;
    final lastSaved = DateTime.fromMillisecondsSinceEpoch(
      state.lastSavedAtUtcMillis,
      isUtc: true,
    ).toLocal();

    Future<void> toggle({
      bool? sound,
      bool? music,
      bool? haptics,
      bool? floating,
      bool? debug,
      int? autosaveSeconds,
    }) {
      return controller.updateSettings(
        settings.copyWith(
          soundEnabled: sound,
          musicEnabled: music,
          hapticsEnabled: haptics,
          floatingTextEnabled: floating,
          debugEnabled: debug,
          autosaveIntervalSeconds: autosaveSeconds,
        ),
      );
    }

    return AlertDialog(
      title: const Text('Settings'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Sound'),
                value: settings.soundEnabled,
                onChanged: (value) => toggle(sound: value),
              ),
              SwitchListTile(
                title: const Text('Music'),
                subtitle: const Text('Foundation only (no music asset configured).'),
                value: settings.musicEnabled,
                onChanged: (value) => toggle(music: value),
              ),
              SwitchListTile(
                title: const Text('Haptics'),
                value: settings.hapticsEnabled,
                onChanged: (value) => toggle(haptics: value),
              ),
              SwitchListTile(
                title: const Text('Floating Text'),
                value: settings.floatingTextEnabled,
                onChanged: (value) => toggle(floating: value),
              ),
              const SizedBox(height: 6),
              Text('Save status: ${state.saveCorrupted ? 'Recovered from corrupted save' : 'OK'}'),
              Text('Last saved: $lastSaved'),
              Text('Save version: ${state.saveVersion}'),
              const SizedBox(height: 10),
              const Text('Cloud Save (Coming Soon)', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Status: ${controller.cloudSyncState.lastSyncStatus}'),
              Text('Sync version: ${controller.cloudSyncState.syncVersion}'),
              Text('Device ID: ${controller.cloudSyncState.deviceId}'),
              Text('Mock cloud sync at: ${state.serviceIntegration.lastMockCloudSyncUtcMillis == 0 ? 'never' : state.serviceIntegration.lastMockCloudSyncUtcMillis}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => controller.simulateCloudSync(),
                    child: const Text('Mock Sync'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.linkAccountPlaceholder('google_play_games'),
                    child: const Text('Link Account Placeholder'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {},
                    child: const Text('Conflict: Keep Local'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {},
                    child: const Text('Conflict: Use Cloud'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Profile (Coming Soon)', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Player ID: ${controller.playerProfile.playerId}'),
              Text('Username: ${controller.playerProfile.username}'),
              Text('Avatar: ${controller.playerProfile.avatarId}'),
              Text('Profile sync status: ${state.serviceIntegration.profileSyncStatus}'),
              Text('Remove ads: ${state.serviceIntegration.removeAds ? 'Yes' : 'No'}'),
              Text('VIP pass: ${state.serviceIntegration.vipPass ? 'Yes' : 'No'}'),
              const SizedBox(height: 10),
              const Text('LiveOps (Coming Soon)', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Remote overrides: ${controller.remoteConfigOverrides.length}'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: state.selectedThemeId,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: liveThemeConfigs
                    .map(
                      (t) => DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(t.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    controller.setTheme(value);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Offline Income Reminder'),
                value: state.notificationPreferences.offlineIncomeReminder,
                onChanged: (value) => controller.updateNotificationPreferences(
                  state.notificationPreferences.copyWith(offlineIncomeReminder: value),
                ),
              ),
              SwitchListTile(
                title: const Text('Daily Reward Reminder'),
                value: state.notificationPreferences.dailyRewardReminder,
                onChanged: (value) => controller.updateNotificationPreferences(
                  state.notificationPreferences.copyWith(dailyRewardReminder: value),
                ),
              ),
              SwitchListTile(
                title: const Text('Event Reminder'),
                value: state.notificationPreferences.eventReminder,
                onChanged: (value) => controller.updateNotificationPreferences(
                  state.notificationPreferences.copyWith(eventReminder: value),
                ),
              ),
              SwitchListTile(
                title: const Text('Prestige Available Reminder'),
                value: state.notificationPreferences.prestigeAvailableReminder,
                onChanged: (value) => controller.updateNotificationPreferences(
                  state.notificationPreferences.copyWith(
                    prestigeAvailableReminder: value,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: settings.autosaveIntervalSeconds,
                decoration: const InputDecoration(labelText: 'Autosave Interval'),
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10s')),
                  DropdownMenuItem(value: 15, child: Text('15s')),
                  DropdownMenuItem(value: 30, child: Text('30s')),
                  DropdownMenuItem(value: 60, child: Text('60s')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    toggle(autosaveSeconds: value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => controller.restartTutorial(),
                    child: const Text('Restart Tutorial'),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      final ok = await showGameDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Reset Run Progress'),
                          content: const Text('Reset current run progress but keep prestige progression?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await controller.resetRunProgress();
                      }
                    },
                    child: const Text('Normal Reset'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final ok = await showGameDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Full Reset'),
                          content: const Text('Delete all local save/settings/tutorial data? This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await controller.resetProgress();
                      }
                    },
                    child: const Text('Full Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Developer / Debug'),
                value: settings.debugEnabled,
                onChanged: (value) => toggle(debug: value),
              ),
              if (settings.debugEnabled)
                FilledButton.tonal(
                  onPressed: () => showGameDialog<void>(
                    context: context,
                    builder: (_) => const DebugPanel(),
                  ),
                  child: const Text('Open Debug Panel'),
                ),
              const SizedBox(height: 8),
              const ListTile(
                title: Text('Login / Account'),
                subtitle: Text('Planned account linking and cloud login flow.'),
                trailing: Chip(label: Text('Coming Soon')),
                dense: true,
              ),
              const ListTile(
                title: Text('Seasonal Content'),
                subtitle: Text('Holiday themes and limited-time experiences.'),
                trailing: Chip(label: Text('Coming Soon')),
                dense: true,
              ),
            ],
          ),
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
