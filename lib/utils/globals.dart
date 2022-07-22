import 'package:path_provider/path_provider.dart';

const String appDocumentsDir = 'wakaranai';

Future<String> getAppDocumentsDir() async =>
    '${(await getApplicationDocumentsDirectory()).path}/$appDocumentsDir';
