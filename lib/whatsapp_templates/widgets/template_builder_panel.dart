import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';
import 'body_editor_widget.dart';
import 'buttons_section_widget.dart';
import 'footer_section_widget.dart';
import 'header_section_widget.dart';
import 'import_export_json_dialog.dart';
import 'variables_panel_widget.dart';
import 'version_history_panel.dart';

const Map<String, String> kCategoryLabels = {
  'MARKETING': 'Marketing',
  'UTILITY': 'Utility',
  'AUTHENTICATION': 'Authentication',
};

const Map<String, String> kTemplateTypeLabels = {
  'TEXT': 'Text',
  'MEDIA': 'Media',
  'CAROUSEL': 'Carousel',
  'INTERACTIVE': 'Interactive',
};

const List<String> kLanguageOptions = [
  'English',
  'Hindi',
  'Tamil',
  'Telugu',
  'Kannada',
  'Malayalam',
  'Marathi',
  'Gujarati',
  'Bengali',
  'Punjabi',
];

class TemplateBuilderPanel extends StatelessWidget {
  final TemplateBuilderController controller;

  const TemplateBuilderPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Template Builder', style: AppTextStyles.headline(context)),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Version History',
                        icon: const Icon(Icons.history, color: AppColors.primary),
                        onPressed: () => showVersionHistoryDialog(context, controller),
                      ),
                      IconButton(
                        tooltip: 'Import JSON',
                        icon: const Icon(Icons.file_upload_outlined, color: AppColors.primary),
                        onPressed: () => showImportJsonDialog(context, controller),
                      ),
                      IconButton(
                        tooltip: 'Export JSON',
                        icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                        onPressed: () => showExportJsonDialog(context, controller),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Template Name',
                controller: controller.nameController,
                onTap: () {},
                validator: (_) => null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomDropdownField(
                      hint: 'Category',
                      items: kCategoryLabels.values.toList(),
                      selectedValue: kCategoryLabels[controller.current.category],
                      onChanged: (value) {
                        final key = kCategoryLabels.entries.firstWhere((e) => e.value == value).key;
                        controller.current.category = key;
                        controller.update();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomDropdownField(
                      hint: 'Language',
                      items: kLanguageOptions,
                      selectedValue: kLanguageOptions.contains(controller.current.language)
                          ? controller.current.language
                          : null,
                      onChanged: (value) {
                        controller.current.language = value ?? 'English';
                        controller.update();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomDropdownField(
                      hint: 'Template Type',
                      items: kTemplateTypeLabels.values.toList(),
                      selectedValue: kTemplateTypeLabels[controller.current.templateType],
                      onChanged: (value) {
                        final key = kTemplateTypeLabels.entries.firstWhere((e) => e.value == value).key;
                        controller.current.templateType = key;
                        controller.update();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (controller.current.templateType == 'CAROUSEL')
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.view_carousel_outlined, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Carousel editing is coming soon. This template will be saved as a draft placeholder for now.',
                          style: AppTextStyles.caption(context, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderSectionWidget(controller: controller),
                    const SizedBox(height: 18),
                    BodyEditorWidget(controller: controller),
                    const SizedBox(height: 12),
                    VariablesPanelWidget(controller: controller),
                    const SizedBox(height: 18),
                    FooterSectionWidget(controller: controller),
                    const SizedBox(height: 18),
                    ButtonsSectionWidget(controller: controller),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
