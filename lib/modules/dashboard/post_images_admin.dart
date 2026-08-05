import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../api/api.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common-alertdialog.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import '../../common_widgets/common_textstyles.dart';
import '../auth/login_screen/login_controller.dart';
import '../plans/plan_controller.dart';
import 'crop_screen.dart';

class UploadImages extends StatefulWidget {
  const UploadImages({super.key});

  @override
  State<UploadImages> createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  final PlanController controller = Get.put(PlanController());
  final LoginController loginController = Get.put(LoginController());
  final ImagePicker picker = ImagePicker();

  final List<String> userTypes = const [
    "Dental Clinic",
    "Dental Lab",
    "Dental Shop",
    "Dental Mechanic",
    "Dental Consultant",
    "Job Seekers",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    String userType = Api.userInfo.read('userType') ?? "";
    if (userType == 'superAdmin') {
      controller.selectedUserType = "Dental Clinic";
    } else {
      controller.selectedUserType = userType;
    }
    await controller.checkPlansStatus(Api.userInfo.read('userId') ?? "", context);
    await refreshData();
  }

  Future<void> refreshData() async {
    String userType = Api.userInfo.read('userType') ?? "";
    String targetUserType = controller.selectedUserType ?? userType;

    String userId = userType == 'superAdmin'
        ? ""
        : (Api.userInfo.read('userId') ?? "");

    await controller.getUploadImages(
      userId: userId,
      userType: targetUserType,
      context: context,
    );

    await controller.getPostImagePlanList(targetUserType, context);
    controller.update();
  }

  Future<void> pickAndCropImage() async {
    bool isBasePlanActive = false;
    bool isPosterPlanActive = false;
    if (controller.checkPlanList.isNotEmpty) {
      final planDetails = controller.checkPlanList[0]["details"]?["plan"];
      isBasePlanActive = planDetails?["basePlan"]?["isActive"] ?? false;
      isPosterPlanActive = planDetails?["posterPlan"]?["isActive"] ?? false;
    }

    if (!isBasePlanActive) {
      showSuccessDialog(
        context,
        title: "Alert",
        message: "Oops! Base plan not Activated.please activate base plan..",
        onOkPressed: () {},
      );
      return;
    }

    if (!isPosterPlanActive) {
      showSuccessDialog(
        context,
        title: "Poster Plan Required",
        message:
            "You need an active poster plan to post scrolling ads. Please choose a plan to continue.",
        onOkPressed: () {
          Get.toNamed('/viewPlanPage');
        },
      );
      return;
    }

    if (controller.editUploadImage1.length >= 20) {
      Get.snackbar("Limit reached", "You can upload only 20 images total.");
      return;
    }
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => CropScreen(imageBytes: bytes)),
    );

    if (croppedBytes != null) {
      controller.editUploadImage1.add(
        AppImage2(bytes: croppedBytes, isActive: true, id: "0"),
      );
      controller.update();
    }
  }

  Future<void> saveAll() async {
    String userType = Api.userInfo.read('userType') ?? "";
    String targetUserType = controller.selectedUserType ?? userType;
    String currentUserId = Api.userInfo.read('userId') ?? "";

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    bool allSuccess = true;
    String lastError = "";

    try {
      for (var img in controller.editUploadImage1) {
        if (img.planId == null || img.planId!.isEmpty) {
          allSuccess = false;
          lastError = "Plan ID missing";
          continue;
        }
        final String imageId = img.id ?? "0";
        final String planId = img.planId ?? "0";
        final String startDate = img.startDate ?? "";
        final String endDate = img.endDate ?? "";
        final String isActiveStr = (img.isActive ?? false).toString();

        debugPrint("========== IMAGE SAVE ==========");
        debugPrint("ID: $imageId");
        debugPrint("PLAN ID: $planId");
        debugPrint("START DATE: $startDate");
        debugPrint("END DATE: $endDate");
        debugPrint("ACTIVE: $isActiveStr");
        debugPrint("BYTES NULL: ${img.bytes == null}");

        final response = await controller.api.uploadImagesUserType(
          currentUserId,
          targetUserType,
          imageId,
          //planId,
          startDate,
          endDate,
          isActiveStr,
          img.bytes != null ? [img.bytes!] : [],
        );

        final data = jsonDecode(response.body);

        if (data["status"].toString().toLowerCase() != "success") {
          allSuccess = false;
          lastError = data["message"] ?? "Unknown error";
        }
      }
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // RESULT
      if (allSuccess) {
        Get.snackbar("Success", "All changes saved successfully.");

        await refreshData();
      } else {
        Get.snackbar("Partial Error", "Some updates failed: $lastError");

        await refreshData();
      }
    } catch (e, stackTrace) {
      debugPrint("SAVE ERROR: $e");
      debugPrint("STACK: $stackTrace");

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar("Error", "Failed to save: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String userType = Api.userInfo.read('userType') ?? "";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          'Create Scrolling Ads',
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.black),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back, color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: refreshData,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (userType == 'superAdmin')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              initialValue: controller.selectedUserType,
                              decoration: const InputDecoration(
                                labelText: "Select User Type",
                                border: OutlineInputBorder(),
                              ),
                              items: userTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectedUserType = val;
                                  refreshData();
                                }
                              },
                            ),
                          ),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.editUploadImage1.length + 1,
                          itemBuilder: (context, index) {
                            if (index == controller.editUploadImage1.length) {
                              return _buildAddButton();
                            }

                            final img = controller.editUploadImage1[index];
                            return _buildImageItem(img, index);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.editUploadImage1.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saveAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save All Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: pickAndCropImage,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text("Add New Image", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(AppImage2 img, int index) {
    final usedPlanIds = controller.editUploadImage1
        .where((other) => other != img && other.planId != null)
        .map((other) => other.planId!)
        .toSet();

    final availablePlans = controller.postImagePlanList
        .where((p) => !usedPlanIds.contains(p.id) || p.id == img.planId)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: availablePlans.any((p) => p.id == img.planId)
                      ? img.planId
                      : null,
                  decoration: const InputDecoration(
                    hintText: "Select Plan",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(),
                  ),
                  items: availablePlans.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text("${p.postPlanName} (${p.duration} days)"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final selected = controller.postImagePlanList.firstWhere(
                      (p) => p.id == val,
                    );
                    final int duration =
                        int.tryParse(selected.duration.toString()) ?? 0;
                    DateFormat formatter = DateFormat('dd-MM-yyyy');
                    DateTime now = DateTime.now();
                    img.planId = val;
                    img.startDate = formatter.format(now);
                    img.endDate = formatter.format(
                      now.add(Duration(days: duration)),
                    );
                    controller.update();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  const Text(
                    "Active",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: img.isActive ?? true,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      showDeactivateConfirmDialog(
                        context: context,
                        isActivating: val,
                        onConfirm: () {
                          img.isActive = val;
                          controller.update();
                        },
                      );
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(index, img),
              ),
            ],
          ),

          if (img.startDate != null && img.startDate!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      "Validity: ${img.startDate} to ${img.endDate}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                img.bytes != null
                    ? Image.memory(
                        img.bytes!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : (img.url != null && img.url!.isNotEmpty)
                    ? Image.network(
                        img.url!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),

                if (img.id == "0")
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index, AppImage2 img) {
    showDeleteDialog(
      context: context,
      title: "Remove Image?",
      message:
          "Are you sure you want to remove this image? This action cannot be undone.",
      onConfirm: () async {
        if (img.url != null && img.url!.isNotEmpty) {
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );
          print('jkdfsf${img.url}');
          await loginController.deleteAwsFile(img.url!, 'postImage', context);
          String userType = Api.userInfo.read('userType') ?? "";
          String targetUserType = controller.selectedUserType ?? userType;
          String currentUserId = Api.userInfo.read('userId') ?? "";

          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );
          final String imageId = img.id ?? "0";
          final String planId = img.planId ?? "0";
          final String startDate = img.startDate ?? "";
          final String endDate = img.endDate ?? "";
          final String isActiveStr = (img.isActive ?? false).toString();

          debugPrint("========== IMAGE SAVE ==========");
          debugPrint("ID: $imageId");
          debugPrint("PLAN ID: $planId");
          debugPrint("START DATE: $startDate");
          debugPrint("END DATE: $endDate");
          debugPrint("ACTIVE: $isActiveStr");
          debugPrint("BYTES NULL: ${img.bytes == null}");
          await controller.api.uploadImagesUserType(
            currentUserId,
            targetUserType,
            imageId,
            //planId,
            '',
            '',
            false.toString(),
            img.bytes != null ? [img.bytes!] : [],
          );
          Get.back();
        }
        controller.editUploadImage1.removeAt(index);
        controller.update();
      },
    );
  }
}
