import 'package:flutter/widgets.dart';

class LocaleRebuildScope extends StatefulWidget {
  const LocaleRebuildScope({super.key, required this.child});

  final Widget child;

  @override
  State<LocaleRebuildScope> createState() => _LocaleRebuildScopeState();
}

class _LocaleRebuildScopeState extends State<LocaleRebuildScope> {
  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Locale locale = Localizations.localeOf(context);
    final Locale? previous = _locale;
    _locale = locale;
    if (previous != null && previous != locale) {
      _rebuildDescendants();
    }
  }

  void _rebuildDescendants() {
    void markForRebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markForRebuild);
    }

    (context as Element).visitChildren(markForRebuild);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
