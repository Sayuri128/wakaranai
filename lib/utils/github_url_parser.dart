import 'package:wakaranai/data/domain/github_url_data.dart';

class GithubUrlParser {
  final String url;

  const GithubUrlParser({
    required this.url,
  });

  GithubUrlData? parse() {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final org = pathSegments[0];
      final repo = pathSegments[1];
      return GithubUrlData(
        org: org,
        repo: repo,
      );
    } catch (e) {
      return null;
    }
  }
}
