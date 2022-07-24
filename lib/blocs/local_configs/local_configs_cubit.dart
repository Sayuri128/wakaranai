import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/models/data/local_config.dart';
import 'package:wakaranai/utils/globals.dart';
import 'package:wakascript/api_controller.dart';

part 'local_configs_state.dart';

class LocalConfigsCubit extends Cubit<LocalConfigsState> {
  LocalConfigsCubit() : super(LocalConfigsInitial());

  String? docDir;

  void init() async {
    docDir ??= '${await getAppDocumentsDir()}/scripts';

    final Directory scriptsDir = Directory(docDir!);

    if (!scriptsDir.existsSync()) {
      scriptsDir.createSync(recursive: true);
    }

    final scripts = <LocalConfig>[];

    if (!scriptsDir.isAbsolute) {
      scriptsDir.listSync().forEach((element) {
        final file = File(element.path);
        final code = file.readAsStringSync();
        scripts.add(
            LocalConfig(file: file, code: code, client: ApiClient(code: code)));
      });
    }

    emit(LocalConfigsInitialized(mangas: scripts));
  }
}
