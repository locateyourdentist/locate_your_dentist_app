import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/crop_screen.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_textstyles.dart';
import '../../common_widgets/common-alertdialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class UploadImagesWeb extends StatefulWidget {
  const UploadImagesWeb({super.key});
  @override
  State<UploadImagesWeb> createState() => _UploadImagesWebState();
}

class _UploadImagesWebState extends State<UploadImagesWeb> {
  final PlanController planController = Get.put(PlanController());
  final GlobalKey<ScaffoldState> _scaffoldKeyAds = GlobalKey<ScaffoldState>();
  final List<String> userTypes = const [
    "Dental Clinic",
    "Dental Lab",
    "Dental Shop",
    "Dental Mechanic",
    "Dental Consultant",
    "Job Seekers"
  ];
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    planController.selectedUserType = "Dental Clinic";
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    String userType = Api.userInfo.read('userType') ?? "";
    String userIdForFetch = userType == 'superAdmin' ? "" : Api.userInfo.read('userId') ?? "";

    await planController.getUploadImages(
      userId: userIdForFetch,
      userType: planController.selectedUserType!,
      context: context,
    );
    await planController.getPostImagePlanList(planController.selectedUserType.toString(), context);
    planController.update();
  }

  Future<void> _refresh() async {
    await _initData();
  }

  Future<void> pickImages(BuildContext context) async {
    final List<XFile>? pickedImages = await picker.pickMultiImage();
    if (pickedImages == null || pickedImages.isEmpty) return;

    for (var file in pickedImages) {
      final bytes = await file.readAsBytes();
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CropScreen(imageBytes: bytes)),
      );

      if (result == null) continue;
      final Uint8List croppedBytes = result;

      planController.editUploadImage1.add(AppImage2(
        bytes: croppedBytes,
        isActive: true,
        id: "0",
      ));
    }
    planController.update();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final String userType = Api.userInfo.read('userType') ?? "";

    return Scaffold(
      key: _scaffoldKeyAds,
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      drawer: !isDesktop ? const Drawer(width: 250, child: AdminSideBar()) : null,
      body: Row(
        children: [
          if (isDesktop) const AdminSideBar(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 15 : 30),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                ),
                                child: Stack(
                                  children: [
                                    if (!isDesktop)
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: IconButton(
                                          icon: const Icon(Icons.menu),
                                          onPressed: () => _scaffoldKeyAds.currentState?.openDrawer(),
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.all(isMobile ? 15 : 30.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (!isDesktop) const SizedBox(height: 40),
                                          if (userType == 'superAdmin') _buildUserTypeSelector(isMobile),
                                          const SizedBox(height: 30),
                                          _buildHeaderRow(context, isMobile),
                                          const SizedBox(height: 20),
                                          GetBuilder<PlanController>(
                                            builder: (controller) {
                                              if (controller.isLoading) {
                                                return _buildShimmerGrid(isMobile);
                                              }
                                              return _buildImageGrid(controller, isMobile, userType);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GetBuilder<PlanController>(
                  builder: (controller) {
                    if (controller.editUploadImage1.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 300,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _saveAll(controller),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Save All Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelector(bool isMobile) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 15,
      runSpacing: 15,
      children: [
        Text("Select User Type", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold)),
        SizedBox(
          width: isMobile ? double.infinity : 350,
          child: CustomDropdownField(
            hint: "Select User Type",
            borderColor: AppColors.grey,
            fillColor: AppColors.white,
            items: userTypes,
            selectedValue: planController.selectedUserType,
            onChanged: (value) async {
              if (value == null) return;
              planController.selectedUserType = value;
              await _refresh();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Manage Scrolling Ads", style: AppTextStyles.subtitle(context)),
        ElevatedButton.icon(
          onPressed: () => pickImages(context),
          icon: const Icon(Icons.add),
          label: const Text("Add Image"),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 15)),
        )
      ],
    );
  }

  Widget _buildShimmerGrid(bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 450,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(PlanController controller, bool isMobile, String userType) {
    if (controller.editUploadImage1.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(50.0), child: Text("No ads found")));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.editUploadImage1.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 450,
      ),
      itemBuilder: (_, index) => _buildImageCard(controller, controller.editUploadImage1[index], index, userType),
    );
  }

  Widget _buildImageCard(PlanController controller, AppImage2 image, int index, String userType) {
    final usedPlans = controller.editUploadImage1.where((o) => o != image && o.planId != null).map((o) => o.planId!).toSet();
    final availablePlans = controller.postImagePlanList.where((p) => !usedPlans.contains(p.id) || p.id == image.planId).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey.withOpacity(0.2))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: image.bytes != null
                  ? Image.memory(image.bytes!, width: double.infinity, fit: BoxFit.cover)
                  : Image.network(image.url ?? "", width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: availablePlans.any((p) => p.id == image.planId) ? image.planId : null,
                  hint: const Text("Select Plan"),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder()),
                  items: availablePlans.map((p) => DropdownMenuItem(value: p.id, child: Text("${p.postPlanName} (${p.duration} days)"))).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    image.planId = val;
                    final p = controller.postImagePlanList.firstWhere((element) => element.id == val);
                    DateFormat formatter = DateFormat('dd-MM-yyyy');
                    DateTime now = DateTime.now();
                    image.startDate = formatter.format(now);
                    image.endDate = formatter.format(now.add(Duration(days: int.tryParse(p.duration.toString()) ?? 0)));
                    controller.update();
                  },
                ),
                const SizedBox(height: 10),
                if (image.startDate != null && image.startDate!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text("Validity: ${image.startDate} to ${image.endDate}", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: image.isActive ?? true,
                          onChanged: (val) {
                            showDeactivateConfirmDialog(
                              context: context,
                              isActivating: val,
                              onConfirm: () {
                                image.isActive = val;
                                controller.update();
                              },
                            );
                          },
                        ),
                        Text(image.isActive == true ? "Active" : "Inactive", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _confirmDelete(index, image)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _confirmDelete(int index, AppImage2 image) {
    showDeleteDialog(
      context: context,
      title: "Remove Ad?",
      message: "Are you sure you want to remove this scrolling ad?",
      onConfirm: () async {
        if (image.url != null) await planController.loginController.deleteAwsFile(image.url!, 'postImage', context);
        planController.editUploadImage1.removeAt(index);
        planController.update();
      },
    );
  }

  Future<void> _saveAll(PlanController controller) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      String userId = Api.userInfo.read('userId')?.toString() ?? "";
      String type = controller.selectedUserType ?? "Dental Clinic";

      for (var img in controller.editUploadImage1) {
        if (img.id == "0" && img.bytes == null) continue;

        await controller.api.uploadImagesUserType(
          userId,
          type,
          img.id?.toString() ?? "0",
          img.planId?.toString() ?? "1",
          img.startDate ?? "",
          img.endDate ?? "",
          (img.isActive ?? true).toString(),
          img.bytes != null ? [img.bytes!] : [],
        );
      }

      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Success", "All changes saved successfully");
      await _refresh();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Failed to save: $e");
    }
  }
}
