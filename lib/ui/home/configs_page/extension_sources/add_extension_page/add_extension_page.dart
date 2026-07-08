import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
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

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.arguments.name);
    _urlController = TextEditingController(text: widget.arguments.url);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(
        AddExtensionPageResult(
          name: _nameController.text,
          url: _urlController.text,
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
                  ],
                ),
              ),
            ),
          ),
        ],
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
