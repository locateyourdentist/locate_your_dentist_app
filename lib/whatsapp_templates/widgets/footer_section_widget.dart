import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';

class FooterSectionWidget extends StatelessWidget {
  final TemplateBuilderController controller;

  const FooterSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Footer (optional)', style: AppTextStyles.subtitle(context)),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Footer text (max 60 chars)',
          controller: controller.footerController,
          maxLength: 60,
          validator: (_) => null,
          onTap: () {},
        ),
      ],
    );
  }
}
