class BaseDomain {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BaseDomain({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });
}
