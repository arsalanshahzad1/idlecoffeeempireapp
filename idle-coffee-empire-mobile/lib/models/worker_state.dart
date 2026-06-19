class WorkerState {
  const WorkerState({required this.id, required this.hired});

  final String id;
  final bool hired;

  WorkerState copyWith({bool? hired}) {
    return WorkerState(id: id, hired: hired ?? this.hired);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'hired': hired};
  }

  factory WorkerState.fromMap(Map<dynamic, dynamic> map) {
    return WorkerState(
      id: map['id'] as String,
      hired: map['hired'] as bool? ?? false,
    );
  }
}
