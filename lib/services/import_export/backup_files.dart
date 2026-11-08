import 'package:flutter/services.dart';

abstract class BackupFiles {
  Future<String> save(String name, Uint8List bytes);

  Future<int> prune(String prefix, int keep);
}

class DownloadsBackupFiles implements BackupFiles {
  static const MethodChannel _channel = MethodChannel('wakaranai/backups');

  @override
  Future<String> save(String name, Uint8List bytes) async {
    final String? location = await _channel.invokeMethod<String>(
      'save',
      <String, Object>{'name': name, 'bytes': bytes},
    );
    return location ?? name;
  }

  @override
  Future<int> prune(String prefix, int keep) async {
    final int? deleted = await _channel.invokeMethod<int>(
      'prune',
      <String, Object>{'prefix': prefix, 'keep': keep},
    );
    return deleted ?? 0;
  }
}
