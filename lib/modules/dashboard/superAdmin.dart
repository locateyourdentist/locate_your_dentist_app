import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../api/api.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_widget_all.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});
  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}
class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  final LoginController loginController = Get.put(LoginController());
  final notificationController=Get.put(NotificationController());
  final planController=Get.put(PlanController());
  @override
  void initState() {
    super.initState();
    _refresh();
      }
  Future<void> _refresh() async {
    await loginController.fetchStates();
    await planController.getIncomeDetailsByPlan(context: context);
    //await planController.getExpense(month: "", year: "");
    await loginController.getAppLogoImage(context);
    await notificationController.getNotificationListAdmin(context);
    Api.userInfo.read('userType')=="superAdmin"?
    await loginController.getProfileDetails('', '', '', '', '','','','','', context): loginController.getProfileDetails('', Api.userInfo.read('state')??"", '', '', '','','','', '',context);
    //await planController.getIncomeDetailsByPlan(context: context);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        appBar: AppBar(
          //backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.white,
              size: size * 0.06,
            ),
            onPressed: () {
              print("Menu pressed");
            },
          ), flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary,AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
          title: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: AppTextStyles.body(context,
                color: AppColors.white,fontWeight: FontWeight.bold,),
            ),
            Text(Api.userInfo.read('name')??"",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.bold,color: Colors.white),),
          ],
        ),
          automaticallyImplyLeading: false,
          actions: [
            GetBuilder<NotificationController>(
              builder: (controller) {
                return Stack(
                  children: [

                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: AppColors.white,
                        size: size * 0.08,
                      ),
                      onPressed: () {
                        notificationController.getNotificationListAdmin(context);
                        notificationController.update();
                        Get.toNamed('/notificationPage');
                        },
                    ),
                 if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
                    Positioned(
                        top: 0,
                        right: 5,
                        child:  GetBuilder<NotificationController>(
                            builder: (controller) {
                              return CircleAvatar(
                              radius: size*0.024,backgroundColor: Colors.redAccent,child: Text(
                              notificationController.unreadCount.toString()??"",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.w500,fontSize: size*0.025),
                            ),
                            );
                          }
                        ))
                  ],
                );
              }
            )
          ],
        ),
        drawer: SizedBox(
          width: size * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Drawer(
              shape:  const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Container(
                height: size*0.01,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  padding:  const EdgeInsets.all(5.0),
                  children: [
                    Center(child: Text('LYC',style: AppTextStyles.subtitle(context,color: AppColors.white,),)),
                    CircleAvatar(
                      radius: size * 0.07,
                      backgroundColor: AppColors.white,
                      child: CircleAvatar(
                        radius: size * 0.065,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: Image.network(
                            loginController.appLogoUrl ?? "",
                            fit: BoxFit.cover,
                            width: size * 0.13,
                            height: size * 0.13,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_hospital,
                                color: AppColors.primary,
                                size: size * 0.06,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size*0.03,),
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Divider(color: AppColors.white,thickness: 0.5,),
                    ),
                    // drawerTitle('Profile','assets/images/lp3.jpg','',context),
                    // SizedBox(height: size*0.005,),
                    drawerTitle('Dashboard', Icons.dashboard, '/superAdminDashboard', context),
                    SizedBox(height: size * 0.005),

                    drawerTitle('Plans', Icons.workspace_premium, '/viewPlanPage', context),
                    SizedBox(height: size * 0.005),
                   if(Api.userInfo.read('userType')=='superAdmin')
                   Column(children: [
                    drawerTitle('Reports', Icons.bar_chart, '/viewReportPage', context),
                    SizedBox(height: size * 0.005),

                    drawerTitle('Create Post', Icons.post_add, '/createPostImages', context),
                    SizedBox(height: size * 0.005),

                    drawerTitle('Create Notification', Icons.notifications_active, '/createNotificationPage', context),
                    SizedBox(height: size * 0.005),



                    drawerTitle('Add GST', Icons.receipt_long, '/addGSTPage', context),
                    SizedBox(height: size * 0.005),

                    drawerTitle('Add Company', Icons.business, '/addCompanyPage', context),
                    SizedBox(height: size * 0.005),
                    ]),
                    drawerTitle('Change Password', Icons.lock_reset, '/changePasswordPage', context),
                    SizedBox(height: size * 0.005),
                    drawerTitle('About Us', Icons.info_outline, '/aboutUsPage', context),
                    SizedBox(height: size * 0.005),

                    drawerTitle('Settings', Icons.settings, '/settingPage', context),
                    SizedBox(height: size * 0.005),
                    drawerTitle('LogOut', Icons.logout, '', context),

                  ]
                )
              )
            )
          )
        ),
        body: GetBuilder<LoginController>(
          builder: (controller) {
            // if (controller.profileList.isEmpty) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    if(loginController.profileList.isEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 15),
                          Center(child: Text('No data found',style: AppTextStyles.caption(context),),),
                        ],
                      ),
                    if(loginController.isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                    if(loginController.profileList.isNotEmpty)
                      AdminDashboardWidget(profiles: controller.profileList),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            'Latest Users List',textAlign: TextAlign.start,
                             style: AppTextStyles.body(context,fontWeight: FontWeight.bold),
                                ),
                            AnimationLimiter(
                            child: Column(
                            children: controller.profileList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final profile = entry.value;
                            return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 1300),
                            child: SlideAnimation(
                            verticalOffset: 120.0,
                            curve: Curves.easeOutBack,
                            child: FadeInAnimation(
                            child: GestureDetector(
                            onTap: () async{
                            print('userlistId ${profile.userId}');
                            // Api.userInfo.write(
                            // 'selectUserId', profile.userId ?? '');
                            Api.userInfo.write('selectUId',profile.userId ?? '');

                            print('ids${profile.userId}');

                            await loginController.getProfileByUserId(
                            profile.userId ?? '', context);
                            if (PlatformHelper.platform != "Web") {
                            Get.toNamed('/${profilePage(profile.userType)}');
                            }
                            },
                            child: SuperAdminProfileCard(
                            profile: profile,
                            size: size,
                            onCall: () {
                            launchCall(profile.mobileNumber);
                            },
                            ),
                            ),
                            ),
                            ),
                            );
                            }).toList(),
                            ),
                            )
                            ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
      ),
    );
  }

}



class SuperAdminProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final double size;
  final void Function()? onCall;
  const SuperAdminProfileCard({
    super.key,
    required this.profile,
    required this.size,
    this.onCall,
  });
  bool isBasePlanActive(ProfileModel profile) {
    final isActive =
    profile.details?["plan"]?["basePlan"]?["isActive"];
    return isActive == true || isActive == "true";
  }
  @override
  Widget build(BuildContext context) {
    final planActive = isBasePlanActive(profile);
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    print('planStatus$planActive isAdminn$isAdminUser');
    String firstImage = profile.images.firstWhere(
          (img) =>
      img.toLowerCase().endsWith('.jpg') ||
          img.toLowerCase().endsWith('.jpeg') ||
          img.toLowerCase().endsWith('.png') ||
          img.toLowerCase().endsWith('.webp'),
      orElse: () => "",
    );
    List<String> parts = [];
    if ((profile.address["state"] ?? "").isNotEmpty) parts.add(profile.address["state"]);
    if ((profile.address["district"] ?? "").isNotEmpty) parts.add(profile.address["district"]);
    if ((profile.address["city"] ?? "").isNotEmpty) parts.add(profile.address["city"]);
    String address = parts.join(", ");

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                // (firstImage.isNotEmpty&&(planActive==true&&profile.details["plan"]?["basePlan"]?["details"]?["images"] == true||
                //     isAdminUser)) ? firstImage : "",
                (firstImage.isNotEmpty && isAdminUser||
                    ((planActive == true &&
                        profile.details["plan"]?["basePlan"]?["details"]?["images"] == true)))
                    ? firstImage
                    : "",
                width: size * 0.25,
                height: size * 0.25,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: size * 0.25,
                    height: size * 0.25,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade400,
                      size: size * 0.08,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (profile.userType == "Dental Clinic" ||
                              profile.userType == "Dental Consultant")
                              ? "Dr. ${profile.name}"
                              : profile.name,softWrap: true,
                          style: AppTextStyles.caption(
                            context,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color:profile.isActive
                            ? Colors.green
                            : Colors.redAccent,borderRadius: BorderRadius.circular(10) ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "•${profile.isActive ? 'Active' : 'Inactive'}",
                            style: TextStyle(
                              color: AppColors.white,fontWeight: FontWeight.bold,fontSize: size*0.025),
                          ),
                        ),
                      )
                    ],
                  ),
                  Text("UserId: ${profile.userId}",
                      style: AppTextStyles.caption(context)),
                  Text("UserType: ${profile.userType}",
                      style: AppTextStyles.caption(context)),
                  Text("Address: $address",
                      style: AppTextStyles.caption(context,
                          color: Colors.grey)),
                  if((planActive==true&&profile.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true)||
                      isAdminUser)
                  Row(children: [
                    IconButton(
                        icon: Icon(Icons.call,
                            size: size * 0.05, color: AppColors.primary),
                        onPressed: onCall),
                    Text(profile.mobileNumber,
                        style: AppTextStyles.caption(context)),
                  ])
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}


class AdminDashboardWidget extends StatelessWidget {
  final List<ProfileModel> profiles;
  final loginController=Get.put(LoginController());
   AdminDashboardWidget({super.key, required this.profiles});
  @override
  Widget build(BuildContext context) {
    int total = profiles.length;
    int active = profiles.where((p) => p.isActive).length;
    int inactive = total - active;
    Map<String, int> typeCounts = {};
    for (var p in profiles) {
      typeCounts[p.userType] = (typeCounts[p.userType] ?? 0) + 1;
    }
    return Column(
      children: [
        _header(context,total,active,inactive),
        const SizedBox(height: 20),
        AnimationLimiter(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //height: MediaQuery.of(context).size.width * 0.8,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
            children: typeCounts.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 1300),
            child: SlideAnimation(
              horizontalOffset: 80.0,
            curve: Curves.easeOutBack,
            child: FadeInAnimation(
            child: Column(
              children:[
               _typeTile(
              e.key,
              e.value,
              context,
              onTap: () async{
              Api.userInfo.write('selectedUserType', e.key);
              Api.userInfo.write('sUserType', e.key);
              Get.toNamed('/userTypeListPage');

             await  loginController.getProfileDetails(
              Api.userInfo.read('selectedUserType'),
              '',
              '',
              '','',
              '','','','',
                context,
              );

              },
               ),
              const Divider(color: Colors.grey,thickness: 0.3,)
              ]
            ),
            ),
            ),
            );
            }).toList(),
            ),
          ),
        ],
      ),
    ),
    ),

      ],
    );
  }
  Widget _header(BuildContext context, int total, int active, int inactive) {
    double width = MediaQuery.of(context).size.width;
    double height = width * 0.35;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard",
                style: AppTextStyles.caption(
                  context,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Overview of user activity",
                style: AppTextStyles.subtitle(
                  context,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -30,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStatCard(context, "Total Users", total, AppColors.white, AppColors.primary),
              _miniStatCard(context, "Active", active, AppColors.white, Colors.green),
              _miniStatCard(context, "Inactive", inactive, AppColors.white, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(
      BuildContext context, String label, int value, Color bgColor, Color textColor) {
    double width = MediaQuery.of(context).size.width * 0.27;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption(
              context,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: AppTextStyles.subtitle(
              context,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  Widget _typeTile(String title, int count, BuildContext context,
      {VoidCallback? onTap}) {
    double size = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "$title ($count)",
                style: AppTextStyles.caption(
                  context,color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,softWrap: true,
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: size * 0.04,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }

}

Widget drawerTitle(
    String title,
    IconData icon,
    String page,
    BuildContext context,
    ) {
  double size = MediaQuery.of(context).size.width;

  return ListTile(
    leading: Icon(
      icon,
      color: AppColors.white,
      size: size * 0.055,
    ),
    title: Text(
      title,
      style: AppTextStyles.caption(
        context,
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: AppColors.white,
      size: size * 0.035,
    ),
    onTap: () {
      if (page.isNotEmpty) {
        Get.toNamed(page);
      }
    },
  );
}
