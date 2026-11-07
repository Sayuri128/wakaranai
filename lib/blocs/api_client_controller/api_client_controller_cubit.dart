import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/services/configs_service/extension_compatibility.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';

part 'api_client_controller_state.dart';

typedef ResolvedExtensionScript = ({String script, ConfigInfo config});

class ApiClientControllerCubit<T extends ApiClient, C>
    extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({
    required this.extensionRepository,
    required this.remoteConfig,
    required this.remoteConfigsCubit,
  }) : super(const ApiClientControllerState());

  final RemoteConfigsCubit remoteConfigsCubit;
  final ExtensionRepository extensionRepository;
  final BaseExtension? remoteConfig;

  Future<void> buildApiClient() async {
    final BaseExtension? extension = remoteConfig;

    if (extension == null) {
      emit(ApiClientControllerError(message: 'No extension was selected'));
      return;
    }

    if (state is ApiClientControllerError) {
      emit(const ApiClientControllerState());
    }

    try {
      final ResolvedExtensionScript resolved = await _resolveScript(extension);
      final ConfigInfo config = resolved.config;

      final ApiClient client = ApiClientFactory.instance
          .create(config: config, code: resolved.script);

      if (isClosed) return;

      switch (config.type) {
        case ConfigInfoType.ANIME:
          emit(ApiClientControllerInitialized<AnimeApiClient>(
              apiClient: client as AnimeApiClient, configInfo: config));
          break;
        case ConfigInfoType.MANGA:
          emit(ApiClientControllerInitialized<MangaApiClient>(
              apiClient: client as MangaApiClient, configInfo: config));
          break;
      }
    } on ExtensionRequiresNewerAppException catch (e) {
      logger.w('Not building ${e.extensionName}: it needs a newer app');
      if (isClosed) return;
      emit(ApiClientControllerRequiresNewerApp(
        message: S.current.compat_requires_newer_app,
        compatibility: e.compatibility,
      ));
    } catch (e, s) {
      logger.e('Failed to build api client for ${remoteConfig?.config.uid}: $e');
      logger.e(s);
      if (isClosed) return;
      emit(ApiClientControllerError(message: e.toString()));
    }
  }

  Future<ResolvedExtensionScript> _resolveScript(
      BaseExtension extension) async {
    if (extension is ExtensionDomain) {
      return (script: extension.sourceCode, config: extension.config);
    }

    if (extension is RemoteConfig) {
      return _resolveRemoteScript(extension);
    }

    throw Exception('Invalid remote config type ${extension.runtimeType}');
  }

  Future<ResolvedExtensionScript> _resolveRemoteScript(
      RemoteConfig extension) async {
    final ExtensionDomain? cached =
        await extensionRepository.getByUid(extension.config.uid);

    final ExtensionCompatibility compatibility = extension.compatibility;
    if (compatibility.requiresNewerApp) {
      if (cached != null) {
        return (script: cached.sourceCode, config: cached.config);
      }
      throw ExtensionRequiresNewerAppException(
        extensionName: extension.config.name,
        compatibility: compatibility,
      );
    }

    if (cached != null &&
        extension.revision != null &&
        cached.revision == extension.revision) {
      return (script: cached.sourceCode, config: extension.config);
    }

    final String script = (await remoteConfigsCubit.configService
            .getRemoteScript(extension.path))
        .script;

    await extensionRepository.createUpdateByUid(
      ExtensionDomain(
        id: 0,
        config: extension.config,
        sourceCode: script,
        revision: extension.revision,
        createdAt: DateTime.now(),
      ),
    );

    return (script: script, config: extension.config);
  }
}
