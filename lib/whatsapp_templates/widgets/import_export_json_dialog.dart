import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import '../controllers/template_builder_controller.dart';
import 'custom_button.dart';

Future<void> showExportJsonDialog(BuildContext context, TemplateBuilderController controller) {
  final jsonText = controller.exportJson();
  return showDialog(
    context: context,
    builder: (context) => _JsonDialog(
      title: 'Export Template JSON',
      initialText: jsonText,
      readOnly: true,
      primaryActionLabel: 'Copy to Clipboard',
      onPrimaryAction: (text) {
        Clipboard.setData(ClipboardData(text: text));
        showCustomToast(context, 'Copied to clipboard');
      },
    ),
  );
}

Future<void> showImportJsonDialog(BuildContext context, TemplateBuilderController controller) {
  return showDialog(
    context: context,
    builder: (context) => _JsonDialog(
      title: 'Import Template JSON',
      initialText: '',
      readOnly: false,
      primaryActionLabel: 'Import',
      onPrimaryAction: (text) {
        final error = controller.importJson(text);
        if (error != null) {
          showCustomToast(context, error);
        } else {
          Navigator.of(context).pop();
          showCustomToast(context, 'Template imported');
        }
      },
    ),
  );
}

class _JsonDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final bool readOnly;
  final String primaryActionLabel;
  final ValueChanged<String> onPrimaryAction;

  const _JsonDialog({
    required this.title,
    required this.initialText,
    required this.readOnly,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  @override
  State<_JsonDialog> createState() => _JsonDialogState();
}

class _JsonDialogState extends State<_JsonDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: AppTextStyles.headline(context)),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: TextField(
                  controller: _controller,
                  readOnly: widget.readOnly,
                  maxLines: 12,
                  style: AppTextStyles.caption(context),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'Paste template JSON here',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: AppTextStyles.body(context, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    label: widget.primaryActionLabel,
                    onPressed: () => widget.onPrimaryAction(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
