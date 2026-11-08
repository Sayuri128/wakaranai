import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';

typedef DownloadProgressReporter = Future<void> Function(
  DownloadJob job, {
  required int progress,
  required int max,
});

typedef DownloadDeletionCheck = bool Function(String uid);

abstract class DownloadJobRunner<J extends DownloadJob> {
  DownloadJobRunner({
    required this.downloadRepository,
    required this.reportProgress,
  });

  static const Duration progressPersistInterval = Duration(milliseconds: 700);

  final DownloadRepository downloadRepository;
  final DownloadProgressReporter reportProgress;

  Future<bool> run(J job);

  Future<void> markFailed(String uid) async {
    final DownloadDomain? current = await downloadRepository.getByUid(uid);
    if (current != null) {
      await downloadRepository
          .update(current.copyWith(status: DownloadStatus.failed));
    }
  }
}
