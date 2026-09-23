import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/crop_screen.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_textstyles.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagesWeb extends StatefulWidget {
  const UploadImagesWeb({super.key});
  @override
  State<UploadImagesWeb> createState() => _UploadImagesWebState();
}

class _UploadImagesWebState extends State<UploadImagesWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PlanController planController = Get.put(PlanController());
  final LoginController loginController = Get.put(LoginController());
  final List<String> userTypes = const [
    "Dental Clinic",
    "Dental Lab",
    "Dental Shop",
    "Dental Mechanic",
    "Dental Consultant",
    "Job Seekers",
  ];
  final ImagePicker picker = ImagePicker();
  String? selectedTargetUserId;

  @override
  void initState() {
    super.initState();
    planController.selectedUserType = "Dental Clinic";
    _initData();
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return "";
    final parts = [
      address['addressLine1'],
      address['area'],
      address['city'],
      address['district'],
      address['state'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e.toString());
    return parts.join(', ');
  }

  Future<void> _initData() async {
    String userType = Api.userInfo.read('userType') ?? "";
    String currentUserId = Api.userInfo.read('userId') ?? "";

    if (userType == 'superAdmin') {
      await loginController.getProfileDetails(
        planController.selectedUserType ?? "",
        '',
        [],
        [],
        [],
        '',
        '',
        '',
        '',
        '',
        context,
      );
      final bool stillValid = loginController.profileList.any(
        (u) => u.userId == selectedTargetUserId,
      );
      if (!stillValid) {
        selectedTargetUserId = null;
      }
    }

    String userIdForFetch = userType == 'superAdmin' ? "" : currentUserId;

    await planController.getUploadImages(
      userId: userIdForFetch,
      userType: planController.selectedUserType!,
      context: context,
    );
    await planController.checkPlansStatus(currentUserId, context);
    await planController.getPostImagePlanList(
      planController.selectedUserType.toString(),
      context,
    );
    planController.update();
  }

  Future<void> _refresh() async {
    await _initData();
  }

  String _resolveUserLabel(String? userId) {
    if (userId == null || userId.isEmpty) return "";
    for (final user in loginController.profileList) {
      if (user.userId == userId) {
        return "${user.name} ($userId)";
      }
    }
    return userId;
  }

  Future<String?> _pickTargetUserDialog(BuildContext context) async {
    final users = loginController.profileList;
    if (users.isEmpty) {
      Get.snackbar("No Users", "No users found for the selected user type");
      return null;
    }
    String? tempSelected =
        users.any((u) => u.userId == selectedTargetUserId)
        ? selectedTargetUserId
        : null;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                "Select User",
                style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: tempSelected,
                  hint: Text(
                    "Select User",
                    style: AppTextStyles.caption(context),
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: users.map((user) {
                    final address = _formatAddress(user.address);
                    final label = address.isNotEmpty
                        ? "${user.name} (${user.userId}) - $address"
                        : "${user.name} (${user.userId})";
                    return DropdownMenuItem<String>(
                      value: user.userId,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => tempSelected = value),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
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
                  onPressed: tempSelected == null
                      ? null
                      : () => Navigator.of(context).pop(tempSelected),
                  child: Text(
                    "Continue",
                    style: AppTextStyles.caption(context, color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> pickImages(BuildContext context) async {
    bool isBasePlanActive = false;
    bool isPosterPlanActive = false;
    if (planController.checkPlanList.isNotEmpty) {
      final planDetails = planController.checkPlanList[0]["details"]?["plan"];
      isBasePlanActive = planDetails?["basePlan"]?["isActive"] ?? false;
      isPosterPlanActive = planDetails?["posterPlan"]?["isActive"] ?? false;
    }
    final bool isSuperAdmin = Api.userInfo.read('userType') == 'superAdmin';
    String? targetUserId = Api.userInfo.read('userId')?.toString() ?? "";
if (!isSuperAdmin) {
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
        Get.toNamed('/viewPlanPageWeb');
      },
    );
    return;
  }
} else {
  targetUserId = await _pickTargetUserDialog(context);
  if (targetUserId == null || targetUserId.isEmpty) return;
  selectedTargetUserId = targetUserId;
}

    if (!context.mounted) return;
    final List<XFile> pickedImages = await picker.pickMultiImage();
    if (pickedImages.isEmpty) return;

    for (var file in pickedImages) {
      final bytes = await file.readAsBytes();
      if (!context.mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CropScreen(imageBytes: bytes)),
      );

      if (result == null) continue;
      final Uint8List croppedBytes = result;

      final appImage2 = AppImage2(
        bytes: croppedBytes,
        isActive: true,
        userId: targetUserId,
      );

      planController.editUploadImage1.add(appImage2);
    }
    planController.update();
  }

  Map<String, dynamic>? getSafePosterPlan(PlanController controller) {
    if (controller.checkPlanList.isEmpty) return null;
    final data = controller.checkPlanList.first;
    if (data is! Map<String, dynamic>) return null;
    return data["details"]?["plan"]?["posterPlan"];
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final String userType = Api.userInfo.read('userType') ?? "";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      drawer: !isDesktop
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return Row(
            children: [
              if (isDesktop) const AdminSideBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Stack(
                    children: [
                      if (!isDesktop)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 10 : 30,
                          !isDesktop ? 60 : 30,
                          isMobile ? 10 : 30,
                          30,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1300),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 15 : 30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (userType == 'superAdmin')
                                      _buildUserTypeSelector(
                                        controller,
                                        isMobile,
                                      ),
                                    const SizedBox(height: 30),
                                    _buildHeaderRow(context, isMobile),
                                    const SizedBox(height: 20),
                                    _buildImageGrid(
                                      controller,
                                      isMobile,
                                      width,
                                      userType,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserTypeSelector(PlanController controller, bool isMobile) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 15,
      runSpacing: 15,
      children: [
        Text(
          "Select User Type",
          style: AppTextStyles.caption(context, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: isMobile ? double.infinity : 350,
          child: CustomDropdownField(
            hint: "Select User Type",
            borderColor: AppColors.grey,
            fillColor: AppColors.white,

            items: userTypes.toSet().toList(),
            selectedValue:
                (controller.selectedUserType != null &&
                    controller.selectedUserType!.isNotEmpty &&
                    userTypes.contains(controller.selectedUserType))
                ? controller.selectedUserType
                : null,

            onChanged: (value) async {
              if (value == null) return;
              controller.selectedUserType = value;
              selectedTargetUserId = null;
              await _initData();
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
        Text("Manage Uploads", style: AppTextStyles.subtitle(context)),
        ElevatedButton.icon(
          onPressed: () => pickImages(context),
          icon: const Icon(Icons.add),
          label: const Text("Upload Images"),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(
    PlanController controller,
    bool isMobile,
    double width,
    String userType,
  ) {
    if (controller.editUploadImage1.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text("No images found", style: AppTextStyles.caption(context)),
        ),
      );
    }

    return GetBuilder<PlanController>(
      builder: (controller) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.editUploadImage1.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 450,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            mainAxisExtent: 420,
          ),
          itemBuilder: (_, index) {
            final image = controller.editUploadImage1[index];
            return _buildImageCard(controller, image, index, userType);
          },
        );
      },
    );
  }

  Widget _buildImageCard(
    PlanController controller,
    AppImage2 image,
    int index,
    String userType,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.grey.withValues(alpha: 0.2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: image.bytes != null
                  ? Image.memory(
                      image.bytes!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : image.url != null
                  ? Image.network(
                      image.url!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
          ),
          if (userType == 'superAdmin')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.indigo),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _resolveUserLabel(image.userId).isNotEmpty
                          ? _resolveUserLabel(image.userId)
                          : "Unknown User",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (image.startDate != null && image.startDate!.isNotEmpty)
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
                      "Validity: ${image.startDate} to ${image.endDate}",
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue:
                      controller.postImagePlanList.any(
                        (plan) => plan.id == image.planId,
                      )
                      ? image.planId
                      : null,
                  hint: Text(
                    "Select Plan",
                    style: AppTextStyles.caption(context),
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: controller.postImagePlanList.map((plan) {
                    return DropdownMenuItem<String>(
                      value: plan.id,
                      child: Text(
                        "${plan.postPlanName} (${plan.duration} days)",
                        style: AppTextStyles.caption(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    image.planId = value;
                    controller.update();
                    await _handleStatusChange(
                      controller,
                      image,
                      index,
                      userType,
                      image.isActive ?? false,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 35,
                          child: Switch(
                            value: image.isActive ?? false,
                            onChanged: (val) => _handleStatusChange(
                              controller,
                              image,
                              index,
                              userType,
                              val,
                            ),
                          ),
                        ),
                        Text(
                          image.isActive == true ? "Active" : "Inactive",
                          style: AppTextStyles.caption(
                            context,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 15),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () async {
                            controller.editUploadImage1.removeAt(index);

                            String storedUserType =
                                Api.userInfo.read('userType')?.toString() ?? "";
                            bool isSuperAdmin =
                                storedUserType.toLowerCase() == 'superadmin';
                            String currentUserId = isSuperAdmin
                                ? (image.userId ?? "")
                                : Api.userInfo.read('userId')?.toString() ??
                                      "";
                            String targetUserType = isSuperAdmin
                                ? (controller.selectedUserType ??
                                      "Dental Clinic")
                                : storedUserType;
                            //_handleStatusChange(controller, image, index, userType, 'delete'),
                            // await controller.uploadImagesUserType(
                            // currentUserId,
                            // targetUserType,
                            // image.id ?? "0",
                            // // "1",
                            // '',
                            // '',
                            // true.toString(),
                            // currentFile,
                            // context,
                            // );
                            controller.update();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatusChange(
    PlanController controller,
    AppImage2 image,
    int index,
    String userType,
    bool val,
  ) async {
    image.isActive = val;
    controller.editUploadImage1[index] = image;
    controller.update();
    final bool isSuperAdmin = Api.userInfo.read('userType') == 'superAdmin';

    if (!isSuperAdmin && (image.planId == null || image.planId == "0")) {
      Get.snackbar("Error", "Please select a plan first");
      return;
    }

    final posterPlan = getSafePosterPlan(controller);
    print('ghgd$posterPlan');
    final startDate = posterPlan?["startDate"]?.toString() ?? "";
    final endDate = posterPlan?["endDate"]?.toString() ?? "";
    print('ghgd$endDate');
    List<Uint8List> currentFile = image.bytes != null ? [image.bytes!] : [];

    String targetUserId = isSuperAdmin
        ? (image.userId ?? "")
        : Api.userInfo.read('userId')?.toString() ?? "";
    String targetUserType = isSuperAdmin
        ? (controller.selectedUserType ?? "Dental Clinic")
        : userType;

    if (isSuperAdmin && targetUserId.isEmpty) {
      Get.snackbar("Error", "Missing user for this image. Please re-upload.");
      return;
    }

    if (targetUserId.isEmpty || targetUserType.isEmpty) {
      Get.snackbar("Error", "Missing session data. Please login again.");
      return;
    }

    await controller.uploadImagesUserType(
      targetUserId,
      targetUserType,
      image.id ?? "0",
      // "1",
      startDate,
      endDate,
      val.toString(),
      currentFile,
      context,
    );
    await _refresh();
  }
}
