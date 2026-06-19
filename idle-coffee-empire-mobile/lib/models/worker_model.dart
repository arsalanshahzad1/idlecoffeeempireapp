class WorkerModel {
  const WorkerModel({
    required this.id,
    required this.name,
    required this.stationId,
    required this.hireCost,
    required this.efficiencyMultiplier,
  });

  final String id;
  final String name;
  final String stationId;
  final double hireCost;
  final double efficiencyMultiplier;
}
