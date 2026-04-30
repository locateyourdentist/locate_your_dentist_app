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

Future<void> showBranchSelectionDialog({
  required BuildContext context,
  String? pageRoute,
}) async {
  final loginController = Get.put(LoginController());
  loginController.getBranchDetails(context);

  final savedUserId = Api.userInfo.read('userId');
  String? selectedName;
  String? selectedUserId = savedUserId;
  String? selectedUserType;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
      child: GetBuilder<LoginController>(
        builder: (controller) {
          final branches = controller.userBranchesList;
          final size = MediaQuery.of(context).size.width;

          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: size * 0.2,
                height: size * 0.25,color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Select Branch",
                      style: AppTextStyles.subtitle(
                        context,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    branches.isEmpty
                        ? Center(
                      child: Text(
                        "No branches found",
                        style: AppTextStyles.caption(context),
                      ),
                    )
                        : Expanded(
                      child: ListView.separated(
                        itemCount: branches.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final branch = branches[index];

                          final name = branch.details['name'] ?? '';
                          final city = branch.address['city'] ?? '';
                          final district =
                              branch.address['district'] ?? '';
                          final state = branch.address['state'] ?? '';

                          final isSelected =
                              selectedUserId == branch.userId;

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
                                  ? Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: RadioListTile<String>(
                              value: branch.userId,
                              groupValue: selectedUserId,

                              title: Text(
                                name,
                                style:AppTextStyles.caption(context,
                                    fontWeight: FontWeight.w600,color: AppColors.black),
                              ),
                              subtitle: Text(
                                "$city, $district\n$state", style:AppTextStyles.caption(context,
                                  fontWeight: FontWeight.normal),
                              ),
                              isThreeLine: true,

                              onChanged: (value) {
                                setState(() {
                                  selectedUserId = value;
                                  selectedName =
                                      branch.details['name'] ?? "";
                                  selectedUserType =
                                      branch.userType ?? "";
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    gradientButton(
                      text: 'Continue',
                      height: size * 0.016,
                      width: size * 0.13,
                      context: context,
                      onTap: () async {

                        String platform = kIsWeb
                            ? "Web"
                            : Platform.isAndroid
                            ? "Android"
                            : Platform.isIOS
                            ? "iOS"
                            : "Unknown";

                        await loginController.switchAccountLogin(
                          selectedUserId.toString(),
                          platform,
                          context,
                        );

                        if (pageRoute == 'dashboard') {
                          Get.toNamed(pageUserTypeWeb(selectedUserType!));
                        } else {
                          Get.toNamed(
                            '/viewPlanPageWeb',
                            arguments: {
                              'selectedUserId': selectedUserId,
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ),
    barrierDismissible: true,
  );
}