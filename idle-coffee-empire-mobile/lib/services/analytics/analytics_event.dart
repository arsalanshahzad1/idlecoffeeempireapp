enum AnalyticsEventType {
  appOpen,
  sessionStart,
  tutorialStepComplete,
  stationUpgrade,
  stationUnlock,
  prestige,
  workerHire,
  decorationPurchase,
  managerPurchase,
  expansionUnlock,
  gemSpend,
  boostActivation,
  adRewardClaim,
  storePurchaseMock,
  levelUp,
  milestoneCompletion,
  achievementCompletion,
  dailyRewardClaimed,
  taskCompleted,
  eventActivated,
  eventShopPurchase,
  streakMilestoneReached,
  themeChanged,
}

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.type,
    required this.occurredAtUtcMillis,
    this.properties = const <String, Object?>{},
  });

  final AnalyticsEventType type;
  final int occurredAtUtcMillis;
  final Map<String, Object?> properties;
}
