import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../api/api.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final userInfo = GetStorage();
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Center(
          child: Text("Logout", style: AppTextStyles.subtitle(context)),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: AppTextStyles.caption(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppTextStyles.caption(context, color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              userInfo.erase();
              kIsWeb ? Get.toNamed('/webLoginPage') : Get.toNamed('/loginPage');
            },
            child: Text("LogOut", style: AppTextStyles.caption(context)),
          ),
        ],
      );
    },
  );
}

void showDeleteDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  String title = "",
  String message = "",
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                /// Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(
                    context,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.caption(
                            context,
                            fontWeight: FontWeight.normal,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: AppTextStyles.caption(
                            context,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class CommonDialog {
  static Future<void> showExitDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Exit Confirmation',
            style: AppTextStyles.caption(context),
          ),
          content: Text(
            'Press back again to exit',
            style: AppTextStyles.caption(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No', style: AppTextStyles.caption(context)),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/loginPage');
              },
              child: Text(
                'Yes',
                style: AppTextStyles.caption(context, color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onOkPressed,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(context),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (onOkPressed != null) {
                onOkPressed();
              }
            },
            child: Text(
              'OK',
              style: AppTextStyles.subtitle(context, color: AppColors.white),
            ),
          ),
        ],
      );
    },
  );
}

/// Modern animated popup for payment result screens (mobile + web checkout).
/// [onContinuePressed] runs after the dialog closes on success; defaults to
/// popping back if not provided.
void showPaymentPopupMessage(
  BuildContext ctx,
  bool isPaymentSuccess,
  String message, {
  VoidCallback? onContinuePressed,
}) {
  showGeneralDialog(
    context: ctx,
    barrierDismissible: false,
    barrierLabel: "PaymentDialog",
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: isPaymentSuccess
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isPaymentSuccess ? Icons.check_circle : Icons.cancel,
                      color: isPaymentSuccess ? Colors.green : Colors.red,
                      size: 45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isPaymentSuccess ? 'Payment Successful' : 'Payment Failed',
                  style: AppTextStyles.body(
                    ctx,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    ctx,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (isPaymentSuccess) {
                        if (onContinuePressed != null) {
                          onContinuePressed();
                        } else if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        }
                      } else if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: isPaymentSuccess
                          ? Colors.green
                          : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isPaymentSuccess ? 'CONTINUE' : 'TRY AGAIN',
                      style: AppTextStyles.body(
                        ctx,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

DateTime parseDate(String date) {
  final parts = date.split('-');
  return DateTime(
    int.parse(parts[2]),
    int.parse(parts[1]),
    int.parse(parts[0]),
  );
}

int getDaysLeft(String endDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  int daysLeft = parseDate(endDate).difference(today).inDays;
  print('fd$daysLeft');
  return daysLeft;
}

String? getAlertMessage(String planName, String endDate) {
  int daysLeft = getDaysLeft(endDate);
  if (daysLeft > 7) return null;
  if (daysLeft == 7) return "$planName will expire in 1 week.";
  if (daysLeft == 3) return "$planName will expire in 3 days.";
  if (daysLeft == 1) return "$planName will expire today.";
  if (daysLeft == 0) return "$planName has expired";
  // if (daysLeft < 0) return "$planName has expired.";
  return null;
}

void showPlanAlerts(
  String userId,
  List<Map<String, dynamic>> dataList,
  BuildContext context,
) async {
  final box = GetStorage();

  final today = DateTime.now();
  final todayString = today.toIso8601String().substring(0, 10);

  final lastAlertDate = box.read("lastPlanAlertDate1_$userId");

  // Prevent showing multiple times in same day
  if (lastAlertDate == todayString) return;

  final loginController = Get.put(LoginController());

  final Map<int, List<String>> expiringPlans = {};

  final planList = {
    "basePlan": "Base Plan",
    "addonsPlan": "Add-ons Plan",
    "jobPlan": "Job Plan",
    "webinarPlan": "Webinar Plan",
    "posterPlan": "Post Image Plan",
  };
  final normalizedToday = DateTime(today.year, today.month, today.day);

  // API format => 27-6-2026
  final formatter = DateFormat("d-M-yyyy");

  for (var item in dataList) {
    final plans = item["details"]?["plan"];

    if (plans == null) continue;

    for (var key in planList.keys) {
      final plan = plans[key];

      if (plan == null) continue;

      final endDateRaw = plan["endDate"];

      if (endDateRaw == null) continue;

      try {
        // Parse date
        DateTime endDate = formatter.parse(endDateRaw.toString());

        final normalizedEndDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        );

        final daysLeft = normalizedEndDate.difference(normalizedToday).inDays;

        // Add only plans within 7 days
        if (daysLeft <= 7) {
          expiringPlans.putIfAbsent(daysLeft, () => []);
          expiringPlans[daysLeft]!.add(planList[key]!);
        }
      } catch (e) {
        print("Date parse error: $e");
        print(endDateRaw);
      }
    }
  }

  if (expiringPlans.isEmpty) return;

  List<String> messages = [];

  for (var entry in expiringPlans.entries) {
    final daysLeft = entry.key;
    final plans = entry.value;

    if (daysLeft < 0) {
      messages.add("Your ${plans.join(", ")} have expired!");
    } else if (daysLeft == 0) {
      messages.add("Your ${plans.join(", ")} expire today!");

      await loginController.sentMailPlan(
        userId,
        "plan",
        "Plan Expires Alert",
        "basePlan",
        context,
      );
    } else if (daysLeft <= 3) {
      messages.add(
        "Your ${plans.join(", ")} will expire within $daysLeft day(s).",
      );

      await loginController.sentMailPlan(
        userId,
        "plan",
        "Plan Expires Alert",
        "basePlan",
        context,
      );
    } else {
      messages.add("Your ${plans.join(", ")} will expire in $daysLeft days.");
    }
  }

  if (messages.isEmpty) return;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(
        child: Text(
          "Plan Expiry Alert",
          style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
        ),
      ),
      content: Text(messages.join("\n"), style: AppTextStyles.caption(context)),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK", style: AppTextStyles.caption(context)),
          ),
        ),
      ],
    ),
  );

  // Save alert shown date
  box.write("lastPlanAlertDate1_$userId", todayString);
}

void showDeactivateConfirmDialog({
  required BuildContext context,
  required bool isActivating,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        isActivating ? "Activate" : "Deactivate",
        textAlign: TextAlign.center,
        style: AppTextStyles.body(
          context,
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        isActivating
            ? "Are you sure you want to activate?"
            : "Are you sure you want to deactivate?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: AppTextStyles.caption(
              context,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.white),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(
            "Confirm",
            style: AppTextStyles.caption(
              context,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Shown when a required-field check finds empty/unselected fields before
/// submitting a multi-step form (e.g. registration) — Form.validate() alone
/// only shows inline red text under each field, which is easy to miss when
/// the offending field is on a different step than the one currently shown.
void showMissingFieldsDialog(BuildContext context, List<String> missingFields) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Please complete these fields",
              style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: missingFields
            .map(
              (field) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.close, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(field, style: AppTextStyles.caption(context)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "OK",
            style: AppTextStyles.caption(context, color: AppColors.white),
          ),
        ),
      ],
    ),
  );
}

/// Shown when location is blocked on web, where browsers deliberately don't
/// allow a site to reopen its own permission prompt or jump to browser
/// settings — the user has to do that manually. Returns true if the user
/// wants to retry after fixing it, false if they chose to skip.
Future<bool> showEnableLocationDialog(BuildContext context) async {
  final retry = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Location access needed",
              style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        "Click the padlock or site-info icon next to your browser's address bar → Location → Allow, then try again.",
        style: AppTextStyles.caption(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "Skip",
            style: AppTextStyles.caption(context, color: AppColors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            "Try Again",
            style: AppTextStyles.caption(context, color: AppColors.white),
          ),
        ),
      ],
    ),
  );
  return retry ?? false;
}

void showUpdateDialog(String storeUrl) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Center(
        child: Text(
          "Update Available",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
      content: const Text(
        "A new version is available. Please update to continue.",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.black,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await launchUrl(Uri.parse(storeUrl));
            },
            child: const Text(
              "Update",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: true,
  );
}
