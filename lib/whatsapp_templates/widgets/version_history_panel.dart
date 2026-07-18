import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import '../controllers/template_builder_controller.dart';
import 'custom_button.dart';

void showVersionHistoryDialog(BuildContext context, TemplateBuilderController controller) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final ctrl = controller;
              final versions = ctrl.current.versionHistory.reversed.toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version History', style: AppTextStyles.headline(context)),
                  const SizedBox(height: 12),
                  if (versions.isEmpty)
                    Text('No saved versions yet', style: AppTextStyles.caption(context, color: AppColors.textSecondary)),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: versions.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final v = versions[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.action == 'submit_to_meta' ? 'Submitted to Meta' : 'Draft saved',
                                    style: AppTextStyles.body(context, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    v.snapshotAt != null
                                        ? DateFormat('dd MMM yyyy, hh:mm a').format(v.snapshotAt!)
                                        : '-',
                                    style: AppTextStyles.caption(context, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            CustomButton(
                              label: 'Restore',
                              outlined: true,
                              onPressed: () async {
                                await ctrl.restoreVersionLocally(v);
                                Navigator.of(context).pop();
                                showCustomToast(context, 'Version restored — remember to Save Draft');
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close', style: AppTextStyles.body(context, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
