import '../data/worker_configs.dart';
import '../models/worker_config.dart';

class WorkerManager {
  const WorkerManager();

  List<WorkerConfig> get allWorkers => workerConfigs;

  WorkerConfig? forStation(String stationId) {
    for (final worker in workerConfigs) {
      if (worker.assignedStationId == stationId) {
        return worker;
      }
    }
    return null;
  }

  WorkerConfig? byId(String workerId) {
    for (final worker in workerConfigs) {
      if (worker.id == workerId) {
        return worker;
      }
    }
    return null;
  }

  double upgradeCost(WorkerConfig worker, int level) {
    return worker.baseUpgradeCost * _pow(worker.upgradeCostGrowth, level - 1);
  }

  double efficiencyForLevel(WorkerConfig worker, int level) {
    final safeLevel = level < 1 ? 1 : level;
    return worker.baseEfficiencyMultiplier +
        (safeLevel - 1) * worker.efficiencyPerLevel;
  }

  double _pow(double base, int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
