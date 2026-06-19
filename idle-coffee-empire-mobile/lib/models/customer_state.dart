enum CustomerStatePhase { spawning, queueing, waiting, served, leaving }

class CustomerState {
  const CustomerState({
    required this.id,
    required this.phase,
    required this.queueIndex,
  });

  final int id;
  final CustomerStatePhase phase;
  final int queueIndex;

  CustomerState copyWith({
    CustomerStatePhase? phase,
    int? queueIndex,
  }) {
    return CustomerState(
      id: id,
      phase: phase ?? this.phase,
      queueIndex: queueIndex ?? this.queueIndex,
    );
  }
}
