class TutorialState {
  const TutorialState({
    required this.currentStepIndex,
    required this.isCompleted,
    required this.isSkipped,
  });

  final int currentStepIndex;
  final bool isCompleted;
  final bool isSkipped;

  static const TutorialState initial = TutorialState(
    currentStepIndex: 0,
    isCompleted: false,
    isSkipped: false,
  );

  bool get isActive => !isCompleted && !isSkipped;

  TutorialState copyWith({
    int? currentStepIndex,
    bool? isCompleted,
    bool? isSkipped,
  }) {
    return TutorialState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentStepIndex': currentStepIndex,
      'isCompleted': isCompleted,
      'isSkipped': isSkipped,
    };
  }

  factory TutorialState.fromMap(Map<dynamic, dynamic> map) {
    return TutorialState(
      currentStepIndex: (map['currentStepIndex'] as num?)?.toInt() ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      isSkipped: map['isSkipped'] as bool? ?? false,
    );
  }
}
