import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakaranai/main.dart';

enum DocumentReadinessStep { ready, keepPolling, settleThenProceed, giveUp }

class DocumentReadiness {
  const DocumentReadiness._();

  static const String completeState = 'complete';
  static const String interactiveState = 'interactive';

  static const Duration pollInterval = Duration(milliseconds: 100);
  static const Duration interactiveSettleDelay = Duration(milliseconds: 500);
  static const int interactivePollsBeforeSettle = 3;
  static const int maxPolls = 50;

  static const String _readyStateScript = 'document.readyState';

  static DocumentReadinessStep nextStep({
    required String? readyState,
    required int polls,
  }) {
    if (readyState == completeState) {
      return DocumentReadinessStep.ready;
    }
    if (readyState == interactiveState &&
        polls > interactivePollsBeforeSettle) {
      return DocumentReadinessStep.settleThenProceed;
    }
    if (polls > maxPolls) {
      return DocumentReadinessStep.giveUp;
    }
    return DocumentReadinessStep.keepPolling;
  }

  static Future<void> waitFor(InAppWebViewController controller) async {
    int polls = 0;
    String? readyState = await _readState(controller);
    while (true) {
      final DocumentReadinessStep step = nextStep(
        readyState: readyState,
        polls: polls,
      );
      switch (step) {
        case DocumentReadinessStep.ready:
          return;
        case DocumentReadinessStep.settleThenProceed:
          await Future<void>.delayed(interactiveSettleDelay);
          return;
        case DocumentReadinessStep.giveUp:
          logger.w('Document never became ready, last state: $readyState');
          return;
        case DocumentReadinessStep.keepPolling:
          await Future<void>.delayed(pollInterval);
          readyState = await _readState(controller);
          polls++;
      }
    }
  }

  static Future<String?> _readState(InAppWebViewController controller) async {
    try {
      final dynamic value = await controller.evaluateJavascript(
        source: _readyStateScript,
      );
      if (value is String) {
        return value;
      }
      return null;
    } catch (e) {
      logger.w('Failed to read document.readyState: $e');
      return null;
    }
  }
}
