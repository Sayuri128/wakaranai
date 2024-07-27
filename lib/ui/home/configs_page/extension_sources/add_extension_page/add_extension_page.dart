import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_arguments.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/add_extension_page/add_extension_page_result.dart';
import 'package:wakaranai/ui/widgets/elevated_appbar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.of(context).pop(
              AddExtensionPageResult(
                name: _nameController.text,
                url: _urlController.text,
                type: widget.arguments.type,
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: CustomScrollView(
          slivers: [
            ElevatedAppbar(
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
                widget.arguments.update
                    ? S.current.add_extension_source_page_appbar_edit_title
                    : S.current.add_extension_source_page_appbar_title,
                style: medium(size: 24),
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 48,
                    ),
                    OutlinedTextFormField(
                      controller: _urlController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.current
                              .add_extension_source_page_url_field_error_text;
                        }

                        final githubParser = GithubUrlParser(url: value);
                        if (githubParser.parse() == null) {
                          return S.current
                              .add_extension_source_page_url_field_error_text;
                        }

                        return null;
                      },
                      title:
                          S.current.add_extension_source_page_url_field_label,
                      hint: S.current
                          .add_extension_source_page_url_field_hint_text,
                    ),
                    const SizedBox(
                      height: 48,
                    ),
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
          ],
        ),
      ),
    );
  }
}
