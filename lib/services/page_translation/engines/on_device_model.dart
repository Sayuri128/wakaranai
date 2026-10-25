import 'package:collection/collection.dart';

enum OnDeviceModel {
  e2b(
    engineId: 'gemma',
    displayName: 'Gemma 4 E2B',
    fileName: 'gemma-4-E2B-it.litertlm',
    repository: 'gemma-4-E2B-it-litert-lm',
    sizeBytes: 2588147712,
    minRamGb: 7,
  ),
  e4b(
    engineId: 'gemma_e4b',
    displayName: 'Gemma 4 E4B',
    fileName: 'gemma-4-E4B-it.litertlm',
    repository: 'gemma-4-E4B-it-litert-lm',
    sizeBytes: 3659530240,
    minRamGb: 10,
  );

  const OnDeviceModel({
    required this.engineId,
    required this.displayName,
    required this.fileName,
    required this.repository,
    required this.sizeBytes,
    required this.minRamGb,
  });

  final String engineId;
  final String displayName;
  final String fileName;
  final String repository;
  final int sizeBytes;
  final double minRamGb;

  String get downloadUrl =>
      'https://huggingface.co/litert-community/$repository/resolve/main/$fileName';

  String get sizeLabel => (sizeBytes / 1e9).toStringAsFixed(1);

  static OnDeviceModel? forEngine(String? engineId) {
    return values.firstWhereOrNull(
      (OnDeviceModel model) => model.engineId == engineId,
    );
  }
}
