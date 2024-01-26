import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/data/domain/extension/extension_source_type.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_arguments.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_result.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/cubit/extension_sources_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/elevated_appbar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MyExtensionSourcesPage extends StatelessWidget {
  const MyExtensionSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExtensionSourcesCubit(database: context.read<WakaranaiDatabase>())
            ..init(),
      child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          floatingActionButton: _buildFloatingActionButton(context),
          appBar: PreferredSize(
            preferredSize: const Size(60, double.maxFinite),
            child: ElevatedAppbar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.mainWhite,
                ),
              ),
              title: Text(
                S.current.extension_sources_page_appbar_title,
                style: medium(
                  size: 24,
                ),
              ),
              actions: IconButton(
                onPressed: () {
                  launchUrl(Uri.parse(
                      "https://github.com/${Env.appRepoOrg}/${Env.appRepoName}/blob/master/docs/inapp_docs/external_extension_sources.md"));
                },
                icon: const Icon(Icons.info),
              ),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 24,
              ),
              Builder(builder: (context) {
                return Expanded(
                  child: _buildBody(),
                );
              })
            ],
          )),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Builder(builder: (context) {
      return FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context)
              .pushNamed(
            Routes.addExtensionSource,
            arguments: const AddExtensionPageArguments(
              name: '',
              url: '',
              type: ExtensionSourceType.github,
            ),
          )
              .then((res) {
            if (res is AddExtensionPageResult) {
              context.read<ExtensionSourcesCubit>().add(context, res);
            }
          });
        },
        child: const Icon(Icons.add),
      );
    });
  }

  BlocBuilder<ExtensionSourcesCubit, ExtensionSourcesState> _buildBody() {
    return BlocBuilder<ExtensionSourcesCubit, ExtensionSourcesState>(
        builder: (context, state) {
      if (state is ExtensionSourcesLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      } else if (state is ExtensionSourcesLoaded) {
        return ListView.builder(
          itemCount: state.repositories.length + 1,
          itemBuilder: (_, index) {
            if (index == 0) {
              return _buildItem(
                  onTap: () {
                    Navigator.of(context).pop(ExtensionSourcesPageResult(
                      id: null,
                      url:
                          "https://github.com/${Env.configsSourceOrg}/${Env.configsSourceRepo}",
                      type: ExtensionSourceType.github,
                      name: S.current
                          .extension_sources_page_wakaranai_github_repo_title,
                    ));
                  },
                  title: S.current
                      .extension_sources_page_wakaranai_github_repo_title);
            }
            final source = state.repositories[index - 1];
            return _buildItem(
              onTap: () {
                Navigator.of(context).pop(
                  ExtensionSourcesPageResult(
                    id: source.id,
                    url: source.url,
                    type: source.type,
                    name: source.name,
                  ),
                );
              },
              onEdit: () {
                Navigator.of(context)
                    .pushNamed(
                  Routes.addExtensionSource,
                  arguments: AddExtensionPageArguments(
                    name: source.name,
                    url: source.url,
                    type: source.type,
                    update: true,
                  ),
                )
                    .then((res) {
                  if (res is AddExtensionPageResult) {
                    context.read<ExtensionSourcesCubit>().update(
                          context,
                          source.copyWith(
                            name: res.name,
                            url: res.url,
                            type: res.type,
                          ),
                        );
                  }
                });
              },
              onDelete: () {
                showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                        title: S.current
                            .extension_source_page_remove_source_dialog_title,
                        message: S.current
                            .extension_source_page_remove_source_dialog_message,
                        yesText: S.current
                            .extension_source_page_remove_source_dialog_ok_label,
                        noText: S.current
                            .extension_source_page_remove_source_dialog_cancel_label)).then(
                    (res) {
                  if (res == true) {
                    context
                        .read<ExtensionSourcesCubit>()
                        .delete(context, source);
                  }
                });
              },
              title: source.name,
            );
          },
        );
      } else {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.current.extension_sources_page_error_loading_sources,
                style: semibold(
                  size: 18,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                  onPressed: () {
                    context.read<ExtensionSourcesCubit>().init();
                  },
                  icon: const Icon(Icons.restart_alt))
            ],
          ),
        );
      }
    });
  }

  ListTile _buildItem({
    required String title,
    required VoidCallback onTap,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    return ListTile(
      title: Text(
        title,
        style: semibold(size: 16),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit,
                color: AppColors.mainGrey,
              ),
            ),
          const SizedBox(
            width: 4,
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete,
                color: AppColors.red,
              ),
            )
        ],
      ),
      onTap: onTap,
    );
  }
}
