import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

class ConcreteDataDomain extends BaseDomain<ConcreteDataTableCompanion> {
  final String uid;
  final String title;
  final String? cover;
  final String? data;

  Map<String, dynamic> get dataJson => data != null ? jsonDecode(data!) : {};

  factory ConcreteDataDomain.fromDrift(ConcreteDataTableData data) =>
      ConcreteDataDomain(
        id: data.id,
        uid: data.uid,
        title: data.title,
        cover: data.cover,
        data: data.data,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  ConcreteDataTableCompanion toDrift(
      {bool update = false, bool create = false}) {
    if (create) {
      return ConcreteDataTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        title: Value(title),
        cover: Value(cover),
        data: Value(data),
        createdAt: Value(createdAt),
      );
    }

    return ConcreteDataTableCompanion(
      id: Value(id),
      uid: Value(uid),
      title: Value(title),
      cover: Value(cover),
      data: Value(data),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

  ConcreteDataDomain copyWith({
    int? id,
    String? uid,
    String? title,
    String? cover,
    String? data,
  }) {
    return ConcreteDataDomain(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      data: data ?? this.data,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  ConcreteDataDomain({
    required super.id,
    required this.uid,
    required this.title,
    this.cover,
    this.data,
    required super.createdAt,
    super.updatedAt,
  });
}

extension ConcreteViewExtension on ConcreteView<dynamic> {
  ConcreteDataDomain toConcreteDataDomain(Map<String, dynamic> data) =>
      ConcreteDataDomain(
        id: 0,
        uid: uid,
        title: title,
        cover: cover,
        data: jsonEncode(data),
        createdAt: DateTime.now(),
      );
}
