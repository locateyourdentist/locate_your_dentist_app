import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';
import '../utils/whatsapp_template_validator.dart';

class VariablesPanelWidget extends StatelessWidget {
  final TemplateBuilderController controller;

  const VariablesPanelWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final numbers = WhatsappTemplateValidator.extractVariableNumbers(
      controller.bodyController.text,
    ).toSet().toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variables', style: AppTextStyles.subtitle(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...numbers.map(
              (n) => Chip(
                label: Text('{{$n}}', style: AppTextStyles.caption(context, color: AppColors.white)),
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: Text('Add Variable', style: AppTextStyles.caption(context, color: AppColors.primary)),
              backgroundColor: AppColors.primaryLight,
              onPressed: controller.insertVariableAtCursor,
            ),
          ],
        ),
      ],
    );
  }
}
