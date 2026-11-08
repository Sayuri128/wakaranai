import 'dart:math';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';

typedef InstanceScriptLoader = Future<String> Function();

class ExtensionInstances {
  ExtensionInstances({required this.repository, Random? random})
      : _random = random ?? Random.secure();

  final ExtensionRepository repository;
  final Random _random;

  Future<List<ExtensionDomain>> all() async {
    final List<ExtensionDomain> installed = await repository.getAll();
    return installed
        .where((ExtensionDomain extension) => extension.isInstance)
        .toList(growable: false);
  }

  Future<List<ExtensionDomain>> of(String baseUid) async {
    return (await all())
        .where((ExtensionDomain extension) => extension.baseUid == baseUid)
        .toList(growable: false);
  }

  Future<String> nextName(ConfigInfo base) async {
    final Set<String> taken = (await of(base.uid))
        .map((ExtensionDomain extension) => extension.config.name)
        .toSet();
    int number = 2;
    while (taken.contains('${base.name.trim()} $number')) {
      number++;
    }
    return '${base.name.trim()} $number';
  }

  Future<ExtensionDomain?> create({
    required ConfigInfo base,
    required String? revision,
    required String name,
    required InstanceScriptLoader script,
  }) async {
    final String uid = _newUid();
    return repository.createUpdateByUid(ExtensionDomain(
      id: 0,
      config: instanceConfig(base, uid: uid, name: name),
      sourceCode: await script(),
      revision: revision,
      baseUid: base.uid,
      createdAt: DateTime.now(),
    ));
  }

  Future<ExtensionDomain?> rename(ExtensionDomain instance, String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty || !instance.isInstance) {
      return Future<ExtensionDomain?>.value(instance);
    }
    return repository.createUpdateByUid(instance.copyWith(
      config: instanceConfig(
        instance.config,
        uid: instance.config.uid,
        name: trimmed,
      ),
    ));
  }

  static ConfigInfo instanceConfig(
    ConfigInfo base, {
    required String uid,
    required String name,
  }) {
    final Map<String, dynamic> json = base.toJson();
    json['uid'] = uid;
    json['name'] = name;
    final Object? protector = json['protectorConfig'];
    if (protector is Map) {
      final Map<String, dynamic> copy = Map<String, dynamic>.from(protector);
      final Object? group = copy['sessionGroup'];
      if (group is String && group.isNotEmpty && !group.endsWith('#$uid')) {
        copy['sessionGroup'] = '${group.split('#').first}#$uid';
      }
      json['protectorConfig'] = copy;
    }
    return ConfigInfo.fromJson(json);
  }

  String _newUid() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final String hex =
        bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
