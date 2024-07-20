import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class ChapterActivityDomain extends BaseDomain<ChapterActivityTableCompanion> {
  final String uid;
  final int concreteId;
  final int readPages;
  final int totalPages;

  factory ChapterActivityDomain.fromDrift(ChapterActivityTableData data) =>
      ChapterActivityDomain(
        id: data.id,
        uid: data.uid,
        concreteId: data.concreteId,
        readPages: data.readPages,
        totalPages: data.totalPages,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  ChapterActivityTableCompanion toDrift(
      {bool update = false, bool create = false}) {

    if (create) {
      return ChapterActivityTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        concreteId: Value(concreteId),
        readPages: Value(readPages),
        totalPages: Value(totalPages),
        createdAt: Value(createdAt),
      );
    }

    return ChapterActivityTableCompanion(
      id: Value(id),
      uid: Value(uid),
      concreteId: Value(concreteId),
      readPages: Value(readPages),
      totalPages: Value(totalPages),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  ChapterActivityDomain({
    required this.uid,
    required this.concreteId,
    required this.readPages,
    required this.totalPages,
    required super.id,
    required super.createdAt,
    super.updatedAt,
  });

  ChapterActivityDomain copyWith({
    int? id,
    String? uid,
    int? concreteId,
    int? readPages,
    int? totalPages,
  }) {
    return ChapterActivityDomain(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      concreteId: concreteId ?? this.concreteId,
      readPages: readPages ?? this.readPages,
      totalPages: totalPages ?? this.totalPages,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
