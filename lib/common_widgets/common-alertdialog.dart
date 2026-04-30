import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';


void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final userInfo=GetStorage();
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Center(
          child: Text(
            "Logout",
            style: AppTextStyles.subtitle(context, ),
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: AppTextStyles.caption(context,),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppTextStyles.caption(context,color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              userInfo.erase();
              kIsWeb?  Get.toNamed('/webLoginPage'):  Get.toNamed('/loginPage');
            },
            child: Text(
              "LogOut",
              style: AppTextStyles.caption(context),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child:ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
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
                  style:AppTextStyles.caption(context,fontWeight: FontWeight.normal)
                ),

                const SizedBox(height: 25),

                /// Buttons
                Row(
                  children: [

                    /// Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text("Cancel",style:AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.black)),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Delete
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
                        child:  Text(
                          "Delete",
                          style:AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: Colors.white)
                        ),
                      ),
                    ),
                  ],
                )
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
          title: Text('Exit Confirmation',
            style: AppTextStyles.caption(context, ),),
          content: Text('Press back again to exit',
            style: AppTextStyles.caption(context,),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: AppTextStyles.caption(
                    context, ),
              ),
            ),
            TextButton(
              onPressed: () {
              Get.toNamed('/loginPage');
              },
              child: Text(
                'Yes',
                style: AppTextStyles.caption(
                    context, color: AppColors.primary),

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(context,fontWeight: FontWeight.bold),
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
            child:  Text('OK',style: AppTextStyles.subtitle(context,color: AppColors.white),),
          ),
        ],
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

// void showPlanAlerts(
//     String userId,
//     List<Map<String, dynamic>> dataList,
//     BuildContext context,
//     ) {
//   final loginController = Get.put(LoginController());
//
//   final Map<int, List<String>> expiringPlans = {};
//   bool? isSameDate;
//   final planList = {
//     "basePlan": "Base Plan",
//     "addonsPlan": "Add-ons Plan",
//     "jobPlan": "Job Plan",
//     "webinarPlan":"webinarPlan",
//     "posterPlan":"post Image Plan"
//   };
//   DateTime parseDDMMYYYY(String date) {
//     final parts = date.split('-');
//     return DateTime(
//       int.parse(parts[2]),
//       int.parse(parts[1]),
//       int.parse(parts[0]),
//     );
//   }
//
//   for (var item in dataList) {
//     final plans = item["details"]?["plan"];
//     if (plans == null) continue;
//
//     for (var key in planList.keys) {
//       final plan = plans[key];
//       if (plan == null) continue;
//
//       final endDateRaw = plan["endDate"];
//       if (endDateRaw == null) continue;
//
//       DateTime endDate = parseDDMMYYYY(endDateRaw.toString());
//       DateTime today = DateTime.now();
//
//       final planIsSameDate =
//           endDate.year == today.year &&
//               endDate.month == today.month &&
//               endDate.day == today.day;
//
//       // Update outer variable if plan expires today
//       if (planIsSameDate) {
//         isSameDate = true;
//       }
//
//       final daysLeft =
//           endDate.difference(DateTime(today.year, today.month, today.day)).inDays;
//
//       if (daysLeft <= 6) {
//         expiringPlans.putIfAbsent(daysLeft, () => []);
//         expiringPlans[daysLeft]!.add(planList[key]!);
//       }
//     }
//   }
//
//   if (expiringPlans.isEmpty) return;
//   int selectedDay = expiringPlans.keys.reduce((a, b) {
//     if (a == 0) return a;
//     if (b == 0) return b;
//     return a < b ? a : b;
//   });
//
//   final plans = expiringPlans[selectedDay]!;
//   final planNames = plans.join(", ");
//
//   String message;
//   bool expired = false;
//
//   if (selectedDay == 7) {
//     message = "Your $planNames will expire in 1 week.";
//   } else if (selectedDay == 2) {
//     message = "Your $planNames will expire within 3 days.";
//   } else if (isSameDate==true) {
//     message = "Your $planNames expire today!";
//   }if (selectedDay == 0) {
//     message = "Your $planNames expire today!";
//   }
//   // else if (selectedDay < 0) {
//   //   message = "Your $planNames have expired.";
//   //   expired = true;
//   // }
//   else {
//     return;
//   }
//   loginController.sentMailPlan(userId, "plan", "Plan Expires Alert", "basePlan", context);
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Center(
//         child: Text("Plan Expiry Alert",
//           style: AppTextStyles.caption(
//             context,
//             fontWeight: FontWeight.bold,
//             color: AppColors.primary,
//           ),
//         ),
//       ),
//       content: Text(message),
//       actions: [
//         if (expired)
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Get.toNamed('/viewPlanPage');
//             },
//             child: Text(
//               "Buy Now",
//               style: AppTextStyles.caption(
//                 context,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.redAccent,
//               ),
//             ),
//           ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: Text(
//             "OK",
//             style: AppTextStyles.caption(
//               context,
//               fontWeight: FontWeight.bold,
//               color: AppColors.black,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// void showPlanAlerts(
//     String userId,
//     List<Map<String, dynamic>> dataList,
//     BuildContext context,
//     ) {
//   final box = GetStorage();
//   final todayString = DateTime.now().toIso8601String().substring(0, 10);
//   final lastAlertDate = box.read("lastPlanAlertDate1_$userId");
//
//   if (lastAlertDate == todayString) return;
//
//   final loginController = Get.put(LoginController());
//
//   final Map<int, List<String>> expiringPlans = {};
//   final planList = {
//     "basePlan": "Base Plan",
//     "addonsPlan": "Add-ons Plan",
//     "jobPlan": "Job Plan",
//     "webinarPlan": "Webinar Plan",
//     "posterPlan": "Post Image Plan"
//   };
//
//   DateTime parseDDMMYYYY(String date) {
//     final parts = date.split('-');
//     return DateTime(
//       int.parse(parts[2]),
//       int.parse(parts[1]),
//       int.parse(parts[0]),
//     );
//   }
//
//   for (var item in dataList) {
//     final plans = item["details"]?["plan"];
//     if (plans == null) continue;
//
//     for (var key in planList.keys) {
//       final plan = plans[key];
//       if (plan == null) continue;
//
//       final endDateRaw = plan["endDate"];
//       if (endDateRaw == null) continue;
//
//       DateTime endDate = parseDDMMYYYY(endDateRaw.toString());
//       DateTime today = DateTime.now();
//
//       final daysLeft =
//           endDate.difference(DateTime(today.year, today.month, today.day)).inDays;
//
//       if (daysLeft <= 7) {
//         expiringPlans.putIfAbsent(daysLeft, () => []);
//         expiringPlans[daysLeft]!.add(planList[key]!);
//       }
//     }
//   }
//
//   if (expiringPlans.isEmpty) return;
//   List<String> messages = [];
//   expiringPlans.forEach((daysLeft, plans)async {
//     if (daysLeft < 0) {
//       messages.add("Your ${plans.join(", ")} have expired!");
//     } else if (daysLeft == 0) {
//       messages.add("Your ${plans.join(", ")} expire today!");
//       await loginController.sentMailPlan(userId, "plan", "Plan Expires Alert", "basePlan", context);
//     } else if (daysLeft <= 3) {
//       messages.add("Your ${plans.join(", ")} will expire within $daysLeft day(s).");
//       await loginController.sentMailPlan(userId, "plan", "Plan Expires Alert", "basePlan", context);
//     } else {
//       messages.add("Your ${plans.join(", ")} will expire in $daysLeft days.");
//       await loginController.sentMailPlan(userId, "plan", "Plan Expires Alert", "basePlan", context);
//     }
//   });
//
//   if (messages.isEmpty) return;
//
//   // Show dialog
//  // loginController.sentMailPlan(userId, "plan", "Plan Expires Alert", "basePlan", context);
//
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Center(child: Text("Plan Expiry Alert",style: AppTextStyles.body(context,fontWeight: FontWeight.bold),)),
//       content: Text(messages.join("\n",),style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
//       actions: [
//         Center(
//           child: TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text("OK",style: AppTextStyles.caption(context),),
//           ),
//         ),
//       ],
//     ),
//   );
//   box.write("lastPlanAlertDate1_$userId", todayString);
// }
void showPlanAlerts(
    String userId,
    List<Map<String, dynamic>> dataList,
    BuildContext context,
    ) async {
  final box = GetStorage();
  final today = DateTime.now();
  final todayString = today.toIso8601String().substring(0, 10);

  final lastAlertDate = box.read("lastPlanAlertDate1_$userId");
  if (lastAlertDate == todayString) return;

  final loginController = Get.put(LoginController());

  final Map<int, List<String>> expiringPlans = {};

  final planList = {
    "basePlan": "Base Plan",
    "addonsPlan": "Add-ons Plan",
    "jobPlan": "Job Plan",
    "webinarPlan": "Webinar Plan",
    "posterPlan": "Post Image Plan"
  };

  // Normalize today (remove time)
  final normalizedToday = DateTime(today.year, today.month, today.day);

  for (var item in dataList) {
    final plans = item["details"]?["plan"];
    if (plans == null) continue;

    for (var key in planList.keys) {
      final plan = plans[key];
      if (plan == null) continue;

      final endDateRaw = plan["endDate"];
      if (endDateRaw == null) continue;

      try {
        // ✅ FIX: correct parsing (YYYY-MM-DD)
        DateTime endDate = DateTime.parse(endDateRaw.toString());

        final normalizedEndDate =
        DateTime(endDate.year, endDate.month, endDate.day);

        final daysLeft =
            normalizedEndDate.difference(normalizedToday).inDays;

        if (daysLeft <= 7) {
          expiringPlans.putIfAbsent(daysLeft, () => []);
          expiringPlans[daysLeft]!.add(planList[key]!);
        }
      } catch (e) {
        print("Date parse error: $e");
      }
    }
  }

  if (expiringPlans.isEmpty) return;

  List<String> messages = [];

  // ✅ FIX: proper async loop
  for (var entry in expiringPlans.entries) {
    final daysLeft = entry.key;
    final plans = entry.value;

    if (daysLeft < 0) {
      messages.add("Your ${plans.join(", ")} have expired!");
    } else if (daysLeft == 0) {
      messages.add("Your ${plans.join(", ")} expire today!");
      await loginController.sentMailPlan(
          userId, "plan", "Plan Expires Alert", "basePlan", context);
    } else if (daysLeft <= 3) {
      messages.add(
          "Your ${plans.join(", ")} will expire within $daysLeft day(s).");
      await loginController.sentMailPlan(
          userId, "plan", "Plan Expires Alert", "basePlan", context);
    } else {
      messages.add(
          "Your ${plans.join(", ")} will expire in $daysLeft days.");
    }
  }

  if (messages.isEmpty) return;

  // ✅ Show dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(
        child: Text(
          "Plan Expiry Alert",
          style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
        ),
      ),
      content: Text(
        messages.join("\n"),
        style: AppTextStyles.caption(context),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "OK",
              style: AppTextStyles.caption(context),
            ),
          ),
        ),
      ],
    ),
  );

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
      title: Text(isActivating ? "Activate User" : "Deactivate User",textAlign: TextAlign.center,style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
      content: Text(
        isActivating
            ? "Are you sure you want to activate this user?"
            : "Are you sure you want to deactivate this user?",
      ),
      actions: [
        TextButton(
          onPressed: () =>  Navigator.of(context).pop(),
          child:  Text("Cancel",style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child:  Text("Confirm",style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
void showUpdateDialog(String storeUrl) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title:  const Center(child: Text("Update Available",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: AppColors.black),)),
      content: const Text(
        "A new version is available. Please update to continue.",style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal,color: AppColors.black),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await launchUrl(Uri.parse(storeUrl));
            },
            child: const Text("Update",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: AppColors.primary),),
          ),
        ),
      ],
    ),
    barrierDismissible: true,
  );
}