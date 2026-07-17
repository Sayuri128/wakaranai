import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_arguments.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_result.dart';
import 'package:wakaranai/ui/widgets/outlined_text_form_field.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/github_url_parser.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AddExtensionPage extends StatefulWidget {
  const AddExtensionPage({
    super.key,
    required this.arguments,
  });

  final AddExtensionPageArguments arguments;

  @override
  State<AddExtensionPage> createState() => _AddExtensionPageState();
}

class _AddExtensionPageState extends State<AddExtensionPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _branches = <String>[];
  String? _selectedRef;
  bool _fetchingBranches = false;
  String? _fetchError;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.arguments.name);
    _urlController = TextEditingController(text: widget.arguments.url);
    _selectedRef = widget.arguments.ref;
    if (_selectedRef != null && _selectedRef!.isNotEmpty) {
      _branches = <String>[_selectedRef!];
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _fetchBranches() async {
    final parsed = GithubUrlParser(url: _urlController.text).parse();
    if (parsed == null) {
      setState(() {
        _fetchError =
            S.current.add_extension_source_page_branch_invalid_url_error;
      });
      return;
    }

    setState(() {
      _fetchingBranches = true;
      _fetchError = null;
    });

    try {
      final List<String> branches =
          await GitHubConfigsService.fetchBranches(parsed.org, parsed.repo);
      if (!mounted) return;
      setState(() {
        _branches = <String>{
          if (_selectedRef != null && _selectedRef!.isNotEmpty) _selectedRef!,
          ...branches,
        }.toList();
        _fetchingBranches = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _fetchingBranches = false;
        _fetchError = S.current.add_extension_source_page_branch_fetch_error;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(
        AddExtensionPageResult(
          name: _nameController.text,
          url: _urlController.text,
          ref: (_selectedRef != null && _selectedRef!.isNotEmpty)
              ? _selectedRef
              : null,
          type: widget.arguments.type,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: _buildSubmitButton(),
      body: CustomScrollView(
        slivers: <Widget>[
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.current.add_extension_source_page_description,
                      style: regular(size: 14, color: AppColors.mainGrey),
                    ),
                    const SizedBox(height: 28),
                    OutlinedTextFormField(
                      controller: _urlController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.current
                              .add_extension_source_page_url_field_error_text;
                        }
                        if (GithubUrlParser(url: value).parse() == null) {
                          return S.current
                              .add_extension_source_page_url_field_error_text;
                        }
                        return null;
                      },
                      title: S.current.add_extension_source_page_url_field_label,
                      hint: S
                          .current.add_extension_source_page_url_field_hint_text,
                    ),
                    const SizedBox(height: 20),
                    OutlinedTextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.current
                              .add_extension_source_page_name_field_error_text;
                        }
                        return null;
                      },
                      title:
                          S.current.add_extension_source_page_name_field_label,
                      hint: S.current
                          .add_extension_source_page_name_field_hint_text,
                    ),
                    const SizedBox(height: 20),
                    _buildBranchSelector(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _buildBranchDropdown()),
            const SizedBox(width: 12),
            _buildFetchButton(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _fetchError ??
              S.current.add_extension_source_page_branch_helper_text,
          style: regular(
            size: 12,
            color: _fetchError != null ? AppColors.red : AppColors.mainGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedRef,
      isExpanded: true,
      dropdownColor: AppColors.dialogSurface,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(Icons.expand_more_rounded, color: AppColors.mainGrey),
      style: medium(size: 15),
      decoration: InputDecoration(
        labelText: S.current.add_extension_source_page_branch_field_label,
        labelStyle: regular(size: 14, color: AppColors.mainGrey),
        floatingLabelStyle: medium(size: 14, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.overlay(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: _dropdownBorder(AppColors.overlay(0.10)),
        focusedBorder: _dropdownBorder(AppColors.primary, width: 1.5),
      ),
      items: <DropdownMenuItem<String?>>[
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            S.current.add_extension_source_page_branch_default_option,
            style: medium(size: 15, color: AppColors.mainGrey),
          ),
        ),
        ..._branches.map(
          (String branch) => DropdownMenuItem<String?>(
            value: branch,
            child: Text(
              branch,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: medium(size: 15),
            ),
          ),
        ),
      ],
      onChanged: (String? value) {
        setState(() => _selectedRef = value);
      },
    );
  }

  OutlineInputBorder _dropdownBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildFetchButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.overlay(0.06),
          foregroundColor: AppColors.mainWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _fetchingBranches ? null : _fetchBranches,
        child: _fetchingBranches
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Text(
                S.current.add_extension_source_page_branch_fetch_button,
                style: medium(size: 15),
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      foregroundColor: AppColors.mainWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.mainWhite),
      ),
      title: Text(
        widget.arguments.update
            ? S.current.add_extension_source_page_appbar_edit_title
            : S.current.add_extension_source_page_appbar_title,
        style: semibold(size: 22),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _submit,
            child: Text(
              widget.arguments.update
                  ? S.current.add_extension_source_page_update_button_title
                  : S.current.add_extension_source_page_add_button_title,
              style: semibold(size: 16, color: AppColors.mainBlack),
            ),
          ),
        ),
      ),
    );
  }
}
