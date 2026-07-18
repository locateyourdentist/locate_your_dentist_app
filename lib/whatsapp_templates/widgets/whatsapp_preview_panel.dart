import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';
import '../models/whatsapp_template_model.dart';
import 'button_editor_tile.dart';

String _withSampleValues(String text) {
  return text.replaceAllMapped(
    RegExp(r'\{\{(\d+)\}\}'),
    (m) => 'Sample Value ${m.group(1)}',
  );
}

IconData _buttonIcon(String type) {
  switch (type) {
    case 'CALL':
      return Icons.call;
    case 'WEBSITE':
    case 'DYNAMIC_URL':
      return Icons.open_in_new;
    case 'COPY_CODE':
      return Icons.copy;
    default:
      return Icons.reply;
  }
}

class WhatsappPreviewPanel extends StatefulWidget {
  final TemplateBuilderController controller;

  const WhatsappPreviewPanel({super.key, required this.controller});

  @override
  State<WhatsappPreviewPanel> createState() => _WhatsappPreviewPanelState();
}

class _WhatsappPreviewPanelState extends State<WhatsappPreviewPanel> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final t = ctrl.current;
        final chatBg = darkMode ? const Color(0xFF0B141A) : const Color(0xFFECE5DD);
        final bubbleColor = darkMode ? const Color(0xFF202C33) : Colors.white;
        final textColor = darkMode ? Colors.white70 : AppColors.textPrimary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Live Preview', style: AppTextStyles.subtitle(context)),
                Row(
                  children: [
                    Icon(darkMode ? Icons.dark_mode : Icons.light_mode, size: 16, color: AppColors.textSecondary),
                    Switch(
                      value: darkMode,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => darkMode = v),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black26, width: 6),
                color: chatBg,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF075E54),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.storefront, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Locate Your Dentist',
                            style: AppTextStyles.body(context, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.call, color: Colors.white70, size: 18),
                        const SizedBox(width: 12),
                        const Icon(Icons.more_vert, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderPreview(context, t, textColor),
                              if (t.body.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _withSampleValues(t.body),
                                    style: AppTextStyles.caption(context, color: textColor),
                                  ),
                                ),
                              if (t.footer != null && t.footer!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    t.footer!,
                                    style: AppTextStyles.caption(context, color: AppColors.textSecondary),
                                  ),
                                ),
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('12:00 PM', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (t.buttons.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Container(
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: t.buttons.map((btn) {
                                final label = btn.text?.isNotEmpty == true
                                    ? btn.text!
                                    : kButtonTypeLabels[btn.type] ?? 'Button';
                                return InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(top: BorderSide(color: Colors.black12)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_buttonIcon(btn.type), size: 15, color: AppColors.secondary),
                                        const SizedBox(width: 6),
                                        Text(
                                          label,
                                          style: AppTextStyles.caption(context, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderPreview(BuildContext context, WhatsappTemplateModel t, Color textColor) {
    switch (t.headerType) {
      case 'TEXT':
        return Text(
          t.headerText ?? '',
          style: AppTextStyles.body(context, color: textColor, fontWeight: FontWeight.w700),
        );
      case 'IMAGE':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image, color: Colors.grey, size: 32),
          ),
        );
      case 'VIDEO':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey.shade800,
            child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
          ),
        );
      case 'DOCUMENT':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Document.pdf',
                  style: AppTextStyles.caption(context, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
