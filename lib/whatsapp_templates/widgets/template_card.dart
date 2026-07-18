import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../models/whatsapp_template_model.dart';

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return AppColors.success;
    case 'pending':
      return AppColors.warning;
    case 'rejected':
      return AppColors.error;
    default:
      return AppColors.grey;
  }
}

class TemplateCard extends StatelessWidget {
  final WhatsappTemplateModel template;
  final bool selected;
  final VoidCallback onEdit;
  final VoidCallback onClone;
  final VoidCallback onDelete;
  final VoidCallback onPreview;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onEdit,
    required this.onClone,
    required this.onDelete,
    required this.onPreview,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(template.status);
    final dateFmt = DateFormat('dd MMM yyyy');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryLight : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.black12,
          width: selected ? 1.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.templateName.isEmpty
                            ? 'Untitled Template'
                            : template.templateName,
                        style: AppTextStyles.subtitle(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _tag(context, template.category),
                          _tag(context, template.language),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              template.status.toUpperCase(),
                              style: AppTextStyles.caption(context, color: color, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated ${template.updatedDate != null ? dateFmt.format(template.updatedDate!) : '-'}',
                        style: AppTextStyles.caption(context, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'clone':
                        onClone();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                      case 'preview':
                        onPreview();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'clone', child: Text('Clone')),
                    PopupMenuItem(value: 'preview', child: Text('Preview')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppTextStyles.caption(context, color: AppColors.textPrimary)),
    );
  }
}
