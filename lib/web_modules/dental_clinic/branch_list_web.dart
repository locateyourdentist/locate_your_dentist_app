import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

//void showBranchSelectionDialog({required BuildContext context, String? pageRoute}) {
  Future<void> showBranchSelectionDialog({required BuildContext context, String? pageRoute}) async {
  final loginController = Get.put(LoginController());
  loginController.getBranchDetails(context);

  String? selectedUserId;
  String? selectedName;
  String? selectedUserType;
  String? email;
  String? password;
 print('kfgjd$pageRoute');
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: GetBuilder<LoginController>(
        builder: (_) {
          final branches = loginController.userBranchesList;
          final size = MediaQuery.of(context).size.width;
          return Container(
            width: size * 0.2,
            height: size*0.25,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Branch",
                  style: AppTextStyles.subtitle(context, color: AppColors.black),
                ),
                const SizedBox(height: 16),

                branches.isEmpty
                    ? Center(child: Text("No branches found", style: AppTextStyles.caption(context)))
                    : Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: branches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      final name = branch.details['name'] ?? '';
                      final city = branch.address['city'] ?? '';
                      final district = branch.address['district'] ?? '';
                      final state = branch.address['state'] ?? '';
                       email=branch.email??"";
                       password=branch.password??"";
                      final bool isSelected = selectedUserId == branch.userId;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.05)
                              : Colors.white,
                        ),
                        child: RadioListTile<String>(
                          value: branch.userId,
                          groupValue: selectedUserId,
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("$city, $district\n$state"),
                          isThreeLine: true,
                          onChanged: (value) {
                            selectedUserId = value;
                            selectedName = branch.details['name'] ?? "";
                            selectedUserType=branch.userType??"";
                            //_.update();
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                gradientButton(text: 'Continue',height: size*0.016,width: size*0.13,
              onTap:()async{
                  Api.userInfo.erase();
              //  Api.userInfo.write("userId", selectedUserId ?? "");
               // Api.userInfo.write("name", selectedName ?? "");
                print('emaill$email$password vfd');
                String platform = kIsWeb
                    ? "Web"
                    : Platform.isAndroid
                    ? "Android"
                    : Platform.isIOS
                    ? "iOS"
                    : "Unknown";
                await loginController.switchAccountLogin(
                    selectedUserId.toString(),platform,context);
                if (pageRoute == 'dashboard') {
                  Get.toNamed(pageUserTypeWeb(selectedUserType!));
                }
                else {print('dfgfd');
                 Get.toNamed('/viewPlanPageWeb', arguments: {'selectedUserId': selectedUserId});
                }
              },
                    context: context)
              ],
            ),
          );
        },
      ),
    ),
    barrierDismissible: true,
  );
}