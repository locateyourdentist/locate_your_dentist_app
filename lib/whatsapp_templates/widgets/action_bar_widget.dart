import 'package:flutter/material.dart';
import '../controllers/template_builder_controller.dart';
import '../models/whatsapp_template_model.dart';
import 'custom_button.dart';
import 'validation_result_dialog.dart';
import 'whatsapp_preview_panel.dart';

class ActionBarWidget extends StatelessWidget {
  final TemplateBuilderController controller;
  final List<WhatsappTemplateModel> existingTemplates;
  final VoidCallback? onSaved;

  const ActionBarWidget({
    super.key,
    required this.controller,
    required this.existingTemplates,
    this.onSaved,
  });

  void _openPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: WhatsappPreviewPanel(controller: controller),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final ctrl = controller;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              CustomButton(
                label: 'Save Draft',
                icon: Icons.save_outlined,
                outlined: true,
                isLoading: ctrl.isSaving,
                onPressed: () async {
                  final saved = await ctrl.saveDraft(context, existing: existingTemplates);
                  if (saved) onSaved?.call();
                },
              ),
              CustomButton(
                label: 'Preview',
                icon: Icons.visibility_outlined,
                outlined: true,
                onPressed: () => _openPreviewDialog(context),
              ),
              CustomButton(
                label: 'Validate',
                icon: Icons.fact_check_outlined,
                outlined: true,
                onPressed: () {
                  final results = ctrl.validate(existing: existingTemplates);
                  showValidationResultDialog(context, results);
                },
              ),
              CustomButton(
                label: 'Submit to Meta',
                icon: Icons.send_outlined,
                isLoading: ctrl.isSaving,
                onPressed: () async {
                  final results = ctrl.validate(existing: existingTemplates);
                  if (results.any((r) => !r.passed)) {
                    await showValidationResultDialog(context, results);
                    return;
                  }
                  final submitted = await ctrl.submitToMeta(context, existing: existingTemplates);
                  if (submitted) onSaved?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
