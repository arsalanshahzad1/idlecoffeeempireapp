class LiveEventModel {
  const LiveEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.multiplier,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final double multiplier;
  final bool isActive;
}
