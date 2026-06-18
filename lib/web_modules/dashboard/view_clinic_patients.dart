import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/common/filter_side_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/color_code.dart';
import '../../common_widgets/platform_helper.dart';
import '../../model/profile_model.dart';
import '../../modules/auth/login_screen/login_controller.dart';

import 'package:get/get.dart';

class ViewClinicPatients extends StatefulWidget {
  const ViewClinicPatients({super.key});

  @override
  State<ViewClinicPatients> createState() => _ViewClinicPatientsState();
}

class _ViewClinicPatientsState extends State<ViewClinicPatients> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final bool isDesktop = size >= 1100;
    final bool isTablet = size >= 700 && size < 1100;
    final bool isMobile = size < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
        return CommonWebAppBar(
          height: isMobile ? 60 : (isTablet ? 70 : 80),
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return const CommonHeader();
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer:( !isDesktop&&isLoggedIn) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      endDrawer: isMobile ? const Drawer(width: 300, child: FilterSidebar()) : null,
      appBar: buildAppBar(),
      body: GetBuilder<LoginController>(
          builder: (controller) {
            return Row(
            children: [
              if (isDesktop && isLoggedIn) const AdminSideBar(),
            Expanded(
            child: Padding(
            padding: EdgeInsets.all(isMobile ? 15.0 : 40.0),
            child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)
            )],
            ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMobile)
                    SizedBox(width: isDesktop ? size * 0.15 : 250, child: const FilterSidebar()),
                  //if(loginController.profileList.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        "Total Profiles : ${loginController.profileList.length}",
                        style:AppTextStyles.body(context,)
                    ),
                  ),
                  Expanded(child: ListView.builder(
                    shrinkWrap: true,
                    //physics: NeverScrollableScrollPhysics(),
                    itemCount: loginController.profileList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: clinicCard(
                          loginController.profileList[index],context,
                        ),
                      );
                    },
                  )),
                ],
              ),
              
              )
            )
            )))
          
            ],
          );
        }
      ),
    );
  }
}
Widget clinicCard(ProfileModel clinic,dynamic context) {
  String firstImage = clinic.logoImages.isNotEmpty
      ? clinic.logoImages.first
      : (clinic.images.isNotEmpty ? clinic.images.first : "");
  final loginController = Get.put(LoginController());
  bool isBasePlanActive(ProfileModel profile) {
    final isActive =
    profile.details?["plan"]?["basePlan"]?["isActive"];
    return isActive == true || isActive == "true";
  }
  final planActive = isBasePlanActive(clinic);
  final userType = Api.userInfo.read('userType')?.toString() ?? "";
  final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
  return GetBuilder<LoginController>(
      builder: (controller) {
      return GestureDetector(
        onTap: () async {
          Api.userInfo.write('selectUId', clinic.userId);

          await loginController.getProfileByUserId(
            clinic.userId,
            context,
          );

          Get.toNamed('/clinicProfileWebPage');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [

                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: firstImage.isNotEmpty
                        ? Image.network(
                      firstImage,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                        size: 50,color: AppColors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          clinic.details["name"] ?? "",
                            style:AppTextStyles.body(context,fontWeight: FontWeight.bold,color: AppColors.primary)
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "Dr. ${clinic.name}",
                          style:AppTextStyles.caption(context,fontWeight: FontWeight.bold)
                        ),
                        // Text(
                        //   clinic.userType,
                        //   style: TextStyle(
                        //     color: Colors.grey.shade600,
                        //   ),
                        // ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                             IconButton(
                             icon: Icon( Icons.location_on,
                              size: 18,
                              color: Colors.red,),
                               onPressed: (){
                                 if(clinic.location.toString().isNotEmpty&&(planActive==true
                                     &&clinic?.details["plan"]?["basePlan"]?["details"]?["location"]==true|| isAdminUser)){
                                   if (PlatformHelper.platform == 'Android' ||
                                       PlatformHelper.platform == 'iOS') {
                                     Get.toNamed(
                                         '/webViewProfilePage', arguments: {
                                       "url": clinic
                                           .location
                                           .toString() ?? "",
                                       "clinicName": clinic
                                           .details["name"].toString() ?? ""
                                     });
                                   }

                                 }
                               },
                            ),
                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                "${clinic.address['area'] ?? ''}, "
                                    "${clinic.address['city'] ?? ''}, "
                                    "${clinic.address['district'] ?? ''}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),
                        if ((planActive == true &&
                            clinic.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                            isAdminUser)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 18,
                              color: AppColors.primary,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              clinic.mobileNumber,
                              style:AppTextStyles.caption(context)
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                 // const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            Get.toNamed('/clinicProfileWebPage');

                          },
                          icon: const Icon(Icons.person,color: AppColors.primary,size: 17,),
                          label:  Text("View Profile",style: AppTextStyles.caption(context,color: AppColors.primary),),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: Colors.white,shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),))
                      ),
                      const SizedBox(height: 20),
                      if ((planActive == true &&
                          clinic.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                          isAdminUser)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await launchCallWeb(
                            "tel:${clinic.mobileNumber}",
                          );
                        },
                        icon: const Icon(Icons.call,color: AppColors.primary,size: 17,),
                        label:  Text("Call",style: AppTextStyles.caption(context,color: AppColors.primary),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: Colors.white,shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(width: 60),

                      // OutlinedButton.icon(
                      //   onPressed: () {
                      //     if (clinic.location.isNotEmpty) {
                      //       launchUrl(
                      //         Uri.parse(clinic.location),
                      //       );
                      //     }
                      //   },
                      //   icon: const Icon(Icons.location_pin,color: AppColors.primary,size: 17,),
                      //   label:  Text("Location",style: AppTextStyles.caption(context,color: AppColors.primary,),),
                      //   style: OutlinedButton.styleFrom(
                      //     side: const BorderSide(
                      //       color: AppColors.primary,
                      //     ),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(6),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                ],
              ),
            ],
          ),
        ),
      );
    }
  );
}