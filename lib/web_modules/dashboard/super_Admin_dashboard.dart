import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKeyAdmin = GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());
  final notificationController = Get.put(NotificationController());
  final PlanController planController = Get.put(PlanController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await loginController.fetchStates();
    await planController.getIncomeDetailsByPlan(context: context);
    await planController.getExpense(month: "", year: "");
    await loginController.getAppLogoImage(context);
    await notificationController.getNotificationListAdmin(context);
    Api.userInfo.read('userType') == "superAdmin"
        ? await loginController.getProfileDetails(
            '',
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
          )
        : loginController.getProfileDetails(
            '',
            Api.userInfo.read('state') ?? "",
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
    await planController.getIncomeDetailsByPlan(context: context);
  }

  @override
  Widget build(BuildContext context) {
    int total = loginController.profileList.length;
    int active = loginController.profileList.where((p) => p.isActive).length;

    double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return Scaffold(
      key: _scaffoldKeyAdmin,
      backgroundColor: Colors.white,
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Row(
              children: [
                if (isLoggedIn && isDesktop) const AdminSideBar(),
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: Stack(
                          children: [
                            if (!isDesktop)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () => _scaffoldKeyAdmin
                                      .currentState
                                      ?.openDrawer(),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                isMobile ? 10 : 20,
                                isLoggedIn && !isDesktop ? 60 : 20,
                                isMobile ? 10 : 20,
                                20,
                              ),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minHeight: isMobile ? 350 : 200,
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: isMobile ? 180 : 150,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.secondary,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.15,
                                                  ),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Admin Dashboard",
                                                      style:
                                                          AppTextStyles.subtitle(
                                                            context,
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .notifications_none,
                                                          color:
                                                              AppColors.white,
                                                          size: 24,
                                                        ),
                                                        onPressed: () async {
                                                          await notificationController
                                                              .getNotificationListAdmin(
                                                                context,
                                                              );
                                                          Get.toNamed(
                                                            '/viewNotificationWebPage',
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            showLogoutDialog(
                                                              context,
                                                            ),
                                                        child:
                                                            const CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                Icons.logout,
                                                                color: AppColors
                                                                    .primary,
                                                                size: 20,
                                                              ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: isMobile ? 0 : -30,
                                            left: 10,
                                            right: 10,
                                            child: isMobile
                                                ? Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: StatCard(
                                                              title:
                                                                  "Total Users",
                                                              value: total
                                                                  .toString(),
                                                              icon:
                                                                  Icons.people,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: StatCard(
                                                              title:
                                                                  "Active Users",
                                                              value: active
                                                                  .toString(),
                                                              icon: Icons
                                                                  .verified_user,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: StatCard(
                                                              title: "Revenue",
                                                              value:
                                                                  "₹ ${planController.income?.total.toStringAsFixed(2)}",
                                                              icon: Icons
                                                                  .currency_rupee,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: StatCard(
                                                              title: "Expenses",
                                                              value:
                                                                  "₹ ${planController.total.toStringAsFixed(2)}",
                                                              icon: Icons
                                                                  .money_off,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : GetBuilder<LoginController>(
                                                    builder: (controller) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: StatCard(
                                                              title:
                                                                  "Total Users",
                                                              value: total
                                                                  .toString(),
                                                              icon:
                                                                  Icons.people,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          Expanded(
                                                            child: StatCard(
                                                              title:
                                                                  "Active Users",
                                                              value: active
                                                                  .toString(),
                                                              icon: Icons
                                                                  .verified_user,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          Expanded(
                                                            child: StatCard(
                                                              title:
                                                                  "Total Revenue",
                                                              value:
                                                                  "₹ ${planController.income?.total.toStringAsFixed(2)}",
                                                              icon: Icons
                                                                  .currency_rupee,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          Expanded(
                                                            child: StatCard(
                                                              title:
                                                                  "Total Expenses",
                                                              value:
                                                                  "₹ ${planController.total.toStringAsFixed(2)}",
                                                              icon: Icons
                                                                  .money_off,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        onChanged: (value) async {
                                          if (Api.userInfo.read('userType') ==
                                              "superAdmin") {
                                            await loginController
                                                .getProfileDetails(
                                                  '',
                                                  '',
                                                  [],
                                                  [],
                                                  [],
                                                  '',
                                                  '',
                                                  '',
                                                  '',
                                                  searchController.text
                                                      .toString(),
                                                  context,
                                                );
                                          }
                                          if (Api.userInfo.read('userType') ==
                                              "admin") {
                                            await loginController
                                                .getProfileDetails(
                                                  '',
                                                  Api.userInfo.read('state') ??
                                                      "",
                                                  [],
                                                  [],
                                                  [],
                                                  '',
                                                  '',
                                                  '',
                                                  '',
                                                  searchController.text
                                                      .toString(),
                                                  context,
                                                );
                                          }
                                        },
                                        controller: searchController,
                                        decoration: const InputDecoration(
                                          icon: Icon(
                                            Icons.search,
                                            color: AppColors.grey,
                                            size: 24,
                                          ),
                                          hintText:
                                              "Search by name, userId, clinic...",
                                          hintStyle: TextStyle(
                                            color: AppColors.grey,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    UserTypeDashboardModern(
                                      userTypeCounts: buildUserTypeCounts(
                                        loginController.profileList,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "User Lists",
                                              style: AppTextStyles.body(
                                                context,
                                                color: AppColors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Get.toNamed('/userTypeListWeb');
                                              },
                                              child: Text(
                                                "View All",
                                                style:
                                                    AppTextStyles.caption(
                                                      context,
                                                      color: AppColors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ).copyWith(
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        AnimationLimiter(
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                loginController.profileList.length > 10
                                                ? 10 : loginController.profileList.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                                  maxCrossAxisExtent: 280,
                                                  mainAxisSpacing: 20,
                                                  crossAxisSpacing: 20,
                                                  childAspectRatio: 0.7,
                                                ),
                                            itemBuilder: (context, index) {
                                              return AnimationConfiguration.staggeredList(
                                                position: index,
                                                duration: const Duration(
                                                  milliseconds: 700,
                                                ),
                                                child: SlideAnimation(
                                                  horizontalOffset: 80.0,
                                                  curve: Curves.easeOutCubic,
                                                  child: FadeInAnimation(
                                                    child: EnlargeOnTapCard(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: clinicCard(
                                                          loginController.profileList[index], context,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 60),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget clinicCard(ProfileModel clinic, BuildContext context) {
    String firstImage = clinic.images.firstWhere(
      (img) =>
          img.toLowerCase().endsWith('.jpg') ||
          img.toLowerCase().endsWith('.png'),
      orElse: () => "",
    );
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, double scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: () async {
          Api.userInfo.write('selectUId', clinic.userId.toString());
          Get.toNamed('/clinicProfileWebPage');
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: firstImage.isNotEmpty
                          ? Image.network(
                              firstImage,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Name: ${clinic.name}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(
                            context,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "UserId: ${clinic.userId}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(context),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "UserType: ${clinic.userType}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(context),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Mobile : ${clinic.mobileNumber}",
                          style: AppTextStyles.caption(context),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Address: ${clinic.address['city'] ?? ""}, ${clinic.address['state'] ?? ""},${clinic.address['district'] ?? ""}",
                          style: AppTextStyles.caption(
                            context,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {},
                          child: Text(
                            "Call",
                            style: AppTextStyles.caption(
                              context,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption(context, color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body(
                    context,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserTypeDashboardModern extends StatefulWidget {
  final Map<String, int> userTypeCounts;
  const UserTypeDashboardModern({super.key, required this.userTypeCounts});
  @override
  State<UserTypeDashboardModern> createState() =>
      _UserTypeDashboardModernState();
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
      default:
        return "assets/images/hospital2.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUserType = Api.userInfo.read('userType') ?? "";
    final allItems = widget.userTypeCounts.keys.where((type) {
      if (loggedInUserType == 'admin') {
        return type != 'admin' && type != 'superAdmin';
      }
      return true;
    }).toList();
    final startIndex = currentPage * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage > allItems.length)
        ? allItems.length
        : startIndex + rowsPerPage;
    final pagedItems = allItems.sublist(startIndex, endIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "User Types Overview",
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
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
                  onTap: () async {
                    Api.userInfo.write('selectedUserType1', typeKey);
                    Api.userInfo.write('sUserType1', typeKey);
                    await loginController.getProfileDetails(
                      typeKey,
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
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
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
                              child: Text(
                                typeKey,
                                style: AppTextStyles.body(
                                  context,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              child: Text(
                                count.toString(),
                                style: AppTextStyles.body(
                                  context,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Page ${currentPage + 1} of ${((allItems.length - 1) ~/ rowsPerPage) + 1}",
            ),
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
    if (counts.containsKey(type)) counts[type] = counts[type]! + 1;
  }
  return counts;
}
