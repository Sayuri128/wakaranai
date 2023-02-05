import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/configs_sources/configs_sources_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakaranai/ui/widgets/primary_input_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AddConfigsSourceDialog extends StatefulWidget {
  const AddConfigsSourceDialog({Key? key}) : super(key: key);

  @override
  State<AddConfigsSourceDialog> createState() => _AddConfigsSourceDialogState();
}

class _AddConfigsSourceDialogState extends State<AddConfigsSourceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  ConfigsSourceType _configsSourceType = ConfigsSourceType.GIT_HUB;
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(32.0),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("New source", style: regular(size: 18)),
            const SizedBox(
              height: 12.0,
            ),
            DropdownButtonFormField<ConfigsSourceType>(
                value: _configsSourceType,
                style: medium(),
                hint: const Text("Type"),
                icon: const Icon(Icons.arrow_drop_down_rounded),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide:
                            const BorderSide(color: Colors.transparent))),
                items: ConfigsSourceType.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          alignment: Alignment.center,
                          child: Text(configsSourceTypeToString(e),
                              textAlign: TextAlign.center, style: medium()),
                        ))
                    .toList(),
                onChanged: (ConfigsSourceType? mode) {
                  if (mode != null) {
                    _configsSourceType = mode;
                  }
                  setState(() {});
                }),
            const SizedBox(
              height: 12,
            ),
            PrimaryInputWidget(
              controller: _nameController,
              label: S.current.new_configs_name_field_label,
              validator: (value) {
                return value == null || value.isEmpty
                    ? S.current.new_configs_name_required_error
                    : null;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            PrimaryInputWidget(
              controller: _baseUrlController,
              label: S.current.new_configs_base_url_field_label,
              validator: (value) {
                return value == null || value.isEmpty
                    ? S.current.new_configs_base_url_required_error
                    : null;
              },
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.primary)),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<ConfigsSourcesCubit>().create(
                              ConfigsSourceItem(
                                  baseUrl: _baseUrlController.text,
                                  name: _nameController.text,
                                  type: _configsSourceType));
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        S.current.create_new_configs_source_button,
                        style: regular(color: AppColors.mainWhite),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
