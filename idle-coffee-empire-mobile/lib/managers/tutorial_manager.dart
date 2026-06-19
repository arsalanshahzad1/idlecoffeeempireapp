import '../data/tutorial_steps.dart';
import '../models/tutorial_state.dart';

class TutorialManager {
  const TutorialManager();

  List<TutorialStep> get steps => tutorialSteps;

  TutorialState skip(TutorialState state) {
    return state.copyWith(isSkipped: true, isCompleted: false);
  }

  TutorialState restart() => TutorialState.initial;

  TutorialState completeStep(TutorialState state, String stepId) {
    if (!state.isActive) {
      return state;
    }
    if (state.currentStepIndex >= tutorialSteps.length) {
      return state.copyWith(isCompleted: true);
    }
    final current = tutorialSteps[state.currentStepIndex];
    if (current.id != stepId) {
      return state;
    }
    final next = state.currentStepIndex + 1;
    if (next >= tutorialSteps.length) {
      return state.copyWith(
        currentStepIndex: tutorialSteps.length - 1,
        isCompleted: true,
      );
    }
    return state.copyWith(currentStepIndex: next);
  }
}
