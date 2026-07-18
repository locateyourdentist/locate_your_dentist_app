import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';
import '../models/whatsapp_template_model.dart';
import 'button_editor_tile.dart';
import 'custom_button.dart';

class ButtonsSectionWidget extends StatelessWidget {
  final TemplateBuilderController controller;

  const ButtonsSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final buttons = controller.current.buttons;
    final atLimit = buttons.length >= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buttons (${buttons.length}/10)', style: AppTextStyles.subtitle(context)),
            CustomButton(
              label: 'Add Button',
              icon: Icons.add,
              outlined: true,
              onPressed: atLimit
                  ? null
                  : () => controller.addButton(WhatsappTemplateButton(type: 'QUICK_REPLY')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (buttons.isEmpty)
          Text('No buttons added yet', style: AppTextStyles.caption(context, color: AppColors.textSecondary)),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: buttons.length,
          onReorder: controller.reorderButtons,
          itemBuilder: (context, index) {
            return ButtonEditorTile(
              key: ValueKey('button_tile_$index'),
              index: index,
              button: buttons[index],
              onChanged: (updated) => controller.updateButton(index, updated),
              onRemove: () => controller.removeButton(index),
            );
          },
        ),
      ],
    );
  }
}
