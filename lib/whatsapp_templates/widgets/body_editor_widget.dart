import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';

const int kBodyMaxLength = 1024;

class BodyEditorWidget extends StatelessWidget {
  final TemplateBuilderController controller;

  const BodyEditorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final length = controller.bodyController.text.length;
    final overLimit = length > kBodyMaxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Body', style: AppTextStyles.subtitle(context)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: overLimit ? AppColors.error : Colors.white, width: 1.5),
          ),
          child: TextField(
            controller: controller.bodyController,
            maxLines: 8,
            style: AppTextStyles.caption(context),
            decoration: const InputDecoration(
              hintText: 'Hello {{1}}, your appointment with {{2}} is confirmed.',
              contentPadding: EdgeInsets.all(14),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$length/$kBodyMaxLength',
            style: AppTextStyles.caption(
              context,
              color: overLimit ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
