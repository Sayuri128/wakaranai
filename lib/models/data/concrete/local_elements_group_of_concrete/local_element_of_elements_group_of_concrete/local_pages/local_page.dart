import 'package:wakaranai/model/wakaranai_db.dart';

class LocalPage {
  final int? id;
  final String url;

  factory LocalPage.fromDrift(DriftLocalPage drift) =>
      LocalPage(url: drift.url, id: drift.id);

  const LocalPage({
    this.id,
    required this.url
  });
}