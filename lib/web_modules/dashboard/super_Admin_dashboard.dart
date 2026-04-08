import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';



class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  final loginController = Get.put(LoginController());
  final userTypeCounts = {
    "admin": 2,
    "superAdmin": 1,
    "Dental Clinic": 12,
    "Dental Lab": 4,
    "Dental Shop": 5,
    "Dental Mechanic": 3,
    "Job Seekers": 10,
    "Dental Consultant": 6,
  };
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await loginController.getProfileDetails('', '', '', '', "", '', '', '', '', context);
    await loginController.fetchStates();
    await loginController.getAppLogoImage(context);
  }
  @override
  Widget build(BuildContext context) {
    int total = loginController.profileList.length;
    int active = loginController.profileList.where((p) => p.isActive).length;
    int inactive = total - active;
    Map<String, int> typeCounts = {};
    for (var p in loginController.profileList) {
      typeCounts[p.userType] = (typeCounts[p.userType] ?? 0) + 1;
    }
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<LoginController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Row(
              children: [
                 const AdminSideBar(),
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child:  Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Container(
                                  height: size * 0.18,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: size * 0.13,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: const LinearGradient(
                                            colors: [AppColors.primary, AppColors.secondary],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Admin Dashboard",
                                                style: AppTextStyles.subtitle(context, color: AppColors.white),
                                              ),
                                              // Icons
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.notifications_none,
                                                        color: AppColors.white, size: size * 0.013),
                                                    onPressed: () {
                                                      Get.toNamed('/viewNotificationWebPage');
                                                    },
                                                  ),
                                                  const SizedBox(width: 10),
                                                  GestureDetector(
                                                    onTap: () => showLogoutDialog(context),
                                                    child:  CircleAvatar(radius: size*0.008,
                                                      backgroundColor: Colors.white,
                                                      child: Icon(Icons.logout, color: AppColors.primary,size: size*0.009,),

                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        bottom: -size * 0.0009,
                                        left: 20,
                                        right: 20,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            StatCard(
                                              title: "Total Users",
                                              value: total.toString(),
                                              icon: Icons.people,
                                              color: Colors.blue,
                                            ),
                                            StatCard(
                                              title: "Active Users",
                                              value: active.toString(),
                                              icon: Icons.verified_user,
                                              color: Colors.green,
                                            ),
                                            const StatCard(
                                              title: "Total Revenue",
                                              value: "₹1,25,000",
                                              icon: Icons.currency_rupee,
                                              color: Colors.orange,
                                            ),
                                            const StatCard(
                                              title: "Total Expenses",
                                              value: "₹40,000",
                                              icon: Icons.money_off,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 25,),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        blurRadius: 6,
                                      )
                                    ],
                                  ),
                                  child: TextField(
                                    onChanged: (value) {
                                      //loginController.searchProfiles(value);
                                    },
                                    decoration:  InputDecoration(
                                      icon: Icon(Icons.search,color: AppColors.grey,size: size*0.008,),
                                      hintText: "Search by name, userId, clinic...",
                                      hintStyle: AppTextStyles.caption(context,color: AppColors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),


                                UserTypeDashboardModern(
                                  userTypeCounts: buildUserTypeCounts(loginController.profileList),
                                ),
                                const SizedBox(height: 30),

                                Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("User Lists", style: AppTextStyles.body(context, color: AppColors.black,fontWeight: FontWeight.bold)),
                                      TextButton(
                                        onPressed: () {
                                          Get.toNamed('/userTypeListWeb');
                                        },
                                        child: Text(
                                          "View All",
                                          style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.bold)
                                              .copyWith(decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AnimationLimiter(
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: loginController.profileList.length > 10
                                          ? 10 : loginController.profileList.length,
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 280,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        childAspectRatio: 0.7,
                                      ),
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration: const Duration(milliseconds: 700),
                                            child: SlideAnimation(
                                                horizontalOffset: 80.0,
                                                curve: Curves.easeOutCubic,
                                                child: FadeInAnimation(
                                                    child: EnlargeOnTapCard(child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: clinicCard(loginController.profileList[index]),
                                                    )))));
                                      },
                                    ),
                                  ),
                                ],),

                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
                        ),
            );
        }
      ),
    );
  }
  Widget clinicCard(ProfileModel clinic) {
    String firstImage = clinic.images.firstWhere((img) => img.toLowerCase().endsWith('.jpg') || img.toLowerCase().endsWith('.png'),
        orElse: () => "");
    //String addOnsPlanStatus = clinic.details?["plan"]?["addonsPlan"]?["isActive"]?.toString() ?? "";
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: ()async{
          Get.toNamed('/viewProfilePageWeb');
         await loginController.getProfileByUserId(clinic.userId.toString() ?? "", context);
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: firstImage.isNotEmpty
                            ? Image.network(firstImage, width: double.infinity, fit: BoxFit.cover)
                            : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                         "Name: ${clinic.name.toString() ?? ""}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "UserId: ${clinic.userId.toString() ?? ""}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(context),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "UserType: ${clinic.userType.toString() ?? ""}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(context),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Mobile : ${clinic.mobileNumber.toString()}",
                          style: AppTextStyles.caption(context),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Address: ${clinic.address['city']?.toString() ?? ""}, ${clinic.address['state']?.toString() ?? ""},${clinic.address['district']?.toString() ?? ""}",
                          style: AppTextStyles.caption(context, color: AppColors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: () {},
                          child: Text(
                            "Call",
                            style: AppTextStyles.caption(context, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // if (addOnsPlanStatus == "true")
            //   Positioned(
            //     top: 8,
            //     right: 8,
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //       decoration: BoxDecoration(
            //         color: Colors.orangeAccent,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Text("SPONSORED", style: AppTextStyles.caption(context)),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xff111827),
      child: Column(
        children: [

          const SizedBox(height: 40),

          const Text(
            "ADMIN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          menuItem(Icons.dashboard, "Dashboard"),
          menuItem(Icons.people, "Users"),
          menuItem(Icons.attach_money, "Revenue"),
          menuItem(Icons.settings, "Settings"),
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}



class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Container(
      height: size*0.06,
      width: size*0.14,
      padding: const EdgeInsets.all(10),
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
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            CircleAvatar(
              radius: size*0.0062,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color,size: size*0.013,),
            ),

             SizedBox(width: size*0.005),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption(context,color: AppColors.grey)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}



class UserTypeDashboardModern extends StatefulWidget {
  final Map<String, int> userTypeCounts;
  UserTypeDashboardModern({super.key, required this.userTypeCounts});
  @override
  State<UserTypeDashboardModern> createState() => _UserTypeDashboardModernState();
}
class _UserTypeDashboardModernState extends State<UserTypeDashboardModern> {
  int rowsPerPage = 4;
  int currentPage = 0;
  final loginController = Get.put(LoginController());
  String imgUserType(String userType) {
    switch (userType) {
      case "Dental Clinic":
        return "assets/images/Dental_clinic.jpg";
      case "Dental Shop":
        return "assets/images/dental_shop.jpg";
      case "Dental Mechanic":
        return "assets/images/lp3.jpg";
      case "Dental Lab":
        return "assets/images/Dental_Lab02.jpg";
      case "Dental Consultant":
        return "assets/images/doctor1.jpg";
      case "Job Seekers":
        return "assets/images/hospital2.png";
      case "superAdmin":
      case "admin":
      default:
        return "assets/images/hospital2.png";
    }
  }
  @override
  Widget build(BuildContext context) {
    String userType=Api.userInfo.read('userType');
    final allItems = widget.userTypeCounts.keys.toList();
    final startIndex = currentPage * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage > allItems.length)
        ? allItems.length
        : startIndex + rowsPerPage;
    final pagedItems = allItems.sublist(startIndex, endIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("User Types Overview", style: AppTextStyles.subtitle(context, color: AppColors.black)),
        const SizedBox(height: 15),
        GetBuilder<LoginController>(
            builder: (controller) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pagedItems.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final typeKey = pagedItems[index];
                final count = widget.userTypeCounts[typeKey] ?? 0;
                final image = imgUserType(typeKey);
                return GestureDetector(
                    onTap:()async{
                      print('dgfdh$typeKey');
                      Api.userInfo.write('selectedUserType1', typeKey);
                      Api.userInfo.write('sUserType1', typeKey);
                      //Get.toNamed('/userTypeListPage');

                      await  loginController.getProfileDetails(
                        Api.userInfo.read('selectedUserType1'),
                        '',
                        '',
                        '','',
                        '','','','',
                        context,
                      );
                      Get.toNamed('/userTypeListWeb');
                      },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage(image),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4))
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        right: 15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(typeKey,
                                  style: AppTextStyles.body(context,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: Text(count.toString(),
                                  style: AppTextStyles.body(context,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
                "Page ${currentPage + 1} of ${((allItems.length - 1) ~/ rowsPerPage) + 1}"),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: currentPage > 0
                  ? () => setState(() => currentPage--)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: endIndex < allItems.length
                  ? () => setState(() => currentPage++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
Map<String, int> buildUserTypeCounts(List<ProfileModel> profiles) {
  final Map<String, int> counts = {
    "admin": 0,
    "superAdmin": 0,
    "Dental Clinic": 0,
    "Dental Lab": 0,
    "Dental Shop": 0,
    "Dental Mechanic": 0,
    "Job Seekers": 0,
    "Dental Consultant": 0,
  };

  for (var p in profiles) {
    final type = (p.userType ?? '').trim();
    if (counts.containsKey(type)) {
      counts[type] = counts[type]! + 1;
    } else {
      counts['Unknown'] = (counts['Unknown'] ?? 0) + 1;
    }
  }
  return counts;
}
