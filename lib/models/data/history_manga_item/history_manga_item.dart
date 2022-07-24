import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';

class HistoryMangaItem {
  int? id;
  final String serviceSourceCode;
  final ConcreteView concreteView;
  final String chapterUid;

  @DateTimeTimeStampJsonConverter()
  final DateTime timestamp;

  HistoryMangaItem({
    this.id,
    required this.serviceSourceCode,
    required this.concreteView,
    required this.chapterUid,
    required this.timestamp,
  });

  HistoryMangaItem copyWith({
    int? id,
    String? serviceSourceCode,
    ConcreteView? concreteView,
    String? chapterUid,
    DateTime? timestamp,
  }) {
    return HistoryMangaItem(
      id: id ?? this.id,
      serviceSourceCode: serviceSourceCode ?? this.serviceSourceCode,
      concreteView: concreteView ?? this.concreteView,
      chapterUid: chapterUid ?? this.chapterUid,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'serviceSourceCode': serviceSourceCode,
      'concreteView': jsonEncode(concreteView.toJson()),
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
