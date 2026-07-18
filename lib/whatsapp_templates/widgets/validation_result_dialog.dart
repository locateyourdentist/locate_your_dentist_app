import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../models/whatsapp_template_model.dart';
import 'custom_button.dart';

Future<void> showValidationResultDialog(
  BuildContext context,
  List<ValidationCheckResult> results,
) {
  final allPassed = results.every((r) => r.passed);

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    allPassed ? Icons.check_circle : Icons.error_outline,
                    color: allPassed ? AppColors.success : AppColors.error,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    allPassed ? 'Template looks good' : 'Validation failed',
                    style: AppTextStyles.headline(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          r.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: r.passed ? AppColors.success : AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.ruleName, style: AppTextStyles.body(context, fontWeight: FontWeight.w600)),
                              Text(
                                r.message,
                                style: AppTextStyles.caption(context, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
