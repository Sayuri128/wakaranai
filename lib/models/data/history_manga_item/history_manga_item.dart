import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/serializable_object.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';
import 'package:wakascript/models/gallery_view/gallery_view.dart';

class HistoryMangaItem extends SerializableObject {
  int? id;
  final String serviceSourceCode;
  final ConcreteView concreteView;
  final GalleryView galleryView;
  final String chapterUid;

  @DateTimeTimeStampJsonConverter()
  final DateTime timestamp;

  HistoryMangaItem({
    this.id,
    required this.serviceSourceCode,
    required this.concreteView,
    required this.galleryView,
    required this.chapterUid,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'serviceSourceCode': serviceSourceCode,
      'concreteView': jsonEncode(concreteView.toJson()),
      'galleryView': jsonEncode(galleryView.toJson()),
      'chapterUid': chapterUid,
      'timestamp': const DateTimeTimeStampJsonConverter().toJson(timestamp),
    };
  }

  factory HistoryMangaItem.fromJson(Map<String, dynamic> map) {
    return HistoryMangaItem(
      id: map['id'] as int,
      serviceSourceCode: map['serviceSourceCode'] as String,
      concreteView:
          ConcreteView.fromJson(jsonDecode(map['concreteView'] as String)),
      galleryView:
          GalleryView.fromJson(jsonDecode(map['galleryView'] as String)),
      chapterUid: map['chapterUid'] as String,
      timestamp: const DateTimeTimeStampJsonConverter()
          .fromJson(map['timestamp'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryMangaItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  HistoryMangaItem copyWith({
    int? id,
    String? serviceSourceCode,
    ConcreteView? concreteView,
    GalleryView? galleryView,
    String? chapterUid,
    DateTime? timestamp,
  }) {
    return HistoryMangaItem(
      id: id ?? this.id,
      serviceSourceCode: serviceSourceCode ?? this.serviceSourceCode,
      concreteView: concreteView ?? this.concreteView,
      galleryView: galleryView ?? this.galleryView,
      chapterUid: chapterUid ?? this.chapterUid,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, dynamic> toMap() => toJson();
}

class DateTimeTimeStampJsonConverter extends JsonConverter<DateTime, int> {
  const DateTimeTimeStampJsonConverter();

  @override
  DateTime fromJson(int json) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  }

  @override
  int toJson(DateTime object) {
    return object.millisecondsSinceEpoch;
  }
}
