abstract class BaseDomain<TTableCompanion> {
  int id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BaseDomain({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });

  TTableCompanion toDrift({
    bool update = false,
    bool create = false,
  });
}
