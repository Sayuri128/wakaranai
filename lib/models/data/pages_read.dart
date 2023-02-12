import 'package:wakaranai/model/wakaranai_db.dart';

class PagesRead {
  final int? id;
  final String uid;
  final int readPages;
  final int totalPages;
  final DateTime? created;
  final DateTime? lastUpdated;

  const PagesRead({
    this.id,
    required this.uid,
    required this.readPages,
    required this.totalPages,
    this.created,
    this.lastUpdated,
  });

  factory PagesRead.fromDrift(DriftPagesRead drift) => PagesRead(
      id: drift.id,
      uid: drift.uid,
      readPages: drift.readPages,
      totalPages: drift.totalPages,
      created: drift.created,
      lastUpdated: drift.lastUpdated);

  PagesRead copyWith({
    int? id,
    String? uid,
    int? readPages,
    int? totalPages,
    DateTime? created,
    DateTime? lastUpdated,
  }) {
    return PagesRead(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      readPages: readPages ?? this.readPages,
      totalPages: totalPages ?? this.totalPages,
      created: created ?? this.created,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
