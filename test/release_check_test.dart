import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/data/domain/app_version.dart';
import 'package:wakaranai/data/domain/latest_release_data.dart';
import 'package:wakaranai/data/models/github/release_response/github_release_response_model.dart';
import 'package:wakaranai/repositories/releases_repository/github/github_releases_repository.dart';
import 'package:wakaranai/services/releases_service/releases_service.dart';
import 'package:wakaranai/utils/installed_app_version.dart';

class _FakeRepository extends GithubReleasesRepository {
  _FakeRepository(this.respond) : super(Dio());

  final Future<GithubReleaseResponseModel> Function() respond;
  int calls = 0;

  @override
  Future<GithubReleaseResponseModel> getLatestRelease({
    required String org,
    required String repo,
  }) {
    calls++;
    return respond();
  }
}

class _FakeReleasesService extends ReleasesService {
  _FakeReleasesService() : super(repository: _FakeRepository(_never));

  static Future<GithubReleaseResponseModel> _never() {
    throw UnimplementedError();
  }

  final List<LatestReleaseData?> results = <LatestReleaseData?>[];
  int calls = 0;

  @override
  Future<LatestReleaseData?> fetchLatestRelease() async {
    calls++;
    if (results.isEmpty) {
      return null;
    }
    return results.removeAt(0);
  }
}

LatestReleaseData _release(String latest, String current) {
  return LatestReleaseData(
    url: 'https://example.com/release',
    latestVersion: AppVersion.tryParse(latest)!,
    currentVersion: AppVersion.tryParse(current)!,
  );
}

ReleasesService _serviceFor(
  Map<String, dynamic> json, {
  String? current = '0.4.0',
}) {
  return ReleasesService(
    repository: _FakeRepository(
      () async => GithubReleaseResponseModel.fromJson(json),
    ),
    currentVersion: () => current,
    org: 'org',
    repo: 'repo',
  );
}

void main() {
  group('release response', () {
    test('parses a release without a title or the unused fields', () {
      final GithubReleaseResponseModel model =
          GithubReleaseResponseModel.fromJson(<String, dynamic>{
        'tag_name': 'v0.5.0',
        'html_url': 'https://github.com/org/repo/releases/tag/v0.5.0',
        'name': null,
      });
      expect(model.tagName, 'v0.5.0');
      expect(model.name, isNull);
    });
  });

  group('releases service', () {
    test('reports an update when the tag is newer than the installed version', () async {
      final LatestReleaseData? data = await _serviceFor(<String, dynamic>{
        'tag_name': 'v0.5.0',
        'html_url': 'https://github.com/org/repo/releases/tag/v0.5.0',
      }).fetchLatestRelease();
      expect(data, isNotNull);
      expect(data!.needsUpdate, isTrue);
      expect(data.url, 'https://github.com/org/repo/releases/tag/v0.5.0');
    });

    test('accepts short and suffixed tags', () async {
      final LatestReleaseData? shortTag = await _serviceFor(<String, dynamic>{
        'tag_name': 'v0.4',
      }).fetchLatestRelease();
      expect(shortTag!.needsUpdate, isFalse);
      final LatestReleaseData? suffixed = await _serviceFor(<String, dynamic>{
        'tag_name': '0.4.1-beta.2',
      }).fetchLatestRelease();
      expect(suffixed!.needsUpdate, isTrue);
    });

    test('falls back to the latest releases page without an html url', () async {
      final LatestReleaseData? data = await _serviceFor(<String, dynamic>{
        'tag_name': 'v0.5.0',
      }).fetchLatestRelease();
      expect(data!.url, 'https://github.com/org/repo/releases/latest');
    });

    test('gives no result for a tag that is not a version', () async {
      final LatestReleaseData? data = await _serviceFor(<String, dynamic>{
        'tag_name': 'nightly',
      }).fetchLatestRelease();
      expect(data, isNull);
    });

    test('gives no result when the installed version is unknown', () async {
      final LatestReleaseData? data = await _serviceFor(
        <String, dynamic>{'tag_name': 'v0.5.0'},
        current: null,
      ).fetchLatestRelease();
      expect(data, isNull);
    });

    test('gives no result when the request fails', () async {
      final ReleasesService service = ReleasesService(
        repository: _FakeRepository(() async => throw DioException(
              requestOptions: RequestOptions(path: '/'),
            )),
        currentVersion: () => '0.4.0',
        org: 'org',
        repo: 'repo',
      );
      expect(await service.fetchLatestRelease(), isNull);
    });
  });

  group('latest release cubit', () {
    late DateTime now;
    late _FakeReleasesService service;
    late LatestReleaseCubit cubit;

    setUp(() {
      now = DateTime(2026, 11, 8, 12);
      service = _FakeReleasesService();
      cubit = LatestReleaseCubit(
        releasesService: service,
        now: () => now,
        checkOnResume: false,
      );
    });

    tearDown(() => cubit.close());

    test('loads on init and skips rechecks within the interval', () async {
      service.results.add(_release('0.5.0', '0.4.0'));
      await cubit.init();
      expect(cubit.state, isA<LatestReleaseLoaded>());
      now = now.add(const Duration(minutes: 30));
      await cubit.check();
      expect(service.calls, 1);
      now = now.add(const Duration(minutes: 31));
      service.results.add(_release('0.6.0', '0.4.0'));
      await cubit.check();
      expect(service.calls, 2);
      final LatestReleaseLoaded loaded = cubit.state as LatestReleaseLoaded;
      expect(loaded.releaseData.latestVersion.toString(), '0.6.0');
    });

    test('keeps the last result when a later check fails', () async {
      service.results.add(_release('0.5.0', '0.4.0'));
      await cubit.init();
      now = now.add(const Duration(hours: 2));
      await cubit.check();
      expect(service.calls, 2);
      expect(cubit.state, isA<LatestReleaseLoaded>());
    });

    test('retries a failed check sooner than a successful one', () async {
      await cubit.init();
      expect(cubit.state, isA<LatestReleaseError>());
      now = now.add(const Duration(seconds: 30));
      await cubit.check();
      expect(service.calls, 1);
      now = now.add(const Duration(seconds: 31));
      service.results.add(_release('0.5.0', '0.4.0'));
      await cubit.check();
      expect(service.calls, 2);
      expect(cubit.state, isA<LatestReleaseLoaded>());
    });
  });

  group('installed app version', () {
    tearDown(InstalledAppVersion.reset);

    test('reads the platform version and drops build suffixes', () async {
      await InstalledAppVersion.load(
        readPackageInfo: () async => PackageInfo(
          appName: 'Wakaranai Debug',
          packageName: 'io.github.sayuri192.wakaranai.debug',
          version: '0.4.0-debug',
          buildNumber: '9',
        ),
      );
      expect(InstalledAppVersion.current, '0.4.0');
    });

    test('falls back to the .env value when the platform has no answer', () async {
      dotenv.testLoad(fileInput: 'CURRENT_APP_VERSION=0.3.1');
      await InstalledAppVersion.load(
        readPackageInfo: () async => throw StateError('no platform'),
      );
      expect(InstalledAppVersion.current, '0.3.1');
    });
  });
}
