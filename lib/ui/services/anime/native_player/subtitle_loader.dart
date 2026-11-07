import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/utils/http_client.dart';

abstract class SubtitleLoader {
  Future<ClosedCaptionFile> load(PlayableSubtitle subtitle);
}

class DioSubtitleLoader implements SubtitleLoader {
  @override
  Future<ClosedCaptionFile> load(PlayableSubtitle subtitle) async {
    final Dio dio = createDio(headers: subtitle.headers);
    try {
      final Response<String> response = await dio.get<String>(
        subtitle.url.trim(),
        options: Options(responseType: ResponseType.plain),
      );
      return parseClosedCaptionFile(subtitle, response.data ?? '');
    } finally {
      dio.close();
    }
  }
}

ClosedCaptionFile parseClosedCaptionFile(
  PlayableSubtitle subtitle,
  String content,
) {
  final String normalized = normalizeSubtitleText(content);
  final PlayableSubtitleFormat format = resolveSubtitleFormat(
    subtitle,
    content: normalized,
  );
  if (format == PlayableSubtitleFormat.srt) {
    return SubRipCaptionFile(normalized);
  }
  return WebVTTCaptionFile(normalized);
}

String normalizeSubtitleText(String content) {
  return stripByteOrderMark(content)
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
}
