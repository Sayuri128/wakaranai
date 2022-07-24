import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/history/history_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/widgets/history_group_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is! HistoryInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
                itemCount: 1 + state.groups.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).padding.top + 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            S.current.history_page_title,
                            style: semibold(size: 18),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).padding.top + 20)
                      ],
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: HistoryGroupWidget(
                        group: state.groups[index - 1],
                        showAll: state.expanded[index - 1]!,
                        index: index - 1),
                  );
                }),
          );
        },
      ),
    );
  }
}
