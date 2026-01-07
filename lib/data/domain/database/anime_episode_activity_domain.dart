
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';

part 'anime_episode_activity_domain.g.dart';

@JsonSerializable()
class AnimeEpisodeActivityDomain extends BaseActivityDomain<AnimeEpisodeActivityTableCompanion> {

  final String? timestamp;
  final String? data;
  final int? watchedTime;
  final int? totalTime;

  Map<String, dynamic> get dataJson => data != null ? jsonDecode(data!) : {};
  
  factory AnimeEpisodeActivityDomain.fromJson(Map<String, dynamic> json) =>
      _$AnimeEpisodeActivityDomainFromJson(json);
  
  Map<String, dynamic> toJson() => _$AnimeEpisodeActivityDomainToJson(this);

  AnimeEpisodeActivityDomain({
    required super.id,
    required super.uid,
    required super.title,
    this.timestamp,
    this.data,
    required super.concreteId,
    this.watchedTime,
    this.totalTime,
    required super.createdAt,
     super.updatedAt,
  });
  

  factory AnimeEpisodeActivityDomain.fromDrift(AnimeEpisodeActivityTableData data) =>
      AnimeEpisodeActivityDomain(
        id: data.id,
        uid: data.uid,
        title: data.title,
        timestamp: data.timestamp,
        data: data.data,
        concreteId: data.concreteId,
        watchedTime: data.watchedTime,
        totalTime: data.totalTime,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );

  @override
  AnimeEpisodeActivityTableCompanion toDrift({bool update = false, bool
  create = false}) {
    if (create) {
      return AnimeEpisodeActivityTableCompanion(
        id: const Value.absent(),
        uid: Value(uid),
        title: Value(title),
        timestamp: Value(timestamp),
        data: Value(data),
        concreteId: Value(concreteId),
        watchedTime: Value(watchedTime),
        totalTime: Value(totalTime),
        createdAt: Value(createdAt),
      );
    }

    return AnimeEpisodeActivityTableCompanion(
      id: Value(id),
      uid: Value(uid),
      title: Value(title),
      timestamp: Value(timestamp),
      data: Value(data),
      concreteId: Value(concreteId),
      watchedTime: Value(watchedTime),
      totalTime: Value(totalTime),
      createdAt: Value(createdAt),
      updatedAt: Value(update ? DateTime.now() : updatedAt),
    );
  }

}