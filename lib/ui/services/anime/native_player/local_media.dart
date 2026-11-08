import 'package:wakaranai/data/domain/playable_video.dart';

bool isLocalFileUrl(String url) {
  final Uri? uri = Uri.tryParse(url.trim());
  if (uri == null) {
    return false;
  }
  return uri.scheme == 'file';
}

String localFilePathOf(String url) {
  return Uri.parse(url.trim()).toFilePath();
}

Map<String, String> playbackHeadersFor(PlayableStream stream) {
  if (isLocalFileUrl(stream.url)) {
    return const <String, String>{};
  }
  return stream.headers;
}
