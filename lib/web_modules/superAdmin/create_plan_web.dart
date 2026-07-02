import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:get/get.dart';

class CreatePlanWeb extends StatefulWidget {
  const CreatePlanWeb({super.key});

  @override
  State<CreatePlanWeb> createState() => _CreatePlanWebState();
}

class _CreatePlanWebState extends State<CreatePlanWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKeyCreatePlan = GlobalKey<ScaffoldState>();
  final planController = Get.put(PlanController());
  final _formKeyPlanProfileWeb = GlobalKey<FormState>();
  String? planId;
  String? addOnsId;
  String? jobPlanId;
  String? webinarPlanId;
  String? postImagePlanId;
  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    //args['selectedString']  = "BasePlan";
    postImagePlanId = (planController.selectPostImageId ?? "").isNotEmpty
        ? planController.selectPostImageId!
        : "0";
    webinarPlanId=(planController.selectWebinarId ?? "").isNotEmpty
        ? planController.selectWebinarId!
        : "0";
    jobPlanId = (planController.selectJobId ?? "").isNotEmpty
        ? planController.selectJobId!
        : "0";

    addOnsId = (planController.selectAddOnsId ?? "").isNotEmpty
        ? planController.selectAddOnsId! : "0";
    planId = (planController.selectPlanId ?? "").isNotEmpty ? planController.selectPlanId! : "0";
    if ((args['selectedString'] ?? "") == "BasePlan") {
      loadBasePlanData(args);
    }
    if ((args['selectedString'] ?? "") == "AddOnsPlan") {
      loadAddOnsPlanData(args);
    }
    if ((args['selectedString'] ?? "") == "JobPlan") {
      loadJobPlanData(args);
    }
    if ((args['selectedString'] ?? "") == "WebinarPlan") {
      loadWebinarPlanData(args);
    }
    if ((args['selectedString'] ?? "") == "PostImagePlan") {
      loadPostImagePlanData(args);
    }
  }
  void loadBasePlanData(Map<String, dynamic> args) {
    setState(() {
      planController.planNameController.text = args['planName'] ?? "";
      planController.selectPlanId = args['planId']?.toString() ?? "";
      planController.priceController.text = args['price'] ?? "";
      planController.durationDaysController.text = args['duration'] ?? "";
      planController.selectedFeatures = args['features'] ?? [];
      planController.selectedString = args['selectedString'] ?? "";
      planController.selectedUserType = args['userType'] ?? "";

      final details = Map<String, dynamic>.from(args['details'] ?? {});

      planController.isImageAndroid = details['images'] ?? false;
      planController.isVideoAndroid = details['video'] ?? false;
      planController.isLocationAndroid = details['location'] ?? false;
      planController.isMobileNumber = details['mobileNumber'] ?? false;
      planController.isServices = details['services'] ?? false;
      planController.imageCountController.text =
          (details['imageCount'] ?? "").toString();

      planController.imageSizeController.text =
          (details['imageSize'] ?? "").toString();

      planController.videoCountController.text =
          (details['videoCount'] ?? "").toString();

      planController.videoSizeController.text =
          (details['videoSize'] ?? "").toString();

      planId = (planController.selectPlanId ?? "").isNotEmpty ? planController.selectPlanId! : "0";
    });
  }
  void loadAddOnsPlanData(Map<String, dynamic> args) {
    setState(() {
      planController.planNameController.text = args['addOnsPlanName'] ?? "";
      planController.selectAddOnsId = args['addOnsId']?.toString() ?? "";
      planController.priceController.text = args['price'] ?? "";
      planController.durationDaysController.text = args['duration'] ?? "";
      planController.selectedFeatures = args['features'] ?? [];
      planController.selectedString = args['selectedString'] ?? "";
      planController.selectedUserType = args['userType'] ?? "";

      final details = Map<String, dynamic>.from(args['details'] ?? {});

      planController.isStateWise = details['state'] ?? false;
      planController.isDistrictWise = details['district'] ?? false;
      planController.isCityWise = details['city'] ?? false;
      planController.isAreaWise = details['area'] ?? false;
      addOnsId = (planController.selectAddOnsId ?? "").isNotEmpty
          ? planController.selectAddOnsId! : "0";
    });
  }
  void loadJobPlanData(Map<String, dynamic> args) {
    setState(() {
      planController.planNameController.text =
          args['planName'] ?? args['jobPlanName'] ?? "";
      planController.selectJobId =
          args['jobPlansId']?.toString() ?? args['jobPlansId']?.toString() ?? "";
      planController.priceController.text = args['price'] ?? "";
      planController.durationDaysController.text = args['duration'] ?? "";
      planController.selectedFeatures =
      List<String>.from(args['features'] ?? []);
      planController.selectedString = args['selectedString'] ?? "";
      planController.selectedUserType = args['userType'] ?? "";
      final details = Map<String, dynamic>.from(args['details'] ?? {});

      planController.isStateWise = details['state'] ?? false;
      planController.isDistrictWise = details['district'] ?? false;
      planController.isCityWise = details['city'] ?? false;
      planController.isAreaWise = details['area'] ?? false;
      jobPlanId = (planController.selectJobId ?? "").isNotEmpty
          ? planController.selectJobId!
          : "0";
      // webinarPlanId=(planController.selectWebinarId ?? "").isNotEmpty
      //     ? planController.selectWebinarId!
      //     : "0";
    });
  }
  void loadWebinarPlanData(Map<String, dynamic> args) {
    setState(() {
      print('fdsgf');
      planController.planNameController.text =
          args['webinarPlanName'] ?? args['webinarPlanName'] ?? "";
      planController.selectJobId =
          args['webinarPlanId']?.toString() ?? args['webinarPlanId']?.toString() ?? "";
      planController.priceController.text = args['price'] ?? "";
      planController.durationDaysController.text = args['duration'] ?? "";
      planController.selectedFeatures = List<String>.from(args['features'] ?? []);
      planController.selectedString = args['selectedString'] ?? "";
      planController.selectedUserType = args['userType'] ?? "";
      final details = Map<String, dynamic>.from(args['details'] ?? {});

      planController.isStateWise = details['state'] ?? false;
      planController.isDistrictWise = details['district'] ?? false;
      planController.isCityWise = details['city'] ?? false;
      planController.isAreaWise = details['area'] ?? false;
      webinarPlanId=(planController.selectWebinarId ?? "").isNotEmpty
          ? planController.selectWebinarId!
          : "0";
    });
  }
  void loadPostImagePlanData(Map<String, dynamic> args) {
    setState(() {
      planController.planNameController.text =
          args['postPlanName'] ?? args['postPlanName'] ?? "";
      planController.selectPostImageId =
          args['postImagesPlanId']?.toString() ??
              args['postImagesPlanId']?.toString() ?? "";
      planController.priceController.text = args['price'] ?? "";
      planController.durationDaysController.text = args['duration'] ?? "";
      planController.selectedFeatures =
      List<String>.from(args['features'] ?? []);
      planController.selectedString = args['selectedString'] ?? "";
      planController.selectedUserType = args['userType'] ?? "";
      final details = Map<String, dynamic>.from(args['details'] ?? {});
      postImagePlanId = (planController.selectPostImageId ?? "").isNotEmpty
          ? planController.selectPostImageId!
          : "0";
      print('pricer${args['price'] ?? ""}duratt${args['duration'] ??
          ""}name${args['postPlanName'] ?? ""}');
    });
  }
  Future<void> _refresh() async {
    final args = Get.arguments ?? {};
    if ((args['selectedString'] ?? "") == "BasePlan") {
      loadBasePlanData(args);
    }
    if ((args['selectedString'] ?? "") == "AddOnsPlan") {
      loadAddOnsPlanData(args);
    }
    if ((args['selectedString'] ?? "") == "JobPlan") {
      loadJobPlanData(args);
    }
    if ((args['selectedString'] ?? "") == "WebinarPlan") {
      loadWebinarPlanData(args);
    }
    if ((args['selectedString'] ?? "") == "PostImagePlan") {
      loadPostImagePlanData(args);
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
      key: _scaffoldKeyCreatePlan,
      backgroundColor: Colors.white,
      drawer: !isDesktop ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<PlanController>(
          builder: (controller) {
            return  RefreshIndicator(
              onRefresh: _refresh,
              child: Row(
                children: [
                  if (isDesktop && isLoggedIn) const AdminSideBar(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 10 : 20),
                        child:ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                              ],
                            ),
                            child: Stack(
                              children: [
                                if (isLoggedIn && !isDesktop)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10, left: 10),
                                    child:    Align(
                                      alignment: Alignment.topLeft,
                                      child: IconButton(
                                        icon: const Icon(Icons.menu,color: AppColors.black,),
                                        onPressed: () => _scaffoldKeyCreatePlan.currentState?.openDrawer(),
                                      ),
                                    ),
                                  ),
                                SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: isMobile ? 10 : 30),
                                  child: Column(
                                    children: [
                                       const SizedBox(height: 20,),
                                      // if(planController.selectedString=="BasePlan")
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                
                                          radioItem("BasePlan", "Base Plan"),
                                          radioItem("AddOnsPlan", "AddOns Plan"),
                                          radioItem("JobPlan", "Job Plan"),
                                          radioItem("WebinarPlan", "Webinar Plan"),
                                          radioItem("PostImagePlan", "Scrolling Ads Plan"),
                
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                
                                      Form(
                                        key: _formKeyPlanProfileWeb,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Add Plan Details', style: AppTextStyles.subtitle(
                                              context, color: AppColors.black,)),
                                            const SizedBox(height: 10,),
                                            Text('Add/edit user Plan details',
                                                style: AppTextStyles.caption(
                                                  context, color: AppColors.grey,)),
                                            const SizedBox(height: 15,),
                                            CustomDropdownField(
                                              hint: "Select User Type",
                                              items: const [
                                                "Dental Clinic",
                                                "Dental Lab",
                                                "Dental Shop",
                                                "Dental Mechanic",
                                                "Dental Consultant",

                                              ],
                                              selectedValue: planController.selectedUserType?.isEmpty == true
                                                  ? null
                                                  : planController.selectedUserType,
                                              onChanged: (value) {
                                                setState(() {
                                                  planController.selectedUserType = value;
                                                });
                                              },
                                            ),
                
                                            const SizedBox(height: 15,),
                                            CustomTextField(
                                              hint: "Plan Name",
                                              controller: planController.planNameController,
                                            ),
                                            const SizedBox(height: 15,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    hint: "Price",
                                                    controller: planController.priceController,
                                                    keyboardType: TextInputType.number,
                                                    maxLength: 4,
                                                  ),
                                                ),
                                                const SizedBox(width: 15,),
                                                Expanded(
                                                  child: CustomTextField(
                                                    hint: "Mark Price",
                                                    controller: planController.markPriceController,
                                                    keyboardType: TextInputType.number,
                                                    maxLength: 4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15,),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    hint: "Duration months",
                                                    controller: planController.durationMonthsController,
                                                    maxLength: 2,
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                ),
                                                const SizedBox(width: 15,),
                                                Expanded(
                                                  child: CustomTextField(
                                                    hint: "Duration Days",
                                                    controller: planController.durationDaysController,
                                                    maxLength: 3,
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15,),
                                            if(planController.selectedString=="BasePlan")
                                              GetBuilder<PlanController>(
                                                  builder: (controller) {
                                                    return Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomTextField(
                                                                hint: "Number of Image",
                                                                controller: planController.imageCountController,
                                                                maxLength: 1,
                                                                keyboardType: TextInputType.number,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 15,),
                                                            Expanded(
                                                              child: CustomTextField(
                                                                hint: "Image Size (MB)",
                                                                controller: planController.imageSizeController,
                                                                maxLength: 3,
                                                                keyboardType: TextInputType.number,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 10,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: CustomTextField(
                                                                hint: "Number Of Video",
                                                                controller: planController.videoCountController,
                                                                maxLength: 1,
                                                                keyboardType: TextInputType.number,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 15,),
                                                            Expanded(
                                                              child: CustomTextField(
                                                                hint: "Video Size (MB)",
                                                                controller: planController.videoSizeController,
                                                                maxLength: 3,
                                                                keyboardType: TextInputType.number,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              ),
                                            const SizedBox(height: 15,),
                                            if (planController.selectedString == "JobPlan")
                                              CustomTextField(
                                                hint: "Job Count",
                                                controller: planController.countDaysController,
                                                maxLength: 3,
                                                keyboardType: TextInputType.number,
                                              ),
                                            const SizedBox(height: 15,),
                
                                            if(planController.selectedString=="BasePlan")
                                              Column(
                                                children: [
                
                                                  buildSwitchRow(
                                                    label: "Show Image",
                                                    value: planController.isImageAndroid,
                                                    onChanged: (val) => setState((){
                                                      planController.isImageAndroid = val;
                                                      planController.update();
                
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show Video",
                                                    value: planController.isVideoAndroid,
                                                    onChanged: (val) => setState((){
                                                      planController.isVideoAndroid = val;
                                                      planController.update();
                
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show Location",
                                                    value: planController.isLocationAndroid,
                                                    onChanged: (val) => setState(() {
                                                      planController.isLocationAndroid = val;
                                                      planController.update();
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show MobileNumber",
                                                    value: planController.isMobileNumber,
                                                    onChanged: (val) => setState(() {
                                                      planController.isMobileNumber = val;
                                                      planController.update();
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show Services",
                                                    value: planController.isServices,
                                                    onChanged: (val) => setState(() {
                                                      planController.isServices = val;
                                                      planController.update();
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            if(planController.selectedString=="AddOnsPlan"||planController.selectedString=="JobPlan")
                                              Column(
                                                children: [
                                                  buildSwitchRow(
                                                    label: "Show State",
                                                    value: planController.isStateWise,
                                                    onChanged: (val) => setState((){
                                                      planController.isStateWise = val;
                                                      planController.update();
                
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show District",
                                                    value: planController.isDistrictWise,
                                                    onChanged: (val) => setState(() {
                                                      planController.isDistrictWise = val;
                                                      planController.update();
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show City",
                                                    value: planController.isCityWise,
                                                    onChanged: (val) => setState(() {
                                                      planController.isCityWise = val;
                                                      planController.update();
                                                    }),
                                                  ),
                                                  buildSwitchRow(
                                                    label: "Show Area",
                                                    value: planController.isAreaWise,
                                                    onChanged: (val) => setState(() {
                                                      planController.isAreaWise = val;
                                                      planController.update();
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 40,),
                                            Center(
                                              child: Container(
                                                width: double.infinity,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [AppColors.primary, AppColors.secondary],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    if (!_formKeyPlanProfileWeb.currentState!.validate()) return;
                                                    int days = int.tryParse(planController.durationDaysController.text) ?? 0;
                                                    int months = int.tryParse(planController.durationMonthsController.text) ?? 0;
                
                                                    int duration = days + (months * 30);
                
                                                    String durationDays = duration.toString();
                                                    if (planController.selectedUserType == null ||
                                                        planController.selectedUserType!.isEmpty) {
                                                      showCustomToast(context, "Please select user type");
                                                      return;
                                                    }
                                                    List<String> features = [];
                                                    if (planController.selectedString == "BasePlan") {
                                                      if (planController.isImageAndroid) {
                                                        features.add("Display clinic photos");
                                                      }
                                                      if (planController.isVideoAndroid) {
                                                        features.add("Display clinic  videos");
                                                      }
                                                      if (planController.isLocationAndroid) {
                                                        features.add("Show clinic location on map");
                                                      }
                                                      if (planController.isMobileNumber) {
                                                        features.add("Show clinic contact number");
                                                      }
                                                      if (planController.isServices) {
                                                        features.add("Display list of offered services");
                                                      }
                                                      await planController.createPlans(
                                                        planController.selectedUserType!,
                                                        planId!,
                                                        planController.planNameController.text,
                                                        planController.priceController.text,
                                                        planController.markPriceController.text,durationDays,
                                                        //planController.durationDaysController.text,
                                                        planController.isImageAndroid,
                                                        planController.isVideoAndroid,
                                                        planController.isLocationAndroid,
                                                        planController.isMobileNumber,
                                                        planController.isServices,
                                                        planController.imageCountController.text,
                                                        planController.imageSizeController.text,
                                                        planController.videoCountController.text,
                                                        planController.videoCountController.text,
                                                        features.toSet().toList(),
                                                        context,
                                                      );
                
                                                      await planController.getBasePlanList(Api.userInfo.read('userType') ?? "", context);
                                                    }
                                                    else if (planController.selectedString == "AddOnsPlan") {
                                                      if (planController.isStateWise) {
                                                        features.add("Display preferences based on State");
                                                      }
                                                      if (planController.isDistrictWise) {
                                                        features.add("Display preferences based on District");
                                                      }
                                                      if (planController.isCityWise) {
                                                        features.add("Display preferences based on City");
                                                      }
                                                      if (planController.isAreaWise) {
                                                        features.add("Display  preferences based on Area");
                                                      }
                                                      await planController.createAddonsPlans(
                                                        planController.selectedUserType!,
                                                        addOnsId!,
                                                        planController.planNameController.text,
                                                        planController.priceController.text,planController.markPriceController.text,
                                                        durationDays,
                                                        //planController.durationDaysController.text,
                                                        planController.isStateWise,
                                                        planController.isDistrictWise,
                                                        planController.isCityWise,
                                                        planController.isAreaWise,
                                                        features.toSet().toList(),
                                                        context,
                                                      );
                
                                                      await planController.getAddOnPlansList(
                                                          planController.selectedUserType!, context);
                                                    }
                                                    else if (planController.selectedString == "JobPlan") {
                                                      if (planController.isStateWise) {
                                                        features.add("Display job posts based on State");
                                                      }
                                                      if (planController.isDistrictWise) {
                                                        features.add("Display job posts based on District");
                                                      }
                                                      if (planController.isCityWise) {
                                                        features.add("Display job posts based on City");
                                                      }
                                                      if (planController.isAreaWise) {
                                                        features.add("Display job posts based on Area");
                                                      }
                                                      await planController.createJobPlans(
                                                        planController.selectedUserType!,
                                                        jobPlanId!,
                                                        planController.planNameController.text,
                                                        planController.priceController.text,planController.markPriceController.text,
                                                        durationDays,
                                                        //planController.durationDaysController.text,
                                                        planController.isStateWise,
                                                        planController.isDistrictWise,
                                                        planController.isCityWise,
                                                        planController.isAreaWise,
                                                        planController.countDaysController.text,
                                                        features.toSet().toList(),
                                                        context,
                                                      );
                
                                                      await planController.getJobPlansList(
                                                          planController.selectedUserType!, context);
                                                    }
                                                    else if (planController.selectedString == "WebinarPlan") {
                                                      await planController.createWebinarPlans(
                                                        planController.selectedUserType!,
                                                        webinarPlanId!,
                                                        planController.planNameController.text,
                                                        planController.priceController.text,planController.markPriceController.text,
                                                        durationDays,
                                                        //planController.durationDaysController.text,
                                                        planController.isStateWise,
                                                        planController.isDistrictWise,
                                                        planController.isCityWise,
                                                        planController.isAreaWise,
                                                        context,
                                                      );
                                                    }
                                                    else if (planController.selectedString == "PostImagePlan") {
                
                
                                                      await planController.createPostImagesPlans(
                                                        planController.selectedUserType!,
                                                        postImagePlanId!,
                                                        planController.planNameController.text,
                                                        planController.priceController.text,planController.markPriceController.text,
                                                        durationDays,
                                                        //planController.durationDaysController.text,
                                                        context,
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    'Create Plan',
                                                    style: AppTextStyles.body(
                                                      context,
                                                      color: AppColors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 40,),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
            );
          }
      ),
    );
  }


  Widget buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GetBuilder<PlanController>(
        builder: (controller) {
          double s=MediaQuery.of(context).size.width;

          return  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.blueGrey.shade600,
                inactiveTrackColor: Colors.grey.shade400,
                splashRadius: s*0.005,
                value: value,
                onChanged: onChanged,
              ),
            ],
          );
        }
    );
  }

  void resetPlanFields() {
    planController.planNameController.clear();
    planController.priceController.clear();
    planController.durationDaysController.clear();
    planController.selectedUserType = "";
    planController.isStateWise = false;
    planController.isDistrictWise = false;
    planController.isCityWise = false;
    planController.isAreaWise = false;
    planController.selectedFeatures.clear();
    planController.isImageAndroid = false;
    planController.isLocationAndroid = false;
    planController.isMobileNumber = false;
    planController.isServices = false;
    planController.selectJobId='';
  }
  Widget radioItem(String value, String label) {
    return GetBuilder<PlanController>(
      builder: (controller) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio(
              value: value,
              groupValue: controller.selectedString,
              activeColor: AppColors.primary,
              fillColor: MaterialStateProperty.all(AppColors.primary),
              onChanged: (val) {
                controller.selectedString = val.toString();
                resetPlanFields();
                controller.update();
              },
            ),
            Text(
              label,
              style: AppTextStyles.caption(context, color: AppColors.black),
            ),
          ],
        );
      },
    );
  }

}