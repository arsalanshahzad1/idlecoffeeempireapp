import 'package:flutter/material.dart';

import '../../data/tutorial_steps.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
    required this.onSkip,
    super.key,
  });

  final TutorialStep step;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      top: 12,
      child: Card(
        color: Colors.black.withValues(alpha: 0.85),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tutorial ${currentIndex + 1}/$totalSteps',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(step.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 2),
              Text(step.message, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text('Skip Tutorial'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
