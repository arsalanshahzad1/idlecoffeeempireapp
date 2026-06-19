enum GameSfx {
  tap('tap'),
  upgrade('upgrade'),
  coin('coin'),
  unlock('unlock'),
  prestige('prestige'),
  milestoneComplete('milestone_complete');

  const GameSfx(this.key);
  final String key;
}

class AudioService {
  const AudioService();

  void playTap({required bool enabled}) => play(GameSfx.tap, enabled: enabled);
  void playUpgrade({required bool enabled}) => play(GameSfx.upgrade, enabled: enabled);
  void playCoin({required bool enabled}) => play(GameSfx.coin, enabled: enabled);
  void playUnlock({required bool enabled}) => play(GameSfx.unlock, enabled: enabled);
  void playPrestige({required bool enabled}) => play(GameSfx.prestige, enabled: enabled);
  void playMilestoneComplete({required bool enabled}) =>
      play(GameSfx.milestoneComplete, enabled: enabled);

  void play(GameSfx sfx, {required bool enabled}) {
    if (!enabled) {
      return;
    }
    // Intentionally stubbed for now.
    // Future integration target:
    // - map GameSfx keys to short assets
    // - route through a real player while preserving this API.
    final _ = sfx.key;
  }
}
