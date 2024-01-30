abstract class BaseDomain<TTableCompanion> {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BaseDomain({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });

  TTableCompanion toDrift({
    bool update = false,
    bool create = false,
  });

}
