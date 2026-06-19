import 'package:flutter/services.dart';

class HapticsService {
  const HapticsService();

  Future<void> lightImpact({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selectionClick({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }
}
