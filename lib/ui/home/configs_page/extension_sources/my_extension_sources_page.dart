import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/data/domain/database/extension_source_type.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/configs_page/configs_list_skeleton.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_arguments.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_result.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/cubit/extension_sources_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MyExtensionSourcesPage extends StatelessWidget {
  const MyExtensionSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExtensionSourcesCubit(
        extensionSourceRepository: context.read<ExtensionSourceRepository>(),
      )..init(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        floatingActionButton: _buildFloatingActionButton(context),
        body: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(context),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      foregroundColor: AppColors.mainWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.mainWhite),
      ),
      title: Text(
        S.current.extension_sources_page_appbar_title,
        style: semibold(size: 22),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            launchUrl(Uri.parse(
                "https://github.com/${Env.appRepoOrg}/${Env.appRepoName}/blob/master/docs/inapp_docs/external_extension_sources.md"));
          },
          icon: Icon(Icons.info_outline_rounded,
              color: AppColors.mainGrey),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Builder(builder: (context) {
      return FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.mainBlack,
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

  Widget _buildBody() {
    return BlocBuilder<ExtensionSourcesCubit, ExtensionSourcesState>(
        builder: (context, state) {
      if (state is ExtensionSourcesLoading) {
        return const SliverToBoxAdapter(child: ConfigsListSkeleton());
      } else if (state is ExtensionSourcesError) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ServiceViewerMessage(
            icon: Icons.error_outline_rounded,
            title: S.current.extension_sources_page_error_loading_sources,
            actions: <Widget>[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.mainBlack,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () =>
                    context.read<ExtensionSourcesCubit>().init(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(S.current.service_view_retry_button_title),
              ),
            ],
          ),
        );
      } else if (state is ExtensionSourcesLoaded) {
        return SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 96),
          sliver: SliverList.builder(
            itemCount: state.repositories.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                return _buildSourceCard(
                  context,
                  title: S
                      .current.extension_sources_page_wakaranai_github_repo_title,
                  url:
                      "https://github.com/${Env.configsSourceOrg}/${Env.configsSourceRepo}",
                  isDefault: true,
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
                );
              }
              final source = state.repositories[index - 1];
              return _buildSourceCard(
                context,
                title: source.name,
                url: source.url,
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
                          destructive: true,
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
              );
            },
          ),
        );
      } else {
        return const SliverToBoxAdapter(child: SizedBox());
      }
    });
  }

  Widget _buildSourceCard(
    BuildContext context, {
    required String title,
    required String url,
    required VoidCallback onTap,
    bool isDefault = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final Color accent = isDefault ? AppColors.primary : AppColors.mediumLight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDefault ? Icons.verified_rounded : Icons.link_rounded,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              title.trim(),
                              style: semibold(size: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDefault) ...<Widget>[
                            const SizedBox(width: 8),
                            _buildDefaultBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _prettyUrl(url),
                        style: regular(size: 12, color: AppColors.mainGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    splashRadius: 20,
                    icon: Icon(Icons.edit_outlined,
                        color: AppColors.mainGrey, size: 20),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    splashRadius: 20,
                    icon: Icon(Icons.delete_outline_rounded,
                        color: AppColors.red, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        S.current.extension_sources_page_default_badge,
        style: medium(size: 11, color: AppColors.primary),
      ),
    );
  }

  String _prettyUrl(String url) {
    return url
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'/$'), '');
  }
}
