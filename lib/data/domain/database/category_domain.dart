import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class CategoryDomain extends BaseDomain<CategoryTableCompanion> {
  final String name;
  final int sortOrder;

  CategoryDomain({
    required super.id,
    required this.name,
    required this.sortOrder,
    required super.createdAt,
    super.updatedAt,
  });

  factory CategoryDomain.fromDrift(CategoryTableData data) => CategoryDomain(
        id: data.id,
        name: data.name,
        sortOrder: data.sortOrder,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  CategoryTableCompanion toDrift({bool update = false, bool create = false}) {
    if (create) {
      return CategoryTableCompanion(
        id: const Value.absent(),
        name: Value(name),
        sortOrder: Value(sortOrder),
        createdAt: Value(createdAt),
      );
    }

    return CategoryTableCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  CategoryDomain copyWith({String? name, int? sortOrder}) => CategoryDomain(
        id: id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
