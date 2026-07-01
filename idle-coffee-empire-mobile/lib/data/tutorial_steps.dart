class TutorialStep {
  const TutorialStep({
    required this.id,
    required this.title,
    required this.message,
  });

  final String id;
  final String title;
  final String message;
}

const List<TutorialStep> tutorialSteps = <TutorialStep>[
  TutorialStep(
    id: 'tap_espresso',
    title: 'Tap Espresso Machine',
    message: 'Tap the Espresso Machine to earn your first coins and cups.',
  ),
  TutorialStep(
    id: 'upgrade_espresso',
    title: 'Upgrade Espresso',
    message: 'Upgrade Espresso Machine once to increase output and speed.',
  ),
  TutorialStep(
    id: 'unlock_grinder',
    title: 'Unlock Grinder',
    message: 'Unlock Coffee Grinder to boost cup production.',
  ),
  TutorialStep(
    id: 'enable_auto',
    title: 'Enable Auto',
    message: 'Turn on Auto Production on a station to keep progress moving.',
  ),
  TutorialStep(
    id: 'hire_worker',
    title: 'Hire Worker',
    message: 'Hire your first worker to automate station performance.',
  ),
  TutorialStep(
    id: 'open_milestones',
    title: 'Open Milestones',
    message: 'Open the Milestones panel and check your claimable rewards.',
  ),
  TutorialStep(
    id: 'offline_income',
    title: 'Offline Income',
    message: 'You earn a portion of income while away. Check the green popup after returning.',
  ),
  TutorialStep(
    id: 'prestige_intro',
    title: 'Prestige Later',
    message: 'Prestige moves you to a new city — shop resets to a roadside stall, but coins, stats, and prestige points carry over, and your chef earns new gear.',
  ),
];
