import '../data/daily_reward_config.dart';
import '../models/daily_reward_state.dart';

class DailyRewardManager {
  const DailyRewardManager();

  DailyRewardConfig getCurrentReward(DailyRewardState state) {
    final index = state.currentDayIndex.clamp(0, dailyRewardCycleConfig.rewards.length - 1);
    return dailyRewardCycleConfig.rewards[index];
  }

  bool canClaim(DailyRewardState state, DateTime nowUtc) {
    return state.lastClaimDate != _dateKey(nowUtc);
  }

  DailyRewardState rollDay(DailyRewardState state, DateTime nowUtc) {
    final today = _dateKey(nowUtc);
    if (state.lastEvaluatedDate == today) {
      return state;
    }
    if (state.lastClaimDate.isEmpty) {
      return state.copyWith(lastEvaluatedDate: today);
    }
    final claimedDay = DateTime.tryParse(state.lastClaimDate);
    if (claimedDay == null) {
      return state.copyWith(currentDayIndex: 0, lastEvaluatedDate: today);
    }
    final diff = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day)
        .difference(DateTime.utc(claimedDay.year, claimedDay.month, claimedDay.day))
        .inDays;
    if (diff > 1 && dailyRewardCycleConfig.resetOnMissedDay) {
      return state.copyWith(currentDayIndex: 0, lastEvaluatedDate: today);
    }
    return state.copyWith(lastEvaluatedDate: today);
  }

  DailyRewardState markClaimed(DailyRewardState state, DateTime nowUtc) {
    final today = _dateKey(nowUtc);
    final nextIndex = (state.currentDayIndex + 1) % dailyRewardCycleConfig.rewards.length;
    return state.copyWith(
      currentDayIndex: nextIndex,
      lastClaimDate: today,
      lastEvaluatedDate: today,
    );
  }

  String _dateKey(DateTime utc) {
    final d = utc.toLocal();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}
