import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/gallery_pagination/gallery_pagination.dart';
import 'package:capyscript/modules/waka_models/models/config_info/preferences/extension_preference.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/extension_preferences/extension_preference_values.dart';
import 'package:wakaranai/services/extension_preferences/extension_preferences_store.dart';
import 'package:wakaranai/ui/widgets/outlined_text_form_field.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<bool> showExtensionSettingsSheet(
  BuildContext context, {
  required ConfigInfo config,
  ExtensionPreferencesStore? store,
}) async {
  bool changed = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => ExtensionSettingsSheet(
      config: config,
      store: store ?? ExtensionPreferencesStore.instance,
      onChanged: () {
        changed = true;
      },
    ),
  );
  return changed;
}

class ExtensionSettingsSheet extends StatefulWidget {
  const ExtensionSettingsSheet({
    super.key,
    required this.config,
    required this.store,
    required this.onChanged,
  });

  final ConfigInfo config;
  final ExtensionPreferencesStore store;
  final VoidCallback onChanged;

  @override
  State<ExtensionSettingsSheet> createState() => _ExtensionSettingsSheetState();
}

class _ExtensionSettingsSheetState extends State<ExtensionSettingsSheet> {
  final Map<String, TextEditingController> _textControllers =
      <String, TextEditingController>{};
  Map<String, Object> _stored = <String, Object>{};
  bool _loaded = false;

  String get _uid => widget.config.uid;

  List<ExtensionPreference> get _preferences =>
      editablePreferences(widget.config);

  List<String> get _mirrors => extensionMirrors(widget.config);

  GalleryPagination? get _pagination => widget.config.pagination;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final Map<String, Object> values = await widget.store.readAll(_uid);
    if (!mounted) {
      return;
    }
    setState(() {
      _stored = values;
      _loaded = true;
      _syncTextControllers();
    });
  }

  void _syncTextControllers() {
    for (final ExtensionPreference definition in _preferences) {
      if (!_isTextual(definition)) {
        continue;
      }
      final TextEditingController controller = _textControllers.putIfAbsent(
        definition.key,
        TextEditingController.new,
      );
      controller.text = _displayText(_currentValue(definition));
    }
  }

  bool _isTextual(ExtensionPreference definition) {
    return definition.type == ExtensionPreferenceType.text ||
        definition.type == ExtensionPreferenceType.number;
  }

  Object? _currentValue(ExtensionPreference definition) {
    return ExtensionPreferenceValues.effectiveValue(
      definition,
      _stored[definition.key],
    );
  }

  String? get _currentMirror {
    return ExtensionPreferenceValues.sanitizeMirror(
      _mirrors,
      _stored[ExtensionPreference.mirrorKey],
    );
  }

  int? get _storedPageSize {
    return ExtensionPreferenceValues.sanitizePageSize(
      _pagination,
      _stored[ExtensionPreference.pageSizeKey],
    );
  }

  String _displayText(Object? value) {
    if (value is num) {
      return ExtensionPreferenceValues.formatNumber(value);
    }
    if (value is String) {
      return value;
    }
    return '';
  }

  Future<void> _write(String key, Object value) async {
    setState(() {
      _stored[key] = value;
    });
    widget.onChanged();
    try {
      await widget.store.write(_uid, key, value);
    } catch (e) {
      logger.w('Failed to save extension preference $key: $e');
    }
  }

  Future<void> _remove(String key) async {
    if (!_stored.containsKey(key)) {
      return;
    }
    setState(() {
      _stored.remove(key);
    });
    widget.onChanged();
    await widget.store.remove(_uid, key);
  }

  Future<void> _resetToDefaults() async {
    final bool hadValues = _stored.isNotEmpty;
    await widget.store.clearExtension(_uid);
    if (!mounted) {
      return;
    }
    setState(() {
      _stored = <String, Object>{};
      _syncTextControllers();
    });
    if (hadValues) {
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildHandle(),
              _buildTitle(),
              Flexible(child: _buildContent()),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.current.ext_prefs_sheet_title, style: semibold(size: 18)),
          const SizedBox(height: 2),
          Text(
            widget.config.name.trim(),
            style: regular(size: 13, color: AppColors.mainGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_loaded) {
      return const SizedBox(height: 120);
    }
    final GalleryPagination? pagination = _pagination;
    final List<Widget> sections = <Widget>[
      if (_mirrors.isNotEmpty) _buildMirrorSection(),
      if (pagination != null) _buildPageSizeSection(pagination),
      for (final ExtensionPreference definition in _preferences)
        _buildPreference(definition),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int index = 0; index < sections.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 12),
            sections[index],
          ],
        ],
      ),
    );
  }

  Widget _buildPreference(ExtensionPreference definition) {
    switch (definition.type) {
      case ExtensionPreferenceType.toggle:
        return _buildToggle(definition);
      case ExtensionPreferenceType.select:
        return _buildSelect(definition);
      case ExtensionPreferenceType.multiselect:
        return _buildMultiselect(definition);
      case ExtensionPreferenceType.text:
        return _buildTextField(definition, numeric: false);
      case ExtensionPreferenceType.number:
        return _buildTextField(definition, numeric: true);
    }
  }

  Widget _buildMirrorSection() {
    final String? selected = _currentMirror;
    return _PreferenceCard(
      children: <Widget>[
        _PreferenceHeader(
          title: S.current.ext_prefs_mirror_title,
          summary: S.current.ext_prefs_mirror_summary,
        ),
        _OptionRow(
          label: S.current.ext_prefs_mirror_automatic,
          selected: selected == null,
          onTap: () => _remove(ExtensionPreference.mirrorKey),
        ),
        for (final String mirror in _mirrors)
          _OptionRow(
            label: _mirrorLabel(mirror),
            selected: selected == mirror,
            onTap: () => _write(ExtensionPreference.mirrorKey, mirror),
          ),
      ],
    );
  }

  Widget _buildPageSizeSection(GalleryPagination pagination) {
    final int selected = _storedPageSize ?? pagination.defaultPageSize;
    return _PreferenceCard(
      children: <Widget>[
        _PreferenceHeader(
          title: S.current.ext_prefs_page_size_title,
          summary: S.current.ext_prefs_page_size_summary,
          trailing: _buildResetButtonForKey(ExtensionPreference.pageSizeKey),
        ),
        for (final int pageSize in pagination.pageSizes)
          _OptionRow(
            label: _pageSizeLabel(pagination, pageSize),
            selected: selected == pageSize,
            onTap: () => _selectPageSize(pagination, pageSize),
          ),
      ],
    );
  }

  String _pageSizeLabel(GalleryPagination pagination, int pageSize) {
    if (pageSize == pagination.defaultPageSize) {
      return S.current.ext_prefs_page_size_default_option(pageSize);
    }
    return S.current.ext_prefs_page_size_option(pageSize);
  }

  Future<void> _selectPageSize(GalleryPagination pagination, int pageSize) {
    if (pageSize == pagination.defaultPageSize) {
      return _remove(ExtensionPreference.pageSizeKey);
    }
    return _write(ExtensionPreference.pageSizeKey, pageSize);
  }

  String _mirrorLabel(String mirror) {
    String label = mirror.replaceFirst(RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://'), '');
    while (label.endsWith('/')) {
      label = label.substring(0, label.length - 1);
    }
    return label.isEmpty ? mirror : label;
  }

  Widget _buildToggle(ExtensionPreference definition) {
    final bool enabled = _currentValue(definition) == true;
    return _PreferenceCard(
      children: <Widget>[
        InkWell(
          onTap: () => _write(definition.key, !enabled),
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          child: _PreferenceHeader(
            title: definition.title,
            summary: definition.summary,
            bottomPadding: 14,
            trailing: Switch(
              value: enabled,
              activeThumbColor: AppColors.mainBlack,
              activeTrackColor: AppColors.primary,
              onChanged: (bool value) => _write(definition.key, value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelect(ExtensionPreference definition) {
    final Object? selected = _currentValue(definition);
    return _PreferenceCard(
      children: <Widget>[
        _PreferenceHeader(
          title: definition.title,
          summary: definition.summary,
          trailing: _buildResetButton(definition),
        ),
        for (final ExtensionPreferenceOption option in definition.options)
          _OptionRow(
            label: option.label,
            selected: selected == option.value,
            onTap: () => _write(definition.key, option.value),
          ),
      ],
    );
  }

  Widget _buildMultiselect(ExtensionPreference definition) {
    final Object? current = _currentValue(definition);
    final List<String> selected =
        current is List ? current.map((Object? e) => '$e').toList() : <String>[];
    return _PreferenceCard(
      children: <Widget>[
        _PreferenceHeader(
          title: definition.title,
          summary: definition.summary,
          trailing: _buildResetButton(definition),
        ),
        for (final ExtensionPreferenceOption option in definition.options)
          _CheckRow(
            label: option.label,
            checked: selected.contains(option.value),
            onTap: () => _toggleOption(definition, selected, option.value),
          ),
      ],
    );
  }

  Widget? _buildResetButton(ExtensionPreference definition) {
    return _buildResetButtonForKey(definition.key);
  }

  Widget? _buildResetButtonForKey(String key) {
    if (!_stored.containsKey(key)) {
      return null;
    }
    return IconButton(
      tooltip: S.current.ext_prefs_reset_one,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.restart_alt_rounded,
        size: 20,
        color: AppColors.mainGrey,
      ),
      onPressed: () => _remove(key),
    );
  }

  void _toggleOption(
    ExtensionPreference definition,
    List<String> selected,
    String value,
  ) {
    final List<String> next = List<String>.of(selected);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    final List<String> ordered = definition.options
        .map((ExtensionPreferenceOption option) => option.value)
        .where(next.contains)
        .toList();
    _write(definition.key, ordered);
  }

  Widget _buildTextField(
    ExtensionPreference definition, {
    required bool numeric,
  }) {
    final TextEditingController controller = _textControllers.putIfAbsent(
      definition.key,
      TextEditingController.new,
    );
    final String? summary = definition.summary;
    return _PreferenceCard(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OutlinedTextFormField(
                controller: controller,
                title: definition.title,
                hint: S.current.ext_prefs_default_hint(
                  _displayText(definition.effectiveDefault),
                ),
                keyboardType: numeric
                    ? const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      )
                    : TextInputType.text,
                autovalidateMode:
                    numeric ? AutovalidateMode.onUserInteraction : null,
                obscureText: definition.secret,
                validator: numeric ? _validateNumber : null,
                onChanged: (String text) =>
                    _onTextChanged(definition, text, numeric: numeric),
              ),
              if (summary != null && summary.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    summary,
                    style: regular(size: 12, color: AppColors.mainGrey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String? _validateNumber(String? text) {
    final String value = text ?? '';
    if (value.trim().isEmpty) {
      return null;
    }
    if (ExtensionPreferenceValues.parseNumber(value) == null) {
      return S.current.ext_prefs_number_invalid;
    }
    return null;
  }

  void _onTextChanged(
    ExtensionPreference definition,
    String text, {
    required bool numeric,
  }) {
    if (text.trim().isEmpty) {
      _remove(definition.key);
      return;
    }
    if (!numeric) {
      _write(definition.key, text);
      return;
    }
    final num? parsed = ExtensionPreferenceValues.parseNumber(text);
    if (parsed == null) {
      return;
    }
    _write(definition.key, parsed);
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SheetButton(
              label: S.current.ext_prefs_reset,
              primary: false,
              onTap: _resetToDefaults,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SheetButton(
              label: S.current.ext_prefs_done,
              primary: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _PreferenceHeader extends StatelessWidget {
  const _PreferenceHeader({
    required this.title,
    this.summary,
    this.trailing,
    this.bottomPadding = 6,
  });

  final String title;
  final String? summary;
  final Widget? trailing;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final String? summaryText = summary;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 12, bottomPadding),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: medium(size: 15)),
                if (summaryText != null && summaryText.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    summaryText,
                    style: regular(size: 12, color: AppColors.mainGrey),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: medium(
                  size: 14,
                  color: selected ? AppColors.primary : AppColors.mainWhite,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: medium(size: 14))),
            Checkbox(
              value: checked,
              activeColor: AppColors.primary,
              checkColor: AppColors.mainBlack,
              side: BorderSide(color: AppColors.mainGrey, width: 1.5),
              onChanged: (bool? value) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: semibold(
                size: 15,
                color: primary ? AppColors.mainBlack : AppColors.mainWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
