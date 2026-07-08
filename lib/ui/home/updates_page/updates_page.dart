import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/data/entities/library_update_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<LibraryUpdatesCubit, LibraryUpdatesState>(
          builder: (BuildContext context, LibraryUpdatesState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHeader(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LibraryUpdatesState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(S.current.updates_title, style: semibold(size: 24)),
          ),
          if (state.updates.isNotEmpty) ...<Widget>[
            _HeaderAction(
              icon: Icons.done_all_rounded,
              tooltip: S.current.updates_mark_all_seen,
              onTap: () => context.read<LibraryUpdatesCubit>().markAllSeen(),
            ),
            const SizedBox(width: 8),
            _HeaderAction(
              icon: Icons.delete_sweep_outlined,
              tooltip: S.current.updates_clear,
              onTap: () => context.read<LibraryUpdatesCubit>().clearAll(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryUpdatesState state) {
    if (state.updates.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.notifications_none_rounded,
        title: S.current.updates_empty_title,
        message: S.current.updates_empty_message,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: state.updates.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final LibraryUpdateDomain update = state.updates[index];
        return Dismissible(
          key: ValueKey<String>(update.uid),
          direction: DismissDirection.endToStart,
          background: _dismissBackground(),
          onDismissed: (DismissDirection _) =>
              context.read<LibraryUpdatesCubit>().dismiss(update.uid),
          child: _UpdateTile(
            update: update,
            onTap: () => _openUpdate(context, update),
          ),
        );
      },
    );
  }

  Widget _dismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.delete_outline_rounded, color: AppColors.red),
    );
  }

  Future<void> _openUpdate(
      BuildContext context, LibraryUpdateDomain update) async {
    final LibraryUpdatesCubit cubit = context.read<LibraryUpdatesCubit>();
    final LibraryEntryRepository repository =
        context.read<LibraryEntryRepository>();

    await cubit.markSeen(update.uid);

    final LibraryEntryDomain? entry =
        await repository.getByUid(update.libraryEntryUid);

    if (entry == null || !context.mounted) return;

    Navigator.of(context).pushNamed(
      Routes.libraryConcreteViewer,
      arguments: LibraryConcreteViewerData(entry: entry),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.update, required this.onTap});

  final LibraryUpdateDomain update;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              _Cover(url: update.concreteCover, mediaType: update.mediaType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      update.concreteTitle,
                      style: medium(size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      update.title,
                      style: regular(size: 13, color: AppColors.mainGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _relativeTime(update.foundAt),
                      style: regular(size: 11, color: AppColors.mainGrey),
                    ),
                  ],
                ),
              ),
              if (!update.seen)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return S.current.updates_time_now;
    if (diff.inHours < 1) return S.current.updates_time_minutes(diff.inMinutes);
    if (diff.inDays < 1) return S.current.updates_time_hours(diff.inHours);
    return S.current.updates_time_days(diff.inDays);
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.mediaType});

  final String? url;
  final UpdateMediaType mediaType;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 64,
        child: url == null
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String _) => _placeholder(),
                errorWidget: (BuildContext context, String _, Object __) =>
                    _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.overlay(0.08),
      child: Center(
        child: Icon(
          mediaType == UpdateMediaType.anime
              ? Icons.movie_outlined
              : Icons.menu_book_rounded,
          color: AppColors.mainGrey,
          size: 22,
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.overlay(0.06),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: AppColors.mainWhite),
          ),
        ),
      ),
    );
  }
}
