import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/data/domain/extension/extension_source_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_source_repository/extension_source_repository.dart';
import 'package:wakaranai/repositories/shared_pref/default_extension_source_repository/default_extension_source_repository.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_result.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

part 'extension_sources_state.dart';

class ExtensionSourcesCubit extends Cubit<ExtensionSourcesState> {
  ExtensionSourcesCubit({
    required this.database,
  }) : super(ExtensionSourcesInitial()) {
    _extensionSourceRepository = ExtensionSourceRepository(database);
  }

  final WakaranaiDatabase database;
  late final ExtensionSourceRepository _extensionSourceRepository;

  Future<void> init() async {
    emit(ExtensionSourcesLoading());

    try {
      final repositories = await _extensionSourceRepository.getAll();

      emit(ExtensionSourcesLoaded(
        repositories: repositories,
      ));
    } catch (e) {
      emit(ExtensionSourcesError(
        message: S.current.extension_sources_page_error_loading_sources,
      ));
    }
  }

  Future<void> delete(
      BuildContext context, ExtensionSourceDomain domain) async {
    emit(ExtensionSourcesLoading());

    final res = await _extensionSourceRepository.delete(domain);

    if (res == null) {
      SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.extension_source_page_error_removing_source);
    }

    await init();
  }

  Future<void> update(
      BuildContext context, ExtensionSourceDomain domain) async {
    emit(ExtensionSourcesLoading());

    final res = await _extensionSourceRepository.update(domain);

    if (res == null) {
      SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.extension_source_page_error_updating_source);
    }

    await init();
  }

  Future<void> add(BuildContext context, AddExtensionPageResult data) async {
    emit(ExtensionSourcesLoading());

    final res = await _extensionSourceRepository.create(
      ExtensionSourceDomain(
        id: 0,
        name: data.name,
        url: data.url,
        type: data.type,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (res == null) {
      SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.extension_source_page_error_adding_source);
    }

    await init();
  }
}
